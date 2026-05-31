import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/glass_field.dart';
import '../../widgets/common/glass_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ── Champs communs ─────────────────────────────────────────────────────────
  final _firstNameCtrl       = TextEditingController();
  final _lastNameCtrl        = TextEditingController();
  final _emailCtrl           = TextEditingController();
  final _phoneCtrl           = TextEditingController();
  final _usernameCtrl        = TextEditingController();
  final _passwordCtrl        = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  // ── Champs Pro uniquement ──────────────────────────────────────────────────
  final _nomEtablissementCtrl  = TextEditingController();
  final _adresseCtrl           = TextEditingController();
  final _descriptionCtrl       = TextEditingController();
  final _siteWebCtrl           = TextEditingController();

  String  _selectedRole   = 'TOURISTE';
  bool    _acceptTerms    = false;
  bool    _isLoading      = false;
  bool    _obscurePass    = true;
  bool    _obscureConfirm = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _nomEtablissementCtrl.dispose();
    _adresseCtrl.dispose();
    _descriptionCtrl.dispose();
    _siteWebCtrl.dispose();
    super.dispose();
  }

  // ── Validation & envoi ─────────────────────────────────────────────────────
  Future<void> _handleRegister() async {
    final isPro = _selectedRole == 'PROFESSIONNEL';

    if (_firstNameCtrl.text.trim().isEmpty ||
        _lastNameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _usernameCtrl.text.trim().isEmpty ||
        _passwordCtrl.text.isEmpty) {
      setState(() => _errorMessage = 'Veuillez remplir tous les champs obligatoires.');
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailCtrl.text.trim())) {
      setState(() => _errorMessage = 'Email invalide.');
      return;
    }
    if (_passwordCtrl.text.length < 6) {
      setState(() => _errorMessage = 'Mot de passe trop court (6 caractères min).');
      return;
    }
    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      setState(() => _errorMessage = 'Les mots de passe ne correspondent pas.');
      return;
    }
    if (isPro && _nomEtablissementCtrl.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Le nom de l\'établissement est obligatoire.');
      return;
    }
    if (!_acceptTerms) {
      setState(() => _errorMessage = 'Veuillez accepter les conditions générales.');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    final body = <String, dynamic>{
      'username':         _usernameCtrl.text.trim(),
      'email':            _emailCtrl.text.trim(),
      'password':         _passwordCtrl.text,
      'password_confirm': _confirmPasswordCtrl.text,
      'first_name':       _firstNameCtrl.text.trim(),
      'last_name':        _lastNameCtrl.text.trim(),
      'telephone':        _phoneCtrl.text.trim(),
      'role':             _selectedRole,
      // Champs Pro (vides pour les touristes, ignorés par le backend)
      if (isPro) 'nom_etablissement':         _nomEtablissementCtrl.text.trim(),
      if (isPro) 'adresse_etablissement':     _adresseCtrl.text.trim(),
      if (isPro) 'description_etablissement': _descriptionCtrl.text.trim(),
      if (isPro) 'site_web':                  _siteWebCtrl.text.trim(),
    };

    final auth    = context.read<AuthProvider>();
    final success = await auth.register(body);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          isPro
              ? 'Compte professionnel créé ! Connectez-vous 🎉'
              : 'Compte créé ! Connectez-vous 🎉',
          style: GoogleFonts.poppins(color: AppColors.background),
        ),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      Navigator.pop(context);
    } else {
      setState(() => _errorMessage = auth.errorMessage);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isPro = _selectedRole == 'PROFESSIONNEL';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fond image
          Image.asset(
            'assets/images/monument_1.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: AppColors.background),
          ),
          // Overlay
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF071A0B).withValues(alpha: 0.5),
                  const Color(0xFF071A0B).withValues(alpha: 0.80),
                  const Color(0xFF071A0B).withValues(alpha: 0.97),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // ── Bouton retour ────────────────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Logo ─────────────────────────────────────────────
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondary
                                      .withValues(alpha: 0.4),
                                  blurRadius: 50,
                                  spreadRadius: 14,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.secondary
                                    .withValues(alpha: 0.6),
                                width: 1.6,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.cover,
                                alignment: const Alignment(0, -0.35),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Togo Tourism',
                        style: GoogleFonts.playfairDisplay(
                          color: AppColors.secondary.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .scale(
                          begin: const Offset(0.7, 0.7),
                          duration: 600.ms,
                          curve: Curves.elasticOut)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 16),

                  Text(
                    'Rejoignez l\'aventure',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                  const SizedBox(height: 4),
                  Text(
                    'Créez votre compte Mayi',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500),
                  ).animate().fadeIn(delay: 350.ms),

                  const SizedBox(height: 24),

                  // ── Card glassmorphisme ───────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF071A0B)
                              .withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color:
                                AppColors.secondary.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Sélecteur de rôle ───────────────────────
                            Text('Type de compte',
                                style: GoogleFonts.poppins(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _RoleCard(
                                    label: 'Touriste',
                                    icon: Icons.explore_outlined,
                                    subtitle: 'Je voyage',
                                    isSelected:
                                        _selectedRole == 'TOURISTE',
                                    onTap: () => setState(
                                        () => _selectedRole = 'TOURISTE'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _RoleCard(
                                    label: 'Professionnel',
                                    icon:
                                        Icons.business_center_outlined,
                                    subtitle: 'Je propose',
                                    isSelected:
                                        _selectedRole == 'PROFESSIONNEL',
                                    onTap: () => setState(() =>
                                        _selectedRole = 'PROFESSIONNEL'),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ── Champs communs ───────────────────────────
                            Text('Informations personnelles',
                                style: GoogleFonts.poppins(
                                    color: AppColors.secondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5)),
                            const SizedBox(height: 10),

                            Row(
                              children: [
                                Expanded(
                                  child: GlassField(
                                    controller: _firstNameCtrl,
                                    hint: 'Prénom',
                                    icon: Icons.person_outline_rounded,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GlassField(
                                    controller: _lastNameCtrl,
                                    hint: 'Nom',
                                    icon: Icons.person_outline_rounded,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            GlassField(
                              controller: _usernameCtrl,
                              hint: 'Nom d\'utilisateur',
                              icon: Icons.alternate_email_rounded,
                            ),
                            const SizedBox(height: 10),
                            GlassField(
                              controller: _emailCtrl,
                              hint: 'Email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 10),
                            GlassField(
                              controller: _phoneCtrl,
                              hint: 'Téléphone (+228...)',
                              icon: Icons.phone_android_outlined,
                              keyboardType: TextInputType.phone,
                            ),

                            // ── Champs Pro (conditionnels) ───────────────
                            AnimatedSize(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                              child: isPro
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            const Icon(
                                                Icons.business_outlined,
                                                color: AppColors.secondary,
                                                size: 16),
                                            const SizedBox(width: 6),
                                            Text(
                                                'Informations de l\'établissement',
                                                style: GoogleFonts.poppins(
                                                    color:
                                                        AppColors.secondary,
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    letterSpacing: 0.5)),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        _ProField(
                                          controller:
                                              _nomEtablissementCtrl,
                                          hint:
                                              'Nom de l\'établissement *',
                                          icon: Icons.storefront_outlined,
                                          required: true,
                                        ),
                                        const SizedBox(height: 10),
                                        _ProField(
                                          controller: _adresseCtrl,
                                          hint: 'Adresse (Ex: Lomé, Togo)',
                                          icon:
                                              Icons.location_on_outlined,
                                        ),
                                        const SizedBox(height: 10),
                                        _ProField(
                                          controller: _descriptionCtrl,
                                          hint:
                                              'Description de votre établissement...',
                                          icon:
                                              Icons.description_outlined,
                                          maxLines: 3,
                                        ),
                                        const SizedBox(height: 10),
                                        _ProField(
                                          controller: _siteWebCtrl,
                                          hint: 'Site web (optionnel)',
                                          icon: Icons.language_outlined,
                                          keyboardType: TextInputType.url,
                                        ),
                                        const SizedBox(height: 4),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 4, top: 6),
                                          child: Text(
                                            '* Champ obligatoire',
                                            style: TextStyle(
                                                color: AppColors.secondary
                                                    .withValues(alpha: 0.7),
                                                fontSize: 10),
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ),

                            const SizedBox(height: 20),

                            // ── Mot de passe ─────────────────────────────
                            Text('Sécurité',
                                style: GoogleFonts.poppins(
                                    color: AppColors.secondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5)),
                            const SizedBox(height: 10),
                            GlassField(
                              controller: _passwordCtrl,
                              hint: 'Mot de passe',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePass,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePass
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePass = !_obscurePass),
                              ),
                            ),
                            const SizedBox(height: 6),
                            _PasswordStrengthBar(
                                password: _passwordCtrl.text),
                            const SizedBox(height: 10),
                            GlassField(
                              controller: _confirmPasswordCtrl,
                              hint: 'Confirmer le mot de passe',
                              icon: Icons.lock_clock_outlined,
                              obscureText: _obscureConfirm,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () => setState(() =>
                                    _obscureConfirm = !_obscureConfirm),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ── CGU ──────────────────────────────────────
                            GestureDetector(
                              onTap: () => setState(
                                  () => _acceptTerms = !_acceptTerms),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(6),
                                      color: _acceptTerms
                                          ? AppColors.secondary
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: _acceptTerms
                                            ? AppColors.secondary
                                            : Colors.white
                                                .withValues(alpha: 0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: _acceptTerms
                                        ? const Icon(Icons.check,
                                            color: AppColors.background,
                                            size: 14)
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'J\'accepte les conditions générales',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ── Erreur ────────────────────────────────────
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 12),
                              GlassCard(
                                borderRadius: 10,
                                fillColor:
                                    Colors.red.withValues(alpha: 0.12),
                                borderColor: Colors.redAccent
                                    .withValues(alpha: 0.4),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: Colors.redAccent, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // ── Bouton ────────────────────────────────────
                            CustomButton(
                              text: isPro
                                  ? 'Créer mon compte Pro'
                                  : 'Créer mon compte',
                              onPressed: _handleRegister,
                              isLoading: _isLoading,
                              gradient: AppColors.goldGradient,
                              textColor: AppColors.background,
                            ),

                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.white
                                        .withValues(alpha: 0.15),
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Text(
                                    'Mayi Togo Tourism',
                                    style: GoogleFonts.playfairDisplay(
                                      color: AppColors.secondary
                                          .withValues(alpha: 0.6),
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.white
                                        .withValues(alpha: 0.15),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 450.ms, duration: 600.ms)
                      .slideY(
                          begin: 0.3,
                          end: 0,
                          delay: 450.ms,
                          duration: 600.ms,
                          curve: Curves.easeOutCubic),

                  const SizedBox(height: 24),

                  // ── Lien connexion ────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Déjà membre ? ',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Se connecter',
                          style: GoogleFonts.poppins(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 750.ms),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Carte sélection de rôle ────────────────────────────────────────────────
class _RoleCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.15),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected
                    ? AppColors.secondary
                    : AppColors.textSecondary,
                size: 26),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 13)),
            Text(subtitle,
                style: TextStyle(
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.textHint,
                    fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// ── Champ formulaire Pro (style cohérent avec GlassField) ─────────────────
class _ProField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType keyboardType;
  final bool required;

  const _ProField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: required
                ? AppColors.secondary.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.15)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.secondary, size: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ── Barre de force du mot de passe ─────────────────────────────────────────
class _PasswordStrengthBar extends StatelessWidget {
  final String password;
  const _PasswordStrengthBar({required this.password});

  ({double factor, Color color, String label}) get _strength {
    if (password.isEmpty) return (factor: 0.0, color: Colors.white24, label: '');
    final hasUpper   = password.contains(RegExp(r'[A-Z]'));
    final hasDigit   = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#\$&*~%^()_\-+=<>?]'));
    final len = password.length;
    if (len < 6)  return (factor: 0.25, color: Colors.redAccent,   label: 'Faible');
    if (len < 9)  return (factor: 0.5,  color: Colors.orange,      label: 'Moyen');
    if (hasUpper && hasDigit && hasSpecial) {
      return (factor: 1.0, color: AppColors.secondary, label: 'Fort');
    }
    return (factor: 0.75, color: Colors.lightGreen, label: 'Bon');
  }

  @override
  Widget build(BuildContext context) {
    final s = _strength;
    return Row(
      children: [
        Text('Force : ',
            style: TextStyle(
                fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: s.factor,
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(s.color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 38,
          child: Text(s.label,
              style: TextStyle(
                  fontSize: 10,
                  color: s.color,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
