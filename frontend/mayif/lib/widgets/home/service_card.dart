import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/service.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/favorite_provider.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback? onTap;

  const ServiceCard({super.key, required this.service, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        margin: const EdgeInsets.only(right: 14, bottom: 8, top: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Image de fond
              CachedNetworkImage(
                imageUrl: service.imagePrincipale ??
                    'https://images.pexels.com/photos/338504/pexels-photo-338504.jpeg',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                placeholder: (_, __) => Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.backgroundGradient,
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.backgroundCard,
                  child: const Icon(Icons.store, color: AppColors.secondary, size: 48),
                ),
              ),

              // Dégradé sombre en bas
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.background.withValues(alpha: 0.5),
                        AppColors.background.withValues(alpha: 0.9),
                      ],
                      stops: const [0.3, 0.65, 1.0],
                    ),
                  ),
                ),
              ),

              // Bouton favori (haut droit) avec glassmorphism
              Positioned(
                top: 10,
                right: 10,
                child: Consumer<FavoriteProvider>(
                  builder: (context, provider, _) {
                    final isFav = provider.isFavorite(service.id);
                    return GestureDetector(
                      onTap: () => provider.toggleFavorite(service),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isFav
                                  ? Colors.red.withValues(alpha: 0.85)
                                  : AppColors.glassFillMed,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isFav ? Colors.red : AppColors.glassBorder,
                              ),
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Contenu bas de carte
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge catégorie
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          service.categorie,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.background,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Titre avec ellipsis
                      Text(
                        service.titre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 4),
                          ],
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Ville
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70, size: 11),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              service.ville,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Prix
                      Text(
                        '${service.prix.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
