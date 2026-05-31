import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../widgets/common/glass_card.dart';
import '../../../core/constants/app_colors.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user == null && auth.isAuthenticated) {
        auth.fetchProfile();
      }
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
        content: const Text('Voulez-vous vraiment vous déconnecter ?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text('Déconnecter', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
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
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 24, right: 24, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('Modifier mon profil', 
                style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),
            CustomTextField(controller: firstNameController, label: 'Prénom', hint: 'Votre prénom', icon: Icons.person_outline),
            const SizedBox(height: 16),
            CustomTextField(controller: lastNameController, label: 'Nom', hint: 'Votre nom', icon: Icons.person_outline),
            const SizedBox(height: 16),
            CustomTextField(controller: phoneController, label: 'Téléphone', hint: '+228...', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Enregistrer',
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

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: AppColors.backgroundMid,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
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
                          color: AppColors.textPrimary)),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('0',
                        style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.glassBorder, height: 1),
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off_outlined,
                        size: 64, color: AppColors.textSecondary),
                    SizedBox(height: 16),
                    Text('Aucune notification pour le moment',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Vous serez alerté des confirmations\nde réservation ici.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.textHint, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpCenter(BuildContext context) {
    const faqs = [
      ('Comment réserver un service ?',
          'Depuis la page d\'accueil ou la recherche, sélectionnez un service, appuyez sur "Réserver maintenant" et remplissez le formulaire.'),
      ('Comment payer l\'acompte ?',
          'Après la réservation, vous serez redirigé vers la page de paiement. Suivez les instructions pour valider votre acompte.'),
      ('Comment annuler ma réservation ?',
          'Rendez-vous dans "Mes Réservations", sélectionnez la réservation "En attente" et appuyez sur "Annuler".'),
      ('Puis-je modifier ma réservation ?',
          'Les modifications ne sont pas disponibles. Annulez et créez une nouvelle réservation si nécessaire.'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: AppColors.backgroundMid,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Centre d\'aide',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('Réponses aux questions fréquentes',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 24),
              ...faqs.map((faq) => _FaqTile(question: faq.$1, answer: faq.$2)),
              const SizedBox(height: 24),
              const Divider(color: AppColors.glassBorder),
              const SizedBox(height: 16),
              const Text('Contacter le support',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              const SizedBox(height: 12),
              _ContactRow(
                  icon: Icons.email_outlined,
                  label: 'support@mayitogo.com'),
              const SizedBox(height: 8),
              _ContactRow(
                  icon: Icons.phone_outlined,
                  label: '+228 90 00 00 00'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(BuildContext context, AuthProvider auth) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final success = await auth.uploadProfilePhoto(image);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo mise à jour !'), backgroundColor: AppColors.primary),
        );
      }
    }
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
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text('Profil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              centerTitle: true,
              leading: Navigator.canPop(context) 
                ? IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.pop(context))
                : null,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Avatar Premium
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5), width: 3),
                          boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 20, offset: const Offset(0, 10))],
                        ),
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: AppColors.backgroundCard,
                          child: ClipOval(
                            child: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty) 
                              ? CachedNetworkImage(
                                  imageUrl: user.photoUrl!,
                                  width: 130, height: 130, fit: BoxFit.cover,
                                  placeholder: (context, url) => Text(initials, style: const TextStyle(fontSize: 45, color: Colors.white, fontWeight: FontWeight.bold)),
                                  errorWidget: (context, url, error) => Text(initials, style: const TextStyle(fontSize: 45, color: Colors.white, fontWeight: FontWeight.bold)),
                                )
                              : Text(initials, style: const TextStyle(fontSize: 45, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _pickAndUploadImage(context, auth),
                          child: GlassCard(
                            borderRadius: 20,
                            padding: const EdgeInsets.all(8),
                            fillColor: AppColors.secondary,
                            child: const Icon(Icons.camera_alt, color: AppColors.background, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${user?.firstName ?? ''} ${user?.lastName ?? ''}', 
                    style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '', 
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                  const SizedBox(height: 40),

                  // Menu Card (Full Glass)
                  GlassCard(
                    borderRadius: 28,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        _buildMenuTile(
                          icon: Icons.person_outline_rounded,
                          title: 'Détails du compte',
                          subtitle: 'Modifier vos informations',
                          onTap: () => _showEditSheet(context, auth),
                        ),
                        _buildMenuTile(
                          icon: Icons.confirmation_number_outlined,
                          title: 'Réservations',
                          subtitle: 'Historique et tickets',
                          onTap: () => Navigator.pushNamed(context, '/reservations'),
                        ),
                        _buildMenuTile(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifications',
                          subtitle: 'Alertes et messages',
                          onTap: () => _showNotifications(context),
                        ),
                        _buildMenuTile(
                          icon: Icons.help_outline_rounded,
                          title: 'Centre d\'aide',
                          subtitle: 'Support client 24/7',
                          onTap: () => _showHelpCenter(context),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          child: Divider(color: Colors.white10),
                        ),
                        _buildMenuTile(
                          icon: Icons.logout_rounded,
                          title: 'Déconnexion',
                          subtitle: 'À bientôt au Togo !',
                          color: Colors.redAccent,
                          onTap: () => _showLogoutDialog(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (color ?? AppColors.primary).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: color ?? AppColors.secondary, size: 24),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white24),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _expanded = !_expanded),
            title: Text(widget.question,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            trailing: Icon(
              _expanded ? Icons.expand_less : Icons.expand_more,
              color: AppColors.secondary,
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(widget.answer,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.5)),
            ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ContactRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.secondary, size: 18),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14)),
      ],
    );
  }
}
