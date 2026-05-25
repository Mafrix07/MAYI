import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/reservation_service.dart';
import '../../../widgets/common/custom_button.dart';
import 'paiement_screen.dart';

class FormulaireReservationScreen extends StatefulWidget {
  final int serviceId;
  final String serviceTitre;
  final double montantAcompte;

  const FormulaireReservationScreen({
    super.key,
    required this.serviceId,
    required this.serviceTitre,
    required this.montantAcompte,
  });

  @override
  State<FormulaireReservationScreen> createState() =>
      _FormulaireReservationScreenState();
}

class _FormulaireReservationScreenState
    extends State<FormulaireReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _dateDebut;
  DateTime? _dateFin;
  int _nombrePersonnes = 1;
  bool _isLoading = false;
  String? _errorMessage;

  final _dateFormat = DateFormat('dd/MM/yyyy');

  Future<void> _pickDate(bool isDebut) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isDebut) {
          _dateDebut = picked;
          if (_dateFin != null && _dateFin!.isBefore(_dateDebut!)) {
            _dateFin = null;
          }
        } else {
          _dateFin = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateDebut == null) {
      setState(() => _errorMessage = 'Veuillez sélectionner une date de début');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final reservationId = await ReservationService.create({
      'service': widget.serviceId,
      'date_debut': DateFormat('yyyy-MM-dd').format(_dateDebut!),
      if (_dateFin != null)
        'date_fin': DateFormat('yyyy-MM-dd').format(_dateFin!),
      'nombre_personnes': _nombrePersonnes,
    });

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (reservationId != null) {
      // Passer à l'écran de paiement
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaiementScreen(
            reservationId: reservationId,
            montantAcompte: widget.montantAcompte,
            serviceTitre: widget.serviceTitre,
          ),
        ),
      );
    } else {
      setState(
          () => _errorMessage = 'Erreur lors de la réservation. Réessayez.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réserver'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre du service
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.store, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.serviceTitre,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                              'Acompte : ${widget.montantAcompte.toStringAsFixed(0)} FCFA',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Date de début
              const Text('Date de début',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _pickDate(true),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: _dateDebut != null
                            ? AppColors.primary
                            : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        _dateDebut != null
                            ? _dateFormat.format(_dateDebut!)
                            : 'Sélectionner une date',
                        style: TextStyle(
                            color: _dateDebut != null
                                ? AppColors.textPrimary
                                : Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date de fin (optionnelle)
              const Text('Date de fin (optionnel)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _pickDate(false),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: _dateFin != null
                            ? AppColors.primary
                            : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        _dateFin != null
                            ? _dateFormat.format(_dateFin!)
                            : 'Sélectionner une date de fin',
                        style: TextStyle(
                            color: _dateFin != null
                                ? AppColors.textPrimary
                                : Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Nombre de personnes
              const Text('Nombre de personnes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.people_outline, color: AppColors.primary),
                    IconButton(
                      onPressed: () {
                        if (_nombrePersonnes > 1) {
                          setState(() => _nombrePersonnes--);
                        }
                      },
                      icon: const Icon(Icons.remove_circle_outline,
                          color: AppColors.primary),
                    ),
                    Text('$_nombrePersonnes',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () => setState(() => _nombrePersonnes++),
                      icon: const Icon(Icons.add_circle_outline,
                          color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Récapitulatif
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    _RecapRow('Personnes', '$_nombrePersonnes'),
                    if (_dateDebut != null)
                      _RecapRow('Début', _dateFormat.format(_dateDebut!)),
                    if (_dateFin != null)
                      _RecapRow('Fin', _dateFormat.format(_dateFin!)),
                    const Divider(),
                    _RecapRow(
                      'Acompte à payer',
                      '${widget.montantAcompte.toStringAsFixed(0)} FCFA',
                      isBold: true,
                      color: AppColors.primary,
                    ),
                  ],
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
                text: 'Continuer vers le paiement',
                onPressed: _submit,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecapRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  const _RecapRow(this.label, this.value,
      {this.isBold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.textSecondary)),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: color ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}
