import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
const _appId = String.fromEnvironment('FIREBASE_APP_ID');
const _senderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
const _authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');

FirebaseOptions? get firebaseOptions {
  if (_apiKey.isEmpty &&
      _appId.isEmpty &&
      _senderId.isEmpty &&
      _projectId.isEmpty) {
    if (kIsWeb || _authDomain.isNotEmpty) {
      throw const FormatException('Missing Firebase client configuration');
    }
    return null;
  }
  if (_apiKey.isEmpty ||
      _appId.isEmpty ||
      _senderId.isEmpty ||
      _projectId.isEmpty) {
    throw const FormatException('Incomplete Firebase client configuration');
  }
  return FirebaseOptions(
    apiKey: _apiKey,
    appId: _appId,
    messagingSenderId: _senderId,
    projectId: _projectId,
    authDomain: _authDomain.isEmpty ? null : _authDomain,
  );
}
