import 'package:dumum_tergo/views/user/car/full_screen_image_gallery.dart';
import 'package:dumum_tergo/views/user/car/responsibility_page.dart';
import 'package:flutter/material.dart';
import 'package:dumum_tergo/constants/colors.dart';

class CarReservationDetails extends StatefulWidget {
  final Map<String, dynamic> car;
  final DateTime pickupDate;
  final DateTime returnDate;
  final String pickupLocation;

  const CarReservationDetails({
    Key? key,
    required this.car,
        required this.pickupLocation,

    required this.pickupDate,
    required this.returnDate,
  }) : super(key: key);

  @override
  _CarReservationDetailsState createState() => _CarReservationDetailsState();
}

class _CarReservationDetailsState extends State<CarReservationDetails> {
  // Variables d'état pour les options
  int _additionalDriverQuantity = 0;
  int _childSeatQuantity = 0;
  double _additionalOptionsPrice = 0;
  int currentPage = 0;

  // Méthode pour calculer les jours de location
  int _calculateRentalDays() {
    final duration = widget.returnDate.difference(widget.pickupDate);
    return duration.inDays;
  }

  // Méthode pour calculer le prix total
  double _calculateTotalPrice() {
    final days = _calculateRentalDays();
    final pricePerDay = double.parse(widget.car['pricePerDay'].toString());
    return (days * pricePerDay) + _additionalOptionsPrice;
  }

