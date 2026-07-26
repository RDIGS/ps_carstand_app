import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import 'suggestions_repository.dart';

/// Ecrã simples para o utilizador (owner ou vendedor) escrever sugestões
/// sobre a app — lidas pelo dono da plataforma via /admin/suggestions,
/// fora do fluxo normal do stand.
class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  final _texto = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final l10n = context.l10n;
    if (_texto.text.trim().isEmpty) return;
    setState(() => _enviando = true);
    try {
      await context.read<SuggestionsRepository>().submit(_texto.text.trim());
      if (!mounted) return;
      _texto.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.sugestaoEnviada)));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sugestoesTitulo)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.sugestoesIntro, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _texto,
            maxLines: 8,
            minLines: 5,
            decoration: InputDecoration(
              labelText: l10n.sugestoesCampoTexto,
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _enviando ? null : _enviar,
            child: _enviando
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.sugestoesEnviar),
          ),
        ],
      ),
    );
  }
}
