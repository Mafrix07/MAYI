import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';

class ProfilProScreen extends StatelessWidget {
  const ProfilProScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Souhaitez-vous vous déconnecter de votre espace pro ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Modifier infos pro', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            CustomTextField(controller: firstNameController, label: 'Prénom', hint: 'Prénom pro', icon: Icons.person_outline),
            const SizedBox(height: 15),
            CustomTextField(controller: lastNameController, label: 'Nom', hint: 'Nom pro', icon: Icons.person_outline),
            const SizedBox(height: 15),
            CustomTextField(controller: phoneController, label: 'Téléphone pro', hint: '+228...', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
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

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mon Profil Pro'),
            backgroundColor: const Color(0xFF006B3F),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF006B3F),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                  ),
                  padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white24,
                        child: ClipOval(
                          child: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                            ? CachedNetworkImage(
                                imageUrl: user.photoUrl!,
                                width: 100, height: 100, fit: BoxFit.cover,
                                placeholder: (context, url) => Text(initials, style: const TextStyle(fontSize: 30, color: Colors.white)),
                                errorWidget: (context, url, error) => Text(initials, style: const TextStyle(fontSize: 30, color: Colors.white)),
                              )
                            : Text(initials, style: const TextStyle(fontSize: 30, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text('${user?.firstName ?? ''} ${user?.lastName ?? ''}', 
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                        child: const Text('COMPTE PROFESSIONNEL', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      _buildStatCard('Services', '5 actifs', Colors.orange),
                      const SizedBox(width: 15),
                      _buildStatCard('Réservations', '12 ce mois', Colors.blue),
                    ],
                  ),
                ),
                _buildTile(icon: Icons.storefront, title: 'Mes services', onTap: () => Navigator.pushNamed(context, '/pro/mes-services')),
                _buildTile(icon: Icons.calendar_month, title: 'Réservations reçues', onTap: () => Navigator.pushNamed(context, '/pro/reservations')),
                _buildTile(icon: Icons.edit_note, title: 'Modifier mes informations', onTap: () => _showEditSheet(context, auth)),
                _buildTile(icon: Icons.settings_outlined, title: 'Paramètres du compte', onTap: () {}),
                const Divider(indent: 70),
                _buildTile(icon: Icons.logout, title: 'Déconnexion pro', color: Colors.red, onTap: () => _showLogoutDialog(context)),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 5),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildTile({required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF006B3F)),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
