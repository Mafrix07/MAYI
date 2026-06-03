import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/theme_colors.dart';
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
    return NatureBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Événements',
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: context.primaryText)),
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
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
                      selectedColor: AppColors.secondary,
                      backgroundColor: AppColors.secondary.withValues(alpha: 0.06),
                      side: BorderSide(color: isSel ? AppColors.secondary : AppColors.glassBorder),
                      labelStyle: TextStyle(
                        color: isSel ? AppColors.background : context.secondaryText,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      checkmarkColor: AppColors.background,
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
                    return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
                  }

                  final events = _filtered(provider.events);

                  if (events.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.event_busy, size: 64, color: Colors.white12),
                          const SizedBox(height: 16),
                          Text(
                            _selectedType == 'TOUT'
                                ? 'Aucun événement prévu.'
                                : 'Aucun événement de ce type.',
                            style: TextStyle(color: context.secondaryText),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.secondary,
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
      case 'CULTUREL': return AppColors.primaryLight;
      case 'GASTRONOMIE': return Colors.redAccent;
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
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.background.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _typeColor.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(event.typeEvenement,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.titre,
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Icon(Icons.access_time, size: 14, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Expanded(child: Text(event.dateAffiche, style: const TextStyle(color: Colors.white70, fontSize: 13))),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Expanded(child: Text(event.lieu, style: const TextStyle(color: Colors.white70, fontSize: 13))),
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

class _EventDetailScreen extends StatelessWidget {
  final Evenement event;
  const _EventDetailScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: NatureBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  CachedNetworkImage(
                    imageUrl: event.image ?? 'https://images.pexels.com/photos/1190297/pexels-photo-1190297.jpeg',
                    height: 350,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.typeEvenement, 
                            style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        const SizedBox(height: 12),
                        Text(event.titre, 
                            style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 24),
                        GlassCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _DetailRow(icon: Icons.calendar_today, label: 'Date', value: event.dateAffiche),
                              const Divider(height: 32, color: AppColors.glassBorder),
                              _DetailRow(icon: Icons.location_on_outlined, label: 'Lieu', value: event.lieu),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text('À propos', 
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 12),
                        Text(
                          event.description.isEmpty ? 'Aucune description disponible.' : event.description,
                          style: TextStyle(color: context.secondaryText, fontSize: 16, height: 1.6),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppColors.secondary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: context.secondaryText)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }
}
