import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:users_api/features/users/user.dart';

void main() {
  const raw =
      r'''{"id":1,"name":"Leanne Graham","username":"Bret","email":"leanne@example.com","address":{"street":"Kulas Light","suite":"Apt. 556","city":"Gwenborough","zipcode":"92998-3874","geo":{"lat":"-37.3159","lng":"81.1496"}},"phone":"1-770-736-8031 x56442","website":"hildegard.org","company":{"name":"Romaguera-Crona","catchPhrase":"Multi-layered client-server neural-net"}}''';

  test('User JSON round trip and geo parsing', () {
    final user = User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    expect(user.address.geo.lat, -37.3159);
    expect(user.phoneDigits, '1770736803156442');
    expect(User.fromJson(user.toJson()).toJson(), user.toJson());
  });

  test('Website can be null', () {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    map.remove('website');
    expect(User.fromJson(map).website, isNull);
  });

  test('Invalid id is rejected', () {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    map['id'] = '1';
    expect(() => User.fromJson(map), throwsA(isA<TypeError>()));
  });
}
