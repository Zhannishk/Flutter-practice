import 'package:http/http.dart' as http;
import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  const UserRepository(this._api);

  factory UserRepository.withClient() =>
      UserRepository(ApiClient(http.Client()));

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

  Future<List<User>> getAll() async {
    final json = await _api.get('/users');
    return _parse(
        'users',
        () => (json as List<dynamic>)
            .map((item) => User.fromJson(item as Map<String, dynamic>))
            .toList());
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
