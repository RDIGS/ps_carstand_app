# PS CarStand — App Cliente (Flutter)

Esqueleto da app (secções 11, 15, 18-20 da arquitetura): sistema de design
"Ficha Técnica", fluxo de autenticação completo (token do stand 1x + login +
refresh automático) e o primeiro ecrã funcional (lista de veículos com o
cartão-assinatura).

> ⚠️ **Este ambiente não tem o Flutter SDK instalado**, por isso não foi
> possível correr `flutter pub get` / `flutter analyze` / `flutter run` para
> verificar a compilação. O código segue a API pública estável do Flutter
> 3.24+/Dart 3.4+, mas confirma com `flutter analyze` assim que tiveres o SDK
> à mão.

## Pôr a correr

Este repositório só tem `lib/`, `pubspec.yaml` e `analysis_options.yaml` —
faltam as pastas de plataforma (`android/`, `ios/`, `windows/`, ...), que só o
`flutter create` sabe gerar corretamente para a tua versão do SDK instalada:

```bash
flutter create --project-name ps_carstand_app .
flutter pub get
flutter run -d windows   # ou -d chrome, -d <device-id> de Android
```

O comando `flutter create .` é seguro de correr num projeto já existente — só
acrescenta as pastas de plataforma em falta, não toca no `lib/` já escrito.

Por omissão a app aponta para `http://localhost:3000` (o backend local). Para
apontar para outro ambiente:

```bash
flutter run --dart-define=API_BASE_URL=https://api.pscarstand.pt
```

## Estrutura

```
lib/
├── core/
│   ├── api/          ApiClient (dio) — injeta JWT, faz refresh-rotation automático no 401
│   ├── storage/      SecureStorage — token do stand (1x) + sessão, encriptados
│   └── theme/        AppColors, AppTypography, AppTheme — sistema "Ficha Técnica" (secção 11)
├── features/
│   ├── auth/         StandTokenScreen, LoginScreen, AuthState, AuthRepository
│   └── vehicles/     Vehicle model, VehiclesRepository, VehicleListScreen
└── shared/widgets/
    ├── vehicle_card.dart   Elemento assinatura — cartão "ficha técnica"
    └── status_badge.dart   Etiquetas de estado (verde/âmbar/cinza)
```

## O que falta (próximos passos naturais)

- Ecrãs de veículo (detalhe, formulário manual, captura DUA com `image_picker`
  + moldura-guia, ecrã de confirmação) — secções 5 e 20.
- Fluxo de venda (formulário de comprador, download do PDF gerado pelo backend).
- Gestão de equipa, financeiro e dashboard (KPIs da secção 12.5).
- i18n `.arb` pt/en (secção 18) — a preferência de idioma já vive em
  `people.idioma` no backend, só falta ligar `flutter_localizations` no
  cliente.
- Testes de widget (`flutter_test` já está nas dev dependencies).
