import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      image: 'assets/images/onboarding_beach.jpg',
      usePhoto: true,
      icon: null,
      iconColor: null,
      gradientColors: null,
      title: 'Découvrez le Togo',
      description:
          'Plages, montagnes, culture locale… Explorez les plus belles destinations touristiques du Togo.',
    ),
    _SlideData(
      image: null,
      usePhoto: false,
      icon: Icons.calendar_month_rounded,
      iconColor: Color(0xFF1A8FDB),
      gradientColors: [Color(0xFF0A2A4A), Color(0xFF1A5276)],
      title: 'Réservez en un clic',
      description:
          'Hôtels, restaurants, activités — trouvez et réservez directement depuis l\'application, sans intermédiaire.',
    ),
    _SlideData(
      image: null,
      usePhoto: false,
      icon: Icons.phone_android_rounded,
      iconColor: Color(0xFF2ECC71),
      gradientColors: [Color(0xFF0A3A1A), Color(0xFF1A6B35)],
      title: 'Payez avec T-Money',
      description:
          'Confirmez votre réservation avec un acompte sécurisé via T-Money ou Flooz. Simple et rapide.',
    ),
  ];

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  void _finish() async {
    // completeOnboarding() appelle notifyListeners()
    // → le Consumer de main.dart rebuildra automatiquement sur WelcomeScreen
    await context.read<AuthProvider>().completeOnboarding();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Slides
          PageView.builder(
            controller: _controller,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
          ),

          // Bouton "Passer" en haut à droite
          if (_currentPage < _slides.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 24,
              child: GestureDetector(
                onTap: _finish,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    'Passer',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                ),
              ),
            ),

          // Bas : points + bouton
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 32,
                right: 32,
                top: 32,
                bottom: MediaQuery.of(context).padding.bottom + 40,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Points de pagination
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppColors.secondary
                              : Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Bouton Suivant / Commencer
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage < _slides.length - 1
                            ? 'Suivant'
                            : 'Commencer',
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Données d'un slide ────────────────────────────────────────────────────────
class _SlideData {
  final String? image;
  final bool usePhoto;
  final IconData? icon;
  final Color? iconColor;
  final List<Color>? gradientColors;
  final String title;
  final String description;

  const _SlideData({
    required this.image,
    required this.usePhoto,
    required this.icon,
    required this.iconColor,
    required this.gradientColors,
    required this.title,
    required this.description,
  });
}

// ── Vue d'un slide ────────────────────────────────────────────────────────────
class _SlideView extends StatelessWidget {
  final _SlideData slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Fond : photo ou gradient
        if (slide.usePhoto && slide.image != null)
          Image.asset(slide.image!, fit: BoxFit.cover)
        else
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: slide.gradientColors!,
              ),
            ),
          ),

        // Overlay sombre pour lisibilité
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.2),
                Colors.black.withValues(alpha: 0.75),
              ],
            ),
          ),
        ),

        // Icône (slides 2 et 3)
        if (!slide.usePhoto && slide.icon != null)
          Center(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: slide.iconColor!.withValues(alpha: 0.15),
                border: Border.all(
                    color: slide.iconColor!.withValues(alpha: 0.4), width: 2),
              ),
              child: Icon(slide.icon, size: 80, color: slide.iconColor),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.05, 1.05),
                  duration: 2000.ms,
                  curve: Curves.easeInOut,
                ),
          ),

        // Textes (centrés verticalement vers le bas)
        Positioned(
          left: 32,
          right: 32,
          bottom: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                slide.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  shadows: [
                    Shadow(
                        blurRadius: 20,
                        color: Colors.black54,
                        offset: Offset(0, 2))
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 16),
              Text(
                slide.description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: 16,
                  height: 1.55,
                  shadows: const [
                    Shadow(blurRadius: 10, color: Colors.black45)
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 400.ms)
                  .slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ],
    );
  }
}
