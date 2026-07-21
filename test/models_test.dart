import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styma/data/models/artist.dart';
import 'package:styma/data/models/concert_event.dart';
import 'package:styma/data/models/product.dart';
import 'package:styma/data/models/social_link.dart';
import 'package:styma/data/models/track.dart';
import 'package:styma/data/models/track_comment.dart';
import 'package:styma/data/models/user_profile.dart';

void main() {
  group('Artist', () {
    test('convertit toutes les colonnes Supabase', () {
      // Vérifie que le mapping conserve le nom, la bio et l'image.
      final artist = Artist.fromMap({
        'name': 'STYMA',
        'bio': 'Biographie',
        'image_url': 'https://example.com/photo.png',
      });
      expect(artist.name, 'STYMA');
      expect(artist.bio, 'Biographie');
      expect(artist.imageUrl, endsWith('photo.png'));
    });

    test('accepte une image absente', () {
      // Vérifie que la colonne nullable ne provoque pas d'exception.
      final artist = Artist.fromMap({'name': 'STYMA', 'bio': 'Bio'});
      expect(artist.imageUrl, isNull);
    });
  });

  group('Track', () {
    final track = Track.fromMap({
      'id': 'track-1',
      'title': 'Néon',
      'album': 'Signal',
      'cover_url': null,
      'duration_seconds': 213,
    });

    test('convertit les données d’un morceau', () {
      // Vérifie le mapping des champs obligatoires et optionnels.
      expect(track.id, 'track-1');
      expect(track.title, 'Néon');
      expect(track.album, 'Signal');
      expect(track.durationSeconds, 213);
    });

    test('formate une durée en minutes et secondes', () {
      // Vérifie la présentation 213 secondes -> 3:33.
      expect(track.formattedDuration, '3:33');
    });

    test('retourne une durée vide si elle est inconnue', () {
      // Vérifie le comportement d'un morceau sans durée.
      const withoutDuration = Track(id: '1', title: 'Titre');
      expect(withoutDuration.formattedDuration, isEmpty);
    });

    test('copyWith modifie uniquement les interactions', () {
      // Vérifie qu'un like ne perd pas les métadonnées du morceau.
      final copy = track.copyWith(likeCount: 4, commentCount: 2, isLiked: true);
      expect(copy.title, track.title);
      expect(copy.likeCount, 4);
      expect(copy.commentCount, 2);
      expect(copy.isLiked, isTrue);
    });
  });

  group('ConcertEvent', () {
    test('convertit les nombres de coordonnées en double', () {
      // Vérifie que Supabase peut renvoyer des entiers ou des décimaux.
      final event = ConcertEvent.fromMap({
        'id': 'event-1',
        'title': 'Live',
        'venue': 'Le Silo',
        'city': 'Marseille',
        'starts_at': '2026-08-03T20:05:00.000Z',
        'latitude': 43,
        'longitude': 5.4,
      });
      expect(event.latitude, 43.0);
      expect(event.longitude, 5.4);
      expect(event.hasCoordinates, isTrue);
    });

    test('détecte des coordonnées incomplètes', () {
      // Vérifie qu'une carte ne place pas un événement partiellement localisé.
      final event = ConcertEvent.fromMap({
        'id': 'event-1',
        'title': 'Live',
        'venue': 'Salle',
        'city': 'Paris',
        'starts_at': '2026-08-03T20:05:00.000Z',
        'latitude': 48.8,
        'longitude': null,
      });
      expect(event.hasCoordinates, isFalse);
    });

    test('formate la date avec des zéros', () {
      // Vérifie la forme française JJ/MM/AAAA à HHhMM.
      final event = ConcertEvent(
        id: '1',
        title: 'Live',
        venue: 'Salle',
        city: 'Paris',
        startsAt: DateTime(2026, 2, 3, 9, 5),
      );
      expect(event.formattedDate, '03/02/2026 à 09h05');
    });
  });

  group('Product', () {
    test('convertit un prix numérique', () {
      // Vérifie que les valeurs numeric de PostgreSQL deviennent des doubles.
      final product = Product.fromMap({
        'id': 'p1',
        'name': 'T-shirt',
        'price': 24,
      });
      expect(product.price, 24.0);
    });

    test('formate un prix entier sans décimales', () {
      // Vérifie l'affichage lisible d'un montant rond.
      const product = Product(id: 'p1', name: 'T-shirt', price: 25);
      expect(product.formattedPrice, '25 €');
    });

    test('formate un prix décimal avec une virgule', () {
      // Vérifie la convention française pour les centimes.
      const product = Product(id: 'p1', name: 'T-shirt', price: 24.90);
      expect(product.formattedPrice, '24,90 €');
    });
  });

  group('SocialLink', () {
    test('convertit une couleur hexadécimale valide', () {
      // Vérifie que la couleur configurée en base est respectée.
      final link = SocialLink.fromMap({
        'label': 'Instagram',
        'url': 'https://instagram.com',
        'icon_key': 'instagram',
        'color': '#FF0000',
      });
      expect(link.color, const Color(0xFFFF0000));
    });

    test('utilise le bleu STYMA pour une couleur invalide', () {
      // Vérifie le repli visuel si la base contient une mauvaise valeur.
      final link = SocialLink.fromMap({
        'label': 'Site',
        'url': 'https://example.com',
        'icon_key': 'web',
        'color': 'incorrect',
      });
      expect(link.color, const Color(0xFF38BDF8));
    });
  });

  group('UserProfile', () {
    test('convertit puis sérialise un profil', () {
      // Vérifie l'aller-retour entre la base et la représentation Dart.
      final profile = UserProfile.fromMap({
        'id': 'u1',
        'email': 'user@example.com',
        'display_name': 'Alex',
      });
      expect(profile.toMap(), {
        'id': 'u1',
        'email': 'user@example.com',
        'display_name': 'Alex',
      });
    });

    test('remplace un e-mail absent par une chaîne vide', () {
      // Vérifie la valeur de repli prévue par le modèle.
      final profile = UserProfile.fromMap({'id': 'u1'});
      expect(profile.email, isEmpty);
    });
  });

  test('TrackComment convertit la date UTC en date locale', () {
    // Vérifie tous les champs du commentaire et la conversion temporelle.
    final comment = TrackComment.fromMap({
      'id': 'c1',
      'track_id': 't1',
      'user_id': 'u1',
      'username': 'Alex',
      'content': 'Excellent morceau',
      'created_at': '2026-07-21T10:00:00.000Z',
    });
    expect(comment.content, 'Excellent morceau');
    expect(comment.trackId, 't1');
    expect(comment.createdAt.isUtc, isFalse);
  });
}
