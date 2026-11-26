import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/storage/secure_store.dart';
import 'features/settings/settings_model.dart';
import 'features/settings/settings_screen.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = SharedPreferencesAsync();
  final dark = await prefs.getBool('darkMode') ?? false;
  final city = await prefs.getString('cityFilter');
  final avatar = await prefs.getString('avatarPath');
  final store = SecureStore();
  final token = await store.readToken();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
        create: (_) => SettingsModel(prefs, dark, city, avatar)),
    ChangeNotifierProvider(create: (_) => AuthModel(store, token)),
    Provider(
        create: (_) => UserRepository.withClient(store),
        dispose: (_, repo) => repo.close()),
  ], child: const App()));
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    final signedIn = context.watch<AuthModel>().signedIn;
    final app = MaterialApp(
      key: ValueKey(signedIn),
      title: 'Users API',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF4866BD),
          scaffoldBackgroundColor: const Color(0xFFF7F8FC),
          appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF7F8FC))),
      darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF4866BD),
          brightness: Brightness.dark),
      themeMode: context.watch<SettingsModel>().dark
          ? ThemeMode.dark
          : ThemeMode.light,
      home: signedIn ? const UsersScreen() : const LoginScreen(),
    );
    if (!signedIn) return app;
    return ChangeNotifierProvider(
        create: (context) {
          final model = UsersModel(context.read<UserRepository>());
          unawaited(model.load());
          return model;
        },
        child: app);
  }
}
