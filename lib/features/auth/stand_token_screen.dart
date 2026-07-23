import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/images/app_icon.png', width: 64, height: 64),
                  const SizedBox(height: 12),
                  Text('PS CarStand', style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 8),
                  Text(l10n.standTokenIntro),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: l10n.standTokenLabel,
                      hintText: 'PSCS-XXXX-XXXX',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(l10n.standTokenContinuar),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
