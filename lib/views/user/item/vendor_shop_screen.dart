import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dumum_tergo/models/camping_item.dart';
import 'package:dumum_tergo/views/user/item/camping_item_card.dart';
import 'package:dumum_tergo/views/user/item/camping_item_detail.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorShopScreen extends StatefulWidget {
  final String vendorId;

  const VendorShopScreen({
    Key? key,
    required this.vendorId,
  }) : super(key: key);

  @override
  _VendorShopScreenState createState() => _VendorShopScreenState();
}

class _VendorShopScreenState extends State<VendorShopScreen> {
  late Future<List<CampingItem>> futureItems;
  Vendor? vendor;
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();
  double _imageHeight = 200.0;

  @override
  void initState() {
    super.initState();
    futureItems = fetchVendorItems();
    _scrollController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<List<CampingItem>> fetchVendorItems() async {
    try {
      final token = await storage.read(key: 'token');

      final response = await http.get(
        Uri.parse('https://dumum-tergo-backend.onrender.com/api/camping/items/vendor/${widget.vendorId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final itemsData = data['data'] as List;
          
          if (itemsData.isNotEmpty) {
            setState(() {
              vendor = Vendor.fromJson(itemsData[0]['vendor']);
            });
          }
          
          return itemsData.map((item) => CampingItem.fromJson(item)).toList();
        }
      }
      throw Exception('Failed to load items');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight = AppBar().preferredSize.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double expandedHeight = _imageHeight + appBarHeight + statusBarHeight;
    final double offset = _scrollController.hasClients ? _scrollController.offset : 0;
    final bool isAppBarTransparent = offset <= _imageHeight - appBarHeight - statusBarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
    
      body: FutureBuilder<List<CampingItem>>(
        future: futureItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Aucun article disponible dans cette boutique'),
            );
          } else {
            final items = snapshot.data!;
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  expandedHeight: expandedHeight,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image de couverture
                        Image.asset(
                          'assets/images/welcome_illustration.png', // Remplacez par votre image de couverture
                          fit: BoxFit.cover,
                        ),
                        // Dégradé pour améliorer la lisibilité du texte
                       DecoratedBox(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        Colors.black.withOpacity(0.7),
        Colors.transparent,
      ],
    ),
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(20.0),
      bottomRight: Radius.circular(20.0),
    ),
  ),
),
                        // Info du vendeur superposée
                        if (vendor != null)
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 16,
                            child: _buildVendorInfoOverlay(context, vendor!),
                          ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Text(
                      'Articles (${items.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.52,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return CampingItemCard(
                          item: items[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CampingItemDetailScreen(item: items[index], fromShop: true),
                              ),
                            );
                          },
                        );
                      },
                      childCount: items.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
              ],
            );
          }
        },
      ),
    );
  }

Widget _buildVendorInfoOverlay(BuildContext context, Vendor vendor) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    
    children: [
      CircleAvatar(
        radius: 40,
        backgroundImage: vendor.image != null
            ? NetworkImage('https://dumum-tergo-backend.onrender.com${vendor.image!}')
            : const AssetImage('assets/default_vendor.png') as ImageProvider,
        onBackgroundImageError: (_, __) {
          // Optionnel : image de secours
        },
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vendor.businessName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            if (vendor.businessAddress != null) ...[
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      vendor.businessAddress!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],

            if (vendor.description != null && vendor.description!.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      vendor.description!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],

            const Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                SizedBox(width: 4),
                Text(
                  '4.5 (24 avis)',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}


  Widget _buildVendorInfoSection(BuildContext context, Vendor vendor) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: vendor.image != null 
                  ? NetworkImage('https://dumum-tergo-backend.onrender.com${vendor.image!}')
                  : const AssetImage('assets/default_vendor.png') as ImageProvider,
                onBackgroundImageError: (_, __) {
                  // Vous pouvez définir une image par défaut ici si nécessaire
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.businessName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (vendor.businessAddress != null)
                      Text(
                        vendor.businessAddress!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        SizedBox(width: 4),
                        Text(
                          '4.5 (24 avis)',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (vendor.description != null && vendor.description!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  vendor.description!,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text('Message'),
                  onPressed: () {
                    // Implémentez la fonctionnalité de messagerie ici
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Appeler'),
                  onPressed: () {
                    if (vendor.mobile.isNotEmpty) {
                      final cleanedNumber = vendor.mobile.replaceAll(RegExp(r'[^0-9+]'), '');
                      final Uri phoneUri = Uri(scheme: 'tel', path: cleanedNumber);
                      launchUrl(phoneUri);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}