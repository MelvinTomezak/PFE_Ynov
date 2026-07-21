/// État générique d'un chargement de données asynchrone.
/// Partagé par les ViewModels pour piloter l'affichage (spinner, contenu, erreur).
enum LoadStatus { idle, loading, success, error }
