import 'package:flutter/material.dart';

import 'data/gadget_repository.dart';
import 'models/gadget.dart';

void main() {
  runApp(const GadgetCatalogApp());
}

class GadgetCatalogApp extends StatelessWidget {
  const GadgetCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF152238);
    const blue = Color(0xFF4263EB);

    return MaterialApp(
      title: 'Gadget Shelf',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: blue,
          primary: blue,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F7FB),
          foregroundColor: navy,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: navy,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE6EAF2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: blue, width: 1.5),
          ),
        ),
      ),
      home: const CatalogPage(),
    );
  }
}

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _repository = GadgetRepository();
  final _searchController = TextEditingController();
  List<Gadget> _gadgets = [];
  bool _isLoading = true;
  String? _loadError;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadGadgets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGadgets() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final gadgets = await _repository.loadGadgets();
      if (!mounted) return;
      setState(() {
        _gadgets = gadgets;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Could not load your gadgets: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveGadgets(List<Gadget> updatedGadgets) async {
    try {
      await _repository.saveGadgets(updatedGadgets);
      if (!mounted) return;
      setState(() => _gadgets = updatedGadgets);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save your changes: $error')),
      );
    }
  }

  Future<void> _openGadgetForm({Gadget? gadget}) async {
    final result = await showDialog<Gadget>(
      context: context,
      builder: (context) => GadgetFormDialog(gadget: gadget),
    );
    if (result == null) return;

    final updatedGadgets = [..._gadgets];
    final existingIndex = updatedGadgets.indexWhere(
      (item) => item.id == result.id,
    );
    if (existingIndex == -1) {
      updatedGadgets.insert(0, result);
    } else {
      updatedGadgets[existingIndex] = result;
    }
    await _saveGadgets(updatedGadgets);
  }

  Future<void> _deleteGadget(Gadget gadget) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete gadget?'),
        content: Text('Remove ${gadget.name} from your collection?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD64545),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;

    final updatedGadgets = _gadgets
        .where((item) => item.id != gadget.id)
        .toList();
    await _saveGadgets(updatedGadgets);
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'All',
      ...{for (final gadget in _gadgets) gadget.category},
    ];
    final query = _searchController.text.trim().toLowerCase();
    final visibleGadgets = _gadgets.where((gadget) {
      final matchesCategory =
          _selectedCategory == 'All' || gadget.category == _selectedCategory;
      final matchesSearch =
          query.isEmpty ||
          gadget.name.toLowerCase().contains(query) ||
          gadget.category.toLowerCase().contains(query) ||
          gadget.description.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gadget Shelf'),
        actions: [
          IconButton(
            tooltip: 'Reload gadgets',
            onPressed: _loadGadgets,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openGadgetForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add gadget'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
            ? _LoadError(message: _loadError!, onRetry: _loadGadgets)
            : RefreshIndicator(
                onRefresh: _loadGadgets,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                        child: _CollectionHeader(count: _gadgets.length),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'Search your collection',
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 62,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return ChoiceChip(
                              label: Text(category),
                              selected: category == _selectedCategory,
                              onSelected: (_) =>
                                  setState(() => _selectedCategory = category),
                            );
                          },
                        ),
                      ),
                    ),
                    if (visibleGadgets.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyCollection(
                          hasGadgets: _gadgets.isNotEmpty,
                          onAdd: () => _openGadgetForm(),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 100),
                        sliver: SliverList.separated(
                          itemCount: visibleGadgets.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final gadget = visibleGadgets[index];
                            return GadgetCard(
                              gadget: gadget,
                              onEdit: () => _openGadgetForm(gadget: gadget),
                              onDelete: () => _deleteGadget(gadget),
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

class _CollectionHeader extends StatelessWidget {
  const _CollectionHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF152238), Color(0xFF263F68)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR COLLECTION',
                  style: TextStyle(
                    color: Color(0xFFB8C7E1),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Keep your tech\nin one place.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    height: 1.12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '$count ${count == 1 ? 'gadget' : 'gadgets'} saved',
                  style: const TextStyle(color: Color(0xFFD3DCEE)),
                ),
              ],
            ),
          ),
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.devices_other_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}

class GadgetCard extends StatelessWidget {
  const GadgetCard({
    super.key,
    required this.gadget,
    required this.onEdit,
    required this.onDelete,
  });

  final Gadget gadget;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE9EDF4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                gadget.imageAsset,
                width: 92,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 92,
                  height: 100,
                  color: const Color(0xFFE9EDF4),
                  child: const Icon(Icons.devices_rounded, size: 32),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF1FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      gadget.category,
                      style: const TextStyle(
                        color: Color(0xFF4263EB),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    gadget.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF152238),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    gadget.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF7D8799),
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₱${gadget.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF152238),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  tooltip: 'Edit ${gadget.name}',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  color: const Color(0xFF4263EB),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  tooltip: 'Delete ${gadget.name}',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: const Color(0xFFD64545),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCollection extends StatelessWidget {
  const _EmptyCollection({required this.hasGadgets, required this.onAdd});

  final bool hasGadgets;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFF9AA5B7),
              size: 52,
            ),
            const SizedBox(height: 12),
            Text(
              hasGadgets ? 'No gadgets match your search' : 'Start your shelf',
              style: const TextStyle(
                color: Color(0xFF152238),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasGadgets
                  ? 'Try a different keyword or category.'
                  : 'Add your first gadget to get started.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF7D8799)),
            ),
            if (!hasGadgets) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add a gadget'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 44),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class GadgetFormDialog extends StatefulWidget {
  const GadgetFormDialog({super.key, this.gadget});

  final Gadget? gadget;

  @override
  State<GadgetFormDialog> createState() => _GadgetFormDialogState();
}

