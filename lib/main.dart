import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MdcConnectApp());

class MdcConnectApp extends StatelessWidget {
  const MdcConnectApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'MDC Connect',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF174D39)),
      scaffoldBackgroundColor: const Color(0xFFF5F7F4),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF5F7F4)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E7E1)),
        ),
      ),
    ),
    home: const ConcernsPage(),
  );
}

class Concern {
  const Concern({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    this.status = 'Received',
  });
  final String id, title, description, category, date, status;
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'date': date,
    'status': status,
  };
  factory Concern.fromJson(Map<String, dynamic> json) => Concern(
    id: '${json['id']}',
    title: json['title'] as String,
    description: json['description'] as String,
    category: json['category'] as String? ?? 'General',
    date: json['date'] as String? ?? '',
    status: json['status'] as String? ?? 'Received',
  );
}

class ConcernRepository {
  static const _key = 'mdc_connect_concerns_v1';
  Future<List<Concern>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_key);
    if (cached != null) {
      return (jsonDecode(cached) as List)
          .map((e) => Concern.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    try {
      final response = await http
          .get(
            Uri.https('jsonplaceholder.typicode.com', '/posts'),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        throw StateError('API returned ${response.statusCode}');
      }
      final posts = (jsonDecode(response.body) as List).take(6).toList();
      final items = posts.asMap().entries.map((entry) {
        final post = entry.value as Map<String, dynamic>;
        final categories = [
          'Facilities',
          'Academic',
          'IT Support',
          'Student Services',
          'Safety',
          'Other',
        ];
        return Concern(
          id: 'api-${post['id']}',
          title: (post['title'] as String)
              .split(' ')
              .take(5)
              .join(' ')
              .toUpperCase(),
          description: post['body'] as String,
          category: categories[entry.key],
          date: DateTime.now().toIso8601String(),
          status: entry.key == 0 ? 'In review' : 'Received',
        );
      }).toList();
      await _save(items);
      return items;
    } catch (_) {
      final items = _samples;
      await _save(items);
      return items;
    }
  }

  Future<void> save(List<Concern> items) => _save(items);
  Future<void> _save(List<Concern> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  List<Concern> get _samples => [
    Concern(
      id: 'sample-1',
      title: 'LIBRARY WIFI CONNECTION',
      description:
          'The Wi-Fi signal in the second-floor study area keeps dropping.',
      category: 'IT Support',
      date: DateTime.now().toIso8601String(),
      status: 'In review',
    ),
    Concern(
      id: 'sample-2',
      title: 'WATER FOUNTAIN',
      description:
          'The water fountain near the science building needs maintenance.',
      category: 'Facilities',
      date: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    ),
    Concern(
      id: 'sample-3',
      title: 'CLASSROOM PROJECTOR',
      description: 'Projector in Room 204 is not displaying a clear image.',
      category: 'Facilities',
      date: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      status: 'Resolved',
    ),
  ];
}

class ConcernsPage extends StatefulWidget {
  const ConcernsPage({super.key});
  @override
  State<ConcernsPage> createState() => _ConcernsPageState();
}

class _ConcernsPageState extends State<ConcernsPage> {
  final _repo = ConcernRepository();
  final _search = TextEditingController();
  List<Concern> _items = [];
  bool _loading = true, _usingFallback = false;
  String _filter = 'All';
  int _selectedSection = 0;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await _repo.load();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
      _usingFallback = items.every((item) => item.id.startsWith('sample-'));
    });
  }

  Future<void> _save(List<Concern> items) async {
    await _repo.save(items);
    if (mounted) setState(() => _items = items);
  }

  Future<void> _addConcern() async {
    final concern = await showDialog<Concern>(
      context: context,
      builder: (_) => const ConcernForm(),
    );
    if (concern != null) {
      await _save([concern, ..._items]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your concern was submitted.')),
        );
      }
    }
  }

  Future<void> _delete(Concern item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this concern?'),
        content: const Text('This removes the concern from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep it'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _save(_items.where((e) => e.id != item.id).toList());
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Concern deleted.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final visible = _items
        .where(
          (item) =>
              (_filter == 'All' || item.status == _filter) &&
              ('${item.title} ${item.description} ${item.category}'
                  .toLowerCase()
                  .contains(query)),
        )
        .toList();
    final headers = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
        child: _DashboardHeader(
          total: _items.length,
          review: _items.where((e) => e.status != 'Resolved').length,
        ),
      ),
      if (_usingFallback)
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(
            'Showing demo concerns while the API is unavailable.',
            style: TextStyle(color: Color(0xFF59665F), fontSize: 12),
          ),
        ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Search concerns',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
      ),
      SizedBox(
        height: 62,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
          itemCount: 4,
          itemBuilder: (context, index) {
            final value = ['All', 'Received', 'In review', 'Resolved'][index];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(value),
                selected: _filter == value,
                onSelected: (_) => setState(() => _filter = value),
              ),
            );
          },
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedSection == 0 ? 'MDC Connect' : 'How it works',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: _selectedSection == 0
            ? [
                IconButton(
                  onPressed: _load,
                  tooltip: 'Refresh concerns',
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ]
            : null,
      ),
      floatingActionButton: _selectedSection == 0
          ? FloatingActionButton.extended(
              onPressed: _addConcern,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New concern'),
            )
          : null,
      body: SafeArea(
        child: _selectedSection == 1
            ? const _HowItWorksPage()
            : _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
                  itemCount:
                      headers.length + (visible.isEmpty ? 1 : visible.length),
                  itemBuilder: (context, index) {
                    if (index < headers.length) return headers[index];
                    if (visible.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.inbox_outlined,
                              size: 48,
                              color: Color(0xFF87958C),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _items.isEmpty
                                  ? 'No concerns yet'
                                  : 'No matching concerns',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Share an issue or suggestion and the school team can follow up.',
                            ),
                          ],
                        ),
                      );
                    }
                    final item = visible[index - headers.length];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: ConcernCard(
                        item: item,
                        onDelete: () => _delete(item),
                      ),
                    );
                  },
                ),
              ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedSection,
        onDestinationSelected: (index) =>
            setState(() => _selectedSection = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox_rounded),
            label: 'Concerns',
          ),
          NavigationDestination(
            icon: Icon(Icons.help_outline_rounded),
            selectedIcon: Icon(Icons.help_rounded),
            label: 'How it works',
          ),
        ],
      ),
    );
  }
}

