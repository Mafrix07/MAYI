import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/theme_colors.dart';
import '../../../services/reservation_service.dart';
import '../../../widgets/common/glass_card.dart';
import '../../../widgets/common/custom_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MesReservationsScreen extends StatefulWidget {
  const MesReservationsScreen({super.key});

  @override
  State<MesReservationsScreen> createState() => _MesReservationsScreenState();
}

class _MesReservationsScreenState extends State<MesReservationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() => _isLoading = true);
    final data = await ReservationService.getMesReservations();
    if (!mounted) return;
    setState(() {
      _reservations = data;
      _isLoading = false;
    });
  }

  List<dynamic> _filtered(String statut) =>
      _reservations.where((r) => r['statut'] == statut).toList();

  @override
  Widget build(BuildContext context) {
    return NatureBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Mes Réservations', 
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: context.primaryText)),
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.secondary,
            indicatorWeight: 3,
            labelColor: AppColors.secondary,
            unselectedLabelColor: context.hintText,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'En attente'),
              Tab(text: 'Confirmées'),
              Tab(text: 'Annulées'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
            : RefreshIndicator(
                color: AppColors.secondary,
                backgroundColor: AppColors.backgroundCard,
                onRefresh: _loadReservations,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ReservationList(
                        reservations: _filtered('EN_ATTENTE'),
                        onAnnuler: _annuler,
                        onModifier: _modifier),
                    _ReservationList(
                        reservations: _filtered('CONFIRMEE'),
                        onAnnuler: _annuler),
                    _ReservationList(
                        reservations: _filtered('ANNULEE'),
                        onAnnuler: null),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _annuler(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Annuler la réservation', style: TextStyle(color: Colors.white)),
        content: Text('Voulez-vous vraiment annuler cette réservation ?', style: TextStyle(color: context.secondaryText)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Non', style: TextStyle(color: Colors.white60))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Oui', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
        ],
      ),
    );
    if (confirm == true) {
      final success = await ReservationService.annuler(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Réservation annulée'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating),
        );
        _loadReservations();
      }
    }
  }

  Future<void> _modifier(dynamic res) async {
    final id = res['id'];
    DateTime? debut = DateTime.tryParse(res['date_debut'] ?? '');
    DateTime? fin = DateTime.tryParse(res['date_fin'] ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ModifierDatesSheet(
        initialDebut: debut,
        initialFin: fin,
        onSave: (newDebut, newFin) async {
          final nav = Navigator.of(ctx);
          final messenger = ScaffoldMessenger.of(context);
          final success = await ReservationService.modifierDates(
            id,
            debut: DateFormat('yyyy-MM-dd').format(newDebut),
            fin: newFin != null ? DateFormat('yyyy-MM-dd').format(newFin) : null,
          );
          if (success) {
            if (!mounted) return;
            nav.pop();
            messenger.showSnackBar(
              const SnackBar(content: Text('Réservation modifiée ✅'), backgroundColor: AppColors.primary),
            );
            _loadReservations();
          } else if (mounted) {
            messenger.showSnackBar(
              const SnackBar(content: Text('Erreur lors de la modification'), backgroundColor: Colors.redAccent),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _ReservationList extends StatelessWidget {
  final List<dynamic> reservations;
  final Function(int)? onAnnuler;
  final Function(dynamic)? onModifier;

  const _ReservationList(
      {required this.reservations, required this.onAnnuler, this.onModifier});

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 80, color: Colors.white12),
            SizedBox(height: 16),
            Text('Aucune réservation ici',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: reservations.length,
      itemBuilder: (context, i) {
        final r = reservations[i];
        return _ReservationTicket(
          reservation: r, 
          onAnnuler: onAnnuler,
          onModifier: onModifier,
        );
      },
    );
  }
}

class _ReservationTicket extends StatelessWidget {
  final dynamic reservation;
  final Function(int)? onAnnuler;
  final Function(dynamic)? onModifier;

  const _ReservationTicket({required this.reservation, required this.onAnnuler, this.onModifier});

  Color _statutColor(String statut) {
    switch (statut) {
      case 'CONFIRMEE': return AppColors.primaryLight;
      case 'EN_ATTENTE': return Colors.orange;
      case 'ANNULEE': return Colors.redAccent;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statut = reservation['statut'] ?? '';
    final id = reservation['id'];
    final color = _statutColor(statut);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GlassCard(
        borderRadius: 24,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Partie Haute (Header Ticket)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: Icon(Icons.confirmation_number_outlined, color: color, size: 24),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reservation['service_titre'] ?? 'Service #${reservation['service']}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: context.primaryText),
                        ),
                        Text('Réf: #MAYI-$id', style: TextStyle(color: context.hintText, fontSize: 12)),
                      ],
                    ),
                  ),
                  _StatusBadge(statut: statut, color: color),
                ],
              ),
            ),

            // Ligne de découpe (Ticket style)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: List.generate(
                  30,
                  (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 1,
                      color: index.isEven ? AppColors.glassBorder.withValues(alpha: 0.3) : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),

            // Partie Basse (Infos)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _InfoItem(label: 'DATE DÉBUT', value: reservation['date_debut'] ?? ''),
                      _InfoItem(label: 'DATE FIN', value: reservation['date_fin'] ?? 'N/A'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TOTAL PAYÉ', style: TextStyle(color: context.secondaryText, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            '${reservation['montant_acompte'] ?? ''} FCFA',
                            style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ],
                      ),
                      if (statut == 'EN_ATTENTE')
                        Row(
                          children: [
                            if (onModifier != null)
                              TextButton.icon(
                                onPressed: () => onModifier!(reservation),
                                icon: const Icon(Icons.edit_calendar_outlined, size: 14, color: AppColors.secondary),
                                label: const Text('Modifier', style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            if (onAnnuler != null)
                              TextButton(
                                onPressed: () => onAnnuler!(id),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: Colors.redAccent, width: 1),
                                  ),
                                ),
                                child: const Text('Annuler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String statut;
  final Color color;
  const _StatusBadge({required this.statut, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        statut.replaceAll('_', ' '),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: context.secondaryText, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.primaryText)),
      ],
    );
  }
}

