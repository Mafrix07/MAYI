import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  String? _errorMessage;
  bool _acceptTerms = false;
  bool _isLoading = false;

  void _handleRegister() async {
  // Vérifications de base
  if (!_acceptTerms) {
    setState(() => _errorMessage = 'Veuillez accepter les conditions.');
    return;
  }
  if (_passwordController.text != _confirmPasswordController.text) {
    setState(() => _errorMessage = 'Les mots de passe ne correspondent pas.');
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  final auth = context.read<AuthProvider>();
  final success = await auth.register({
    'username':         _usernameController.text.trim(),
    'email':            _emailController.text.trim(),
    'password':         _passwordController.text,
    'password_confirm': _confirmPasswordController.text,
    'first_name':       _firstNameController.text.trim(),
    'last_name':        _lastNameController.text.trim(),
    'telephone':        _phoneController.text.trim(),
    'role':             'TOURISTE',
  });

  if (!mounted) return;

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compte créé avec succès ! Connectez-vous.'),
        backgroundColor: Color(0xFF1A6B3C),
      ),
    );
    Navigator.pop(context); // Retour vers Login
  } else {
    setState(() => _errorMessage = 'Erreur lors de la création du compte.');
  }

  setState(() => _isLoading = false);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Hero(
                tag: 'logo',
                child: Image.asset('assets/images/logo.png', height: 100),
              ),
              const SizedBox(height: 20),
              Text(
                'Rejoignez l\'aventure',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 30),
              
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _firstNameController,
                      label: 'Prénom',
                      hint: 'Koffi',
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _lastNameController,
                      label: 'Nom',
                      hint: 'HOUNDJO',
                      icon: Icons.person_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                  controller: _usernameController,
                  label: 'Nom d\'utilisateur',
                  hint: 'ex: username',
                  icon: Icons.alternate_email,
                ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'votre@email.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'Téléphone',
                hint: '+228 00 00 00 00',
                icon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                label: 'Mot de passe',
                hint: '********',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Confirmation',
                hint: '********',
                icon: Icons.lock_clock_outlined,
                isPassword: true,
              ),
              
              const SizedBox(height: 20),
              
              // Barre de force du mot de passe (UI simulée)
              Row(
                children: [
                  const Text('Force du mot de passe: '),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.7,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Fort', style: TextStyle(color: Colors.green, fontSize: 12)),
                ],
              ),
              
              const SizedBox(height: 20),
              
              CheckboxListTile(
                value: _acceptTerms,
                onChanged: (val) => setState(() => _acceptTerms = val!),
                title: const Text(
                  'J\'accepte les conditions générales d\'utilisation',
                  style: TextStyle(fontSize: 12),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
              
              const SizedBox(height: 30),
              // Ajouter juste avant CustomButton
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              CustomButton(
                text: 'Créer mon compte',
                onPressed: _handleRegister,
                isLoading: _isLoading,
              ),
              
              const SizedBox(height: 20),
              
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(color: AppColors.textSecondary),
                    children: const [
                      TextSpan(text: 'Déjà membre ? '),
                      TextSpan(
                        text: 'Se connecter',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
        ),
      ),
    );
  }
}
