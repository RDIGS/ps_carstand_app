import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'core/api/api_client.dart';
import 'core/storage/secure_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_state.dart';
import 'features/app_version/app_version_repository.dart';
import 'features/app_version/update_required_screen.dart';
import 'features/audit/audit_repository.dart';
import 'features/checklist/checklist_repository.dart';
import 'features/auth/auth_repository.dart';
import 'features/auth/auth_state.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/stand_token_screen.dart';
import 'features/finance/finance_repository.dart';
import 'features/home/home_shell.dart';
import 'features/legal/legal_acceptance_screen.dart';
import 'features/legal/legal_repository.dart';
import 'features/sales/sales_repository.dart';
import 'features/team/team_repository.dart';
import 'features/vehicles/vehicles_repository.dart';

void main() {
  runApp(const PsCarStandApp());
}

class PsCarStandApp extends StatelessWidget {
  const PsCarStandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SecureStorage>(create: (_) => SecureStorage()),
        ChangeNotifierProxyProvider<SecureStorage, ThemeState>(
          create: (context) => ThemeState(context.read<SecureStorage>()),
          update: (_, __, previous) => previous!,
        ),
        // ApiClient precisa de notificar o AuthState quando uma sessão expira
        // (401 + refresh falhado) — o callback é ligado depois de o
        // AuthState existir, através deste indirection simples.
        ProxyProvider<SecureStorage, ApiClient>(
          update: (_, storage, previous) => previous ?? ApiClient(storage, onSessionExpired: () => _onSessionExpired?.call()),
        ),
        ProxyProvider<ApiClient, AuthRepository>(update: (_, api, __) => AuthRepository(api)),
        ProxyProvider<ApiClient, AppVersionRepository>(update: (_, api, __) => AppVersionRepository(api)),
        ProxyProvider<ApiClient, VehiclesRepository>(update: (_, api, __) => VehiclesRepository(api)),
        ProxyProvider<ApiClient, SalesRepository>(update: (_, api, __) => SalesRepository(api)),
        ProxyProvider<ApiClient, TeamRepository>(update: (_, api, __) => TeamRepository(api)),
        ProxyProvider<ApiClient, FinanceRepository>(update: (_, api, __) => FinanceRepository(api)),
        ProxyProvider<ApiClient, AuditRepository>(update: (_, api, __) => AuditRepository(api)),
        ProxyProvider<ApiClient, ChecklistRepository>(update: (_, api, __) => ChecklistRepository(api)),
        ProxyProvider<ApiClient, LegalRepository>(update: (_, api, __) => LegalRepository(api)),
        ChangeNotifierProxyProvider4<AuthRepository, SecureStorage, AppVersionRepository, LegalRepository, AuthState>(
          create: (context) => AuthState(
            context.read<AuthRepository>(),
            context.read<SecureStorage>(),
            context.read<AppVersionRepository>(),
            context.read<LegalRepository>(),
          ),
          update: (_, __, ___, ____, _____, previous) => previous!,
        ),
      ],
      child: Builder(
        builder: (context) {
          _onSessionExpired = context.read<AuthState>().forceSessionExpired;
          return const _AppRoot();
        },
      ),
    );
  }
}

void Function()? _onSessionExpired;

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthState, ThemeState>(
      builder: (context, auth, themeState, _) {
        return MaterialApp(
          title: 'PS CarStand',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          // Nunca segue o sistema/browser sozinho (secção 11: claro é o
          // default) — só muda com o alternador explícito no menu de perfil.
          themeMode: themeState.mode,
          // Idioma vem de people.idioma (secção 18), não do dispositivo.
          locale: Locale(auth.userIdioma),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: switch (auth.status) {
            AuthStatus.loading => const Scaffold(body: Center(child: CircularProgressIndicator())),
            AuthStatus.updateRequired => const UpdateRequiredScreen(),
            AuthStatus.legalPending => const LegalAcceptanceScreen(),
            AuthStatus.needsStandToken => const StandTokenScreen(),
            AuthStatus.needsLogin => const LoginScreen(),
            AuthStatus.authenticated => const HomeShell(),
          },
        );
      },
    );
  }
}