class _ModifierDatesSheet extends StatefulWidget {
  final DateTime? initialDebut;
  final DateTime? initialFin;
  final Function(DateTime, DateTime?) onSave;

  const _ModifierDatesSheet({this.initialDebut, this.initialFin, required this.onSave});

  @override
  State<_ModifierDatesSheet> createState() => _ModifierDatesSheetState();
}

class _ModifierDatesSheetState extends State<_ModifierDatesSheet> {
  late DateTime _debut;
  DateTime? _fin;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _debut = widget.initialDebut ?? DateTime.now().add(const Duration(days: 1));
    _fin = widget.initialFin;
  }

  Future<void> _pickDate(bool isDebut) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDebut ? _debut : (_fin ?? _debut.add(const Duration(days: 1))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isDebut) {
          _debut = picked;
          if (_fin != null && _fin!.isBefore(_debut)) _fin = null;
        } else {
          _fin = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.midBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.glassBorder, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Text('Modifier la réservation', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: context.primaryText)),
          const SizedBox(height: 32),
          _DateTile(label: 'Nouvelle date de début', date: _debut, onTap: () => _pickDate(true)),
          const SizedBox(height: 16),
          _DateTile(label: 'Nouvelle date de fin (optionnel)', date: _fin, onTap: () => _pickDate(false)),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Enregistrer',
            isLoading: _isSaving,
            onPressed: () async {
              setState(() => _isSaving = true);
              await widget.onSave(_debut, _fin);
              if (mounted) setState(() => _isSaving = false);
            },
          ),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateTile({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: AppColors.secondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: context.secondaryText, fontSize: 11)),
                  Text(date != null ? DateFormat('dd MMMM yyyy').format(date!) : 'Choisir une date', 
                      style: TextStyle(color: context.primaryText, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
