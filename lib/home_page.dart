import 'package:escritura/verse_memorization.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<Feature> features = const [
    (title: 'Memorize', icon: Icons.voice_chat, widget: VerseMemorization()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Escritura')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'An app for building strong daily habits in interacting with the Word of God.',
              style: Theme.of(
                context,
              ).textTheme.titleSmall!.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
          for (final feature in features) FeatureCard(feature),
          ListTile(leading: Text('More features coming soon!')),
        ],
      ),
    );
  }
}

typedef Feature = ({String title, IconData icon, Widget widget});

class FeatureCard extends StatelessWidget {
  const FeatureCard(this.feature, {super.key});

  final Feature feature;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Card.filled(
      child: ListTile(
        contentPadding: EdgeInsetsGeometry.symmetric(
          vertical: 16,
          horizontal: 24,
        ),
        leading: Text(
          feature.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: Icon(feature.icon),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => feature.widget)),
      ),
    ),
  );
}
