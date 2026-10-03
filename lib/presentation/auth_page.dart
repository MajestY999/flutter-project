// Предоставляет формы регистрации, входа и восстановления пароля через Firebase.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_error_message.dart';
import '../theme/app_colors.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, this.auth});

  final FirebaseAuth? auth;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegistering = false;
  bool _isBusy = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  FirebaseAuth get _auth => widget.auth ?? FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      if (_isRegistering) {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final name = _nameController.text.trim();
        if (name.isNotEmpty) {
          await credential.user?.updateDisplayName(name);
          await credential.user?.reload();
        }
      } else {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = authErrorMessage(error));
      }
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = 'Не удалось выполнить запрос: $error');
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Сначала укажите корректный email.');
      return;
    }
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (mounted) {
        setState(() {
          _errorMessage = 'Письмо для сброса пароля отправлено на $email.';
        });
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = authErrorMessage(error));
      }
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = 'Не удалось отправить письмо: $error');
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _toggleMode() {
    setState(() {
      _isRegistering = !_isRegistering;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _isRegistering ? 'Создать аккаунт' : 'С возвращением';
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _AuthBrand(),
                  const SizedBox(height: 32),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRegistering
                        ? 'Зарегистрируйтесь, чтобы вести свой счёт обещаниям.'
                        : 'Войдите, чтобы продолжить вести счёт обещаниям.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .07),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_isRegistering) ...[
                            TextFormField(
                              controller: _nameController,
                              enabled: !_isBusy,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.name],
                              maxLength: 40,
                              decoration: const InputDecoration(
                                labelText: 'Ваше имя',
                                hintText: 'Например, Саша',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                                border: OutlineInputBorder(),
                                counterText: '',
                              ),
                              validator: (value) {
                                if (!_isRegistering) return null;
                                if ((value ?? '').trim().isEmpty) {
                                  return 'Напишите, как к вам обращаться.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                          ],
                          TextFormField(
                            controller: _emailController,
                            enabled: !_isBusy,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty || !email.contains('@')) {
                                return 'Введите корректный email.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordController,
                            enabled: !_isBusy,
                            obscureText: !_isPasswordVisible,
                            autofillHints: [
                              _isRegistering
                                  ? AutofillHints.newPassword
                                  : AutofillHints.password,
                            ],
                            onFieldSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: 'Пароль',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                tooltip: _isPasswordVisible
                                    ? 'Скрыть пароль'
                                    : 'Показать пароль',
                                onPressed: () => setState(
                                  () => _isPasswordVisible =
                                      !_isPasswordVisible,
                                ),
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                            validator: (value) {
                              final password = value ?? '';
                              if (password.isEmpty) return 'Введите пароль.';
                              if (_isRegistering && password.length < 6) {
                                return 'Минимум 6 символов.';
                              }
                              return null;
                            },
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 14),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFFFFA17F),
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (!_isRegistering)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed:
                                    _isBusy ? null : _sendPasswordReset,
                                child: const Text('Забыли пароль?'),
                              ),
                            )
                          else
                            const SizedBox(height: 12),
                          const SizedBox(height: 4),
                          FilledButton(
                            onPressed: _isBusy ? null : _submit,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: AppColors.lime,
                              foregroundColor: AppColors.background,
                            ),
                            child: _isBusy
                                ? const SizedBox.square(
                                    dimension: 21,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.background,
                                    ),
                                  )
                                : Text(
                                    _isRegistering
                                        ? 'Зарегистрироваться'
                                        : 'Войти',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _isBusy ? null : _toggleMode,
                            child: Text(
                              _isRegistering
                                  ? 'Уже есть аккаунт? Войти'
                                  : 'Нет аккаунта? Зарегистрироваться',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Ваши карточки сохраняются отдельно для каждого аккаунта на этом устройстве.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
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

class _AuthBrand extends StatelessWidget {
  const _AuthBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.lime,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.bolt_rounded,
            color: AppColors.background,
            size: 25,
          ),
        ),
        const SizedBox(width: 11),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GHOSTING',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                fontSize: 14,
              ),
            ),
            Text(
              'PROMISE TRACKER',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 9,
                letterSpacing: 1.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
