import 'dart:developer' as developer;

abstract final class AppLogger {
  static void log(String message) => developer.log(message, name: 'ledger');
}
