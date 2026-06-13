import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/theme_colors.dart';
import '../../services/reservation_service.dart';
import '../../widgets/common/glass_card.dart';

class DashboardProScreen extends StatefulWidget {
  const DashboardProScreen({super.key});

  @override
  State<DashboardProScreen> createState() => _DashboardProScreenState();
}

class _DashboardProScreenState extends State<DashboardProScreen> {
  int _enAttente = 0;
  int _confirmees = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final reservations = await ReservationService.getReservationsRecues();
      if (!mounted) return;
      setState(() {
        _enAttente = reservations
            .where((r) =>
                r['statut'] == 'EN_ATTENTE' ||
                r['statut'] == 'ACOMPTE_EN_VERIFICATION')
            .length;
        _confirmees =
            reservations.where((r) => r['statut'] == 'CONFIRMEE').length;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NatureBackground(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Header Premium ────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: AppColors.backgroundMid,
              elevation: 0,
              title: Text('Espace Professionnel',
                  style: GoogleFonts.playfairDisplay(
                      fontWeight: FontWeight.bold,
                      color: context.primaryText)),
              actions: [
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) => IconButton(
                    tooltip: themeProvider.isDark ? 'Mode clair' : 'Mode sombre',
                    icon: Icon(
                      themeProvider.isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
                      color: AppColors.secondary,
                    ),
                    onPressed: themeProvider.toggle,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.logout, color: context.secondaryText),
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.background, AppColors.backgroundMid],
                        ),
                      ),
                    ),
                    // Orb décoratif
                    Positioned(
                      top: -40,
                      right: -60,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              AppColors.secondary.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 100, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${user?.firstName ?? ''} ${user?.lastName ?? user?.username ?? ''} 👋',
                            style: GoogleFonts.playfairDisplay(
                              color: context.primaryText,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Établissement : ${(() { final n = (user?.profilProfessionnel?['nom_entreprise'] as String?)?.trim(); return (n != null && n.isNotEmpty) ? n : 'Non renseigné'; })()}',
                            style: TextStyle(
                                color: context.secondaryText, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Contenu ───────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: RefreshIndicator(
                color: AppColors.secondary,
                backgroundColor: AppColors.backgroundCard,
                onRefresh: _loadStats,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Barre de stats ────────────────────────────────────
                      Text('Performance',
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: context.primaryText)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                              child: _StatTile(
                            label: 'En attente',
                            value: '$_enAttente',
                            color: Colors.orange,
                            icon: Icons.hourglass_empty_rounded,
                          )),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _StatTile(
                            label: 'Confirmées',
                            value: '$_confirmees',
                            color: AppColors.primaryLight,
                            icon: Icons.check_circle_rounded,
                          )),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _StatTile(
                            label: 'Revenus (Est.)',
                            value: '${(_confirmees * 15000) / 1000}k',
                            color: AppColors.secondary,
                            icon: Icons.payments_outlined,
                          )),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ── Grille d'actions ───────────────────────────────────
                      Text('Gestion',
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: context.primaryText)),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.95,
                        children: [
                          _DashboardActionCard(
                            icon: Icons.add_business_rounded,
                            title: 'Mes Services',
                            subtitle: 'Publier & Modifier',
                            color: AppColors.primary,
                            onTap: () => Navigator.pushNamed(
                                context, '/pro/mes-services'),
                          ),
                          _DashboardActionCard(
                            icon: Icons.receipt_long_rounded,
                            title: 'Réservations',
                            subtitle: '$_enAttente nouvelles demandes',
                            color: Colors.orange,
                            badge: _enAttente > 0 ? '$_enAttente' : null,
                            onTap: () => Navigator.pushNamed(
                                context, '/pro/reservations'),
                          ),
                          _DashboardActionCard(
                            icon: Icons.reviews_rounded,
                            title: 'Avis Clients',
                            subtitle: 'Répondre aux avis',
                            color: Colors.blue,
                            onTap: () =>
                                Navigator.pushNamed(context, '/pro/avis'),
                          ),
                          _DashboardActionCard(
                            icon: Icons.manage_accounts_rounded,
                            title: 'Paramètres',
                            subtitle: 'Profil & Entreprise',
                            color: Colors.deepPurple,
                            onTap: () =>
                                Navigator.pushNamed(context, '/pro/profil'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatTile(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.secondary, size: 20),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.primaryText)),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
                fontSize: 10,
                color: context.secondaryText,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DashboardActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  const _DashboardActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 24,
      onTap: onTap,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: context.primaryText),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                      color: context.secondaryText,
                      fontSize: 11,
                      height: 1.2),
                ),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.red.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
