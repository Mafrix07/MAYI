import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/service.dart';
import '../../screens/services/service_detail_screen.dart';

class HeroBanner extends StatefulWidget {
  /// Services réels passés depuis HomeContent (top-rated).
  /// Si vide ou null → fallback texte Mayi.
  final List<Service> services;

  const HeroBanner({super.key, this.services = const []});

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  List<Service> get _slides =>
      widget.services.isNotEmpty ? widget.services.take(4).toList() : [];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(HeroBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Relancer le timer quand les services arrivent
    if (oldWidget.services.isEmpty && widget.services.isNotEmpty) {
      _currentPage = 0;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || _slides.isEmpty) return;
      setState(() => _currentPage = (_currentPage + 1) % _slides.length);
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Aucun service chargé → placeholder Mayi
    if (_slides.isEmpty) {
      return _MayiBannerPlaceholder();
    }

    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (p) => setState(() => _currentPage = p),
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final service = _slides[index];
              final imageUrl = service.imagePrincipale ??
                  (service.photos.isNotEmpty ? service.photos.first : null);

              return Stack(
                fit: StackFit.expand,
                children: [
                  // ── Image du service ────────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) =>
                                progress == null
                                    ? child
                                    : Container(color: AppColors.backgroundCard),
                            errorBuilder: (_, __, ___) =>
                                _ServicePlaceholder(service: service),
                          )
                        : _ServicePlaceholder(service: service),
                  ),

                  // ── Dégradé chaud signature Mayi ────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.warmOverlayGradient,
                      ),
                    ),
                  ),

                  // ── Badge catégorie + Texte ──────────────────────────
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.secondary.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              service.categorie,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.background),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            service.titre,
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: AppColors.secondary, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                service.ville,
                                style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.85),
                                    fontSize: 13),
                              ),
                              const Spacer(),
                              const Icon(Icons.star,
                                  color: AppColors.secondary, size: 14),
                              const SizedBox(width: 3),
                              Text(
                                service.noteMoyenne.toString(),
                                style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // ── Overlay tap transparent — intercepte le tap sans bloquer le swipe
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (_currentPage < _slides.length) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ServiceDetailScreen(service: _slides[_currentPage]),
                    ),
                  );
                }
              },
            ),
          ),

          // ── Indicateurs de page ──────────────────────────────────────
          Positioned(
            top: 14,
            right: 16,
            child: Row(
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 6,
                  width: _currentPage == i ? 20 : 6,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? AppColors.secondary
                        : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
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

// ── Fallback quand aucun service n'est encore chargé ─────────────────────────
class _MayiBannerPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.backgroundMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
                color: AppColors.secondary, strokeWidth: 2),
            const SizedBox(height: 12),
            Text(
              'Découvrez le Togo',
              style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Fallback quand l'image d'un service est absente ───────────────────────────
class _ServicePlaceholder extends StatelessWidget {
  final Service service;
  const _ServicePlaceholder({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.backgroundMid, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          _iconForCategory(service.categorie),
          size: 64,
          color: AppColors.secondary.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  IconData _iconForCategory(String cat) {
    switch (cat) {
      case 'HEBERGEMENT':
        return Icons.hotel_outlined;
      case 'SNACK':
        return Icons.restaurant_menu_outlined;
      case 'ACTIVITE':
        return Icons.hiking_outlined;
      case 'TRANSPORT':
        return Icons.directions_car_outlined;
      default:
        return Icons.explore_outlined;
    }
  }
}
