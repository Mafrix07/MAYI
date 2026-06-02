import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/theme_colors.dart';
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
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _captureEcranFile = picked);
    }
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
      widget.reservationId,
      _captureEcranFile!,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.backgroundCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: AppColors.primaryLight, size: 80),
              const SizedBox(height: 20),
              Text('Réservation envoyée !',
                  style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              const Text(
                'Votre paiement est en cours de vérification. Vous recevrez une confirmation sous 24h.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Retour à l\'accueil', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      setState(() => _errorMessage = 'Erreur lors de l\'envoi. Réessayez.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NatureBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Paiement Sécurisé', 
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: context.primaryText)),
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Card
              GlassCard(
                borderRadius: 24,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text('TOTAL À RÉGLER', 
                        style: TextStyle(color: context.secondaryText, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(
                      '${widget.montantAcompte.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(color: AppColors.secondary, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(widget.serviceTitre, style: TextStyle(color: context.secondaryText, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Text('Choisir votre opérateur', 
                  style: TextStyle(color: context.primaryText, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),

              // Operator Selector
              Row(
                children: [
                  _OperatorCard(
                    label: 'T-Money',
                    icon: Icons.account_balance_wallet,
                    color: Colors.yellow[700]!,
                    isSelected: _methodePaiement == 'T-Money',
                    onTap: () => setState(() => _methodePaiement = 'T-Money'),
                  ),
                  const SizedBox(width: 16),
                  _OperatorCard(
                    label: 'Flooz',
                    icon: Icons.payments,
                    color: Colors.blue[600]!,
                    isSelected: _methodePaiement == 'Flooz',
                    onTap: () => setState(() => _methodePaiement = 'Flooz'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Instructions (Glass)
              GlassCard(
                borderRadius: 20,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.info_outline, color: AppColors.secondary, size: 22),
                      const SizedBox(width: 10),
                      Text('Instructions $_methodePaiement',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.primaryText)),
                    ]),
                    const SizedBox(height: 12),
                    Text(
                      _methodePaiement == 'T-Money'
                          ? '1. Composez *145#\n2. Choisissez "Paiement de facture"\n3. Numéro : 90 00 00 00\n4. Montant : ${widget.montantAcompte.toStringAsFixed(0)} F\n5. Sauvegardez la capture écran'
                          : '1. Composez *160#\n2. Choisissez "Paiement marchand"\n3. Code : MAYI2024\n4. Montant : ${widget.montantAcompte.toStringAsFixed(0)} F\n5. Sauvegardez la capture écran',
                      style: TextStyle(fontSize: 14, height: 1.8, color: context.secondaryText),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Upload Section
              Text('Preuve de paiement', 
                  style: TextStyle(color: context.primaryText, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.secondary.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _captureEcranFile != null ? AppColors.secondary : AppColors.glassBorder, width: 2),
                  ),
                  child: _captureEcranFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: kIsWeb
                            ? Image.network(_captureEcranFile!.path, fit: BoxFit.cover)
                            : Image.file(File(_captureEcranFile!.path), fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 40, color: context.hintText),
                            const SizedBox(height: 12),
                            Text('Ajouter la capture écran', style: TextStyle(color: context.hintText)),
                          ],
                        ),
                ),
              ),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(_errorMessage!, 
                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
              
              const SizedBox(height: 32),
              CustomButton(
                text: 'Confirmer mon paiement',
                onPressed: _submit,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
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
            color: isSelected ? AppColors.secondary.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? AppColors.secondary : AppColors.glassBorder, width: 2),
            boxShadow: isSelected ? [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 5))] : [],
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : context.hintText, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? context.primaryText : context.hintText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
