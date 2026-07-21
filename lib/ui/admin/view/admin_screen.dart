import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/concert_event.dart';
import '../../../data/models/product.dart';
import '../../../data/models/track.dart';
import '../../../data/repositories/admin_repository.dart';

enum _ContentType { track, event, product }

/// Tableau de bord visible uniquement pour les comptes administrateurs.
class AdminScreen extends StatefulWidget {
  final VoidCallback? onContentChanged;

  const AdminScreen({super.key, this.onContentChanged});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  final _repository = AdminRepository();
  late final TabController _tabs;
  int _revision = 0;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this)..addListener(_refresh);
  }

  @override
  void dispose() {
    _tabs
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  _ContentType get _type => _ContentType.values[_tabs.index];

  Future<void> _openForm([Object? item]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AdminEditSheet(
        type: _type,
        item: item,
        repository: _repository,
      ),
    );
    if (saved == true && mounted) {
      setState(() => _revision++);
      widget.onContentChanged?.call();
    }
  }

  Future<void> _delete(Object item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Cette action est définitive.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      if (item is Track) await _repository.deleteTrack(item.id);
      if (item is ConcertEvent) await _repository.deleteEvent(item.id);
      if (item is Product) await _repository.deleteProduct(item.id);
      if (mounted) {
        setState(() => _revision++);
        widget.onContentChanged?.call();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Suppression impossible.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TabBar(
            controller: _tabs,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primaryLight,
            unselectedLabelColor: AppColors.textMuted,
            tabs: const [
              Tab(icon: Icon(Icons.headphones), text: 'Musiques'),
              Tab(icon: Icon(Icons.event), text: 'Événements'),
              Tab(icon: Icon(Icons.checkroom), text: 'Merch'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _AdminList<Track>(
                key: ValueKey('tracks-$_revision'),
                future: _repository.fetchTracks(),
                title: (item) => item.title,
                subtitle: (item) => item.album ?? 'Sans album',
                onEdit: _openForm,
                onDelete: _delete,
              ),
              _AdminList<ConcertEvent>(
                key: ValueKey('events-$_revision'),
                future: _repository.fetchEvents(),
                title: (item) => item.title,
                subtitle: (item) => '${item.venue} — ${item.formattedDate}',
                onEdit: _openForm,
                onDelete: _delete,
              ),
              _AdminList<Product>(
                key: ValueKey('products-$_revision'),
                future: _repository.fetchProducts(),
                title: (item) => item.name,
                subtitle: (item) =>
                    '${item.formattedPrice} · ${item.category ?? 'Sans catégorie'}',
                onEdit: _openForm,
                onDelete: _delete,
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            child: ElevatedButton.icon(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: Text(
                switch (_type) {
                  _ContentType.track => 'Ajouter une musique',
                  _ContentType.event => 'Ajouter un événement',
                  _ContentType.product => 'Ajouter un produit',
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminList<T> extends StatelessWidget {
  final Future<List<T>> future;
  final String Function(T) title;
  final String Function(T) subtitle;
  final ValueChanged<T> onEdit;
  final ValueChanged<T> onDelete;

  const _AdminList({
    super.key,
    required this.future,
    required this.title,
    required this.subtitle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Impossible de charger le contenu.'));
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('Aucun contenu pour le moment.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, index) {
            final item = items[index];
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                title: Text(title(item)),
                subtitle: Text(subtitle(item)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Modifier',
                      onPressed: () => onEdit(item),
                      icon: const Icon(Icons.edit_outlined,
                          color: AppColors.primary),
                    ),
                    IconButton(
                      tooltip: 'Supprimer',
                      onPressed: () => onDelete(item),
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.danger),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AdminEditSheet extends StatefulWidget {
  final _ContentType type;
  final Object? item;
  final AdminRepository repository;

  const _AdminEditSheet({
    required this.type,
    required this.item,
    required this.repository,
  });

  @override
  State<_AdminEditSheet> createState() => _AdminEditSheetState();
}

class _AdminEditSheetState extends State<_AdminEditSheet> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _fields = {};
  DateTime? _startsAt;
  bool _saving = false;

  TextEditingController _field(String name, [String value = '']) =>
      _fields.putIfAbsent(name, () => TextEditingController(text: value));

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item is Track) {
      _field('title', item.title);
      _field('album', item.album ?? '');
      _field('cover', item.coverUrl ?? '');
      _field('duration', item.durationSeconds?.toString() ?? '');
    } else if (item is ConcertEvent) {
      _field('title', item.title);
      _field('venue', item.venue);
      _field('city', item.city);
      _field('latitude', item.latitude?.toString() ?? '');
      _field('longitude', item.longitude?.toString() ?? '');
      _startsAt = item.startsAt;
    } else if (item is Product) {
      _field('name', item.name);
      _field('category', item.category ?? '');
      _field('price', item.price.toString());
      _field('image', item.imageUrl ?? '');
      _field('description', item.description ?? '');
    }
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Ce champ est requis.' : null;

  Future<void> _pickDate() async {
    final initial = _startsAt ?? DateTime.now().add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;
    setState(() {
      _startsAt =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.type == _ContentType.event && _startsAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez la date de l’événement.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final item = widget.item;
      switch (widget.type) {
        case _ContentType.track:
          await widget.repository.saveTrack(
            id: item is Track ? item.id : null,
            title: _field('title').text,
            album: _field('album').text,
            coverUrl: _field('cover').text,
            durationSeconds: int.tryParse(_field('duration').text),
          );
        case _ContentType.event:
          await widget.repository.saveEvent(
            id: item is ConcertEvent ? item.id : null,
            title: _field('title').text,
            venue: _field('venue').text,
            city: _field('city').text,
            startsAt: _startsAt!,
            latitude:
                double.tryParse(_field('latitude').text.replaceAll(',', '.')),
            longitude:
                double.tryParse(_field('longitude').text.replaceAll(',', '.')),
          );
        case _ContentType.product:
          await widget.repository.saveProduct(
            id: item is Product ? item.id : null,
            name: _field('name').text,
            category: _field('category').text,
            price: double.parse(_field('price').text.replaceAll(',', '.')),
            imageUrl: _field('image').text,
            description: _field('description').text,
          );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enregistrement impossible.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Material(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.item == null
                                ? 'Nouveau contenu'
                                : 'Modifier le contenu',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ..._buildFields(),
                    const SizedBox(height: 22),
                    ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: const Text('Enregistrer'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFields() {
    Widget input(String key, String label,
        {bool required = false, TextInputType? keyboard, int maxLines = 1}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
          controller: _field(key),
          keyboardType: keyboard,
          maxLines: maxLines,
          decoration: InputDecoration(labelText: label),
          validator: required ? _required : null,
        ),
      );
    }

    switch (widget.type) {
      case _ContentType.track:
        return [
          input('title', 'Titre', required: true),
          input('album', 'Album'),
          input('duration', 'Durée en secondes',
              keyboard: TextInputType.number),
          input('cover', 'URL de la pochette', keyboard: TextInputType.url),
        ];
      case _ContentType.event:
        return [
          input('title', 'Nom de l’événement', required: true),
          input('venue', 'Salle / lieu', required: true),
          input('city', 'Ville', required: true),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month),
            label: Text(
              _startsAt == null
                  ? 'Choisir la date et l’heure'
                  : '${_startsAt!.day.toString().padLeft(2, '0')}/${_startsAt!.month.toString().padLeft(2, '0')}/${_startsAt!.year} à ${_startsAt!.hour.toString().padLeft(2, '0')}h${_startsAt!.minute.toString().padLeft(2, '0')}',
            ),
          ),
          const SizedBox(height: 14),
          input('latitude', 'Latitude',
              keyboard: const TextInputType.numberWithOptions(
                  decimal: true, signed: true)),
          input('longitude', 'Longitude',
              keyboard: const TextInputType.numberWithOptions(
                  decimal: true, signed: true)),
        ];
      case _ContentType.product:
        return [
          input('name', 'Nom du produit', required: true),
          input('category', 'Catégorie'),
          input('price', 'Prix en euros',
              required: true,
              keyboard: const TextInputType.numberWithOptions(decimal: true)),
          input('image', 'URL de l’image', keyboard: TextInputType.url),
          input('description', 'Description', maxLines: 4),
        ];
    }
  }
}
