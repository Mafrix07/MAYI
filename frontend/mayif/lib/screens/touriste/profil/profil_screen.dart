import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment nous quitter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const Text('Modifier mon profil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              CustomTextField(controller: firstNameController, label: 'Prénom', hint: 'Votre prénom', icon: Icons.person_outline),
              const SizedBox(height: 15),
              CustomTextField(controller: lastNameController, label: 'Nom', hint: 'Votre nom', icon: Icons.person_outline),
              const SizedBox(height: 15),
              CustomTextField(controller: phoneController, label: 'Téléphone', hint: '+228...', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
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
          const SnackBar(content: Text('Photo mise à jour !'), backgroundColor: Colors.green),
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

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mon Profil'),
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
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    children: [
                      Stack(
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
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _pickAndUploadImage(context, auth),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.camera_alt, color: Color(0xFF006B3F), size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text('${user?.firstName ?? ''} ${user?.lastName ?? ''}', 
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(user?.email ?? '', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildTile(
                  icon: Icons.edit_outlined,
                  title: 'Modifier mon profil',
                  onTap: () => _showEditSheet(context, auth),
                ),
                _buildTile(
                  icon: Icons.history,
                  title: 'Mes réservations',
                  onTap: () => Navigator.pushNamed(context, '/reservations'),
                ),
                _buildTile(
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                  onTap: () {},
                ),
                _buildTile(
                  icon: Icons.help_outline,
                  title: 'Aide & Support',
                  onTap: () {},
                ),
                const Divider(indent: 70),
                _buildTile(
                  icon: Icons.logout,
                  title: 'Déconnexion',
                  color: Colors.red,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTile({required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: (color ?? const Color(0xFF006B3F)).withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color ?? const Color(0xFF006B3F)),
      ),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
