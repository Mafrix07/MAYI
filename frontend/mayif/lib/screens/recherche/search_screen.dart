import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/service_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/home/service_card.dart';
import '../../widgets/common/glass_card.dart';
import '../services/service_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _prixMinController = TextEditingController();
  final TextEditingController _prixMaxController = TextEditingController();
  Timer? _debounce;
  String _selectedCategory = 'TOUT';
  bool _showFilters = false;
  double? _noteMin;
  String? _ordering;

  final List<Map<String, String>> _categories = [
    {'label': 'Tous', 'value': 'TOUT'},
    {'label': 'Hôtels', 'value': 'HEBERGEMENT'},
    {'label': 'Restaurants', 'value': 'SNACK'},
    {'label': 'Activités', 'value': 'ACTIVITE'},
    {'label': 'Transports', 'value': 'TRANSPORT'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchServices();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _prixMinController.dispose();
    _prixMaxController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String _) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _performSearch);
  }

  void _performSearch() {
    context.read<ServiceProvider>().fetchServices(
      search: _searchController.text,
      typeService: _selectedCategory,
      prixMin: double.tryParse(_prixMinController.text),
      prixMax: double.tryParse(_prixMaxController.text),
      noteMin: _noteMin,
      ordering: _ordering,
    );
  }

  void _resetFilters() {
    _prixMinController.clear();
    _prixMaxController.clear();
    setState(() {
      _showFilters = false;
      _noteMin = null;
      _ordering = null;
    });
    _performSearch();
  }

  List<({String label, VoidCallback onRemove})> get _activeFilters {
    final filters = <({String label, VoidCallback onRemove})>[];
    if (_selectedCategory != 'TOUT') {
      final label = _categories.firstWhere((c) => c['value'] == _selectedCategory)['label']!;
      filters.add((label: label, onRemove: () { setState(() => _selectedCategory = 'TOUT'); _performSearch(); }));
    }
    if (_prixMinController.text.isNotEmpty || _prixMaxController.text.isNotEmpty) {
      final min = _prixMinController.text.isEmpty ? '0' : _prixMinController.text;
      final max = _prixMaxController.text.isEmpty ? '∞' : _prixMaxController.text;
      filters.add((label: '$min—$max F', onRemove: () { _prixMinController.clear(); _prixMaxController.clear(); setState(() {}); _performSearch(); }));
    }
    if (_noteMin != null) {
      filters.add((label: '${_noteMin!.toStringAsFixed(0)}⭐+', onRemove: () { setState(() => _noteMin = null); _performSearch(); }));
    }
    if (_ordering != null) {
      const labels = {'-note_moyenne': 'Mieux notés', 'prix': 'Prix ↑', '-prix': 'Prix ↓'};
      filters.add((label: labels[_ordering] ?? _ordering!, onRemove: () { setState(() => _ordering = null); _performSearch(); }));
    }
    return filters;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NatureBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── AppBar ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    const Text(
                      'Rechercher',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _showFilters = !_showFilters),
                      child: GlassCard(
                        borderRadius: 12,
                        padding: const EdgeInsets.all(10),
                        fillColor: _showFilters ? AppColors.secondary.withValues(alpha: 0.2) : null,
                        borderColor: _showFilters ? AppColors.secondary : null,
                        child: Icon(
                          Icons.tune,
                          color: _showFilters ? AppColors.secondary : AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Barre de recherche ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: GlassCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Hôtel, restaurant, activité...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      icon: Icon(Icons.search, color: AppColors.secondary),
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),

              // ── Chips catégories ────────────────────────────────────
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSel = _selectedCategory == cat['value'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(cat['label']!),
                        selected: isSel,
                        onSelected: (_) {
                          setState(() => _selectedCategory = cat['value']!);
                          _performSearch();
                        },
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.glassFill,
                        side: BorderSide(
                          color: isSel ? AppColors.primary : AppColors.glassBorder,
                        ),
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        checkmarkColor: Colors.white,
                      ),
                    );
                  },
                ),
              ),

              // ── Panneau filtres avancés ─────────────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _showFilters
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                        child: GlassCard(
                          borderRadius: 16,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Filtres avancés',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                  GestureDetector(
                                    onTap: _resetFilters,
                                    child: const Text('Réinitialiser',
                                        style: TextStyle(color: AppColors.secondary, fontSize: 12)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Prix
                              const Text('Prix (FCFA)',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _prixMinController,
                                      keyboardType: TextInputType.number,
                                      onSubmitted: (_) => _performSearch(),
                                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                      decoration: const InputDecoration(
                                        labelText: 'Min',
                                        prefixText: 'F ',
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Text('—', style: TextStyle(color: AppColors.textSecondary)),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _prixMaxController,
                                      keyboardType: TextInputType.number,
                                      onSubmitted: (_) => _performSearch(),
                                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                      decoration: const InputDecoration(
                                        labelText: 'Max',
                                        prefixText: 'F ',
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Note min
                              const Text('Note minimum',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: <(String, double?)>[
                                  ('Toutes', null), ('3⭐+', 3.0), ('4⭐+', 4.0),
                                ].map((opt) {
                                  final isSel = _noteMin == opt.$2;
                                  return ChoiceChip(
                                    label: Text(opt.$1),
                                    selected: isSel,
                                    onSelected: (_) => setState(() => _noteMin = opt.$2),
                                    selectedColor: AppColors.primary,
                                    backgroundColor: AppColors.glassFill,
                                    labelStyle: TextStyle(
                                      color: isSel ? Colors.white : AppColors.textPrimary,
                                      fontSize: 12,
                                    ),
                                    checkmarkColor: Colors.white,
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 14),

                              // Tri
                              const Text('Trier par',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: <(String, String?)>[
                                  ('Pertinence', null), ('Prix ↑', 'prix'),
                                  ('Prix ↓', '-prix'), ('Mieux notés', '-note_moyenne'),
                                ].map((opt) {
                                  final isSel = _ordering == opt.$2;
                                  return ChoiceChip(
                                    label: Text(opt.$1),
                                    selected: isSel,
                                    onSelected: (_) => setState(() => _ordering = opt.$2),
                                    selectedColor: AppColors.secondary,
                                    backgroundColor: AppColors.glassFill,
                                    labelStyle: TextStyle(
                                      color: isSel ? AppColors.background : AppColors.textPrimary,
                                      fontSize: 12,
                                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    checkmarkColor: AppColors.background,
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _performSearch,
                                  child: const Text('Appliquer',
                                      style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // ── Chips filtres actifs ────────────────────────────────
              if (_activeFilters.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _activeFilters.map((f) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Chip(
                                label: Text(f.label,
                                    style: const TextStyle(fontSize: 11, color: AppColors.background)),
                                backgroundColor: AppColors.secondary,
                                deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.background),
                                onDeleted: f.onRemove,
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                side: BorderSide.none,
                              ),
                            )).toList(),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _resetFilters,
                        child: const Text('Effacer', style: TextStyle(color: AppColors.secondary, fontSize: 12)),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // ── Résultats ───────────────────────────────────────────
              Expanded(
                child: Consumer<ServiceProvider>(
                  builder: (context, sp, _) {
                    if (sp.isLoading && sp.services.isEmpty) {
                      return _SearchShimmer();
                    }
                    if (sp.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.wifi_off, size: 56, color: AppColors.textSecondary),
                            const SizedBox(height: 16),
                            const Text('Erreur de connexion',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _performSearch,
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (sp.services.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🔍', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Aucun service disponible'
                                  : 'Aucun résultat pour "${_searchController.text}"',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                      itemCount: sp.services.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ServiceCard(
                            service: sp.services[index],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServiceDetailScreen(service: sp.services[index]),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, _) => Shimmer.fromColors(
        baseColor: AppColors.glassFill,
        highlightColor: AppColors.glassFillMed,
        child: Container(
          height: 180,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.glassBorder),
          ),
        ),
      ),
    );
  }
}
