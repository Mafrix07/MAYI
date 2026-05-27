import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  Future<void> _handleReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _message = "Veuillez entrer votre email.");
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      // Simulation ou appel API réel selon votre backend
      final response = await ApiService.post('/auth/password-reset/', {'email': email});
      
      if (response.statusCode == 200) {
        setState(() {
          _isSuccess = true;
          _message = "Un email de réinitialisation a été envoyé à $email";
        });
      } else {
        setState(() {
          _isSuccess = false;
          _message = "Erreur : Impossible de trouver un compte avec cet email.";
        });
      }
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _message = "Erreur réseau. Veuillez réessayer plus tard.";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pas de panique ! 🛡️',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Entrez votre adresse email pour recevoir un lien de réinitialisation.',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 40),
            CustomTextField(
              controller: _emailController,
              label: 'Votre Email',
              hint: 'exemple@mail.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 30),
            if (_message != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: _isSuccess ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(color: _isSuccess ? Colors.green : Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            CustomButton(
              text: _isSuccess ? 'Retour au Login' : 'Envoyer le lien',
              onPressed: _isSuccess ? () => Navigator.pop(context) : _handleReset,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
