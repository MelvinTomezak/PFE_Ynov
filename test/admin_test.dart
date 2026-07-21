import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styma/data/models/concert_event.dart';
import 'package:styma/data/models/product.dart';
import 'package:styma/data/models/track.dart';
import 'package:styma/ui/admin/view/admin_screen.dart';

import 'helpers/fakes.dart';

void main() {
  Future<void> pumpAdmin(
    WidgetTester tester,
    FakeAdminDataSource repository, {
    VoidCallback? onContentChanged,
  }) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminScreen(
            repository: repository,
            onContentChanged: onContentChanged,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Navigation et chargement Admin', () {
    testWidgets('affiche les trois menus de gestion', (tester) async {
      // Vérifie que l'administrateur peut atteindre chaque type de contenu.
      await pumpAdmin(tester, FakeAdminDataSource());
      expect(find.text('Musiques'), findsOneWidget);
      expect(find.text('Événements'), findsOneWidget);
      expect(find.text('Merch'), findsOneWidget);
      expect(find.text('Ajouter une musique'), findsOneWidget);
    });

    testWidgets('affiche les musiques existantes', (tester) async {
      // Vérifie le titre, l'album et les actions modifier/supprimer.
      final repository = FakeAdminDataSource()
        ..tracks = const [
          Track(id: 't1', title: 'Néon', album: 'Signal'),
        ];
      await pumpAdmin(tester, repository);
      expect(find.text('Néon'), findsOneWidget);
      expect(find.text('Signal'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('affiche un état vide', (tester) async {
      // Vérifie qu'une liste sans contenu n'est pas présentée comme une erreur.
      await pumpAdmin(tester, FakeAdminDataSource());
      expect(find.text('Aucun contenu pour le moment.'), findsOneWidget);
    });

    testWidgets('affiche une erreur lorsque le chargement échoue',
        (tester) async {
      // Vérifie la branche d'échec d'un repository indisponible.
      final repository = FakeAdminDataSource()..error = Exception('offline');
      await pumpAdmin(tester, repository);
      expect(find.text('Impossible de charger le contenu.'), findsOneWidget);
    });

    testWidgets('change le bouton d’ajout selon l’onglet', (tester) async {
      // Vérifie que chaque menu ouvre le formulaire correspondant.
      await pumpAdmin(tester, FakeAdminDataSource());
      await tester.tap(find.text('Événements'));
      await tester.pumpAndSettle();
      expect(find.text('Ajouter un événement'), findsOneWidget);
      await tester.tap(find.text('Merch'));
      await tester.pumpAndSettle();
      expect(find.text('Ajouter un produit'), findsOneWidget);
    });
  });

  group('Formulaire musique', () {
    testWidgets('crée une musique avec tous ses champs', (tester) async {
      // Vérifie la conversion de la durée et les données envoyées au repository.
      final repository = FakeAdminDataSource();
      var changes = 0;
      await pumpAdmin(
        tester,
        repository,
        onContentChanged: () => changes++,
      );
      await tester.tap(find.text('Ajouter une musique'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Pulsar');
      await tester.enterText(find.byType(TextFormField).at(1), 'Signal');
      await tester.enterText(find.byType(TextFormField).at(2), '241');
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'https://example.com/cover.png',
      );
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(repository.savedTrack?['id'], isNull);
      expect(repository.savedTrack?['title'], 'Pulsar');
      expect(repository.savedTrack?['album'], 'Signal');
      expect(repository.savedTrack?['durationSeconds'], 241);
      expect(changes, 1);
    });

    testWidgets('refuse un titre vide', (tester) async {
      // Vérifie que le champ obligatoire bloque l'enregistrement.
      final repository = FakeAdminDataSource();
      await pumpAdmin(tester, repository);
      await tester.tap(find.text('Ajouter une musique'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enregistrer'));
      await tester.pump();
      expect(find.text('Ce champ est requis.'), findsOneWidget);
      expect(repository.savedTrack, isNull);
    });

    testWidgets('refuse une durée non numérique', (tester) async {
      // Vérifie la validation locale avant tout appel Supabase.
      final repository = FakeAdminDataSource();
      await pumpAdmin(tester, repository);
      await tester.tap(find.text('Ajouter une musique'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Pulsar');
      await tester.enterText(find.byType(TextFormField).at(2), 'trois minutes');
      await tester.tap(find.text('Enregistrer'));
      await tester.pump();
      expect(find.text('Saisissez un nombre valide.'), findsOneWidget);
      expect(repository.savedTrack, isNull);
    });

    testWidgets('modifie une musique existante', (tester) async {
      // Vérifie que l'identifiant est conservé lors d'une mise à jour.
      final repository = FakeAdminDataSource()
        ..tracks = const [Track(id: 't1', title: 'Ancien titre')];
      await pumpAdmin(tester, repository);
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Nouveau titre');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(repository.savedTrack?['id'], 't1');
      expect(repository.savedTrack?['title'], 'Nouveau titre');
    });

    testWidgets('affiche une erreur si l’enregistrement échoue',
        (tester) async {
      // Vérifie le retour utilisateur lorsqu'une écriture distante est refusée.
      final repository = FakeAdminDataSource()..error = Exception('RLS');
      await pumpAdmin(tester, repository);
      // Le chargement échoue aussi : on retire l'erreur après le premier rendu.
      repository.error = null;
      await tester.tap(find.text('Ajouter une musique'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Titre');
      repository.error = Exception('RLS');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(find.text('Enregistrement impossible.'), findsOneWidget);
      expect(repository.savedTrack, isNull);
    });
  });

  group('Suppression', () {
    testWidgets('annule une suppression', (tester) async {
      // Vérifie que le bouton Annuler ne touche jamais au repository.
      final repository = FakeAdminDataSource()
        ..tracks = const [Track(id: 't1', title: 'Néon')];
      await pumpAdmin(tester, repository);
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(repository.deletedTrackId, isNull);
    });

    testWidgets('confirme la suppression d’une musique', (tester) async {
      // Vérifie l'identifiant transmis et la notification du contenu modifié.
      final repository = FakeAdminDataSource()
        ..tracks = const [Track(id: 't1', title: 'Néon')];
      var changes = 0;
      await pumpAdmin(
        tester,
        repository,
        onContentChanged: () => changes++,
      );
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();
      expect(repository.deletedTrackId, 't1');
      expect(changes, 1);
    });

    testWidgets('supprime un événement', (tester) async {
      // Vérifie la branche de suppression propre aux événements.
      final repository = FakeAdminDataSource()
        ..events = [
          ConcertEvent(
            id: 'e1',
            title: 'Live',
            venue: 'Salle',
            city: 'Paris',
            startsAt: DateTime(2026, 9, 10),
          ),
        ];
      await pumpAdmin(tester, repository);
      await tester.tap(find.text('Événements'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();
      expect(repository.deletedEventId, 'e1');
    });

    testWidgets('supprime un produit', (tester) async {
      // Vérifie la branche de suppression propre au merchandising.
      final repository = FakeAdminDataSource()
        ..products = const [
          Product(id: 'p1', name: 'Casquette', price: 20),
        ];
      await pumpAdmin(tester, repository);
      await tester.tap(find.text('Merch'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();
      expect(repository.deletedProductId, 'p1');
    });
  });

  group('Formulaire événement', () {
    testWidgets('crée un événement avec le sélecteur de date et heure',
        (tester) async {
      // Vérifie le parcours complet de création et l'envoi d'une date choisie.
      final repository = FakeAdminDataSource();
      await pumpAdmin(tester, repository);
      await tester.tap(find.text('Événements'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ajouter un événement'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Release Party');
      await tester.enterText(find.byType(TextFormField).at(1), 'Le Silo');
      await tester.enterText(find.byType(TextFormField).at(2), 'Marseille');
      await tester.tap(find.text('Choisir la date et l’heure'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(repository.savedEvent?['id'], isNull);
      expect(repository.savedEvent?['title'], 'Release Party');
      expect(repository.savedEvent?['startsAt'], isA<DateTime>());
    });

    testWidgets('préremplit et modifie un événement', (tester) async {
      // Vérifie la conservation de la date, des coordonnées et de l'identifiant.
      final repository = FakeAdminDataSource()
        ..events = [
          ConcertEvent(
            id: 'e1',
            title: 'Live',
            venue: 'Le Silo',
            city: 'Marseille',
            startsAt: DateTime(2026, 9, 10, 20, 30),
            latitude: 43.3,
            longitude: 5.4,
          ),
        ];
      await pumpAdmin(tester, repository);
      await tester.tap(find.text('Événements'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
      expect(find.textContaining('10/09/2026'), findsWidgets);
      await tester.enterText(
          find.byType(TextFormField).at(2), 'Aix-en-Provence');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(repository.savedEvent?['id'], 'e1');
      expect(repository.savedEvent?['city'], 'Aix-en-Provence');
      expect(repository.savedEvent?['latitude'], 43.3);
    });

    testWidgets('exige une date pour un nouvel événement', (tester) async {
      // Vérifie que titre, lieu et ville ne suffisent pas sans date/heure.
      final repository = FakeAdminDataSource();
      await pumpAdmin(tester, repository);
      await tester.tap(find.text('Événements'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ajouter un événement'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Live');
      await tester.enterText(find.byType(TextFormField).at(1), 'Salle');
      await tester.enterText(find.byType(TextFormField).at(2), 'Paris');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(find.text('Choisissez la date de l’événement.'), findsOneWidget);
      expect(repository.savedEvent, isNull);
    });

    testWidgets('refuse des coordonnées non numériques', (tester) async {
      // Vérifie la validation des coordonnées optionnelles lorsqu'elles sont saisies.
      final repository = FakeAdminDataSource()
        ..events = [
          ConcertEvent(
            id: 'e1',
            title: 'Live',
            venue: 'Salle',
            city: 'Paris',
            startsAt: DateTime(2026, 9, 10),
          ),
        ];
      await pumpAdmin(tester, repository);
      await tester.tap(find.text('Événements'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(3), 'nord');
      await tester.tap(find.text('Enregistrer'));
      await tester.pump();
      expect(find.text('Saisissez un nombre valide.'), findsOneWidget);
      expect(repository.savedEvent, isNull);
    });
  });

  group('Formulaire merchandising', () {
    testWidgets('crée un produit et accepte une virgule dans le prix',
        (tester) async {
      // Vérifie tous les champs du merch et la conversion française du prix.
      final repository = FakeAdminDataSource();
      await pumpAdmin(tester, repository);
      await tester.tap(find.text('Merch'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ajouter un produit'));
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'T-shirt Signal');
      await tester.enterText(fields.at(1), 'Textile');
      await tester.enterText(fields.at(2), '24,90');
      await tester.enterText(fields.at(3), 'https://example.com/shirt.png');
      await tester.enterText(fields.at(4), 'T-shirt officiel');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(repository.savedProduct?['name'], 'T-shirt Signal');
      expect(repository.savedProduct?['price'], 24.9);
      expect(repository.savedProduct?['description'], 'T-shirt officiel');
    });

    testWidgets('refuse un prix invalide', (tester) async {
      // Vérifie qu'aucun produit n'est envoyé avec un prix non numérique.
      final repository = FakeAdminDataSource();
      await pumpAdmin(tester, repository);
      await tester.tap(find.text('Merch'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ajouter un produit'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Casquette');
      await tester.enterText(find.byType(TextFormField).at(2), 'gratuit');
      await tester.tap(find.text('Enregistrer'));
      await tester.pump();
      expect(find.text('Saisissez un nombre valide.'), findsOneWidget);
      expect(repository.savedProduct, isNull);
    });

    testWidgets('modifie un produit existant', (tester) async {
      // Vérifie que l'édition du merch conserve son identifiant.
      final repository = FakeAdminDataSource()
        ..products = const [
          Product(id: 'p1', name: 'Casquette', price: 20),
        ];
      await pumpAdmin(tester, repository);
      await tester.tap(find.text('Merch'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(2), '22');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(repository.savedProduct?['id'], 'p1');
      expect(repository.savedProduct?['price'], 22.0);
    });
  });
}
