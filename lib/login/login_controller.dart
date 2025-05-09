import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/trakt/trakt_api.dart';
import '../providers/auth_provider.dart';

/// State for the login flow.
class LoginState {
  final bool loading;
  final String? error;
  final bool showCodeInput;
  final String? username;

  const LoginState({
    this.loading = false,
    this.error,
    this.showCodeInput = false,
    this.username,
  });

  LoginState copyWith({
    bool? loading,
    String? error,
    bool? showCodeInput,
    String? username,
  }) => LoginState(
    loading: loading ?? this.loading,
    error: error,
    showCodeInput: showCodeInput ?? this.showCodeInput,
    username: username ?? this.username,
  );
}

class LoginController extends StateNotifier<LoginState> {
  final Ref ref;
  final TraktApi apiService;
  final BuildContext context;

  LoginController(this.ref, this.apiService, this.context)
    : super(const LoginState());

  void startAuth({bool signup = false, bool promptLogin = false}) {
    state = state.copyWith(showCodeInput: true);
    _authorizeWithTrakt(signup: signup, promptLogin: promptLogin);
  }

  Future<void> _authorizeWithTrakt({
    bool signup = false,
    bool promptLogin = false,
  }) async {
    final params = <String, String>{'state': 'login'};
    if (signup) params['signup'] = 'true';
    if (promptLogin) params['prompt'] = 'login';
    final url = apiService.getAuthorizationUrl(extraParams: params);
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el navegador.')),
      );
    }
  }

  Future<void> submitCode(String code) async {
    if (code.isEmpty) {
      state = state.copyWith(error: 'Introduce el código', loading: false);
      return;
    }
    state = state.copyWith(loading: true, error: null);
    try {
      await ref.read(authProvider.notifier).loginWithCode(code);
      final authState = ref.read(authProvider);
      if (authState.hasValue && authState.value?.username != null) {
        if (!context.mounted) return;
        Navigator.of(context).pop(true);
      } else {
        state = state.copyWith(loading: false);
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Código incorrecto o expirado',
        loading: false,
      );
    }
  }
}

final loginControllerProvider = StateNotifierProvider.autoDispose
    .family<LoginController, LoginState, BuildContext>((ref, context) {
      final apiService = TraktApi();
      return LoginController(ref, apiService, context);
    });
