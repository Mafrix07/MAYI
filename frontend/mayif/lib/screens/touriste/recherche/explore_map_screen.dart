import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/theme_colors.dart';
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
  
  // Tâche 6: Position GPS
  LatLng? _userPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchServices();
      context.read<EventProvider>().fetchEvents();
      _getUserLocation();
    });
  }

  Future<void> _getUserLocation() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activez la localisation dans les paramètres'), backgroundColor: AppColors.primary));
      }
      return;
    }
    if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
        if (!mounted) return;
        setState(() => _userPosition = LatLng(pos.latitude, pos.longitude));
        
        // Centrer la carte sur l'utilisateur
        _mapController.move(_userPosition!, 14.0);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return NatureBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Explorer le Togo', 
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: context.primaryText)),
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'gps_fab',
          onPressed: () {
            if (_userPosition != null) {
              _mapController.move(_userPosition!, 15.0);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Position non disponible'), behavior: SnackBarBehavior.floating),
              );
              _getUserLocation();
            }
          },
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.background,
          child: const Icon(Icons.my_location_rounded),
        ),
        body: Stack(
          children: [
            // 1. La Carte
            Consumer2<ServiceProvider, EventProvider>(
              builder: (context, sp, ep, _) {
                final markers = <Marker>[];

                // Position utilisateur (Tâche 6)
                if (_userPosition != null) {
                  markers.add(
                    Marker(
                      point: _userPosition!,
                      width: 60,
                      height: 60,
                      child: const Column(
                        children: [
                          Icon(Icons.person_pin_circle, color: Colors.blueAccent, size: 45),
                          Text('Moi', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 10, shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
                        ],
                      ),
                    ),
                  );
                }

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
                          child: const Icon(Icons.event, color: Colors.orangeAccent, size: 40),
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
                bottom: 40,
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
                bottom: 40,
                left: 20,
                right: 20,
                child: _PreviewCard(
                  title: _selectedEvent!.titre,
                  subtitle: _selectedEvent!.lieu,
                  category: 'ÉVÉNEMENT',
                  color: Colors.orangeAccent,
                  onTap: () {}, // Détail événement
                  onClose: () => setState(() => _selectedEvent = null),
                ),
              ),
          ],
        ),
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
    this.color = AppColors.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle),
                child: Icon(Icons.place_rounded, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category,
                        style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5)),
                    Text(title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: context.primaryText)),
                    Text(subtitle,
                        style: TextStyle(
                            color: context.secondaryText, fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: Icon(Icons.close_rounded, color: context.hintText),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Découvrir ce lieu',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}
