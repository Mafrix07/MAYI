import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../services/api_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/theme_colors.dart';
import '../../widgets/home/hero_banner.dart';
import '../../widgets/home/service_card.dart';
import '../../widgets/common/glass_card.dart';
import '../touriste/profil/profil_screen.dart';
import '../services/service_detail_screen.dart';
import '../recherche/search_screen.dart';
import '../favoris/favoris_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? _searchCategory;

  List<Widget> get _pages => [
    HomeContent(
      onTabChange: (index, {String? categorie}) => setState(() {
        _currentIndex = index;
        if (categorie != null) _searchCategory = categorie;
      }),
    ),
    SearchScreen(key: ValueKey(_searchCategory), initialCategory: _searchCategory),
    const FavorisScreen(),
    const ProfilScreen(),
  ];

  static const _navItems = [
    (Icons.home_filled,    Icons.home_outlined,     'Accueil'),
    (Icons.explore,        Icons.explore_outlined,   'Explorer'),
    (Icons.favorite,       Icons.favorite_border,    'Favoris'),
    (Icons.person,         Icons.person_outline,     'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: GlassCard(
          borderRadius: 30,
          fillColor: AppColors.glassFillMed,
          blurStrength: 24,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (i) {
              final item = _navItems[i];
              final sel  = _currentIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: sel
                      ? BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.secondary, AppColors.accent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        )
                      : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        sel ? item.$1 : item.$2,
                        color: sel ? Colors.white : context.secondaryText,
                        size: 22,
                      ),
                      if (sel) ...[
                        const SizedBox(width: 6),
                        Text(
                          item.$3,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Contenu principal ──────────────────────────────────────────────────────
class HomeContent extends StatefulWidget {
  final Function(int, {String? categorie}) onTabChange;
  const HomeContent({super.key, required this.onTabChange});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final ScrollController _scrollController = ScrollController();
  
  // Tâche 7: Notifications
  int _notifCount = 0;
  List<dynamic> _notifications = [];

  static const _categories = [
    (Icons.hotel_outlined,           'Hôtels',      Color(0xFF1A8FDB), 'HEBERGEMENT'),
    (Icons.restaurant_menu_outlined,  'Restos',      Color(0xFFE85D04), 'SNACK'),
    (Icons.hiking_outlined,           'Activités',   Color(0xFF2ECC71), 'ACTIVITE'),
    (Icons.directions_car_outlined,   'Transport',   Color(0xFF9B59B6), 'TRANSPORT'),
    (Icons.event_outlined,            'Événements',  Color(0xFFFF6B6B), null),
    (Icons.map_outlined,              'Carte',       Color(0xFF1DB97A), null),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user == null && auth.isAuthenticated) {
        auth.fetchProfile();
      }
      final sp = context.read<ServiceProvider>();
      sp.fetchServices();
      sp.fetchTopRated();
      sp.fetchActivities();
      _loadNotifications();
    });
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

  Future<void> _loadNotifications() async {
    try {
      final res = await ApiService.get('/notifications/');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (!mounted) return;
        setState(() {
          _notifications = data is List ? data : (data['results'] ?? []);
          _notifCount = _notifications.length;
        });
      }
    } catch (_) {}
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: context.midBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text('Notifications',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: context.primaryText)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('$_notifCount',
                        style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.glassBorder, height: 1),
            Expanded(
              child: _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off_outlined,
                              size: 64, color: context.secondaryText),
                          const SizedBox(height: 16),
                          Text('Aucune notification pour le moment',
                              style: TextStyle(
                                  color: context.secondaryText, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(
                            'Vous serez alerté des confirmations\nde réservation ici.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: context.hintText, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: _notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, i) {
                        final n = _notifications[i];
                        return GlassCard(
                          borderRadius: 16,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.info_outline, color: AppColors.secondary, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(n['titre'] ?? 'Notification', style: TextStyle(color: context.primaryText, fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text(n['message'] ?? '', style: TextStyle(color: context.secondaryText, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
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

  void _onCategoryTap(int index) {
    final cat = _categories[index];
    if (cat.$4 == null) {
      Navigator.pushNamed(
          context, index == 4 ? '/events' : '/explore-map');
    } else {
      widget.onTabChange(1, categorie: cat.$4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth    = context.watch<AuthProvider>();
    final hour    = DateTime.now().hour;
    final greeting = hour < 12 ? 'Bonjour' : hour < 18 ? 'Bonsoir' : 'Bonne soirée';
    final firstName = auth.user?.firstName?.isNotEmpty == true
        ? auth.user!.firstName!
        : 'Voyageur';

    return NatureBackground(
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.secondary,
          backgroundColor: AppColors.backgroundCard,
          onRefresh: () => context.read<ServiceProvider>().refresh(),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // ── Header ────────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$greeting 👋',
                              style: TextStyle(
                                color: context.secondaryText,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              firstName,
                              style: GoogleFonts.playfairDisplay(
                                color: context.primaryText,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Pill localisation
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/explore-map'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppColors.secondary
                                          .withValues(alpha: 0.30)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.location_on_rounded,
                                        color: AppColors.secondary, size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      'Lomé · Togo 🇹🇬',
                                      style: TextStyle(
                                        color: AppColors.secondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.15),
                      ),

                      // Notification bell
                      GestureDetector(
                        onTap: _showNotifications,
                        child: GlassCard(
                          borderRadius: 14,
                          padding: const EdgeInsets.all(12),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(Icons.notifications_outlined,
                                  color: context.primaryText, size: 24),
                              if (_notifCount > 0)
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                    child: Text('$_notifCount', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Barre de recherche glass ──────────────────────────
                  GestureDetector(
                    onTap: () => widget.onTabChange(1), // Change d'onglet via le callback
                    child: GlassCard(
                      borderRadius: 18,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.search,
                              color: AppColors.secondary, size: 22),
                          const SizedBox(width: 12),
                          Text(
                            'Hôtel, restaurant, activité...',
                            style: TextStyle(
                              color: context.hintText,
                              fontSize: 15,
                            ),
                          ),
                          const Spacer(),
                          GlassCard(
                            borderRadius: 10,
                            padding: const EdgeInsets.all(6),
                            fillColor: AppColors.secondary.withValues(alpha: 0.15),
                            borderColor: AppColors.secondary.withValues(alpha: 0.4),
                            child: const Icon(Icons.tune,
                                color: AppColors.secondary, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.15),

                  const SizedBox(height: 24),

                  // ── Catégories avec icônes ────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(_categories.length, (i) {
                        final cat = _categories[i];
                        return GestureDetector(
                          onTap: () => _onCategoryTap(i),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      cat.$3,
                                      cat.$3.withValues(alpha: 0.55),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: cat.$3.withValues(alpha: 0.30),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Icon(cat.$1, color: Colors.white, size: 24),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                cat.$2,
                                style: TextStyle(
                                  color: context.secondaryText,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: (i * 60 + 200).ms).slideY(begin: 0.2);
                      }),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Hero Banner (images des services réels) ───────────
                  Consumer<ServiceProvider>(
                    builder: (context, sp, _) => HeroBanner(
                      services: sp.topRatedServices,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms)
                      .slideY(begin: 0.1),

                  const SizedBox(height: 32),

                  // ── Populaires ────────────────────────────────────────
                  _SectionTitle(
                    title: 'Populaires',
                    onTap: () => widget.onTabChange(1),
                  ).animate().fadeIn(delay: 350.ms),
                  const SizedBox(height: 14),

                  Consumer<ServiceProvider>(
                    builder: (context, sp, _) {
                      if (sp.isLoading && sp.services.isEmpty) {
                        return _ServicesShimmer();
                      }
                      if (sp.hasError && sp.services.isEmpty) {
                        return _ErrorWidget(
                          message: sp.errorMessage ?? 'Erreur de connexion',
                          onRetry: () => sp.fetchServices(),
                        );
                      }
                      if (sp.services.isEmpty) {
                        return const _EmptyWidget(
                            message: 'Aucun service disponible');
                      }
                      return SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          itemCount:
                              sp.services.length + (sp.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == sp.services.length) {
                              return const Center(
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              );
                            }
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ServiceDetailScreen(
                                      service: sp.services[index]),
                                ),
                              ),
                              child: SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.44,
                                child: ServiceCard(service: sp.services[index]),
                              ),
                            ).animate()
                                .fadeIn(delay: (index * 60).ms)
                                .slideX(begin: 0.1);
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // ── Mieux notés ───────────────────────────────────────
                  _SectionTitle(
                    title: 'Les mieux notés',
                    onTap: () => widget.onTabChange(1),
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 14),

                  Consumer<ServiceProvider>(
                    builder: (context, sp, _) {
                      if (sp.isTopRatedLoading &&
                          sp.topRatedServices.isEmpty) {
                        return _ServicesShimmer();
                      }
                      if (sp.topRatedServices.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          itemCount: sp.topRatedServices.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ServiceDetailScreen(
                                      service: sp.topRatedServices[index]),
                                ),
                              ),
                              child: SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.44,
                                child: ServiceCard(
                                    service: sp.topRatedServices[index]),
                              ),
                            ).animate()
                                .fadeIn(delay: (index * 60).ms)
                                .slideX(begin: 0.1);
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // ── Activités (données réelles API) ───────────────────
                  _SectionTitle(
                    title: 'Activités',
                    onTap: () => widget.onTabChange(1),
                  ).animate().fadeIn(delay: 450.ms),
                  const SizedBox(height: 14),

                  Consumer<ServiceProvider>(
                    builder: (context, sp, _) {
                      if (sp.isActivitiesLoading && sp.activityServices.isEmpty) {
                        return _ServicesShimmer();
                      }
                      if (sp.activityServices.isEmpty) {
                        return const _EmptyWidget(
                            message: 'Aucune activité disponible pour le moment');
                      }
                      return SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          itemCount: sp.activityServices.length,
                          itemBuilder: (context, index) {
                            final activity = sp.activityServices[index];
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ServiceDetailScreen(service: activity),
                                ),
                              ),
                              child: SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.44,
                                child: ServiceCard(service: activity),
                              ),
                            )
                                .animate()
                                .fadeIn(delay: (index * 80).ms)
                                .slideX(begin: 0.1);
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets partagés ───────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SectionTitle({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Barre accent gradient
        Container(
          width: 4,
          height: 22,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.secondary, AppColors.ocean],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.primaryText,
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: const Row(
            children: [
              Text(
                'Voir tout',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios,
                  color: AppColors.secondary, size: 12),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServicesShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, _) => Shimmer.fromColors(
          baseColor: AppColors.glassFill,
          highlightColor: AppColors.glassFillMed,
          child: Container(
            width: 180,
            margin: const EdgeInsets.only(right: 16, bottom: 8, top: 8),
            decoration: BoxDecoration(
              color: AppColors.glassFill,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.glassBorder),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.wifi_off,
              size: 40, color: context.secondaryText),
          const SizedBox(height: 8),
          Text(message,
              style: TextStyle(color: context.secondaryText),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, color: AppColors.background),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

class _EmptyWidget extends StatelessWidget {
  final String message;
  const _EmptyWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          Icon(Icons.search_off,
              size: 40, color: context.secondaryText),
          const SizedBox(height: 8),
          Text(message,
              style: TextStyle(color: context.secondaryText),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
