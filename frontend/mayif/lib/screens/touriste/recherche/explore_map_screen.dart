import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/service_provider.dart';
import '../../../providers/event_provider.dart';
import '../../../models/service.dart';
import '../../../models/evenement.dart';
import '../../../widgets/common/glass_card.dart';
import '../../services/service_detail_screen.dart';

class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  final MapController _mapController = MapController();
  Service? _selectedService;
  Evenement? _selectedEvent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchServices();
      context.read<EventProvider>().fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorer le Togo'),
        backgroundColor: AppColors.backgroundMid,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. La Carte
          Consumer2<ServiceProvider, EventProvider>(
            builder: (context, sp, ep, _) {
              final markers = <Marker>[];

              // Ajout des services
              for (var service in sp.services) {
                if (service.latitude != null && service.longitude != null) {
                  markers.add(
                    Marker(
                      point: LatLng(service.latitude!, service.longitude!),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _selectedService = service;
                          _selectedEvent = null;
                        }),
                        child: const Icon(Icons.location_on, color: AppColors.secondary, size: 40),
                      ),
                    ),
                  );
                }
              }

              // Ajout des événements
              for (var event in ep.events) {
                if (event.latitude != null && event.longitude != null) {
                  markers.add(
                    Marker(
                      point: LatLng(event.latitude!, event.longitude!),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _selectedEvent = event;
                          _selectedService = null;
                        }),
                        child: const Icon(Icons.event, color: Colors.orange, size: 40),
                      ),
                    ),
                  );
                }
              }

              return FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: LatLng(6.1375, 1.2125),
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.frontend_new',
                  ),
                  MarkerLayer(markers: markers),
                ],
              );
            },
          ),

          // 2. Carte de prévisualisation (si un point est sélectionné)
          if (_selectedService != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _PreviewCard(
                title: _selectedService!.titre,
                subtitle: _selectedService!.ville,
                category: _selectedService!.categorie,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: _selectedService!)),
                ),
                onClose: () => setState(() => _selectedService = null),
              ),
            ),

          if (_selectedEvent != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _PreviewCard(
                title: _selectedEvent!.titre,
                subtitle: _selectedEvent!.lieu,
                category: 'ÉVÉNEMENT',
                color: Colors.orange,
                onTap: () {}, // Détail événement à venir
                onClose: () => setState(() => _selectedEvent = null),
              ),
            ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String category;
  final VoidCallback onTap;
  final VoidCallback onClose;
  final Color color;

  const _PreviewCard({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.onTap,
    required this.onClose,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle),
                child: Icon(Icons.place, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category,
                        style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary)),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Voir plus',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
