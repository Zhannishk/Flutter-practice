import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_model.dart';

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({super.key});

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required field' : null;

  String? _validateEmail(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) return requiredError;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((value ?? '').trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  Future<void> _save() async {
    if (_saving || _formKey.currentState?.validate() != true) return;
    setState(() => _saving = true);
    final model = context.read<UsersModel>();
    final draft = User(
      id: 0,
      name: _name.text.trim(),
      username: _username.text.trim(),
      email: _email.text.trim(),
      phone: '',
      website: null,
      address: const Address(
        street: '',
        suite: '',
        city: '',
        zipcode: '',
        geo: Geo(lat: 0, lng: 0),
      ),
      company: (name: '', catchPhrase: ''),
    );
    try {
      await model.create(draft);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      final message = switch (e) {
        NoConnectionException() => 'No connection. Try again.',
        ServerException(:final status) => 'Server error: $status',
        NotFoundException() => 'Endpoint not found',
        UnauthorizedException() => 'Unauthorized',
        BadResponseException(:final detail) =>
          'Bad response: ${detail ?? 'invalid data'}',
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('New user')),
        body: Form(
          key: _formKey,
          child: ListView(padding: const EdgeInsets.all(20), children: [
            const Text('Create a user',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'JSONPlaceholder simulates POST requests; data is not permanently saved.'),
            const SizedBox(height: 24),
            TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                    labelText: 'Name', border: OutlineInputBorder()),
                validator: _required),
            const SizedBox(height: 16),
            TextFormField(
                controller: _username,
                decoration: const InputDecoration(
                    labelText: 'Username', border: OutlineInputBorder()),
                validator: _required),
            const SizedBox(height: 16),
            TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder()),
                validator: _validateEmail),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Saving...' : 'Save'),
            ),
          ]),
        ),
      );
}
