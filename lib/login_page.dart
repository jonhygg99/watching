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

  Widget _buildUserDisplay() {
    return widget.username != null
        ? Column(
            children: [
              const Icon(Icons.person, size: 32, color: Colors.green),
              const SizedBox(height: 8),
              Text('Hola, ${widget.username}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          )
        : const SizedBox();
  }

  Widget _buildAuthButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _loading ? null : onPressed,
        child: _loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : Text(text),
      ),
    );
  }

  void _handleAuth({bool signup = false, bool promptLogin = false}) {
    setState(() {
      _showCodeInput = true;
    });
    _authorizeWithTrakt(signup: signup, promptLogin: promptLogin);
  }

  List<Widget> _buildCodeInput() {
    return [
      TextField(
        controller: _codeController,
        decoration: InputDecoration(
          labelText: 'Código de autorización',
          errorText: _error,
        ),
        enabled: !_loading,
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _loading ? null : _submitCode,
          child: _loading ? const CircularProgressIndicator(strokeWidth: 2) : const Text('Enviar código'),
        ),
      ),
    ];
  }

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
              _buildUserDisplay(),
              const SizedBox(height: 24),
              _buildAuthButton('Iniciar sesión con Trakt.tv', () => _handleAuth(promptLogin: true)),
              const SizedBox(height: 24),
              _buildAuthButton('Registrarse con Trakt.tv', () => _handleAuth(signup: true)),
              const SizedBox(height: 32),
              if (_showCodeInput) ..._buildCodeInput(),
            ],
          ),
        ),
      ),
    );
  }
}
