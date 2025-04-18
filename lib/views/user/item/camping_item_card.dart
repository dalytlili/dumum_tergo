import 'package:dumum_tergo/models/camping_item.dart';
import 'package:dumum_tergo/views/user/item/camping_item_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CampingItemCard extends StatelessWidget {
  final CampingItem item;
  final VoidCallback? onTap;

  const CampingItemCard({
    Key? key,
    required this.item,
    this.onTap,
  }) : super(key: key);

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) return 'À l\'instant';
    if (difference.inMinutes < 60) return 'il y a ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'il y a ${difference.inHours} h';
    if (difference.inDays < 7) return 'il y a ${difference.inDays} j';
    
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              body: CampingItemDetailScreen(item: item),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image with badge
            Stack(
              children: [
     ClipRRect(
  borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
  child: Container(
    height: 180,
    width: double.infinity,
    color: Colors.grey[200], // Fond uni si l'image ne remplit pas tout
    child: Image.network(
      'http://localhost:9098/images/${item.images.isNotEmpty ? item.images[0] : 'default.jpg'}',
      fit: BoxFit.contain, // Ajuste l'image pour être entièrement visible
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 40),
    ),
  ),
),
                // Badges container
                Positioned(
                  top: 8,
                  left: 8,
                  child: Row(
                    children: [
                   
                      if (item.isForSale)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'À vendre',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                           if (item.isForRent)
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'À louer',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Photo du vendeur (cercle en haut à droite)
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 18,
                    child: CircleAvatar(
                      radius: 17,
                      backgroundImage: NetworkImage(
                        'http://localhost:9098${item.vendor.image ?? 'default.jpg'}',
                      ),
                      onBackgroundImageError: (_, __) {},
                    ),
                  ),
                ),
              ],
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Price
             // Remplacer la section Price par:
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    if (item.isForSale && item.isForRent) ...[
      Row(
        children: [
          Icon(Icons.sell, size: 16, color: Colors.blue),
          SizedBox(width: 4),
          Text(
            '${item.price.toStringAsFixed(0)} TND',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
        ],
      ),
      SizedBox(height: 4),
      Row(
        children: [
          Icon(Icons.calendar_today, size: 16, color: Colors.green),
          SizedBox(width: 4),
          Text(
            '${item.rentalPrice.toStringAsFixed(0)} TND/jour',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green,
            ),
          ),
        ],
      ),
    ] else if (item.isForSale) ...[
      Row(
        children: [
          Icon(Icons.sell, size: 16, color: Colors.blue),
          SizedBox(width: 4),
          Text(
            '${item.price.toStringAsFixed(0)} TND',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    ] else if (item.isForRent) ...[
      Row(
        children: [
          Icon(Icons.calendar_today, size: 16, color: Colors.green),
          SizedBox(width: 4),
          Text(
            '${item.rentalPrice.toStringAsFixed(0)} TND/jour',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green,
            ),
          ),
        ],
      ),
    ],
  ],
),
                  
                  const SizedBox(height: 8),
                  
                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.location.title,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Time
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimeAgo(item.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
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