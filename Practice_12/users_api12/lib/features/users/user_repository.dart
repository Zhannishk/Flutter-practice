import 'package:http/http.dart' as http;
import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_cache.dart';
import '../../core/storage/secure_store.dart';

class UserRepository {
  UserRepository(this._api, this._cache);
  final UsersCache _cache;

  factory UserRepository.withClient(SecureStore store) =>
      UserRepository(ApiClient(http.Client(), store), UsersCache());

  void close() => _api.close();
  final ApiClient _api;

  T _parse<T>(String path, T Function() parse) {
    try {
      return parse();
    } on TypeError catch (e) {
      throw BadResponseException('$path: $e');
    } on FormatException catch (e) {
      throw BadResponseException('$path: $e');
    } on RangeError catch (e) {
      throw BadResponseException('$path: $e');
    }
  }

  Future<List<User>> _fetch() async {
    final json = await _api.get('/users');
    return _parse(
        'users',
        () => (json as List<dynamic>)
            .map((item) => User.fromJson(item as Map<String, dynamic>))
            .toList());
  }

  Future<({List<User> items, bool fromCache})> getAll() async {
    try {
      final fresh = await _fetch();
      await _cache.save(fresh);
      return (items: fresh, fromCache: false);
    } on NoConnectionException {
      final saved = await _cache.load();
      if (saved == null) rethrow;
      return (items: saved, fromCache: true);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;
      throw BadResponseException('Storage: $e');
    }
  }

  Future<User> getById(int id) async {
    final json = await _api.get('/users/$id');
    return _parse(
        'users/$id', () => User.fromJson(json as Map<String, dynamic>));
  }

  Future<User> create(User draft) async {
    final json = await _api.post('/users', draft.toJson());
    return _parse(
        'POST users', () => User.fromJson(json as Map<String, dynamic>));
  }
}
