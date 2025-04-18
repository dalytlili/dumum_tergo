import 'package:dumum_tergo/views/user/full_screen_image_gallery.dart';
import 'package:dumum_tergo/views/user/item/vendor_shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dumum_tergo/models/camping_item.dart';

class CampingItemDetailScreen extends StatefulWidget {
  final CampingItem item;
  final bool fromShop; // Nouveau paramètre pour indiquer si on vient de la boutique

  const CampingItemDetailScreen({Key? key, required this.item, this.fromShop = false,}) : super(key: key);

  @override
  State<CampingItemDetailScreen> createState() => _CampingItemDetailScreenState();
}

class _CampingItemDetailScreenState extends State<CampingItemDetailScreen> {
  int _currentImageIndex = 0;

  void _changeMainImage(int index) {
    setState(() {
      _currentImageIndex = index;
    });
  }

  Future<void> _callVendor(BuildContext context, String phoneNumber) async {
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    
    if (cleanedNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Numéro de téléphone invalide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: cleanedNumber);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        final Uri fallbackUri = Uri(scheme: 'tel', path: cleanedNumber);
        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(fallbackUri);
        } else {
          await Clipboard.setData(ClipboardData(text: cleanedNumber));
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Appel impossible. Numéro copié: $cleanedNumber'),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openFullScreenGallery() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageGallery(
          images: widget.item.images.map((image) => 'http://localhost:9098/images/$image').toList(),
          initialIndex: _currentImageIndex,
        ),
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedReason;
        final reasons = [
          'Contenu inapproprié',
          'Information fausse ou trompeuse',
          'Prix incorrect',
          'Article déjà vendu',
          'Autre raison'
        ];

        return AlertDialog(
          title: const Text('Signaler cette publication'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Veuillez sélectionner une raison :'),
                  const SizedBox(height: 16),
                  ...reasons.map((reason) => RadioListTile<String>(
                    title: Text(reason),
                    value: reason,
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                  )).toList(),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: selectedReason == null 
                  ? null 
                  : () {
                      // Ici vous pouvez ajouter la logique pour envoyer le signalement
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Merci pour votre signalement ($selectedReason)'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
              child: const Text('Envoyer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    final surfaceColor = theme.colorScheme.surface;
    final onSurfaceColor = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.report, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Signaler'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'report') {
                _showReportDialog();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildImageCarousel(),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.item.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: onSurfaceColor,
                              ),
                            ),
                          ),
                          if (widget.item.isForRent)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Text(
                                'À louer',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (widget.item.isForSale)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: primaryColor),
                              ),
                              child: Text(
                                'À vendre',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            '${widget.item.price.toStringAsFixed(2)} TND',
                            style: TextStyle(
                              fontSize: 24,
                              color: secondaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.item.isForRent)
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                '${widget.item.rentalPrice.toStringAsFixed(2)} TND/jour',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (widget.item.condition != null && widget.item.condition!.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Condition: ${widget.item.condition}',
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: onSurfaceColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.item.description,
                              style: TextStyle(
                                fontSize: 15,
                                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.item.isForRent && widget.item.rentalTerms?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Conditions de location',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.item.rentalTerms!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueGrey,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _buildVendorRatingSection(),
                      const SizedBox(height: 16),
                      _buildReportSection(),
                                            const SizedBox(height: 16),

                    ]),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: NetworkImage(
                    'http://localhost:9098${widget.item.vendor.image ?? 'default.jpg'}',
                  ),
                  onBackgroundImageError: (_, __) {},
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.vendor.businessName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: onSurfaceColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '4.5 (24 avis)',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.phone, color: Colors.white, size: 26),
                    onPressed: () => _callVendor(context, widget.item.vendor.mobile),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    final images = widget.item.images;
    return Column(
      children: [
        GestureDetector(
          onTap: _openFullScreenGallery,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 320,
                width: double.infinity,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: Image.network(
                  'http://localhost:9098/images/${widget.item.images.isNotEmpty ? widget.item.images[_currentImageIndex] : 'default.jpg'}',
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / 
                              loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
                  ),
                ),
              ),
              if (widget.item.images.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.item.images.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentImageIndex 
                              ? Colors.white 
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (widget.item.images.length > 1)
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: widget.item.images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _changeMainImage(index),
                  child: Container(
                    width: 70,
                    height: 70,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: index == _currentImageIndex 
                            ? Theme.of(context).colorScheme.primary 
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        'http://localhost:9098/images/${widget.item.images[index]}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 24, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

   Widget _buildVendorRatingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'À propos du vendeur',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                  'http://localhost:9098${widget.item.vendor.image ?? 'default.jpg'}',
                ),
                onBackgroundImageError: (_, __) {},
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.vendor.businessName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Membre depuis 2023',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 24,
                  );
                }),
              ),
              const SizedBox(width: 8),
              const Text(
                '4.5 (24 avis)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.chat, size: 18),
                label: const Text('Message'),
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.store, size: 18),
                label: const Text('Voir la boutique'),
                onPressed: () {
                  if (widget.fromShop) {
                    // Si on vient de la boutique, on retourne en arrière
                    Navigator.pop(context);
                  } else {
                    // Sinon, on navigue normalement vers la boutique
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VendorShopScreen(
                          vendorId: widget.item.vendor.id,
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection() {
    return GestureDetector(
      onTap: _showReportDialog,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.report, color: Colors.red[400]),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Signaler cette publication',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }
}