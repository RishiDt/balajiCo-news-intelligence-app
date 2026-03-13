// Login screen UI
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_news_intelligence/src/core/app_routes.dart';
import 'package:mini_news_intelligence/src/features/auth/auth_providers.dart';
import 'package:mini_news_intelligence/src/shared/widgets/loading_widget.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _remember = true;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    await ref.read(authStateProvider.notifier).login(_username, _password, remember: _remember);
    final state = ref.read(authStateProvider);
    if (state.isAuthenticated) {
      // Replace route to home
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.routeHome);
    } else if (state.error != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: authState.isLoading
          ? const LoadingWidget(message: 'Signing in...')
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      key: const ValueKey('username'),
                      decoration: const InputDecoration(labelText: 'Username'),
                      onSaved: (v) => _username = v ?? '',
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter username' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const ValueKey('password'),
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      onSaved: (v) => _password = v ?? '',
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter password' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(value: _remember, onChanged: (v) => setState(() => _remember = v ?? true)),
                        const Text('Remember me'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                        child: Text('Login'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
