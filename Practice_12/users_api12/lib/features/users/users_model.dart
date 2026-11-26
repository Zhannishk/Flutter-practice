import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';

class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);
  final UserRepository _repo;

  List<User> items = const [];
  ApiException? error;
  bool loading = false;
  bool fromCache = false;
  bool saving = false;
  bool _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> load() async {
    if (loading) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _repo.getAll();
      items = result.items;
      fromCache = result.fromCache;
    } on ApiException catch (e) {
      error = e;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> create(User draft) async {
    if (saving) return;
    saving = true;
    notifyListeners();
    try {
      final created = await _repo.create(draft);
      items = [created, ...items];
      notifyListeners();
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
