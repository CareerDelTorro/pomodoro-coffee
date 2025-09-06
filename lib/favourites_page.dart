import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key, required this.favourites});

  final List<WordPair> favourites;

  @override
  Widget build(BuildContext context) {
    if (favourites.isEmpty) {
      return Center(child: Text('No favorites yet.'));
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'You have '
            '${favourites.length} favorites:',
          ),
        ),
        for (var pair in favourites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}