  @override
  Widget build(BuildContext context) {
    // Définir l'URL de base du serveur
    const String baseUrl = "http://127.0.0.1:9098/images/";
    
    // Construire la liste des URLs complètes
    List<String> images = (widget.car['images'] as List<dynamic>?)
        ?.map((image) => "$baseUrl$image")
        .toList() ?? [];
    
    // Créer un controller pour gérer les pages
    final PageController pageController = PageController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Votre offre'),
      ),
      body: Column(
        children: [
          // Partie défilable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Votre offre',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  const Text('Suivant... Responsabilité et Caution'),
                  const SizedBox(height: 24),

               Row(
  children: [
    Expanded(
      child: Column(
        children: [
          Container(height: 2, color: AppColors.primary),
          const SizedBox(height: 4),
        ],
      ),
    ),
    Expanded(
      child: Column(
        children: [
          Container(height: 2, color: Colors.grey),
          const SizedBox(height: 4),
        ],
      ),
    ),
    Expanded(
      child: Column(
        children: [
          Container(height: 2, color: Colors.grey),
          const SizedBox(height: 4),
        ],
      ),
    ),
  ],
),


                  const SizedBox(height: 24),
                
                  // Détails du véhicule
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Détails du véhicule',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (images.isNotEmpty)
                          StatefulBuilder(
                            builder: (context, setState) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullScreenImageGallery(
                                        images: images,
                                        initialIndex: currentPage,
                                      ),
                                    ),
                                  );
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 200,
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey[200],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: PageView.builder(
                                          controller: pageController,
                                          itemCount: images.length,
                                          onPageChanged: (index) {
                                            setState(() {
                                              currentPage = index;
                                            });
                                          },
                                          itemBuilder: (context, index) {
                                            return Image.network(
                                              images[index],
                                              fit: BoxFit.cover,
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
                                              errorBuilder: (context, error, stackTrace) {
                                                return const Center(
                                                  child: Icon(Icons.error, color: Colors.red),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(images.length, (index) {
                                          return AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            margin: const EdgeInsets.symmetric(horizontal: 4),
                                            width: currentPage == index ? 12 : 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: currentPage == index
                                                  ? Theme.of(context).primaryColor
                                                  : Colors.grey.withOpacity(0.5),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        Text(
                          '${widget.car['brand']} ${widget.car['model']} (${widget.car['year']})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.car['color']} • ${widget.car['registrationNumber']}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildFeatureRow('${widget.car['seats']} sièges', icon: Icons.airline_seat_recline_normal),
                        _buildFeatureRow('${widget.car['transmission']}', icon: Icons.settings),
                        _buildFeatureRow('Kilométrage ${widget.car['mileagePolicy']}', icon: Icons.speed),
                        Text(
                          'caractéristiques:',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        ...widget.car['features'].map<Widget>((feature) => 
                          _buildFeatureItem(feature, useDash: true)
                        ).toList(),
                        
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        
                        Text(
                          widget.car['location'] ?? 'Emplacement non spécifié',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: widget.car['vendor']['image'] != null 
                                  ? NetworkImage("http://127.0.0.1:9098${widget.car['vendor']['image'] ?? '/images/default.png'}") 
                                  : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.car['vendor']['businessName'] ?? 'Vendor',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '4.8',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'Ajoutez des options, complétez votre voyage',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Option Conducteur supplémentaire
                  _buildOptionCard(
                    title: 'Conducteur supplémentaire',
                    price: '30 TND pièce par location',
                    description: 'Partagez la conduite et gardez l\'esprit tranquille sachant que quelqu\'un d\'autre est couvert si besoin.',
                    quantity: _additionalDriverQuantity,
                    onIncrement: () {
                      if (_additionalDriverQuantity < 2) {
                        setState(() {
                          _additionalDriverQuantity++;
                          _additionalOptionsPrice += 30;
                        });
                      }
                    },
                    onDecrement: () {
                      if (_additionalDriverQuantity > 0) {
                        setState(() {
                          _additionalDriverQuantity--;
                          _additionalOptionsPrice -= 30;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Option Siège enfant
                  _buildOptionCard(
                    title: 'Siège enfant',
                    price: '30 TND pièce par location',
                    description: 'Recommandé pour les enfants pesant 9-18 kg (env. 1-3 ans)',
                    quantity: _childSeatQuantity,
                    onIncrement: () {
                      if (_childSeatQuantity < 2) {
                        setState(() {
                          _childSeatQuantity++;
                          _additionalOptionsPrice += 30;
                        });
                      }
                    },
                    onDecrement: () {
                      if (_childSeatQuantity > 0) {
                        setState(() {
                          _childSeatQuantity--;
                          _additionalOptionsPrice -= 30;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  Text(
  'Nous transmettrons vos demandes d\'options à ${widget.car['vendor']['businessName'] ?? 'Vendor'} et vous les paierez lors de la prise en charge. '
  'La disponibilité et les tarifs des options ne peuvent pas être garantis avant votre arrivée.',
  style: TextStyle(
    color: Colors.grey[600],
    fontSize: 12,
  ),
),


                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          // Partie fixe en bas
          Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    border: const Border(
      top: BorderSide(color: Colors.grey, width: 1),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, -5),
      ),
    ],
  ),
  child: Column(
    children: [
      Text(
        'Durée de location: ${_calculateRentalDays()} jours',
        style: TextStyle(color: Colors.grey[600]),
      ),
      const SizedBox(height: 4),
      Text(
        'Prix par jour : ${widget.car['pricePerDay']} TND',
        style: TextStyle(color: Colors.grey[600]),
      ),
      const SizedBox(height: 4),
      Text(
        'Prix total: ${_calculateTotalPrice().toStringAsFixed(2)} TND',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
         style: ElevatedButton.styleFrom(

                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
      
onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ResponsibilityPage(
        car: widget.car,          
        pickupLocation: widget.pickupLocation,
        pickupDate: widget.pickupDate,
        returnDate: widget.returnDate,
        totalPrice: _calculateTotalPrice(),
        additionalDrivers: _additionalDriverQuantity, // Ajoutez cette ligne
        childSeats: _childSeatQuantity, // Ajoutez cette ligne
      ),
    ),
  );
},

            child: const Text(
              'Continuer la réservation',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      )
    ],
  ),
)
        ]
      ),
    );
  }

Widget _buildOptionCard({
  required String title,
  required String price,
  required String description,
  required int quantity,
  required VoidCallback onIncrement,
  required VoidCallback onDecrement,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Price + Quantity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        price,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Quantity Selector
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: quantity > 0 ? onDecrement : null,
                      visualDensity: VisualDensity.compact,
                    ),
                    Text(
                      '$quantity',
                      style: const TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: quantity < 2 ? onIncrement : null,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    },
  );
}


  Widget _buildFeatureItem(String feature, {bool useDash = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          useDash
              ? Text(' • ', style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold))
              : Icon(Icons.check_circle_outline,
                  size: 18, 
                  color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String text, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          if (icon != null) Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}