import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/theme_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/api_service.dart';
import '../../../services/reservation_service.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../widgets/common/glass_card.dart';

class ProfilProScreen extends StatefulWidget {
  const ProfilProScreen({super.key});

  @override
  State<ProfilProScreen> createState() => _ProfilProScreenState();
}

class _ProfilProScreenState extends State<ProfilProScreen> {
  int _nbServices = 0;
  int _nbReservationsMois = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStats());
  }

  Future<void> _loadStats() async {
    final auth = context.read<AuthProvider>();
    final profilId = auth.user?.profilProfessionnel?['id'];
    try {
      final servicesRes = await ApiService.get(
          profilId != null ? '/services/?professionnel=$profilId' : '/services/');
      int nbServices = 0;
      if (servicesRes.statusCode == 200) {
        final data = jsonDecode(servicesRes.body);
        final results = data is Map ? (data['results'] as List?) ?? [] : data as List;
        nbServices = results.length;
      }

      final reservations = await ReservationService.getReservationsRecues();
      final now = DateTime.now();
      final nbMois = reservations.where((r) {
        final dateStr = r['date_creation'] as String?;
        if (dateStr == null) return false;
        final date = DateTime.tryParse(dateStr);
        return date != null && date.year == now.year && date.month == now.month;
      }).length;

      if (mounted) {
        setState(() {
          _nbServices = nbServices;
          _nbReservationsMois = nbMois;
        });
      }
    } catch (_) {}
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Déconnexion', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text('Souhaitez-vous vous déconnecter de votre espace pro ?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text('Déconnexion', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, AuthProvider auth) {
    final firstNameController = TextEditingController(text: auth.user?.firstName);
    final lastNameController = TextEditingController(text: auth.user?.lastName);
    final phoneController = TextEditingController(text: auth.user?.telephone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 24, right: 24, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: context.hintText, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('Modifier infos pro', style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: context.primaryText)),
            const SizedBox(height: 24),
            CustomTextField(controller: firstNameController, label: 'Prénom', hint: 'Prénom pro', icon: Icons.person_outline),
            const SizedBox(height: 16),
            CustomTextField(controller: lastNameController, label: 'Nom', hint: 'Nom pro', icon: Icons.person_outline),
            const SizedBox(height: 16),
            CustomTextField(controller: phoneController, label: 'Téléphone pro', hint: '+228...', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Enregistrer les modifications',
              onPressed: () async {
                final success = await auth.updateProfile(
                  firstName: firstNameController.text.trim(),
                  lastName: lastNameController.text.trim(),
                  phone: phoneController.text.trim(),
                );
                if (success && context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final user = auth.user;
        final initials = "${user?.firstName?[0] ?? ''}${user?.lastName?[0] ?? ''}".toUpperCase();

        return NatureBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text('Mon Profil Pro', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: context.primaryText)),
              backgroundColor: Colors.transparent,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              elevation: 0,
              centerTitle: true,
            ),
            body: RefreshIndicator(
              color: AppColors.secondary,
              backgroundColor: AppColors.backgroundCard,
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Avatar section
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final xFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
                          if (xFile != null) await auth.uploadProfilePhoto(xFile);
                        },
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: AppColors.backgroundCard,
                              child: ClipOval(
                                child: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                                  ? CachedNetworkImage(
                                      imageUrl: user.photoUrl!,
                                      width: 120, height: 120, fit: BoxFit.cover,
                                      placeholder: (context, url) => Text(initials, style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
                                      errorWidget: (context, url, error) => Text(initials, style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
                                    )
                                  : Text(initials, style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                                child: const Icon(Icons.camera_alt, color: AppColors.background, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                        style: GoogleFonts.playfairDisplay(color: context.primaryText, fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3))),
                      child: Text('COMPTE PROFESSIONNEL', style: TextStyle(color: context.primaryText, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ),

                    const SizedBox(height: 32),

                    // Stats row
                    Row(
                      children: [
                        _buildStatCard(context, 'Services', '$_nbServices actif${_nbServices > 1 ? 's' : ''}', Icons.storefront_rounded),
                        const SizedBox(width: 16),
                        _buildStatCard(context, 'Réservations', '$_nbReservationsMois ce mois', Icons.calendar_today_rounded),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Menu
                    GlassCard(
                      borderRadius: 28,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          _buildTile(context, icon: Icons.storefront, title: 'Mes services', onTap: () => Navigator.pushNamed(context, '/pro/mes-services')),
                          _buildTile(context, icon: Icons.calendar_month, title: 'Réservations reçues', onTap: () => Navigator.pushNamed(context, '/pro/reservations')),
                          _buildTile(context, icon: Icons.edit_note, title: 'Modifier mes informations', onTap: () => _showEditSheet(context, auth)),
                          Consumer<ThemeProvider>(
                            builder: (context, themeProvider, _) => _buildTile(
                              context,
                              icon: themeProvider.isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
                              title: themeProvider.isDark ? 'Passer en mode clair' : 'Passer en mode sombre',
                              onTap: themeProvider.toggle,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            child: Divider(color: context.hintText.withValues(alpha: 0.3)),
                          ),
                          _buildTile(context, icon: Icons.logout, title: 'Déconnexion pro', color: Colors.redAccent, onTap: () => _showLogoutDialog(context)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    return Expanded(
      child: GlassCard(
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.secondary, size: 24),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: context.secondaryText, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: context.primaryText, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: (color ?? AppColors.secondary).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color ?? AppColors.secondary, size: 20),
      ),
      title: Text(title, style: TextStyle(color: color ?? context.primaryText, fontWeight: FontWeight.bold, fontSize: 15)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: context.hintText),
    );
  }
}
