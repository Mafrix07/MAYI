import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/api_service.dart';
import '../../../models/service.dart';
import '../../../widgets/common/glass_card.dart';

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
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Mes Services',
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundMid,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: NatureBackground(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.secondary))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off,
                            size: 48, color: AppColors.textSecondary),
                        const SizedBox(height: 12),
                        Text(_error!,
                            style: const TextStyle(
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                            onPressed: _load,
                            child: const Text('Réessayer')),
                      ],
                    ),
                  )
                : _services.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.store_outlined,
                                size: 64, color: AppColors.textSecondary),
                            const SizedBox(height: 16),
                            const Text("Aucun service pour l'instant",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary)),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => _openForm(),
                              icon: const Icon(Icons.add),
                              label: const Text('Ajouter mon premier service'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.secondary,
                        backgroundColor: AppColors.backgroundCard,
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
              child: service.imagePrincipale != null
                  ? Image.network(
                      service.imagePrincipale!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.glassFill,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.store,
                            size: 30, color: AppColors.secondary),
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.glassFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.store,
                          size: 30, color: AppColors.secondary),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.titre,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(service.categorie,
                      style: const TextStyle(
                          color: AppColors.secondary, fontSize: 12)),
                  Text(
                      '${service.prix.toStringAsFixed(0)} FCFA · ⭐ ${service.noteMoyenne}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.secondary),
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
    {'label': 'Snack / Restaurant', 'value': 'SNACK'},
    {'label': 'Activité', 'value': 'ACTIVITE'},
    {'label': 'Transport', 'value': 'TRANSPORT'},
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _nomCtrl = TextEditingController(text: s?.titre);
    _descCtrl = TextEditingController(text: s?.description);
    _prixCtrl =
        TextEditingController(text: s != null ? s.prix.toStringAsFixed(0) : '');
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
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _photoFile = picked);
  }

  Future<void> _uploadPhoto(int serviceId) async {
    if (_photoFile == null) return;
    try {
      if (kIsWeb) {
        final bytes = await _photoFile!.readAsBytes();
        await ApiService.uploadFile(
          '/services/$serviceId/photos/',
          'image',
          bytes: bytes,
          fileName: _photoFile!.name,
        );
      } else {
        await ApiService.uploadFile(
          '/services/$serviceId/photos/',
          'image',
          filePath: _photoFile!.path,
        );
      }
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    final profilId = auth.user?.profilProfessionnel?['id'];

    final body = <String, dynamic>{
      'nom': _nomCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'type_service': _typeService,
      'prix': _prixCtrl.text.trim(),
      'adresse': _adresseCtrl.text.trim(),
      if (widget.service == null && profilId != null)
        'professionnel_id': profilId,
    };

    try {
      final response = widget.service == null
          ? await ApiService.post('/services/', body)
          : await ApiService.patch('/services/${widget.service!.id}/', body);

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Upload la photo si une a été sélectionnée
        if (_photoFile != null) {
          final data = jsonDecode(response.body);
          final serviceId = data['id'] as int;
          await _uploadPhoto(serviceId);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.service == null
              ? 'Service créé ✅'
              : 'Service modifié ✅'),
          backgroundColor: AppColors.backgroundCard,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        Navigator.pop(context);
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _error = 'Erreur ${response.statusCode} : $data';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erreur réseau : $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildPhotoPreview() {
    // Photo existante (mode édition)
    if (_photoFile == null && widget.service?.imagePrincipale != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.service!.imagePrincipale!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _photoPlaceholder(),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.backgroundMid.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Changer',
                    style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    }

    // Nouvelle photo sélectionnée
    if (_photoFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            kIsWeb
                ? FutureBuilder<Uint8List>(
                    future: _photoFile!.readAsBytes(),
                    builder: (_, snap) => snap.hasData
                        ? Image.memory(snap.data!, fit: BoxFit.cover)
                        : const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.secondary)),
                  )
                : Image.network(_photoFile!.path, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Image.asset('assets/images/logo.png',
                            fit: BoxFit.cover)),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => setState(() => _photoFile = null),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                      color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close,
                      color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Aucune photo
    return _photoPlaceholder();
  }

  Widget _photoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_photo_alternate_outlined,
            size: 40, color: AppColors.secondary),
        const SizedBox(height: 10),
        Text('Ajouter une photo',
            style: GoogleFonts.poppins(
                color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 4),
        Text('Galerie · JPEG ou PNG',
            style: GoogleFonts.poppins(
                color: AppColors.textHint, fontSize: 11)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.service != null;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Modifier le service' : 'Nouveau service',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.backgroundMid,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: NatureBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type de service
                Text('Type de service',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _types.map((t) {
                    final sel = _typeService == t['value'];
                    return ChoiceChip(
                      label: Text(t['label']!),
                      selected: sel,
                      onSelected: (_) =>
                          setState(() => _typeService = t['value']!),
                      selectedColor: AppColors.secondary,
                      backgroundColor: AppColors.glassFill,
                      side: BorderSide(
                        color: sel
                            ? AppColors.secondary
                            : AppColors.glassBorder,
                      ),
                      labelStyle: TextStyle(
                        color: sel ? AppColors.background : AppColors.textPrimary,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      ),
                      checkmarkColor: AppColors.background,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                _GlassField(
                  controller: _nomCtrl,
                  label: 'Nom du service',
                  hint: 'Ex: Hôtel de la Paix',
                  icon: Icons.store_outlined,
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                _GlassField(
                  controller: _descCtrl,
                  label: 'Description',
                  hint: 'Décrivez votre service...',
                  icon: Icons.description_outlined,
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                _GlassField(
                  controller: _prixCtrl,
                  label: 'Prix (FCFA)',
                  hint: '5000',
                  icon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty
                      ? 'Requis'
                      : double.tryParse(v) == null
                          ? 'Nombre invalide'
                          : null,
                ),
                const SizedBox(height: 16),
                _GlassField(
                  controller: _adresseCtrl,
                  label: 'Adresse / Ville',
                  hint: 'Ex: Lomé, Togo',
                  icon: Icons.location_on_outlined,
                ),

                const SizedBox(height: 24),

                // ── Photo principale ──────────────────────────────────
                Text('Photo principale',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickPhoto,
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _photoFile != null
                            ? AppColors.secondary
                            : AppColors.glassBorder,
                        width: _photoFile != null ? 1.8 : 1,
                      ),
                    ),
                    child: _buildPhotoPreview(),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  GlassCard(
                    borderRadius: 12,
                    fillColor: Colors.red.withValues(alpha: 0.12),
                    borderColor: Colors.redAccent.withValues(alpha: 0.4),
                    padding: const EdgeInsets.all(12),
                    child: Text(_error!,
                        style: const TextStyle(
                            color: Colors.redAccent, fontSize: 13),
                        textAlign: TextAlign.center),
                  ),
                ],

                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: AppColors.background, strokeWidth: 2))
                        : Text(
                            isEdit
                                ? 'Enregistrer les modifications'
                                : 'Créer le service',
                            style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.background,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _GlassField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.secondary, size: 20),
          ),
        ),
      ],
    );
  }
}
