import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

/// URL base da API — passa `--dart-define=API_BASE_URL=https://...` em
/// builds de produção; por omissão aponta para o backend local (secção 15).
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

/// Erro de API já traduzido para o formato transversal da secção 13:
/// { error, message, campo? }.
class ApiException implements Exception {
  ApiException(this.error, this.message, [this.campo]);

  factory ApiException.fromDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return ApiException(
        (data['error'] as String?) ?? 'erro_desconhecido',
        (data['message'] as String?) ?? 'Ocorreu um erro inesperado.',
        data['campo'] as String?,
      );
    }
    return ApiException('erro_rede', 'Sem ligação ao servidor. Verifica a tua ligação à internet.');
  }

  final String error;
  final String message;
  final String? campo;

  @override
  String toString() => message;
}

/// Cliente HTTP único da app: injeta o JWT em todos os pedidos e faz o
/// refresh-rotation automático (secção 21) quando a API responde 401.
class ApiClient {
  ApiClient(this._storage, {this.onSessionExpired}) {
    // O backend em produção corre no plano free do Render: adormece ao fim
    // de ~15 min sem pedidos e pode demorar dezenas de segundos a "acordar"
    // no primeiro pedido — um timeout curto dava falso "Sem ligação ao
    // servidor" nesse cenário (mesmo ajuste feito em ps_carstand_admin).
    // receiveTimeout é a rede de segurança para o OCR (DUA/CC): o backend já
    // tem o seu próprio timeout de 60s à chamada ao Gemini
    // (gemini-fetch.util.ts) e devolve erro antes disso, mas sem isto aqui
    // também, se o próprio backend ficasse preso por qualquer outro motivo a
    // app ficava com o spinner infinito — bug real reportado em produção
    // (2026-07-27).
    _dio = Dio(BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 75),
    ));
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final jwt = await _storage.readJwt();
          if (jwt != null) options.headers['Authorization'] = 'Bearer $jwt';
          handler.next(options);
        },
        onError: (error, handler) async {
          final pedido = error.requestOptions;
          if (error.response?.statusCode == 401 &&
              !_isAuthEndpoint(pedido.path) &&
              pedido.extra[_kJaRepetido] != true) {
            // Se outro pedido já renovou a sessão entretanto (este saiu com o
            // JWT antigo), basta repetir com o novo — não renova outra vez.
            final jwtAtual = await _storage.readJwt();
            // Sem sessão guardada = outro pedido já concluiu que ela acabou
            // (e já avisou a app) — não tenta renovar nem avisa outra vez.
            if (jwtAtual == null) return handler.next(error);
            final jwtUsado = (pedido.headers['Authorization'] as String?)?.replaceFirst('Bearer ', '');
            final jwt = jwtAtual != jwtUsado ? jwtAtual : await _renovarJwt();
            if (jwt != null) {
              pedido.headers['Authorization'] = 'Bearer $jwt';
              pedido.extra[_kJaRepetido] = true;
              try {
                return handler.resolve(await _dio.fetch(pedido));
              } on DioException catch (e) {
                return handler.next(e);
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  late final Dio _dio;
  final SecureStorage _storage;
  final void Function()? onSessionExpired;

  // Marca um pedido já repetido depois de renovar — evita ciclo infinito se
  // o backend continuar a responder 401 mesmo com o JWT novo.
  static const _kJaRepetido = 'ps_ja_repetido_apos_refresh';

  // Pedidos em paralelo com o JWT expirado recebem 401 todos ao mesmo tempo.
  // Antes cada um fazia o seu próprio refresh — e como o backend roda o
  // refresh token a cada uso, só o primeiro resultava: os outros falhavam e
  // faziam logout a quem tinha a sessão válida (e, no Windows, as escritas
  // simultâneas estragavam o ficheiro da sessão). Agora partilham todos a
  // mesma renovação em curso.
  Future<String?>? _renovacaoEmCurso;

  bool _isAuthEndpoint(String path) => path.contains('/auth/login') || path.contains('/auth/refresh');

  Future<String?> _renovarJwt() =>
      _renovacaoEmCurso ??= _executarRenovacao().whenComplete(() => _renovacaoEmCurso = null);

  /// Devolve o JWT novo, ou `null` se não foi possível renovar.
  Future<String?> _executarRenovacao() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null) return _sessaoPerdida();

    try {
      final response = await _dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
      final jwt = response.data['jwt'] as String;
      final newRefreshToken = response.data['refresh_token'] as String;
      final user = response.data['user'] as Map<String, dynamic>;

      await _storage.saveSession(
        jwt: jwt,
        refreshToken: newRefreshToken,
        userId: user['id'] as String,
        userNome: user['nome'] as String,
        userRole: user['role'] as String,
        userIdioma: (user['idioma'] as String?) ?? await _storage.readUserIdioma() ?? 'pt',
      );
      return jwt;
    } on DioException catch (e) {
      // Sem resposta = falha de rede: não deita fora uma sessão que pode
      // estar válida, só este pedido falha. Com resposta (refresh recusado),
      // a sessão acabou mesmo.
      if (e.response == null) return null;
      return _sessaoPerdida();
    }
  }

  Future<String?> _sessaoPerdida() async {
    await _storage.clearSession();
    onSessionExpired?.call();
    return null;
  }

  Future<T> request<T>(
    String method,
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) parse,
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method),
      );
      return parse(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Upload multipart (fotos de DUA/CC/Título de Residência, secções 5/23).
  Future<T> uploadMultipart<T>(
    String path, {
    required Map<String, List<int>> files,
    Map<String, String> fields = const {},
    required T Function(dynamic data) parse,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...fields,
        for (final entry in files.entries)
          entry.key: MultipartFile.fromBytes(entry.value, filename: '${entry.key}.jpg'),
      });
      final response = await _dio.post<dynamic>(path, data: formData);
      return parse(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Dio get raw => _dio;
}
