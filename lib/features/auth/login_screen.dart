import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import 'auth_state.dart';
import 'reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  Future<void> _submit() async {
    final auth = context.read<AuthState>();
    setState(() => _loading = true);
    final ok = await auth.submitLogin(_emailController.text.trim(), _passwordController.text);
    if (mounted) setState(() => _loading = false);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error?.localizado(context) ?? context.l10n.loginErroGenerico)),
      );
    }
  }

  // Sem envio de email (secção 3.2): vendedor pede ao owner para lhe repor a
  // password em Equipa (team_screen.dart). Owner não tem ninguém acima dele
  // dentro da app — contacta o suporte, que gera um código curto no painel
  // de super-admin (secção 29) para usar no ecrã de reposição.
  Future<void> _mostrarEsqueceuPassword(BuildContext context) async {
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.esqueceuPasswordTitulo),
        content: Text(l10n.esqueceuPasswordTexto),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ResetPasswordScreen()));
            },
            child: Text(l10n.esqueceuPasswordJaTenhoCodigo),
          ),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.ok)),
        ],
      ),
    );
  }

  // Mesmo padrão/strings do menu de perfil (vehicle_list_screen.dart) — aqui
  // dá para trocar de stand mesmo antes de fazer login, sem reinstalar.
  Future<void> _trocarDeStand() async {
    final l10n = context.l10n;
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.trocarDeStandTitulo),
        content: Text(l10n.trocarDeStandTexto),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancelar)),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.trocarDeStandTitulo)),
        ],
      ),
    );
    if (confirmou == true && mounted) await context.read<AuthState>().logoutCompleto();
  }

  @override
  Widget build(BuildContext context) {
    final standNome = context.watch<AuthState>().standNome;
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
                  Text(l10n.loginTitulo, style: Theme.of(context).textTheme.displayMedium),
                  if (standNome != null) ...[
                    const SizedBox(height: 4),
                    Text(standNome, style: Theme.of(context).textTheme.bodyLarge),
                  ],
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: l10n.loginEmail, border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: l10n.loginPassword,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(l10n.loginTitulo),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _loading ? null : () => _mostrarEsqueceuPassword(context),
                    child: Text(l10n.loginEsqueceuPassword),
                  ),
                  TextButton(
                    onPressed: _loading ? null : _trocarDeStand,
                    child: Text(l10n.trocarDeStandTitulo),
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
