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
          if (error.response?.statusCode == 401 && !_isAuthEndpoint(error.requestOptions.path)) {
            final retried = await _retryAfterRefresh(error.requestOptions);
            if (retried != null) return handler.resolve(retried);
            await _storage.clearSession();
            onSessionExpired?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  late final Dio _dio;
  final SecureStorage _storage;
  final void Function()? onSessionExpired;

  bool _isAuthEndpoint(String path) => path.contains('/auth/login') || path.contains('/auth/refresh');

  Future<Response<dynamic>?> _retryAfterRefresh(RequestOptions failedRequest) async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null) return null;

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

      failedRequest.headers['Authorization'] = 'Bearer $jwt';
      return _dio.fetch(failedRequest);
    } on DioException {
      return null;
    }
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
