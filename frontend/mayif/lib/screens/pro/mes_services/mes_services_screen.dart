import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/theme_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/api_service.dart';
import '../../../models/service.dart';
import '../../../widgets/common/glass_card.dart';
import '../../../widgets/common/custom_button.dart';

class MesServicesScreen extends StatefulWidget {
  const MesServicesScreen({super.key});

  @override
  State<MesServicesScreen> createState() => _MesServicesScreenState();
}

class _MesServicesScreenState extends State<MesServicesScreen> {
  List<Service> _services = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final auth = context.read<AuthProvider>();
    final profilId = auth.user?.profilProfessionnel?['id'];

    try {
      final response = await ApiService.get('/services/');
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>;
        final all = results.map((e) => Service.fromJson(e)).toList();

        final mes = profilId != null
            ? all.where((s) {
                final raw = results.firstWhere(
                  (e) => e['id'] == s.id,
                  orElse: () => <String, dynamic>{},
                );
                return raw['professionnel']?['id'] == profilId;
              }).toList()
            : all;

        setState(() {
          _services = mes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Erreur serveur (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erreur réseau';
        _isLoading = false;
      });
    }
  }

  void _openForm({Service? service}) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => _ServiceFormScreen(service: service)),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return NatureBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Mes Services',
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: context.primaryText)),
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openForm(),
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.background,
          icon: const Icon(Icons.add),
          label: const Text('Ajouter', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.secondary))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off, size: 48, color: Colors.white24),
                        const SizedBox(height: 12),
                        Text(_error!, style: TextStyle(color: context.secondaryText)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                            onPressed: _load,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                            child: const Text('Réessayer')),
                      ],
                    ),
                  )
                : _services.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.store_outlined, size: 64, color: Colors.white12),
                            const SizedBox(height: 16),
                            Text("Aucun service pour l'instant",
                                style: TextStyle(fontSize: 16, color: context.secondaryText)),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => _openForm(),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                              icon: const Icon(Icons.add),
                              label: const Text('Ajouter mon premier service'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.secondary,
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _services.length,
                          itemBuilder: (context, i) => _ServiceTile(
                            service: _services[i],
                            onEdit: () => _openForm(service: _services[i]),
                          ),
                        ),
                      ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final Service service;
  final VoidCallback onEdit;

  const _ServiceTile({required this.service, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 60, height: 60,
                color: AppColors.glassBorder,
                child: service.imagePrincipale != null
                    ? Image.network(service.imagePrincipale!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.store, color: AppColors.secondary))
                    : const Icon(Icons.store, color: AppColors.secondary),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.titre,
                      style: TextStyle(fontWeight: FontWeight.bold, color: context.primaryText, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(service.categorie,
                      style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w600)),
                  Text('${service.prix.toStringAsFixed(0)} FCFA',
                      style: TextStyle(fontSize: 12, color: context.secondaryText)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.secondary, size: 20),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Formulaire Créer / Modifier un service ─────────────────────────────────
class _ServiceFormScreen extends StatefulWidget {
  final Service? service;
  const _ServiceFormScreen({this.service});

  @override
  State<_ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<_ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _prixCtrl;
  late final TextEditingController _adresseCtrl;
  String _typeService = 'HEBERGEMENT';
  bool _isLoading = false;
  String? _error;
  XFile? _photoFile;

  final List<Map<String, String>> _types = [
    {'label': 'Hébergement', 'value': 'HEBERGEMENT'},
    {'label': 'Snack / Resto', 'value': 'SNACK'},
    {'label': 'Activité', 'value': 'ACTIVITE'},
    {'label': 'Transport', 'value': 'TRANSPORT'},
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _nomCtrl = TextEditingController(text: s?.titre);
    _descCtrl = TextEditingController(text: s?.description);
    _prixCtrl = TextEditingController(text: s != null ? s.prix.toStringAsFixed(0) : '');
    _adresseCtrl = TextEditingController(text: s?.ville);
    if (s != null) _typeService = s.categorie;
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _descCtrl.dispose();
    _prixCtrl.dispose();
    _adresseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _photoFile = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });

    final profilId = context.read<AuthProvider>().user?.profilProfessionnel?['id'];
    final body = <String, dynamic>{
      'nom': _nomCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'type_service': _typeService,
      'prix': _prixCtrl.text.trim(),
      'adresse': _adresseCtrl.text.trim(),
      if (widget.service == null && profilId != null) 'professionnel_id': profilId,
    };

    try {
      final response = widget.service == null
          ? await ApiService.post('/services/', body)
          : await ApiService.patch('/services/${widget.service!.id}/', body);

      if (!mounted) return;
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (_photoFile != null) {
          final sid = jsonDecode(response.body)['id'];
          final bytes = await _photoFile!.readAsBytes();
          await ApiService.uploadFile('/services/$sid/photos/', 'image', bytes: bytes, fileName: _photoFile!.name);
        }
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        setState(() { _error = 'Erreur serveur'; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Erreur réseau'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NatureBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.service != null ? 'Modifier' : 'Nouveau service', 
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: context.primaryText)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.pop(context)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type de service', style: TextStyle(color: context.primaryText, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: _types.map((t) {
                    final sel = _typeService == t['value'];
                    return ChoiceChip(
                      label: Text(t['label']!),
                      selected: sel,
                      onSelected: (_) => setState(() => _typeService = t['value']!),
                      selectedColor: AppColors.secondary,
                      backgroundColor: AppColors.secondary.withValues(alpha: 0.06),
                      labelStyle: TextStyle(color: sel ? AppColors.background : context.secondaryText, fontWeight: sel ? FontWeight.bold : FontWeight.normal),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                _buildField(_nomCtrl, 'Nom du service', Icons.storefront),
                const SizedBox(height: 20),
                _buildField(_descCtrl, 'Description', Icons.description, maxLines: 3),
                const SizedBox(height: 20),
                _buildField(_prixCtrl, 'Prix (FCFA)', Icons.payments, keyboardType: TextInputType.number),
                const SizedBox(height: 20),
                _buildField(_adresseCtrl, 'Lieu (Ville)', Icons.location_on),
                const SizedBox(height: 32),
                
                Text('Photo de couverture', style: TextStyle(color: context.primaryText, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickPhoto,
                  child: Container(
                    height: 160, width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _photoFile != null ? AppColors.secondary : AppColors.glassBorder),
                    ),
                    child: _photoFile == null 
                      ? Icon(Icons.add_a_photo_outlined, color: context.hintText, size: 40)
                      : ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(_photoFile!.path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.check, color: AppColors.secondary))),
                  ),
                ),
                if (_error != null) Padding(padding: const EdgeInsets.only(top: 20), child: Text(_error!, style: const TextStyle(color: Colors.redAccent))),
                const SizedBox(height: 40),
                CustomButton(text: 'Enregistrer', onPressed: _submit, isLoading: _isLoading),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: context.secondaryText, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl, maxLines: maxLines, keyboardType: keyboardType,
          style: TextStyle(color: context.primaryText),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.secondary, size: 20),
            filled: true, fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.secondary.withValues(alpha: 0.04),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.secondary)),
          ),
        ),
      ],
    );
  }
}
