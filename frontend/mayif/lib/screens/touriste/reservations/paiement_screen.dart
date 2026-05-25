import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/reservation_service.dart';
import '../../../widgets/common/custom_button.dart';

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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text('Réservation envoyée !',
                  style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Votre paiement est en cours de vérification. Vous recevrez une confirmation sous 24h.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
                child: const Text('Retour à l\'accueil',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    } else {
      setState(() =>
          _errorMessage = 'Erreur lors de l\'envoi. Réessayez.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Montant
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('Acompte à payer',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.montantAcompte.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(widget.serviceTitre,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Méthode de paiement
            const Text('Méthode de paiement',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            Row(
              children: ['T-Money', 'Flooz'].map((method) {
                final selected = _methodePaiement == method;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _methodePaiement = method),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.white,
                        border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : Colors.grey[300]!,
                            width: selected ? 2 : 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone_android,
                              color: selected
                                  ? AppColors.primary
                                  : Colors.grey),
                          const SizedBox(width: 8),
                          Text(method,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.info_outline,
                        color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Text('Instructions $_methodePaiement',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700])),
                  ]),
                  const SizedBox(height: 8),
                  Text(
                    _methodePaiement == 'T-Money'
                        ? '1. Composez *145# sur votre téléphone\n2. Choisissez "Paiement de facture"\n3. Entrez le numéro : 90 00 00 00\n4. Montant : ${widget.montantAcompte.toStringAsFixed(0)} FCFA\n5. Prenez une capture écran de la confirmation'
                        : '1. Composez *160# sur votre téléphone\n2. Choisissez "Paiement marchand"\n3. Entrez le code : MAYI2024\n4. Montant : ${widget.montantAcompte.toStringAsFixed(0)} FCFA\n5. Prenez une capture écran de la confirmation',
                    style: const TextStyle(fontSize: 13, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Upload capture écran
            const Text('Capture écran du paiement',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: _captureEcranFile != null ? 200 : 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: _captureEcranFile != null
                          ? AppColors.primary
                          : Colors.grey[300]!,
                      style: BorderStyle.solid,
                      width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _captureEcranFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: kIsWeb 
                          ? Image.network(_captureEcranFile!.path, fit: BoxFit.cover)
                          : Image.asset(_captureEcranFile!.path, fit: BoxFit.cover), // Pour mobile
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 40, color: AppColors.primary),
                          SizedBox(height: 8),
                          Text('Appuyer pour ajouter la capture',
                              style: TextStyle(
                                  color: AppColors.textSecondary)),
                        ],
                      ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center),
            ],
            const SizedBox(height: 24),

            CustomButton(
              text: 'Confirmer le paiement',
              onPressed: _submit,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
