import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../users/users_model.dart';
import 'settings_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final email = TextEditingController(), password = TextEditingController();
  final form = GlobalKey<FormState>();
  bool busy = false;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy || form.currentState?.validate() != true) return;
    setState(() => busy = true);
    try {
      await context.read<AuthModel>().login(email.text, password.text);
    } catch (_) {
      if (mounted) message(context, 'Login failed');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Center(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                  key: form,
                  child: Column(children: [
                    TextFormField(
                        controller: email,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) =>
                            (v ?? '').contains('@') ? null : 'Enter email'),
                    TextFormField(
                        controller: password,
                        obscureText: true,
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                        validator: (v) => (v ?? '').length >= 8
                            ? null
                            : 'Minimum 8 characters'),
                    const SizedBox(height: 20),
                    FilledButton(
                        onPressed: busy ? null : submit,
                        child: Text(busy ? 'Signing in…' : 'Sign in'))
                  ])))));
}

void message(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsModel>();
    final cities = {
      for (final u in context.watch<UsersModel>().items)
        if (u.address.city.isNotEmpty) u.address.city,
      if (s.city case final c?) c
    }.toList()
      ..sort();
    return ListView(padding: const EdgeInsets.all(16), children: [
      SwitchListTile(
          title: const Text('Dark mode'), value: s.dark, onChanged: s.setDark),
      DropdownButtonFormField<String>(
          key: ValueKey(s.city),
          initialValue: s.city ?? '',
          decoration: const InputDecoration(labelText: 'City filter'),
          items: [
            const DropdownMenuItem(value: '', child: Text('All cities')),
            for (final city in cities)
              DropdownMenuItem(value: city, child: Text(city))
          ],
          onChanged: (v) => unawaited(s.setCity(v == '' ? null : v))),
      ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Sign out'),
          onTap: () async {
            await context.read<AuthModel>().logout();
          })
    ]);
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileState();
}

class _ProfileState extends State<ProfileScreen> {
  Future<void> pick(ImageSource source) async {
    final settings = context.read<SettingsModel>();
    try {
      final shot = await ImagePicker()
          .pickImage(source: source, maxWidth: 1024, imageQuality: 85);
      if (shot == null || !mounted) return;
      final dir = await getApplicationDocumentsDirectory();
      final saved = await File(shot.path).copy('${dir.path}/avatar.jpg');
      await FileImage(saved).evict();
      if (!mounted) return;
      await settings.setAvatar(saved.path);
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) message(context, 'Could not save photo');
    }
  }

  Future<void> takePhoto() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    switch (status) {
      case PermissionStatus.granted:
        await pick(ImageSource.camera);
        break;
      case PermissionStatus.permanentlyDenied:
        final go = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
                    title: const Text('Camera is disabled'),
                    content: const Text(
                        'Allow camera access in Settings to take a profile photo.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: const Text('Open settings'))
                    ]));
        if (go == true) await openAppSettings();
        break;
      case PermissionStatus.denied:
        message(
            context, 'Camera is needed to take a photo. You can try again.');
        break;
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        message(context, 'Camera access is restricted or limited.');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = context.watch<SettingsModel>().avatar;
    final file = path == null ? null : File(path);
    final exists = file?.existsSync() ?? false;
    return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      CircleAvatar(
          radius: 64,
          backgroundImage: exists && file != null ? FileImage(file) : null,
          child:
              exists ? null : const Text('U', style: TextStyle(fontSize: 44))),
      const SizedBox(height: 24),
      FilledButton.tonal(
          onPressed: () => pick(ImageSource.gallery),
          child: const Text('Choose photo')),
      OutlinedButton(onPressed: takePhoto, child: const Text('Take photo'))
    ]));
  }
}
