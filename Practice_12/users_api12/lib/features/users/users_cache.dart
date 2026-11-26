import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'user.dart';
import '../../core/api/api_exception.dart';

class UsersCache {
  Future<File> _file() async =>
      File('${(await getApplicationDocumentsDirectory()).path}/users.json');
  Future<void> save(List<User> list) async {
    await (await _file())
        .writeAsString(jsonEncode([for (final u in list) u.toJson()]));
  }

  Future<List<User>?> load() async {
    final file = await _file();
    if (!await file.exists()) return null;
    try {
      return [
        for (final j in jsonDecode(await file.readAsString()) as List<dynamic>)
          User.fromJson(j as Map<String, dynamic>)
      ];
    } on FormatException {
      throw const BadResponseException('Invalid cache JSON');
    } on TypeError {
      throw const BadResponseException('Invalid cache structure');
    } on FileSystemException {
      throw const BadResponseException('Unable to read cache');
    }
  }
}
