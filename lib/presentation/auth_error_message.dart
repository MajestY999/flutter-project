import 'package:firebase_auth/firebase_auth.dart';

String authErrorMessage(FirebaseAuthException error) {
  return switch (error.code) {
    'invalid-email' => 'Проверьте формат email.',
    'email-already-in-use' => 'Этот email уже зарегистрирован. Войдите.',
    'weak-password' =>
      'Пароль слишком простой: используйте не менее 6 символов.',
    'user-not-found' => 'Аккаунт с таким email не найден. Сначала создайте его.',
    'wrong-password' || 'invalid-credential' => 'Неверный email или пароль.',
    'too-many-requests' =>
      'Слишком много попыток. Подождите немного и попробуйте снова.',
    'network-request-failed' =>
      'Нет соединения с интернетом. Проверьте сеть и повторите попытку.',
    'configuration-not-found' || 'auth/configuration-not-found' =>
      'Firebase Authentication ещё не настроен. В Firebase Console откройте '
          'Authentication → Get started, затем включите Email/Password в '
          'Sign-in method.',
    'operation-not-allowed' || 'auth/operation-not-allowed' =>
      'В Firebase Console включите Authentication → Sign-in method → '
          'Email/Password.',
    _ => 'Ошибка авторизации (${error.code}). ${error.message ?? ''}',
  };
}
