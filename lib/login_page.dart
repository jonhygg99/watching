import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';
import 'splash_wrapper.dart';

class LoginPage extends StatefulWidget {
  final String? username;
  const LoginPage({super.key, this.username});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showCodeInput = false;
  final TextEditingController _codeController = TextEditingController();
  String? _error;
  bool _loading = false;

  Future<void> _authorizeWithTrakt({bool signup = false, bool promptLogin = false}) async {
    final params = <String, String>{'state': 'login'};
    if (signup) params['signup'] = 'true';
    if (promptLogin) params['prompt'] = 'login';
    final url = apiService.getAuthorizationUrl(extraParams: params);
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el navegador.')),
      );
    }
  }

  Future<void> _submitCode() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _error = 'Introduce el código';
        _loading = false;
      });
      return;
    }
    try {
      await apiService.getToken(code);
      setState(() {
        _loading = false;
      });
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => SplashWrapper()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Código incorrecto o expirado';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Registro')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.username != null)
                Text('Usuario: ${widget.username}', style: const TextStyle(fontWeight: FontWeight.bold))
              else
                FutureBuilder(
                  future: apiService.get('/users/me'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    final response = snapshot.data;
                    if (snapshot.hasError || response == null || response.statusCode != 200) {
                      return const Text('Usuario: No conectado', style: TextStyle(fontWeight: FontWeight.bold));
                    }
                    final data = response.body;
                    final username = RegExp(r'"username"\s*:\s*"([^"]+)"').firstMatch(data)?.group(1);
                    return Text('Usuario: ${username ?? 'No conectado'}', style: const TextStyle(fontWeight: FontWeight.bold));
                  },
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() => _showCodeInput = true);
                  _authorizeWithTrakt(promptLogin: true);
                },
                child: const Text('Iniciar sesión con Trakt.tv'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() => _showCodeInput = true);
                  _authorizeWithTrakt(signup: true);
                },
                child: const Text('Registrarse con Trakt.tv'),
              ),
              const SizedBox(height: 32),
              if (_showCodeInput) ...[
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Código de autorización',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitCode,
                  child: const Text('Enviar código'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
