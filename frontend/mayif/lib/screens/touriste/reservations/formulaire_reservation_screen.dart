import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/theme_colors.dart';
import '../../../services/reservation_service.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/glass_card.dart';
import 'paiement_screen.dart';

class FormulaireReservationScreen extends StatefulWidget {
  final int serviceId;
  final String serviceTitre;
  final double montantAcompte;
  final String? serviceCategorie;

  const FormulaireReservationScreen({
    super.key,
    required this.serviceId,
    required this.serviceTitre,
    required this.montantAcompte,
    this.serviceCategorie,
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
  TimeOfDay? _heureArrivee;
  int _nombrePersonnes = 1;
  bool _isLoading = false;
  String? _errorMessage;

  final _dateFormat = DateFormat('dd/MM/yyyy');

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _heureArrivee ?? TimeOfDay.now(),
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
    if (picked != null) setState(() => _heureArrivee = picked);
  }

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
        if (_heureArrivee != null)
          'heure_arrivee':
              '${_heureArrivee!.hour.toString().padLeft(2, '0')}:${_heureArrivee!.minute.toString().padLeft(2, '0')}:00',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NatureBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Réserver', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: context.primaryText)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: context.primaryText),
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
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: context.primaryText)),
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

                Text('Détails du séjour', style: GoogleFonts.playfairDisplay(color: context.primaryText, fontSize: 22, fontWeight: FontWeight.bold)),
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

                      Text('Nombre de voyageurs',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.primaryText)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.secondary.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () { if (_nombrePersonnes > 1) setState(() => _nombrePersonnes--); },
                              icon: const Icon(Icons.remove_circle_outline, color: AppColors.secondary),
                            ),
                            Text('$_nombrePersonnes',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.primaryText)),
                            IconButton(
                              onPressed: () => setState(() => _nombrePersonnes++),
                              icon: const Icon(Icons.add_circle_outline, color: AppColors.secondary),
                            ),
                          ],
                        ),
                      ),

                      if (widget.serviceCategorie == 'SNACK') ...[
                        const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.white10)),
                        Text('Heure d\'arrivée estimée',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.primaryText)),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _pickTime,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.secondary.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _heureArrivee != null ? AppColors.secondary : AppColors.glassBorder, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time_rounded, color: _heureArrivee != null ? AppColors.secondary : context.hintText, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  _heureArrivee != null ? _heureArrivee!.format(context) : 'Sélectionner l\'heure',
                                  style: TextStyle(color: _heureArrivee != null ? context.primaryText : context.hintText, fontWeight: _heureArrivee != null ? FontWeight.bold : FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                      const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: AppColors.glassBorder)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.secondaryText)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickDate(isDebut),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.secondary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: date != null ? AppColors.secondary : AppColors.glassBorder, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: date != null ? AppColors.secondary : context.hintText, size: 20),
                const SizedBox(width: 12),
                Text(
                  date != null ? _dateFormat.format(date) : 'Choisir une date',
                  style: TextStyle(color: date != null ? context.primaryText : context.hintText, fontWeight: date != null ? FontWeight.bold : FontWeight.normal),
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
          Text(label, style: TextStyle(color: context.secondaryText, fontSize: 13)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color ?? context.primaryText, fontSize: isBold ? 16 : 14)),
        ],
      ),
    );
  }
}
