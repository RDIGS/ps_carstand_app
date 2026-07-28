import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import 'auth_repository.dart';

/// "Esqueceste-te da password?" para o owner (secção 29) — o vendedor
/// continua a ser reposto pelo owner em Equipa (team_screen.dart). O código
/// aqui introduzido é gerado pelo super-admin fora da app (painel
/// ps_carstand_admin) e partilhado por fora (WhatsApp/telefone), válido 1h
/// e de uso único.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _novaPasswordController = TextEditingController();
  bool _submitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _novaPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await context.read<AuthRepository>().resetPasswordWithCode(
            email: _emailController.text.trim(),
            code: _codeController.text.trim(),
            novaPassword: _novaPasswordController.text,
          );
      if (mounted) {
        final l10n = context.l10n;
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.resetPasswordSucessoTitulo),
            content: Text(l10n.resetPasswordSucessoTexto),
            actions: [ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.ok))],
          ),
        );
        if (mounted) Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.resetPasswordTitulo)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.resetPasswordTexto, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: l10n.loginEmail, border: const OutlineInputBorder()),
                      validator: (v) => (v == null || !v.contains('@')) ? l10n.validacaoCampoObrigatorio : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _codeController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: l10n.campoCodigoReset,
                        hintText: 'XXXX-XXXX',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? l10n.validacaoCampoObrigatorio : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _novaPasswordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: l10n.campoNovaPassword,
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 8) ? l10n.validacaoPasswordCurta : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(l10n.resetPasswordTitulo),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