class _GadgetFormDialogState extends State<GadgetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late String _imageAsset;

  static const _images = [
    'assets/gadgets/smartphone.jpg',
    'assets/gadgets/laptop.jpg',
    'assets/gadgets/headphones.jpg',
    'assets/gadgets/watch.jpg',
    'assets/gadgets/keyboard.jpg',
    'assets/gadgets/earbuds.jpg',
  ];

  @override
  void initState() {
    super.initState();
    final gadget = widget.gadget;
    _nameController = TextEditingController(text: gadget?.name ?? '');
    _categoryController = TextEditingController(
      text: gadget?.category ?? 'Accessories',
    );
    _priceController = TextEditingController(
      text: gadget?.price.toStringAsFixed(2) ?? '',
    );
    _descriptionController = TextEditingController(
      text: gadget?.description ?? '',
    );
    _imageAsset = gadget?.imageAsset ?? _images.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _required(String? value, String field) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.gadget;
    final gadget = Gadget(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      description: _descriptionController.text.trim(),
      imageAsset: _imageAsset,
    );
    Navigator.pop(context, gadget);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.gadget != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit gadget' : 'Add a gadget'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 420,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Gadget name'),
                  validator: (value) => _required(value, 'Name'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (value) => _required(value, 'Category'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price (₱)',
                    prefixText: '₱ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    final requiredError = _required(value, 'Price');
                    if (requiredError != null) return requiredError;
                    final price = double.tryParse(value!.trim());
                    if (price == null || !price.isFinite || price < 0) {
                      return 'Enter a valid non-negative price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                  validator: (value) => _required(value, 'Description'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _imageAsset,
                  decoration: const InputDecoration(labelText: 'Gadget image'),
                  items: _images
                      .map(
                        (path) => DropdownMenuItem(
                          value: path,
                          child: Text(_imageLabel(path)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _imageAsset = value);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Save changes' : 'Add gadget'),
        ),
      ],
    );
  }

  String _imageLabel(String path) {
    final fileName = path.split('/').last.split('.').first;
    return '${fileName[0].toUpperCase()}${fileName.substring(1)}';
  }
}
