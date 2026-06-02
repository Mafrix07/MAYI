import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/theme_colors.dart';
import '../../providers/avis_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../widgets/avis/avis_bottom_sheet.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/glass_card.dart';
import '../touriste/reservations/formulaire_reservation_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final Service service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  late final PageController _photoController;
  
  // Tâche 3: Filtre avis
  int? _noteFiltre;
  bool _voirTousAvis = false;

  @override
  void initState() {
    super.initState();
    _photoController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AvisProvider>().fetchAvis(widget.service.id);
    });
  }

  @override
  void dispose() {
    _photoController.dispose();
    super.dispose();
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    if (parts.length >= 2) return '${parts[0]}h${parts[1]}';
    return time;
  }

  Future<void> _openMap() async {
    final query = Uri.encodeComponent('${widget.service.titre}, ${widget.service.ville}');
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showAvisSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: context.midBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: AvisBottomSheet(serviceId: widget.service.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NatureBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // 1. Content
            CustomScrollView(
              slivers: [
                // Header Image
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  backgroundColor: AppColors.backgroundMid,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      children: [
                        PageView.builder(
                          controller: _photoController,
                          itemCount: widget.service.photos.isNotEmpty ? widget.service.photos.length : 1,
                          onPageChanged: (_) {},
                          itemBuilder: (context, i) {
                            final url = widget.service.photos.isNotEmpty
                                ? widget.service.photos[i]
                                : (widget.service.imagePrincipale ?? 'https://images.pexels.com/photos/338504/pexels-photo-338504.jpeg');
                            return CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              placeholder: (_, __) => Container(color: Colors.white10),
                            );
                          },
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black38, Colors.transparent, Colors.black87],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  leading: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  actions: [
                    Consumer<FavoriteProvider>(
                      builder: (context, favProvider, _) {
                        final isFav = favProvider.isFavorite(widget.service.id);
                        return Container(
                          margin: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
                          child: IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.redAccent : Colors.white,
                              size: 20,
                            ),
                            onPressed: () => favProvider.toggleFavorite(widget.service),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // Details
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                widget.service.categorie,
                                style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: AppColors.secondary, size: 22),
                                const SizedBox(width: 4),
                                Text(
                                  widget.service.noteMoyenne.toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: context.primaryText),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Text(
                          widget.service.titre,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: context.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: AppColors.secondary, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              widget.service.ville,
                              style: TextStyle(color: context.secondaryText, fontSize: 16),
                            ),
                          ],
                        ),

                        if (widget.service.horaireOuverture != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded, color: context.secondaryText, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                widget.service.horaireFermeture != null
                                    ? '${_formatTime(widget.service.horaireOuverture!)} — ${_formatTime(widget.service.horaireFermeture!)}'
                                    : 'Ouvert à partir de ${_formatTime(widget.service.horaireOuverture!)}',
                                style: TextStyle(color: context.secondaryText, fontSize: 15),
                              ),
                            ],
                          ),
                        ],
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Divider(color: AppColors.glassBorder),
                        ),

                        Text('Description',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.primaryText)),
                        const SizedBox(height: 12),
                        Text(
                          widget.service.description,
                          style: TextStyle(color: context.secondaryText, fontSize: 16, height: 1.6),
                        ),

                        const SizedBox(height: 32),

                        // GPS Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _openMap,
                            icon: const Icon(Icons.directions_rounded),
                            label: const Text('Itinéraire GPS'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: AppColors.secondary),
                              foregroundColor: AppColors.secondary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Avis clients',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.primaryText)),
                            TextButton(
                              onPressed: _showAvisSheet,
                              child: const Text('Laisser un avis', style: TextStyle(color: AppColors.secondary)),
                            ),
                          ],
                        ),
                        
                        // Tâche 3: Filtre par note
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip('Tous', null),
                              _buildFilterChip('5★', 5),
                              _buildFilterChip('4★', 4),
                              _buildFilterChip('3★', 3),
                              _buildFilterChip('2★', 2),
                              _buildFilterChip('1★', 1),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                        Consumer<AvisProvider>(
                          builder: (context, provider, _) {
                            if (provider.isLoading) {
                              return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
                            }
                            
                            // Filtrage local
                            final avisFiltres = provider.avis.where((a) => _noteFiltre == null || a.note.round() == _noteFiltre).toList();

                            if (avisFiltres.isEmpty) {
                              return Text('Aucun avis pour le moment.', 
                                  style: TextStyle(color: context.secondaryText));
                            }
                            
                            final affichage = _voirTousAvis ? avisFiltres : avisFiltres.take(3).toList();

                            return Column(
                              children: [
                                ...affichage.map((a) => _AvisItem(avis: a)),
                                if (!_voirTousAvis && avisFiltres.length > 3)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: TextButton(
                                      onPressed: () => setState(() => _voirTousAvis = true),
                                      child: Text('Voir les ${avisFiltres.length} avis →', 
                                          style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 140),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 2. Bottom Bar glassmorphism
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                    decoration: BoxDecoration(
                      color: context.midBackground.withValues(alpha: 0.8),
                      border: const Border(top: BorderSide(color: AppColors.glassBorder)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Prix total', style: TextStyle(color: context.secondaryText, fontSize: 12)),
                              Text('${widget.service.prix.toStringAsFixed(0)} F', 
                                  style: const TextStyle(color: AppColors.secondary, fontSize: 22, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: CustomButton(
                            text: 'Réserver',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FormulaireReservationScreen(
                                    serviceId: widget.service.id,
                                    serviceTitre: widget.service.titre,
                                    montantAcompte: widget.service.montantAcompte,
                                    serviceCategorie: widget.service.categorie,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int? val) {
    final isSel = _noteFiltre == val;
    return GestureDetector(
      onTap: () => setState(() => _noteFiltre = val),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? AppColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSel ? AppColors.secondary : AppColors.glassBorder),
        ),
        child: Text(label, style: TextStyle(
          color: isSel ? Colors.white : context.secondaryText,
          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
          fontSize: 13
        )),
      ),
    );
  }
}

class _AvisItem extends StatelessWidget {
  final dynamic avis;
  const _AvisItem({required this.avis});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(avis.auteurNom, style: TextStyle(fontWeight: FontWeight.bold, color: context.primaryText)),
                RatingBarIndicator(
                  rating: avis.note,
                  itemBuilder: (context, index) => const Icon(Icons.star_rounded, color: AppColors.secondary),
                  itemCount: 5,
                  itemSize: 14.0,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(avis.commentaire, style: TextStyle(color: context.secondaryText, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
