import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'new_user_screen.dart';
import 'users_model.dart';
import '../settings/settings_model.dart';
import '../settings/settings_screen.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UsersModel>();
    final city = context.watch<SettingsModel>().city;
    final filtered = model.items
        .where((u) => city == null || u.address.city == city)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Users'), actions: [
        IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () async {
              await Navigator.of(context).push<void>(MaterialPageRoute(
                  builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text('Profile')),
                      body: const SafeArea(child: ProfileScreen()))));
            }),
        IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () async {
              await Navigator.of(context).push<void>(MaterialPageRoute(
                  builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text('Settings')),
                      body: const SettingsScreen())));
            }),
        IconButton(
          tooltip: 'Refresh',
          onPressed: model.loading ? null : model.load,
          icon: const Icon(Icons.refresh),
        ),
      ]),
      body: model.loading && model.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : switch (model.error) {
              null => Column(children: [
                  if (model.fromCache)
                    MaterialBanner(
                        content: const Text('Saved data · no connection'),
                        actions: [
                          TextButton(
                              onPressed: model.loading ? null : model.load,
                              child: const Text('Retry'))
                        ]),
                  Expanded(
                      child: _UserList(items: filtered, onRefresh: model.load)),
                ]),
              NoConnectionException() => _ErrorView(
                  icon: Icons.wifi_off,
                  title: 'You are offline',
                  message: 'Check your connection and try again.',
                  onRetry: model.load,
                ),
              NotFoundException() => _ErrorView(
                  icon: Icons.search_off,
                  title: 'Not found',
                  message: 'The requested resource does not exist.',
                  onRetry: model.load,
                ),
              UnauthorizedException() => _ErrorView(
                  icon: Icons.lock_outline,
                  title: 'Unauthorized',
                  message: 'You do not have access to this resource.',
                  onRetry: model.load,
                ),
              ServerException(:final status) => _ErrorView(
                  icon: Icons.cloud_off,
                  title: 'Server error $status',
                  message: 'The server could not complete the request.',
                  onRetry: model.load,
                ),
              BadResponseException() => const _ErrorView(
                  icon: Icons.error_outline,
                  title: 'Invalid response',
                  message: 'The server returned unexpected data.',
                ),
            },
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async => await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const NewUserScreen()),
        ),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('New user'),
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  const _UserList({required this.items, required this.onRefresh});
  final List<User> items;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: onRefresh,
        child: items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 220),
                  Center(child: Text('No users yet')),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final user = items[index];
                  return Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surface,
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${user.id}')),
                      title: Text(user.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${user.email} • ${user.address.city}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async => await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => UserDetailScreen(user: user),
                        ),
                      ),
                    ),
                  );
                },
              ),
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });
  final IconData icon;
  final String title;
  final String message;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ]),
        ),
      );
}
