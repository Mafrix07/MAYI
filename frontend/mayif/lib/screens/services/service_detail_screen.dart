import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/service.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/avis_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../widgets/avis/avis_bottom_sheet.dart';
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
  int _currentPhotoIndex = 0;

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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => AvisBottomSheet(serviceId: widget.service.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Content
          CustomScrollView(
            slivers: [
              // Header Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Galerie photos (PageView)
                      PageView.builder(
                        controller: _photoController,
                        itemCount: widget.service.photos.isNotEmpty ? widget.service.photos.length : 1,
                        onPageChanged: (i) => setState(() => _currentPhotoIndex = i),
                        itemBuilder: (context, i) {
                          final url = widget.service.photos.isNotEmpty
                              ? widget.service.photos[i]
                              : (widget.service.imagePrincipale ?? 'https://images.pexels.com/photos/338504/pexels-photo-338504.jpeg');
                          return CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (_, __) => Container(color: Colors.grey[300]),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.store, size: 60, color: AppColors.primary),
                            ),
                          );
                        },
                      ),

                      // Indicateur de pages (dots)
                      if (widget.service.photos.length > 1)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              widget.service.photos.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: _currentPhotoIndex == i ? 20 : 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  color: _currentPhotoIndex == i
                                      ? Colors.white
                                      : Colors.white54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Compteur photos (ex: 2 / 5)
                      if (widget.service.photos.length > 1)
                        Positioned(
                          top: 56,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_currentPhotoIndex + 1} / ${widget.service.photos.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Consumer<FavoriteProvider>(
                    builder: (context, favProvider, _) {
                      final isFav = favProvider.isFavorite(widget.service.id);
                      return Container(
                        margin: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                        child: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.white,
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
                      // Badge Categorie
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.service.categorie,
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: AppColors.secondary, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                widget.service.noteMoyenne.toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Titre & Prix
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.service.titre,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            '${widget.service.prix.toStringAsFixed(0)} F',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Ville
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.textSecondary, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            widget.service.ville,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                          ),
                        ],
                      ),

                      // Horaires
                      if (widget.service.horaireOuverture != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.schedule, color: AppColors.textSecondary, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              widget.service.horaireFermeture != null
                                  ? '${_formatTime(widget.service.horaireOuverture!)} — ${_formatTime(widget.service.horaireFermeture!)}'
                                  : 'Ouvert à partir de ${_formatTime(widget.service.horaireOuverture!)}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 16),

                      const Divider(height: 48),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.service.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // GPS Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _openMap,
                          icon: const Icon(Icons.directions),
                          label: const Text('Itinéraire GPS'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: AppColors.secondary),
                            foregroundColor: AppColors.secondary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // ── Section Avis (Tâche 2) ─────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Avis clients',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: _showAvisSheet,
                            child: const Text('Laisser un avis'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Consumer<AvisProvider>(
                        builder: (context, provider, _) {
                          if (provider.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (provider.avis.isEmpty) {
                            return const Text('Aucun avis pour le moment. Soyez le premier !');
                          }
                          return Column(
                            children: provider.avis.take(3).map((a) => _AvisItem(avis: a)).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 2. Bottom Bar glassmorphism
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundMid.withValues(alpha: 0.85),
                    border: const Border(
                      top: BorderSide(color: AppColors.glassBorder),
                    ),
                  ),
                  child: SafeArea(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FormulaireReservationScreen(
                              serviceId: widget.service.id,
                              serviceTitre: widget.service.titre,
                              montantAcompte: widget.service.montantAcompte,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, size: 18),
                          SizedBox(width: 10),
                          Text('Réserver maintenant'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
                Text(avis.auteurNom,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                RatingBarIndicator(
                  rating: avis.note,
                  itemBuilder: (context, index) =>
                      const Icon(Icons.star, color: AppColors.secondary),
                  itemCount: 5,
                  itemSize: 14.0,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(avis.commentaire,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
