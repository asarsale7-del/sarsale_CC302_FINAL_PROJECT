import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/gadget.dart';

class GadgetRepository {
  static const _storageKey = 'gadget_shelf_gadgets';

  Future<List<Gadget>> loadGadgets() async {
    final preferences = await SharedPreferences.getInstance();
    final storedValue = preferences.getString(_storageKey);
    if (storedValue == null) {
      final starterGadgets = _starterGadgets;
      await saveGadgets(starterGadgets);
      return starterGadgets;
    }

    final decoded = jsonDecode(storedValue) as List<dynamic>;
    return decoded
        .map((item) => Gadget.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveGadgets(List<Gadget> gadgets) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(gadgets.map((gadget) => gadget.toJson()).toList());
    final saved = await preferences.setString(_storageKey, encoded);
    if (!saved) throw StateError('Local storage did not save the gadget list.');
  }

  List<Gadget> get _starterGadgets => const [
    Gadget(
      id: 'starter-phone',
      name: 'Everyday Smartphone',
      category: 'Phones',
      price: 18999,
      description: 'A dependable phone for work, photos, and daily life.',
      imageAsset: 'assets/gadgets/smartphone.jpg',
    ),
    Gadget(
      id: 'starter-laptop',
      name: 'Student Laptop',
      category: 'Computers',
      price: 32999,
      description: 'Lightweight laptop ready for classes and projects.',
      imageAsset: 'assets/gadgets/laptop.jpg',
    ),
    Gadget(
      id: 'starter-headphones',
      name: 'Studio Headphones',
      category: 'Audio',
      price: 3499,
      description: 'Comfortable over-ear headphones for focused listening.',
      imageAsset: 'assets/gadgets/headphones.jpg',
    ),
    Gadget(
      id: 'starter-watch',
      name: 'Fitness Watch',
      category: 'Wearables',
      price: 5999,
      description: 'Track activity and stay on top of your day.',
      imageAsset: 'assets/gadgets/watch.jpg',
    ),
    Gadget(
      id: 'starter-keyboard',
      name: 'Mechanical Keyboard',
      category: 'Accessories',
      price: 2799,
      description: 'A compact keyboard for a more satisfying typing setup.',
      imageAsset: 'assets/gadgets/keyboard.jpg',
    ),
    Gadget(
      id: 'starter-earbuds',
      name: 'Wireless Earbuds',
      category: 'Audio',
      price: 1999,
      description: 'Small, portable earbuds for music on the move.',
      imageAsset: 'assets/gadgets/earbuds.jpg',
    ),
  ];
}
