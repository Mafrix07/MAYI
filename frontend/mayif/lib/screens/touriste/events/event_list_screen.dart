import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/event_provider.dart';
import '../../../models/evenement.dart';
import '../../../widgets/common/glass_card.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  String _selectedType = 'TOUT';

  final List<Map<String, String>> _types = [
    {'label': 'Tous', 'value': 'TOUT'},
    {'label': 'Festivals', 'value': 'FESTIVAL'},
    {'label': 'Concerts', 'value': 'CONCERT'},
    {'label': 'Sports', 'value': 'SPORTIF'},
    {'label': 'Culture', 'value': 'CULTUREL'},
    {'label': 'Gastronomie', 'value': 'GASTRONOMIE'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().fetchEvents();
    });
  }

  List<Evenement> _filtered(List<Evenement> events) {
    if (_selectedType == 'TOUT') return events;
    return events.where((e) => e.typeEvenement == _selectedType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Calendrier des Événements',
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundMid,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: NatureBackground(
        child: Column(
        children: [
          // Filtres par type
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _types.length,
              itemBuilder: (context, index) {
                final t = _types[index];
                final isSel = _selectedType == t['value'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: FilterChip(
                    label: Text(t['label']!),
                    selected: isSel,
                    onSelected: (_) => setState(() => _selectedType = t['value']!),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                );
              },
            ),
          ),

          // Liste d'événements
          Expanded(
            child: Consumer<EventProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.events.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                final events = _filtered(provider.events);

                if (events.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: AppColors.textSecondary),
                        const SizedBox(height: 16),
                        Text(
                          _selectedType == 'TOUT'
                              ? 'Aucun événement prévu pour le moment.'
                              : 'Aucun événement de ce type.',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchEvents(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    itemBuilder: (context, index) => _EventCard(
                      event: events[index],
                      onTap: () => _showDetail(context, events[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, Evenement event) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _EventDetailScreen(event: event)));
  }
}

class _EventCard extends StatelessWidget {
  final Evenement event;
  final VoidCallback onTap;
  const _EventCard({required this.event, required this.onTap});

  Color get _typeColor {
    switch (event.typeEvenement) {
      case 'FESTIVAL': return Colors.purple;
      case 'CONCERT': return Colors.blue;
      case 'SPORTIF': return Colors.orange;
      case 'CULTUREL': return AppColors.primary;
      case 'GASTRONOMIE': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GlassCard(
        borderRadius: 28,
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo avec overlay dégradé
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: event.image ??
                        'https://images.pexels.com/photos/1190297/pexels-photo-1190297.jpeg',
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                        height: 170, color: AppColors.backgroundCard),
                    errorWidget: (_, __, ___) => Container(
                      height: 170,
                      color: _typeColor.withValues(alpha: 0.15),
                      child: Icon(Icons.event, size: 48, color: _typeColor),
                    ),
                  ),
                  // Gradient overlay pour que le texte "pop"
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.background.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Badge type en haut à gauche
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _typeColor.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(event.typeEvenement,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.titre,
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.access_time,
                        size: 14, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Expanded(
                        child: Text(event.dateAffiche,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13))),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Expanded(
                        child: Text(event.lieu,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13))),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Écran Détail Événement ─────────────────────────────────────────────────
class _EventDetailScreen extends StatelessWidget {
  final Evenement event;
  const _EventDetailScreen({required this.event});

  Color get _typeColor {
    switch (event.typeEvenement) {
      case 'FESTIVAL': return Colors.purple;
      case 'CONCERT': return Colors.blue;
      case 'SPORTIF': return Colors.orange;
      case 'CULTUREL': return AppColors.primary;
      case 'GASTRONOMIE': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: _typeColor,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: event.image ?? 'https://images.pexels.com/photos/1190297/pexels-photo-1190297.jpeg',
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: _typeColor.withValues(alpha: 0.3),
                      child: Icon(Icons.event, size: 80, color: _typeColor),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(event.typeEvenement, style: TextStyle(color: _typeColor, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  Text(event.titre, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  _DetailRow(icon: Icons.access_time, label: 'Date', value: event.dateAffiche),
                  const SizedBox(height: 12),
                  _DetailRow(icon: Icons.location_on_outlined, label: 'Lieu', value: event.lieu),
                  const SizedBox(height: 24),

                  const Text('À propos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    event.description.isEmpty ? 'Aucune description disponible.' : event.description,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.6),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.secondary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
