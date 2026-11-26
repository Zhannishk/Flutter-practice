import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/storage/secure_store.dart';

class SettingsModel extends ChangeNotifier {
  SettingsModel(this._prefs, this.dark, this.city, this.avatar);
  final SharedPreferencesAsync _prefs;
  bool dark;
  String? city, avatar;
  Future<void> setDark(bool v) async {
    dark = v;
    notifyListeners();
    await _prefs.setBool('darkMode', v);
  }

  Future<void> setCity(String? c) async {
    city = c;
    notifyListeners();
    if (c == null) {
      await _prefs.remove('cityFilter');
    } else {
      await _prefs.setString('cityFilter', c);
    }
  }

  Future<void> setAvatar(String path) async {
    await _prefs.setString('avatarPath', path);
    avatar = path;
    notifyListeners();
  }
}

class AuthModel extends ChangeNotifier {
  AuthModel(this._store, this._token);
  final SecureStore _store;
  String? _token;
  bool get signedIn => _token != null;
  Future<void> login(String email, String password) async {
    if (password.length < 8) throw ArgumentError('Use at least 8 characters');
    await Future<void>.delayed(const Duration(seconds: 1));
    final token = 'tok_${email.hashCode}';
    await _store.saveToken(token);
    _token = token;
    notifyListeners();
  }

  Future<void> logout() async {
    await _store.clear();
    _token = null;
    notifyListeners();
  }

  Future<void> copyToken() async {
    final token = await _store.readToken();
    if (token != null) await Clipboard.setData(ClipboardData(text: token));
  }
}
