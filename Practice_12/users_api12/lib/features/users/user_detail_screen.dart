import 'package:flutter/material.dart';
import 'user.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../settings/settings_model.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});
  final User user;

  Future<void> open(BuildContext context, Uri uri) async {
    bool ok = false;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No app can open this')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(user.name)),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          const SizedBox(height: 8),
          CircleAvatar(
              radius: 36,
              child: Text('${user.id}', style: const TextStyle(fontSize: 26))),
          const SizedBox(height: 16),
          Center(
              child: Text(user.name,
                  style: Theme.of(context).textTheme.headlineSmall)),
          Center(child: Text('@${user.username}')),
          const SizedBox(height: 24),
          _InfoTile(
              icon: Icons.email_outlined,
              title: 'Email',
              value: user.email,
              onTap: () =>
                  open(context, Uri(scheme: 'mailto', path: user.email))),
          _InfoTile(
              icon: Icons.phone_outlined,
              title: 'Phone',
              value: user.phone,
              onTap: () =>
                  open(context, Uri(scheme: 'tel', path: user.phoneDigits))),
          _InfoTile(
              icon: Icons.language,
              title: 'Website',
              value: user.website ?? 'Not provided',
              onTap: user.website == null
                  ? null
                  : () => open(context, Uri.parse('https://${user.website}'))),
          _InfoTile(
              icon: Icons.location_city,
              title: 'Street',
              value: user.address.street),
          _InfoTile(
              icon: Icons.home_outlined,
              title: 'Suite',
              value: user.address.suite),
          _InfoTile(
              icon: Icons.location_on_outlined,
              title: 'City',
              value: user.address.city),
          _InfoTile(
              icon: Icons.markunread_mailbox_outlined,
              title: 'Zipcode',
              value: user.address.zipcode),
          _InfoTile(
              icon: Icons.map_outlined,
              title: 'Geo',
              value: '${user.address.geo.lat}, ${user.address.geo.lng}'),
          _InfoTile(
              icon: Icons.business_outlined,
              title: 'Company',
              value: user.company.name),
          _InfoTile(
              icon: Icons.format_quote,
              title: 'Catch phrase',
              value: user.company.catchPhrase),
          _InfoTile(
              icon: Icons.dialpad,
              title: 'Phone digits',
              value: user.phoneDigits),
          if (kDebugMode)
            ListTile(
                title: const Text('Copy token to clipboard'),
                onTap: context.read<AuthModel>().copyToken),
        ]),
      );
}

class _InfoTile extends StatelessWidget {
  const _InfoTile(
      {required this.icon,
      required this.title,
      required this.value,
      this.onTap});
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
        color: Theme.of(context).colorScheme.surface,
        elevation: 0,
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(value),
          onTap: onTap,
        ),
      );
}
