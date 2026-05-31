import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/reservation_service.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/glass_card.dart';

class PaiementScreen extends StatefulWidget {
  final int reservationId;
  final double montantAcompte;
  final String serviceTitre;

  const PaiementScreen({
    super.key,
    required this.reservationId,
    required this.montantAcompte,
    required this.serviceTitre,
  });

  @override
  State<PaiementScreen> createState() => _PaiementScreenState();
}

class _PaiementScreenState extends State<PaiementScreen> {
  XFile? _captureEcranFile;
  bool _isLoading = false;
  String? _errorMessage;
  String _methodePaiement = 'T-Money';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _captureEcranFile = picked);
  }

  Future<void> _submit() async {
    if (_captureEcranFile == null) {
      setState(() =>
          _errorMessage = 'Veuillez ajouter la capture écran du paiement');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await ReservationService.uploadProof(
        widget.reservationId, _captureEcranFile!);
    setState(() => _isLoading = false);
    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.backgroundMid,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle,
                  color: AppColors.primaryLight, size: 80),
              const SizedBox(height: 20),
              Text('Réservation envoyée !',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              const Text(
                'Votre paiement est en cours de vérification.\nVous recevrez une confirmation sous 24h.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Retour à l'accueil",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      setState(() => _errorMessage = "Erreur lors de l'envoi. Réessayez.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Paiement Sécurisé',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // ── Fond image Togo avec fallback ─────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/togo_land.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.backgroundGradient),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withValues(alpha: 0.5)),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Carte montant ──────────────────────────────────────
                  GlassCard(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text('TOTAL À RÉGLER',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(
                          '${widget.montantAcompte.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 32,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(widget.serviceTitre,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text('Choisir votre opérateur',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      _OperatorCard(
                        label: 'T-Money',
                        icon: Icons.account_balance_wallet,
                        color: Colors.amber[700]!,
                        isSelected: _methodePaiement == 'T-Money',
                        onTap: () =>
                            setState(() => _methodePaiement = 'T-Money'),
                      ),
                      const SizedBox(width: 16),
                      _OperatorCard(
                        label: 'Flooz',
                        icon: Icons.payments,
                        color: Colors.blue[400]!,
                        isSelected: _methodePaiement == 'Flooz',
                        onTap: () =>
                            setState(() => _methodePaiement = 'Flooz'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ── Instructions — fond blanc → texte sombre ───────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.info_outline,
                              color: AppColors.primary, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Comment payer avec $_methodePaiement ?',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                // BUG CORRIGÉ : fond blanc → texte sombre
                                color: AppColors.background,
                              ),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        Text(
                          _methodePaiement == 'T-Money'
                              ? '1. Composez *145#\n2. Choisissez "Paiement de facture"\n3. Numéro : 90 00 00 00\n4. Montant : ${widget.montantAcompte.toStringAsFixed(0)} F\n5. Sauvegardez la capture écran'
                              : '1. Composez *160#\n2. Choisissez "Paiement marchand"\n3. Code : MAYI2024\n4. Montant : ${widget.montantAcompte.toStringAsFixed(0)} F\n5. Sauvegardez la capture écran',
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.8,
                            // BUG CORRIGÉ : fond blanc → texte sombre
                            color: AppColors.background,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Upload preuve ──────────────────────────────────────
                  const Text('Preuve de paiement',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _captureEcranFile != null
                              ? AppColors.secondary
                              : Colors.white24,
                          width: 2,
                        ),
                      ),
                      child: _captureEcranFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: kIsWeb
                                  ? Image.network(
                                      _captureEcranFile!.path,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                  Icons.broken_image_outlined,
                                                  color: Colors.white54,
                                                  size: 48),
                                    )
                                  : Image.file(
                                      File(_captureEcranFile!.path),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                  Icons.broken_image_outlined,
                                                  color: Colors.white54,
                                                  size: 48),
                                    ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined,
                                    size: 40, color: Colors.white70),
                                SizedBox(height: 12),
                                Text('Ajouter la capture écran',
                                    style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                    ),
                  ),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(_errorMessage!,
                          style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                    ),

                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Confirmer mon paiement',
                    onPressed: _submit,
                    isLoading: _isLoading,
                    gradient: AppColors.goldGradient,
                    textColor: AppColors.background,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OperatorCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _OperatorCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.secondary : Colors.white24,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                  ]
                : [],
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Colors.white70, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  // BUG CORRIGÉ : fond blanc quand sélectionné → texte sombre
                  color: isSelected ? AppColors.background : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
