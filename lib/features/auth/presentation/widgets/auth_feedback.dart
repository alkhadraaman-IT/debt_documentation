import '../../domain/auth_repository.dart';
import '../bloc/auth_state.dart';

String? authFeedback(AuthState state) {
  if (!state.sessionReady) return null;
  if (state.failure case final failure?) {
    return switch (failure) {
      AuthFailure.offline => 'لا يوجد اتصال بالإنترنت. حاول مرة أخرى.',
      AuthFailure.invalidCredentials => 'تعذّر تسجيل الدخول بهذه البيانات.',
      AuthFailure.invalidEmail => 'أدخل بريداً إلكترونياً صالحاً.',
      AuthFailure.emailInUse =>
        'البريد مستخدم. سجّل الدخول أو استعد كلمة المرور.',
      AuthFailure.weakPassword => 'اختر كلمة مرور أقوى.',
      AuthFailure.rateLimited => 'محاولات كثيرة. انتظر قليلاً ثم حاول مجدداً.',
      AuthFailure.sessionExpired => 'انتهت الجلسة. سجّل الدخول مجدداً.',
      AuthFailure.unexpected => 'تعذّر إتمام العملية. حاول مرة أخرى.',
    };
  }
  return switch (state.notice) {
    AuthNotice.verificationSent => 'أُرسل رابط تأكيد البريد.',
    AuthNotice.verificationPending => 'لم يُؤكّد البريد بعد.',
    AuthNotice.passwordReset =>
      'إذا كان البريد مرتبطاً بحساب، فستصلك رسالة الاستعادة.',
    null => null,
  };
}
