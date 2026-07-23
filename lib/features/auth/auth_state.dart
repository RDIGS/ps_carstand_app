import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/api/api_client.dart';
import '../../core/app_version/platform_util.dart';
import '../../core/storage/secure_storage.dart';
import '../app_version/app_version_repository.dart';
import '../legal/legal_models.dart';
import '../legal/legal_repository.dart';
import 'auth_repository.dart';

enum AuthStatus { loading, needsStandToken, needsLogin, authenticated, updateRequired, legalPending }

/// Estado global de sessão (secção 4): token do stand pedido 1 só vez,
/// depois disso é sempre email/password até logout completo.
class AuthState extends ChangeNotifier {
  AuthState(this._repository, this._storage, this._appVersionRepository, this._legalRepository) {
    _bootstrap();
  }

  final AuthRepository _repository;
  final SecureStorage _storage;
  final AppVersionRepository _appVersionRepository;
  final LegalRepository _legalRepository;

  AuthStatus status = AuthStatus.loading;
  String? standId;
  String? standNome;
  String? userNome;
  String? userRole;
  // Preferência guardada em people.idioma (secção 18), não no dispositivo —
  // 'pt' antes de autenticar, porque ainda não sabemos quem é o utilizador.
  String userIdioma = 'pt';
  // Guarda a exceção (não já uma String) para o ecrã poder traduzi-la com o
  // BuildContext dele, via ApiExceptionL10n.localizado — AuthState não tem
  // acesso a contexto para traduzir aqui (secção 18, texto vive no .arb).
  ApiException? error;
  // Aviso persistente de subscrição (secção 3.4, O14) — carregado depois de
  // autenticar, nunca bloqueia o login se falhar (best-effort).
  SubscriptionStatus? subscriptionStatus;
  // Dados para o ecrã de bloqueio (secção 22) — só preenchidos quando
  // status == updateRequired.
  String? updateVersaoMinima;
  String? updateChangelogUrl;
  // Aviso não-bloqueante de atualização recomendada (secção 22) — mostrado
  // como banner, nunca impede o uso da app.
  String? updateRecomendadaVersao;
  String? updateRecomendadaChangelogUrl;
  // Documentos por aceitar (secção 24) — só preenchidos quando
  // status == legalPending.
  List<PendingLegalDocument> pendingLegalDocuments = [];

  Future<void> _bootstrap() async {
    // Secção 22: chamado antes de qualquer outro pedido. Falha de rede aqui
    // nunca bloqueia a app (fail-open) — só um `obrigatoria: true` explícito
    // do backend bloqueia.
    if (await _checkAppVersion()) return;

    final standToken = await _storage.readStandToken();
    if (standToken == null) {
      status = AuthStatus.needsStandToken;
      notifyListeners();
      return;
    }
    standId = await _storage.readStandId();
    standNome = await _storage.readStandNome();

    final jwt = await _storage.readJwt();
    if (jwt == null) {
      status = AuthStatus.needsLogin;
      notifyListeners();
      return;
    }

    userNome = await _storage.readUserNome();
    userRole = await _storage.readUserRole();
    userIdioma = await _storage.readUserIdioma() ?? 'pt';
    await _finishLogin();
  }

  /// Comum a `_bootstrap` (sessão já guardada) e `submitLogin` (login novo):
  /// marca autenticado, dispara o aviso de subscrição em background
  /// (best-effort) e verifica se há documentos legais por aceitar (secção
  /// 24) — só aí é que HomeShell fica de facto acessível.
  Future<void> _finishLogin() async {
    status = AuthStatus.authenticated;
    notifyListeners();
    unawaited(_loadSubscriptionStatus());
    await _checkLegalStatus();
  }

  Future<void> _checkLegalStatus() async {
    try {
      final pendentes = await _legalRepository.status();
      if (pendentes.isNotEmpty) {
        pendingLegalDocuments = pendentes;
        status = AuthStatus.legalPending;
        notifyListeners();
      }
    } catch (_) {
      // Fail-open, mesmo padrão do resto do arranque (secção 22): sem
      // ligação ainda não há forma de saber se falta aceitar algo — nunca
      // bloqueia por isso.
    }
  }

