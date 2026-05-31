import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/reservation_service.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../widgets/common/glass_card.dart';
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
          colorScheme: const ColorScheme.dark(
            primary: AppColors.secondary,
            onPrimary: AppColors.background,
            surface: AppColors.backgroundCard,
            onSurface: Colors.white,
          ),
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

    try {
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
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Une erreur est survenue : $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NatureBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Réserver', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Recap (Glass)
                GlassCard(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.hotel_outlined, color: AppColors.secondary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.serviceTitre,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(
                                'Acompte : ${widget.montantAcompte.toStringAsFixed(0)} FCFA',
                                style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Text('Détails du séjour', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Main Form (Glass)
                GlassCard(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDatePicker('Date de début', _dateDebut, true),
                      const SizedBox(height: 20),
                      _buildDatePicker('Date de fin (optionnel)', _dateFin, false),
                      const SizedBox(height: 32),

                      const Text('Nombre de voyageurs',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () { if (_nombrePersonnes > 1) setState(() => _nombrePersonnes--); },
                              icon: const Icon(Icons.remove_circle_outline, color: AppColors.secondary),
                            ),
                            Text('$_nombrePersonnes',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                            IconButton(
                              onPressed: () => setState(() => _nombrePersonnes++),
                              icon: const Icon(Icons.add_circle_outline, color: AppColors.secondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Final Recap
                GlassCard(
                  borderRadius: 20,
                  fillColor: AppColors.primary.withValues(alpha: 0.2),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _RecapRow('Nombre de personnes', '$_nombrePersonnes'),
                      if (_dateDebut != null) _RecapRow('Arrivée', _dateFormat.format(_dateDebut!)),
                      if (_dateFin != null) _RecapRow('Départ', _dateFormat.format(_dateFin!)),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Colors.white10)),
                      _RecapRow(
                        'Total Acompte',
                        '${widget.montantAcompte.toStringAsFixed(0)} FCFA',
                        isBold: true,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Valider la réservation',
                  onPressed: _submit,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, bool isDebut) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickDate(isDebut),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: date != null ? AppColors.secondary : Colors.white12, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: date != null ? AppColors.secondary : Colors.white38, size: 20),
                const SizedBox(width: 12),
                Text(
                  date != null ? _dateFormat.format(date) : 'Choisir une date',
                  style: TextStyle(color: date != null ? Colors.white : Colors.white38, fontWeight: date != null ? FontWeight.bold : FontWeight.normal),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RecapRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  const _RecapRow(this.label, this.value, {this.isBold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color ?? Colors.white, fontSize: isBold ? 16 : 14)),
        ],
      ),
    );
  }
}
