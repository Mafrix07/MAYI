import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/theme_colors.dart';
import '../../services/api_service.dart';
import '../../widgets/common/glass_card.dart';

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;
  String _filter = 'TOUS';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get('/services/');
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        List<dynamic> list = data is List ? data : data['results'] ?? [];
        setState(() {
          _services = list.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _toggle(Map<String, dynamic> service) async {
    final res =
        await ApiService.patch('/admin/services/${service['id']}/toggle/', {});
    if (!mounted) return;
    if (res.statusCode == 200) {
      final updated = jsonDecode(res.body);
      setState(() {
        final idx =
            _services.indexWhere((s) => s['id'] == service['id']);
        if (idx != -1) _services[idx]['est_actif'] = updated['est_actif'];
      });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    switch (_filter) {
      case 'ACTIFS':
        return _services.where((s) => s['est_actif'] == true).toList();
      case 'INACTIFS':
        return _services.where((s) => s['est_actif'] == false).toList();
      default:
        return _services;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return NatureBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Services (${_services.length})',
              style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.bold, color: context.primaryText)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: context.primaryText),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: ['TOUS', 'ACTIFS', 'INACTIFS'].map((f) {
                  final selected = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(f,
                          style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : context.secondaryText,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      selected: selected,
                      onSelected: (_) => setState(() => _filter = f),
                      backgroundColor: AppColors.glassFill,
                      selectedColor: AppColors.secondary,
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      side: BorderSide(
                          color: selected
                              ? AppColors.secondary
                              : AppColors.glassBorder),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.secondary))
                  : filtered.isEmpty
                      ? Center(
                          child: Text('Aucun service',
                              style:
                                  TextStyle(color: context.secondaryText)))
                      : RefreshIndicator(
                          color: AppColors.secondary,
                          backgroundColor: AppColors.backgroundCard,
                          onRefresh: _load,
                          child: ListView.separated(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 20),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) => _ServiceTile(
                                service: filtered[i],
                                onToggle: () => _toggle(filtered[i])),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final Map<String, dynamic> service;
  final VoidCallback onToggle;

  const _ServiceTile({required this.service, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isActive = service['est_actif'] == true;
    final pro = service['professionnel'];
    final ownerName = pro?['nom_entreprise'] ?? pro?['username'] ?? '?';

    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isActive
                  ? AppColors.secondary.withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.1),
            ),
            child: Icon(Icons.storefront_rounded,
                color: isActive ? AppColors.secondary : Colors.grey,
                size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service['nom'] ?? '',
                    style: TextStyle(
                        color: context.primaryText,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(ownerName,
                    style: TextStyle(
                        color: context.secondaryText, fontSize: 11)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.withValues(alpha: 0.12)
                            : Colors.grey.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(isActive ? 'Actif' : 'Inactif',
                          style: TextStyle(
                              color:
                                  isActive ? Colors.green : Colors.grey,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 6),
                    Text('${service['prix'] ?? ''} FCFA',
                        style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggle,
            icon: Icon(
              isActive
                  ? Icons.pause_circle_outline_rounded
                  : Icons.play_circle_outline_rounded,
              color: isActive ? Colors.orange : Colors.green,
              size: 28,
            ),
            tooltip: isActive ? 'Désactiver' : 'Activer',
          ),
        ],
      ),
    );
  }
}