  /// Chamado pelo ecrã de aceitação depois de um documento ser aceite com
  /// sucesso no backend — remove-o (e "dpa" junto, se foi "termos" que
  /// acabou de ser aceite: o backend já aceitou os dois na mesma ação,
  /// secção 24.3) da lista local, e conclui quando não sobrar nenhum.
  void markLegalDocumentAccepted(String tipo) {
    pendingLegalDocuments = [...pendingLegalDocuments]..removeWhere((d) => d.tipo == tipo);
    if (tipo == 'termos') {
      pendingLegalDocuments.removeWhere((d) => d.tipo == 'dpa');
    }
    if (pendingLegalDocuments.isEmpty) {
      status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  /// Devolve `true` se bloqueou a app (status passou a `updateRequired`).
  Future<bool> _checkAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final result = await _appVersionRepository.versionCheck(
        plataforma: PlatformUtil.current(),
        versaoAtual: packageInfo.version,
      );
      if (result.obrigatoria) {
        updateVersaoMinima = result.versaoMinimaObrigatoria;
        updateChangelogUrl = result.changelogUrl;
        status = AuthStatus.updateRequired;
        notifyListeners();
        return true;
      }
      if (result.versaoRecomendada != null && result.versaoRecomendada != packageInfo.version) {
        updateRecomendadaVersao = result.versaoRecomendada;
        updateRecomendadaChangelogUrl = result.changelogUrl;
      }
      return false;
    } catch (_) {
      // Fail-open (comentário em _bootstrap): sem ligação ao backend ainda
      // não há forma de saber se é obrigatória — nunca bloqueia por isso.
      return false;
    }
  }

  // Só o owner precisa disto (é um assunto financeiro/administrativo do
  // stand) — poupa um pedido de rede sem sentido nas sessões de vendedor.
  Future<void> _loadSubscriptionStatus() async {
    if (userRole != 'owner') return;
    try {
      subscriptionStatus = await _repository.subscriptionStatus();
      notifyListeners();
    } catch (_) {
      // Best-effort: se falhar, simplesmente não há aviso — nunca bloqueia o
      // resto da app por causa disto.
    }
  }

  Future<bool> submitStandToken(String token) async {
    try {
      error = null;
      final result = await _repository.validateStandToken(token);
      await _storage.saveStandToken(token, result.standId, result.standNome);
      standId = result.standId;
      standNome = result.standNome;
      status = AuthStatus.needsLogin;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      error = e;
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitLogin(String email, String password) async {
    if (standId == null) return false;
    try {
      error = null;
      final result = await _repository.login(email: email, password: password, standId: standId!);
      await _storage.saveSession(
        jwt: result.jwt,
        refreshToken: result.refreshToken,
        userId: result.userId,
        userNome: result.userNome,
        userRole: result.userRole,
        userIdioma: result.userIdioma,
      );
      userNome = result.userNome;
      userRole = result.userRole;
      userIdioma = result.userIdioma;
      await _finishLogin();
      return true;
    } on ApiException catch (e) {
      error = e;
      notifyListeners();
      return false;
    }
  }

  Future<void> changeIdioma(String idioma) async {
    if (idioma == userIdioma) return;
    userIdioma = idioma;
    notifyListeners();
    await _storage.saveUserIdioma(idioma);
    try {
      await _repository.updateIdioma(idioma);
    } catch (_) {
      // Best-effort: a app já mudou de idioma localmente; sincroniza com o
      // backend na próxima oportunidade (ex.: outro pedido autenticado).
    }
  }

  /// Logout normal — mantém o token do stand guardado (secção 4).
  Future<void> logout() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken != null) {
      try {
        await _repository.logout(refreshToken);
      } catch (_) {
        // Best-effort: mesmo que o pedido falhe, a sessão local é sempre limpa.
      }
    }
    await _storage.clearSession();
    status = AuthStatus.needsLogin;
    subscriptionStatus = null;
    notifyListeners();
  }

  /// Logout completo (secção 4: "só volta a pedir token se o utilizador
  /// fizer logout completo") — ao contrário de `logout()`, também esquece o
  /// token do stand. Único caminho para trocar de stand no mesmo
  /// dispositivo sem reinstalar.
  Future<void> logoutCompleto() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken != null) {
      try {
        await _repository.logout(refreshToken);
      } catch (_) {
        // Best-effort, mesmo padrão do logout normal.
      }
    }
    await _storage.clearAll();
    standId = null;
    standNome = null;
    userNome = null;
    userRole = null;
    userIdioma = 'pt';
    subscriptionStatus = null;
    pendingLegalDocuments = [];
    status = AuthStatus.needsStandToken;
    notifyListeners();
  }

  /// Chamado pelo ApiClient quando o refresh falha (sessão comprometida/expirada).
  void forceSessionExpired() {
    status = AuthStatus.needsLogin;
    notifyListeners();
  }
}