class _HowItWorksPage extends StatelessWidget {
  const _HowItWorksPage();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
    children: const [
      _GuideCard(
        icon: Icons.edit_note_rounded,
        title: '1. Describe the concern',
        body:
            'Choose a category and give your concern a clear title and description.',
      ),
      SizedBox(height: 12),
      _GuideCard(
        icon: Icons.track_changes_rounded,
        title: '2. Follow its status',
        body:
            'Use the status filters to find concerns that are received, in review, or resolved.',
      ),
      SizedBox(height: 12),
      _GuideCard(
        icon: Icons.shield_outlined,
        title: 'Your demo data',
        body:
            'This class prototype saves concerns on this device. Its public API supplies sample posts; it does not contact MDC staff.',
      ),
    ],
  );
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title, body;

  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: Color(0xFFE7ECE7)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF287254), size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(height: 1.4, color: Color(0xFF59665F)),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.total, required this.review});
  final int total, review;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF174D39), Color(0xFF287254)],
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
                'STUDENT SUPPORT',
                style: TextStyle(
                  color: Color(0xFFC4E3D1),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your voice helps\nour campus grow.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '$review active  ·  $total total concerns',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .14),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.forum_outlined,
            color: Colors.white,
            size: 30,
          ),
        ),
      ],
    ),
  );
}

class ConcernCard extends StatelessWidget {
  const ConcernCard({super.key, required this.item, required this.onDelete});
  final Concern item;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    final color = item.status == 'Resolved'
        ? const Color(0xFF287254)
        : item.status == 'In review'
        ? const Color(0xFF9A6412)
        : const Color(0xFF4263A5);
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE7ECE7)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.category.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF287254),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .7,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Delete concern',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 21),
                ),
              ],
            ),
            Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: 7),
            Text(
              item.description,
              style: const TextStyle(height: 1.4, color: Color(0xFF59665F)),
            ),
            const SizedBox(height: 12),
            Text(
              _date(item.date),
              style: const TextStyle(color: Color(0xFF7D8981), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  String _date(String value) {
    final date = DateTime.tryParse(value)?.toLocal();
    return date == null
        ? 'Recently submitted'
        : 'Submitted ${date.day}/${date.month}/${date.year}';
  }
}

class ConcernForm extends StatefulWidget {
  const ConcernForm({super.key});
  @override
  State<ConcernForm> createState() => _ConcernFormState();
}

class _ConcernFormState extends State<ConcernForm> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  String _category = 'Facilities';
  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Share a concern'),
    content: SizedBox(
      width: 420,
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _title,
                maxLength: 60,
                decoration: const InputDecoration(labelText: 'Short title'),
                validator: (v) => v == null || v.trim().length < 4
                    ? 'Enter at least 4 characters'
                    : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items:
                    [
                          'Facilities',
                          'Academic',
                          'IT Support',
                          'Student Services',
                          'Safety',
                          'Other',
                        ]
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                maxLines: 4,
                maxLength: 400,
                decoration: const InputDecoration(labelText: 'Tell us more'),
                validator: (v) => v == null || v.trim().length < 10
                    ? 'Add a little more detail (10 characters minimum)'
                    : null,
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
        onPressed: () {
          if (!_form.currentState!.validate()) return;
          Navigator.pop(
            context,
            Concern(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              title: _title.text.trim().toUpperCase(),
              description: _description.text.trim(),
              category: _category,
              date: DateTime.now().toIso8601String(),
            ),
          );
        },
        child: const Text('Submit concern'),
      ),
    ],
  );
}
