import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/max_width_body.dart';
import '../auth/auth_state.dart';
import 'legal_models.dart';
import 'legal_repository.dart';

/// Ecrã de aceitação de documentos legais (secção 24) — bloqueia o acesso à
/// app até aceitar tudo o que falta para o role do utilizador (owner:
/// Termos+DPA+Privacidade; vendedor: só Privacidade). Um documento de cada
/// vez, para não misturar leitura/aceitação de vários textos longos.
class LegalAcceptanceScreen extends StatefulWidget {
  const LegalAcceptanceScreen({super.key});

  @override
  State<LegalAcceptanceScreen> createState() => _LegalAcceptanceScreenState();
}

class _LegalAcceptanceScreenState extends State<LegalAcceptanceScreen> {
  bool _li = false;
  bool _aceitando = false;
  String? _erro;

  String _titulo(BuildContext context, String tipo) {
    final l10n = context.l10n;
    return switch (tipo) {
      'termos' => l10n.legalTermosTitulo,
      'privacidade' => l10n.legalPrivacidadeTitulo,
      'dpa' => l10n.legalDpaTitulo,
      _ => tipo,
    };
  }

  Future<void> _aceitar(PendingLegalDocument doc) async {
    setState(() {
      _aceitando = true;
      _erro = null;
    });
    try {
      await context.read<LegalRepository>().accept(doc.tipo);
      if (!mounted) return;
      context.read<AuthState>().markLegalDocumentAccepted(doc.tipo);
      setState(() {
        _li = false;
        _aceitando = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _aceitando = false;
          _erro = e.localizado(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pendentes = context.watch<AuthState>().pendingLegalDocuments;
    if (pendentes.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final doc = pendentes.first;

    return Scaffold(
      appBar: AppBar(title: Text(_titulo(context, doc.tipo)), automaticallyImplyLeading: false),
      body: MaxWidthBody(
        child: SafeArea(
          child: Column(
            children: [
              if (pendentes.length > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    l10n.legalProgresso(pendentes.length),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.grafiteVendido),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(doc.conteudo, style: Theme.of(context).textTheme.bodyMedium),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_erro != null) ...[
                      Text(_erro!, style: const TextStyle(color: AppColors.amberSinal)),
                      const SizedBox(height: 8),
                    ],
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _li,
                      onChanged: _aceitando ? null : (v) => setState(() => _li = v ?? false),
                      title: Text(l10n.legalLiEAceito),
                    ),
                    ElevatedButton(
                      onPressed: (_li && !_aceitando) ? () => _aceitar(doc) : null,
                      child: _aceitando
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(l10n.legalAceitarEContinuar),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
