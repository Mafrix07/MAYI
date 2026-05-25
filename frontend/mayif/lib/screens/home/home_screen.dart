import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/home/hero_banner.dart';
import '../../widgets/home/destination_card.dart';
import '../../widgets/home/activity_card.dart';
import '../../data/mock_data.dart';
import '../touriste/profil/profil_screen.dart';
import '../touriste/reservations/formulaire_reservation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const Center(child: Text('Exploration')),  // Paola — S2
    const Center(child: Text('Favoris')),       // Paola — S2
    const ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.secondary,
            unselectedItemColor: Colors.white.withValues(alpha: 0.5),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
            ],
          ),
        ),
      ),
      extendBody: true,
    );
  }
}

// ─── Contenu principal de l'accueil ─────────────────────────────────────────
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Charger les services au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchServices();
    });
    // Infinite scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<ServiceProvider>().fetchMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 30),
            const SizedBox(width: 8),
            const Text('Mayi',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FormulaireReservationScreen(
                    serviceId: 1,
                    serviceTitre: "Hôtel de la Paix (TEST)",
                    montantAcompte: 5000,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.bug_report, color: Colors.orange, size: 20),
            label: const Text('Test S2', style: TextStyle(color: Colors.orange)),
          ),
          Consumer<AuthProvider>(
            builder: (context, auth, _) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Badge(
                  label: Text('2'),
                  child: Icon(Icons.notifications_none, color: AppColors.textPrimary),
                ),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => context.read<ServiceProvider>().refresh(),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // ── Barre de recherche ──────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Où voulez-vous aller ?',
                      prefixIcon: Icon(Icons.search, color: AppColors.primary),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const HeroBanner(),
                const SizedBox(height: 32),

                // ── Section Services populaires (API réelle) ────────────
                _SectionTitle(title: 'Populaires', action: 'Voir tout', onTap: () {}),
                const SizedBox(height: 16),
                Consumer<ServiceProvider>(
                  builder: (context, sp, _) {
                    if (sp.isLoading && sp.services.isEmpty) {
                      return _ServicesShimmer();
                    }
                    if (sp.hasError && sp.services.isEmpty) {
                      return _ErrorWidget(
                        message: sp.errorMessage ?? 'Erreur',
                        onRetry: () => sp.fetchServices(),
                      );
                    }
                    if (sp.services.isEmpty) {
                      return const _EmptyWidget(
                        message: 'Aucun service disponible pour le moment',
                      );
                    }
                    return SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: sp.services.length,
                        itemBuilder: (context, index) {
                          final service = sp.services[index];
                          // Adapter Service → Destination pour le widget existant
                          return DestinationCard(
                            destination: Destination(
                              title: service.titre,
                              image: service.imagePrincipale ??
                                  'https://images.pexels.com/photos/338504/pexels-photo-338504.jpeg',
                              category: service.categorie,
                              rating: 4.5,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // ── Section Activités (mock en attendant Paola S2) ──────
                _SectionTitle(title: 'Activités', action: 'Voir tout', onTap: () {}),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: mockActivities.length,
                  itemBuilder: (context, index) {
                    return ActivityCard(activity: mockActivities[index]);
                  },
                ),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Widgets utilitaires ────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onTap;

  const _SectionTitle(
      {required this.title, required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        GestureDetector(
          onTap: onTap,
          child: const Text('Voir tout',
              style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ),
      ],
    );
  }
}

// Shimmer de chargement
class _ServicesShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, _) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 180,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(24)),
          ),
        ),
      ),
    );
  }
}

// État d'erreur
class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(message,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

// État vide
class _EmptyWidget extends StatelessWidget {
  final String message;
  const _EmptyWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(message,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
