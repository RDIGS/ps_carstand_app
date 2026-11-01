import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import 'auth_layout.dart';
import 'auth_state.dart';

class StandTokenScreen extends StatefulWidget {
  const StandTokenScreen({super.key});

  @override
  State<StandTokenScreen> createState() => _StandTokenScreenState();
}

class _StandTokenScreenState extends State<StandTokenScreen> {
  final _controller = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    final auth = context.read<AuthState>();
    setState(() => _loading = true);
    final ok = await auth.submitStandToken(_controller.text.trim());
    if (mounted) setState(() => _loading = false);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error?.localizado(context) ?? context.l10n.standTokenErroGenerico)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthLayout(
      kicker: l10n.standTokenKicker,
      titulo: l10n.standTokenTitulo,
      subtitulo: l10n.standTokenIntro,
      children: [
        TextField(
          controller: _controller,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(labelText: l10n.standTokenLabel, hintText: 'PSCS-XXXX-XXXX'),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 22),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.standTokenContinuar),
        ),
      ],
    );
  }
}
