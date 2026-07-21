import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:styma/core/utils/load_status.dart';
import 'package:styma/data/models/artist.dart';
import 'package:styma/data/models/concert_event.dart';
import 'package:styma/data/models/product.dart';
import 'package:styma/data/models/social_link.dart';
import 'package:styma/data/models/track.dart';
import 'package:styma/data/models/track_comment.dart';
import 'package:styma/ui/artist/viewmodel/artist_viewmodel.dart';
import 'package:styma/ui/auth/viewmodel/auth_viewmodel.dart';
import 'package:styma/ui/events/viewmodel/events_viewmodel.dart';
import 'package:styma/ui/home/viewmodel/home_viewmodel.dart';
import 'package:styma/ui/linktree/viewmodel/linktree_viewmodel.dart';
import 'package:styma/ui/music/viewmodel/music_viewmodel.dart';
import 'package:styma/ui/shop/viewmodel/shop_viewmodel.dart';

import 'helpers/fakes.dart';

void main() {
  group('AuthViewModel', () {
    test('connecte un utilisateur et transmet ses identifiants', () async {
      // Vérifie le chemin nominal et les paramètres remis au repository.
      final repository = FakeAuthDataSource();
      final vm = AuthViewModel(repository: repository);
      final result = await vm.signIn(email: 'a@b.fr', password: 'abcd1234');
      expect(result, isTrue);
      expect(vm.status, AuthStatus.idle);
      expect(repository.email, 'a@b.fr');
      expect(repository.password, 'abcd1234');
    });

    test('inscrit un utilisateur avec son pseudonyme', () async {
      // Vérifie que les trois informations d'inscription sont transmises.
      final repository = FakeAuthDataSource();
      final vm = AuthViewModel(repository: repository);
      expect(
        await vm.signUp(
          email: 'a@b.fr',
          password: 'abcd1234',
          username: 'Alex',
        ),
        isTrue,
      );
      expect(repository.username, 'Alex');
    });

    test('expose le message précis d’une AuthException', () async {
      // Vérifie que les erreurs Supabase compréhensibles atteignent l'interface.
      final repository = FakeAuthDataSource()
        ..error = const AuthException('Identifiants invalides');
      final vm = AuthViewModel(repository: repository);
      expect(await vm.signIn(email: 'a@b.fr', password: 'bad'), isFalse);
      expect(vm.status, AuthStatus.error);
      expect(vm.errorMessage, 'Identifiants invalides');
    });

    test('masque le détail d’une erreur technique inconnue', () async {
      // Vérifie que l'application renvoie un message générique et sûr.
      final repository = FakeAuthDataSource()..error = Exception('secret');
      final vm = AuthViewModel(repository: repository);
      expect(await vm.deleteAccount(), isFalse);
      expect(vm.errorMessage, contains('Veuillez réessayer'));
    });

    test('demande la déconnexion au repository', () async {
      // Vérifie que l'action de session est bien déléguée.
      final repository = FakeAuthDataSource();
      await AuthViewModel(repository: repository).signOut();
      expect(repository.signedOut, isTrue);
    });

    test('notifie le passage par l’état de chargement', () async {
      // Vérifie que l'interface peut afficher puis retirer son indicateur.
      final vm = AuthViewModel(repository: FakeAuthDataSource());
      final states = <AuthStatus>[];
      vm.addListener(() => states.add(vm.status));
      await vm.signIn(email: 'a@b.fr', password: 'abcd1234');
      expect(states, [AuthStatus.loading, AuthStatus.idle]);
    });
  });

  group('ViewModels de contenu', () {
    test('ArtistViewModel charge la biographie', () async {
      // Vérifie le passage de idle à success et la conservation de l'artiste.
      final source = FakeContentDataSource()
        ..artist = const Artist(name: 'STYMA', bio: 'Une bio');
      final vm = ArtistViewModel(repository: source);
      await vm.load();
      expect(vm.status, LoadStatus.success);
      expect(vm.artist?.bio, 'Une bio');
    });

    test('ArtistViewModel expose une erreur de chargement', () async {
      // Vérifie le message affiché lorsque Supabase est indisponible.
      final vm = ArtistViewModel(
        repository: FakeContentDataSource()..error = Exception(),
      );
      await vm.load();
      expect(vm.status, LoadStatus.error);
      expect(vm.errorMessage, contains('biographie'));
    });

    test('EventsViewModel charge les événements', () async {
      // Vérifie que la liste reçue devient la liste publique du ViewModel.
      final source = FakeContentDataSource()..events = [_event('e1')];
      final vm = EventsViewModel(repository: source);
      await vm.load();
      expect(vm.status, LoadStatus.success);
      expect(vm.events.single.id, 'e1');
    });

    test('EventsViewModel gère un échec', () async {
      // Vérifie la branche error de l'écran Événements.
      final vm = EventsViewModel(
        repository: FakeContentDataSource()..error = Exception(),
      );
      await vm.load();
      expect(vm.status, LoadStatus.error);
      expect(vm.errorMessage, contains('événements'));
    });

    test('ShopViewModel charge même une boutique vide', () async {
      // Vérifie qu'une liste vide est un succès et non une erreur.
      final vm = ShopViewModel(repository: FakeContentDataSource());
      await vm.load();
      expect(vm.status, LoadStatus.success);
      expect(vm.products, isEmpty);
    });

    test('ShopViewModel conserve les produits', () async {
      // Vérifie la transmission des articles reçus du repository.
      final source = FakeContentDataSource()
        ..products = const [Product(id: 'p1', name: 'T-shirt', price: 25)];
      final vm = ShopViewModel(repository: source);
      await vm.load();
      expect(vm.products.single.name, 'T-shirt');
    });

    test('ShopViewModel gère une erreur', () async {
      // Vérifie le texte d'erreur spécifique à la boutique.
      final vm = ShopViewModel(
        repository: FakeContentDataSource()..error = Exception(),
      );
      await vm.load();
      expect(vm.status, LoadStatus.error);
      expect(vm.errorMessage, contains('boutique'));
    });

    test('HomeViewModel sélectionne les trois derniers titres', () async {
      // Vérifie l'inversion de la liste chronologique et la limite à trois.
      final source = FakeContentDataSource()
        ..tracks = [_track('1'), _track('2'), _track('3'), _track('4')]
        ..events = [_event('next'), _event('later')];
      final vm = HomeViewModel(repository: source);
      await vm.load();
      expect(vm.latestTracks.map((track) => track.id), ['4', '3', '2']);
      expect(vm.nextEvent?.id, 'next');
    });

    test('HomeViewModel accepte une liste d’événements vide', () async {
      // Vérifie que l'absence de concert produit null sans faire échouer l'accueil.
      final vm = HomeViewModel(repository: FakeContentDataSource());
      await vm.load();
      expect(vm.status, LoadStatus.success);
      expect(vm.nextEvent, isNull);
    });

    test('HomeViewModel gère une erreur de l’une des sources', () async {
      // Vérifie que l'échec global est signalé si les actualités sont incomplètes.
      final vm = HomeViewModel(
        repository: FakeContentDataSource()..error = Exception(),
      );
      await vm.load();
      expect(vm.status, LoadStatus.error);
      expect(vm.errorMessage, contains('actualités'));
    });

    test('LinktreeViewModel charge photo et liens', () async {
      // Vérifie l'agrégation de l'artiste et des réseaux sociaux.
      final source = FakeContentDataSource()
        ..artist = const Artist(name: 'STYMA', bio: 'Bio', imageUrl: 'photo')
        ..links = const [
          SocialLink(
            label: 'Site',
            url: 'https://example.com',
            iconKey: 'web',
            color: Colors.blue,
          ),
        ];
      final vm = LinktreeViewModel(repository: source);
      await vm.load();
      expect(vm.status, LoadStatus.success);
      expect(vm.photoUrl, 'photo');
      expect(vm.links, hasLength(1));
    });

    test('LinktreeViewModel ignore une URL de photo vide', () async {
      // Vérifie que l'interface utilise son image de repli pour une chaîne vide.
      final source = FakeContentDataSource()
        ..artist = const Artist(name: 'STYMA', bio: 'Bio', imageUrl: '');
      final vm = LinktreeViewModel(repository: source);
      await vm.load();
      expect(vm.photoUrl, isNull);
    });

    test('LinktreeViewModel gère une erreur', () async {
      // Vérifie la branche error des réseaux sociaux.
      final vm = LinktreeViewModel(
        repository: FakeContentDataSource()..error = Exception(),
      );
      await vm.load();
      expect(vm.status, LoadStatus.error);
      expect(vm.errorMessage, contains('liens'));
    });
  });

  group('MusicViewModel', () {
    test('charge les morceaux', () async {
      // Vérifie le chemin nominal de la liste musicale.
      final source = FakeMusicDataSource()..tracks = [_track('t1')];
      final vm = MusicViewModel(repository: source, username: () => 'Alex');
      await vm.load();
      expect(vm.status, LoadStatus.success);
      expect(vm.tracks.single.id, 't1');
    });

    test('gère une erreur de chargement', () async {
      // Vérifie le message propre à l'écran Musique.
      final source = FakeMusicDataSource()..fetchError = Exception();
      final vm = MusicViewModel(repository: source, username: () => 'Alex');
      await vm.load();
      expect(vm.status, LoadStatus.error);
      expect(vm.errorMessage, contains('morceaux'));
    });

    test('ajoute immédiatement un like réussi', () async {
      // Vérifie la mise à jour optimiste du cœur et du compteur.
      final track = _track('t1');
      final source = FakeMusicDataSource()..tracks = [track];
      final vm = MusicViewModel(repository: source, username: () => 'Alex');
      await vm.load();
      expect(await vm.toggleLike(track), isTrue);
      expect(vm.tracks.single.isLiked, isTrue);
      expect(vm.tracks.single.likeCount, 1);
      expect(source.toggledTrack, same(track));
    });

    test('retire un like sans produire de compteur négatif', () async {
      // Vérifie la protection du compteur face à une donnée initiale incohérente.
      final track = _track('t1').copyWith(isLiked: true, likeCount: 0);
      final source = FakeMusicDataSource()..tracks = [track];
      final vm = MusicViewModel(repository: source, username: () => 'Alex');
      await vm.load();
      await vm.toggleLike(track);
      expect(vm.tracks.single.likeCount, 0);
      expect(vm.tracks.single.isLiked, isFalse);
    });

    test('annule la mise à jour optimiste si Supabase échoue', () async {
      // Vérifie que l'interface revient à l'état réel après une erreur réseau.
      final track = _track('t1');
      final source = FakeMusicDataSource()
        ..tracks = [track]
        ..likeError = Exception();
      final vm = MusicViewModel(repository: source, username: () => 'Alex');
      await vm.load();
      expect(await vm.toggleLike(track), isFalse);
      expect(vm.tracks.single.isLiked, isFalse);
      expect(vm.tracks.single.likeCount, 0);
    });

    test('refuse un like sur un morceau absent', () async {
      // Vérifie qu'une ancienne carte ne provoque pas d'accès à l'index -1.
      final vm = MusicViewModel(
        repository: FakeMusicDataSource(),
        username: () => 'Alex',
      );
      expect(await vm.toggleLike(_track('absent')), isFalse);
    });

    test('charge les commentaires du bon morceau', () async {
      // Vérifie que les commentaires d'un autre titre ne sont pas retournés.
      final source = FakeMusicDataSource()
        ..comments = [_comment('c1', 't1'), _comment('c2', 't2')];
      final vm = MusicViewModel(repository: source, username: () => 'Alex');
      final comments = await vm.fetchComments('t1');
      expect(comments.single.id, 'c1');
    });

    test('ajoute un commentaire et incrémente le compteur', () async {
      // Vérifie le pseudonyme transmis et le compteur visible sur la carte.
      final track = _track('t1');
      final source = FakeMusicDataSource()..tracks = [track];
      final vm = MusicViewModel(repository: source, username: () => 'Alex');
      await vm.load();
      final result = await vm.addComment(track, 'Très bon titre');
      expect(result, isNotNull);
      expect(source.addedUsername, 'Alex');
      expect(source.addedContent, 'Très bon titre');
      expect(vm.tracks.single.commentCount, 1);
    });

    test('retourne null si l’ajout du commentaire échoue', () async {
      // Vérifie que l'échec est signalé sans modifier le compteur.
      final track = _track('t1');
      final source = FakeMusicDataSource()
        ..tracks = [track]
        ..commentError = Exception();
      final vm = MusicViewModel(repository: source, username: () => 'Alex');
      await vm.load();
      expect(await vm.addComment(track, 'Texte'), isNull);
      expect(vm.tracks.single.commentCount, 0);
    });
  });
}

Track _track(String id) => Track(id: id, title: 'Titre $id');

ConcertEvent _event(String id) => ConcertEvent(
      id: id,
      title: 'Live $id',
      venue: 'Salle',
      city: 'Paris',
      startsAt: DateTime(2026, 8, 1),
    );

TrackComment _comment(String id, String trackId) => TrackComment(
      id: id,
      trackId: trackId,
      userId: 'u1',
      username: 'Alex',
      content: 'Commentaire',
      createdAt: DateTime(2026),
    );
