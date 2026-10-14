// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: const ActivityPage(),
//     );
//   }
// }

// class ActivityPage extends StatelessWidget {
//   const ActivityPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Tech Gadget Catalog'),
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),

//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),

//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // Title
//               const Text(
//                 'Student Tech Gadget Catalog',
//                 style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//               ),

//               const SizedBox(height: 15),

//               // Network Image
//               Image.network(
//                 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
//                 height: 200,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//               ),


//               const SizedBox(height: 20),

//               // Row with five icons and labels
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: const [
//                   Column(
//                     children: [
//                       Icon(Icons.phone, size: 30),
//                       SizedBox(height: 5),
//                       Text('Phones'),
//                     ],
//                   ),

//                   Column(
//                     children: [
//                       Icon(Icons.laptop, size: 30),
//                       SizedBox(height: 5),
//                       Text('Lapt'),
//                     ],
//                   ),

//                   Column(
//                     children: [
//                       Icon(Icons.water, size: 30),
//                       SizedBox(height: 5),
//                       Text('Water'),
//                     ],
//                   ),

//                   Column(
//                     children: [
//                       Icon(Icons.photo_camera, size: 30),
//                       SizedBox(height: 5),
//                       Text('Photo'),
//                     ],
//                   ),

//                   Column(
//                     children: [
//                       Icon(Icons.favorite, size: 30),
//                       SizedBox(height: 5),
//                       Text('Love'),
//                     ], // 
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 20),

//               // Divider
//               const Divider(thickness: 2),

//               const SizedBox(height: 20),

//               // Asset Image
//               Image.asset(
//                 'assets/images/beach.jpg',
//                 height: 200,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

void main() {
  runApp(const GadgetCatalogApp());
}

class GadgetCatalogApp extends StatelessWidget {
  const GadgetCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gadget Catalog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const HomeScreen(),
    );
  }
}

class Gadget {
  final String name;
  final String category;
  final double price;
  final String imageAsset;
  final String specification;
  bool isFavorite;

  Gadget({
    required this.name,
    required this.category,
    required this.price,
    required this.imageAsset,
    required this.specification,
    this.isFavorite = false,
  });
}

class GadgetRepository {
  static List<Gadget> getGadgets() {
    return [
      Gadget(
        name: 'Nova X12 Phone',
        category: 'Phones',
        price: 18999,
        imageAsset: 'assets/images/phone.png',
        specification: '6.5" AMOLED, 128GB, 5000mAh battery',
      ),
      Gadget(
        name: 'AirBook 14',
        category: 'Laptops',
        price: 42999,
        imageAsset: 'assets/images/laptop.png',
        specification: 'Intel i5, 16GB RAM, 512GB SSD',
      ),
      Gadget(
        name: 'SoundWave Pro',
        category: 'Headphones',
        price: 3499,
        imageAsset: 'assets/images/headphones.png',
        specification: 'Active noise cancelling, 30h battery',
      ),
      Gadget(
        name: 'TypeMaster K2',
        category: 'Keyboards',
        price: 2199,
        imageAsset: 'assets/images/keyboard.png',
        specification: 'Mechanical, hot-swappable, RGB backlight',
      ),
      Gadget(
        name: 'HomeHub Mini',
        category: 'Smart Devices',
        price: 2799,
        imageAsset: 'assets/images/smart_device.png',
        specification: 'Voice assistant, smart home controller',
      ),
      Gadget(
        name: 'Tab Air 10',
        category: 'Phones',
        price: 15999,
        imageAsset: 'assets/images/tablet.png',
        specification: '10.5" display, 64GB storage, stylus support',
      ),
    ];
  }
}

class CatalogHeader extends StatelessWidget {
  final VoidCallback onViewDetailsPressed;

  const CatalogHeader({super.key, required this.onViewDetailsPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.indigo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/catalog_banner.png',
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.devices_other, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Gadget Catalog',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Browse phones, laptops, and accessories',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onViewDetailsPressed,
            icon: const Icon(Icons.info_outline),
            label: const Text('View Details'),
          ),
        ],
      ),
    );
  }
}

class PriceBox extends StatelessWidget {
  final double price;

  const PriceBox({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.sell, size: 14),
        const SizedBox(width: 4),
        Text('\u20B1${price.toStringAsFixed(0)}'),
      ],
    );
  }
}

class GadgetCard extends StatelessWidget {
  final Gadget gadget;
  final VoidCallback onFavoriteToggle;

  const GadgetCard({
    super.key,
    required this.gadget,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              gadget.imageAsset,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          gadget.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: onFavoriteToggle,
                        icon: Icon(
                          gadget.isFavorite
                              ? Icons.star
                              : Icons.star_border,
                          color: gadget.isFavorite ? Colors.amber : null,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.category, size: 14),
                      SizedBox(width: 4),
                      Text(gadget.category),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    gadget.specification,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  PriceBox(price: gadget.price),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Gadget> _gadgets = GadgetRepository.getGadgets();

  void _toggleFavorite(int index) {
    setState(() {
      _gadgets[index].isFavorite = !_gadgets[index].isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoriteCount = _gadgets.where((g) => g.isFavorite).length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CatalogHeader(
              onViewDetailsPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Scroll down to view all gadgets')),
                );
              },
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: Text(
                '${_gadgets.length} Gadgets Â· $favoriteCount favorited',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _gadgets.length,
                itemBuilder: (context, index) {
                  return GadgetCard(
                    gadget: _gadgets[index],
                    onFavoriteToggle: () => _toggleFavorite(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

