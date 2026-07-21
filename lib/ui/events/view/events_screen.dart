import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/load_status.dart';
import '../../../data/models/concert_event.dart';
import '../../common/error_state.dart';
import '../viewmodel/events_viewmodel.dart';

/// Écran « Événements » : liste des concerts, avec bascule vers une carte.
class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventsViewModel()..load(),
      child: const _EventsView(),
    );
  }
}

class _EventsView extends StatefulWidget {
  const _EventsView();

  @override
  State<_EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends State<_EventsView> {
  bool _mapView = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventsViewModel>();

    Widget content;
    switch (vm.status) {
      case LoadStatus.loading:
      case LoadStatus.idle:
        content = const Center(child: CircularProgressIndicator());
        break;
      case LoadStatus.error:
        content = ErrorState(
          message: vm.errorMessage!,
          onRetry: () => context.read<EventsViewModel>().load(),
        );
        break;
      case LoadStatus.success:
        if (vm.events.isEmpty) {
          content = const Center(child: Text('Aucun événement à venir.'));
        } else {
          content = _mapView
              ? _EventsMap(events: vm.events)
              : _EventsList(events: vm.events);
        }
        break;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: _ViewToggle(
            mapView: _mapView,
            onChanged: (v) => setState(() => _mapView = v),
          ),
        ),
        Expanded(child: content),
      ],
    );
  }
}

/// Sélecteur Liste / Carte.
class _ViewToggle extends StatelessWidget {
  final bool mapView;
  final ValueChanged<bool> onChanged;

  const _ViewToggle({required this.mapView, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _ToggleButton(
              label: 'Liste',
              icon: Icons.view_list,
              selected: !mapView,
              onTap: () => onChanged(false)),
          _ToggleButton(
              label: 'Carte',
              icon: Icons.map,
              selected: mapView,
              onTap: () => onChanged(true)),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.neonGradient : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: selected ? Colors.white : AppColors.textMuted),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      color: selected ? Colors.white : AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vue liste.
class _EventsList extends StatelessWidget {
  final List<ConcertEvent> events;
  const _EventsList({required this.events});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = events[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              _InfoRow(
                  icon: Icons.place_outlined,
                  text: '${event.venue} — ${event.city}',
                  color: AppColors.primary),
              const SizedBox(height: 6),
              _InfoRow(
                  icon: Icons.event_outlined,
                  text: event.formattedDate,
                  color: AppColors.secondary),
            ],
          ),
        );
      },
    );
  }
}

/// Vue carte (OpenStreetMap).
class _EventsMap extends StatefulWidget {
  final List<ConcertEvent> events;
  const _EventsMap({required this.events});

  @override
  State<_EventsMap> createState() => _EventsMapState();
}

class _EventsMapState extends State<_EventsMap> {
  ConcertEvent? _selected;

  @override
  Widget build(BuildContext context) {
    final located = widget.events.where((e) => e.hasCoordinates).toList();

    return Stack(
      children: [
        FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(46.6, 2.4), // centre France
            initialZoom: 5,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.styma.app',
            ),
            MarkerLayer(
              markers: located
                  .map(
                    (e) => Marker(
                      point: LatLng(e.latitude!, e.longitude!),
                      width: 44,
                      height: 44,
                      child: GestureDetector(
                        onTap: () => setState(() => _selected = e),
                        child: Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 40,
                          shadows: [
                            Shadow(
                              color: AppColors.primary.withValues(alpha: 0.8),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        if (_selected != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 100,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xF00A0A0A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selected!.title,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _InfoRow(
                      icon: Icons.place_outlined,
                      text: '${_selected!.venue} — ${_selected!.city}',
                      color: AppColors.primary),
                  const SizedBox(height: 4),
                  _InfoRow(
                      icon: Icons.event_outlined,
                      text: _selected!.formattedDate,
                      color: AppColors.secondary),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoRow(
      {required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
        ),
      ],
    );
  }
}
