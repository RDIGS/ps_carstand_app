import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../auth/auth_state.dart';

/// Ecrã de bloqueio total (secção 22): sem acesso a login nem dados
/// enquanto a versão instalada estiver abaixo da mínima obrigatória.
class UpdateRequiredScreen extends StatelessWidget {
  const UpdateRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthState>();
    final changelogUrl = auth.updateChangelogUrl;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.system_update, size: 56, color: AppColors.azulMatricula),
                  const SizedBox(height: 16),
                  Text(
                    l10n.atualizacaoObrigatoriaTitulo,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.atualizacaoObrigatoriaTexto,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (changelogUrl != null) ...[
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => launchUrl(Uri.parse(changelogUrl), mode: LaunchMode.externalApplication),
                      child: Text(l10n.atualizacaoObrigatoriaBotao),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
