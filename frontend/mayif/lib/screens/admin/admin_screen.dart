import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/theme_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/common/glass_card.dart';
import 'admin_users_screen.dart';
import 'admin_services_screen.dart';
import 'admin_reviews_screen.dart';
import 'admin_reservations_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  bool _isOpeningDashboard = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get('/admin/stats/');
      if (!mounted) return;
      if (res.statusCode == 200) {
        setState(() {
          _stats = jsonDecode(res.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _ouvrirDashboard() async {
    setState(() => _isOpeningDashboard = true);
    try {
      final codeResponse = await ApiService.post('/auth/dashboard-code/', {});
      if (!mounted) return;
      if (codeResponse.statusCode == 200) {
        final data = jsonDecode(codeResponse.body);
        final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
        final url = Uri.parse('$baseUrl/dashboard/auto-login/?code=${data['code']}');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isOpeningDashboard = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return NatureBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Administration',
              style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.bold, color: context.primaryText)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
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
        ),
        body: RefreshIndicator(
          color: AppColors.secondary,
          backgroundColor: AppColors.backgroundCard,
          onRefresh: _loadStats,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                GlassCard(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.secondary.withValues(alpha: 0.15),
                          border: Border.all(
                              color: AppColors.secondary.withValues(alpha: 0.4)),
                        ),
                        child: const Icon(Icons.admin_panel_settings_rounded,
                            color: AppColors.secondary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${user?.firstName ?? ''} ${user?.lastName ?? user?.username ?? ''}',
                              style: GoogleFonts.playfairDisplay(
                                  color: context.primaryText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.secondary.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                user?.role == 'ADMIN' ? 'ADMINISTRATEUR' : 'SUPPORT',
                                style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Text('Vue d\'ensemble',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.primaryText)),
                const SizedBox(height: 16),

                // KPIs
                _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(
                              color: AppColors.secondary),
                        ),
                      )
                    : Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _KpiTile(
                                  label: 'Utilisateurs',
                                  value: '${_stats?['total_users'] ?? 0}',
                                  icon: Icons.people_rounded,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _KpiTile(
                                  label: 'Services actifs',
                                  value: '${_stats?['total_services'] ?? 0}',
                                  icon: Icons.storefront_rounded,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _KpiTile(
                                  label: 'Réserv. ce mois',
                                  value: '${_stats?['reservations_ce_mois'] ?? 0}',
                                  icon: Icons.calendar_month_rounded,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _KpiTile(
                                  label: 'Avis signalés',
                                  value: '${_stats?['avis_signales'] ?? 0}',
                                  icon: Icons.flag_rounded,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          if ((_stats?['services_signales'] ?? 0) > 0) ...[
                            const SizedBox(height: 12),
                            GlassCard(
                              borderRadius: 16,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.warning_amber_rounded,
                                        color: Colors.redAccent, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${_stats?['services_signales']} service(s) signalé(s) en attente de modération',
                                      style: TextStyle(
                                          color: context.primaryText,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),

                const SizedBox(height: 32),

                Text('Gestion',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.primaryText)),
                const SizedBox(height: 16),

                // Grille navigation
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    _NavCard(
                      icon: Icons.people_rounded,
                      label: 'Utilisateurs',
                      color: AppColors.primary,
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const AdminUsersScreen())),
                    ),
                    _NavCard(
                      icon: Icons.storefront_rounded,
                      label: 'Services',
                      color: AppColors.secondary,
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const AdminServicesScreen())),
                    ),
                    _NavCard(
                      icon: Icons.reviews_rounded,
                      label: 'Avis',
                      color: Colors.blue,
                      badge: (_stats?['avis_signales'] ?? 0) > 0
                          ? '${_stats!['avis_signales']}'
                          : null,
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const AdminReviewsScreen())),
                    ),
                    _NavCard(
                      icon: Icons.receipt_long_rounded,
                      label: 'Réservations',
                      color: Colors.deepPurple,
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const AdminReservationsScreen())),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Bouton dashboard web
                GlassCard(
                  borderRadius: 20,
                  onTap: _isOpeningDashboard ? null : _ouvrirDashboard,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.secondary, AppColors.accent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: _isOpeningDashboard
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.open_in_browser_rounded,
                                  color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dashboard Web',
                                  style: TextStyle(
                                      color: context.primaryText,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              Text('Ouvrir dans le navigateur',
                                  style: TextStyle(
                                      color: context.secondaryText,
                                      fontSize: 11)),
                            ],
                          ),
                        ),
                        Icon(Icons.open_in_new_rounded,
                            color: AppColors.secondary, size: 18),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  const _NavCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 20,
      onTap: onTap,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Text(label,
                    style: TextStyle(
                        color: context.primaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: context.secondaryText, size: 12),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(badge!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: context.primaryText)),
          const SizedBox(height: 2),
          Text(label,
              style:
                  TextStyle(color: context.secondaryText, fontSize: 12)),
        ],
      ),
    );
  }
}
