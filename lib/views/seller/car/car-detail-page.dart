import 'package:dumum_tergo/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CarDetailPage extends StatefulWidget {
  final Map<String, dynamic> car;
  final VoidCallback? onCarDeleted;
  final VoidCallback onBack;

  const CarDetailPage({
    Key? key,
    required this.car,
    this.onCarDeleted,
    required this.onBack,
  }) : super(key: key);

  @override
  _CarDetailPageState createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  final storage = const FlutterSecureStorage();

  Future<void> deleteCar(BuildContext context) async {
    try {
      final token = await storage.read(key: 'seller_token');

      final response = await http.delete(
        Uri.parse('http://127.0.0.1:9098/api/cars/cars/${widget.car['_id']}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        widget.onCarDeleted?.call();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voiture supprimée avec succès'),
            backgroundColor: Colors.green,
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            widget.onBack();
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${json.decode(response.body)['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text(
              'Voulez-vous vraiment supprimer cette voiture et toutes ses réservations?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Supprimer',
                  style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                deleteCar(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: color ?? AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label $value',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateChips(List<dynamic> dates) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: dates.map<Widget>((date) {
        try {
          String formattedDate = 'Date invalide';

          if (date is Map && date['from'] != null && date['to'] != null) {
            final fromDate = DateTime.parse(date['from']);
            final toDate = DateTime.parse(date['to']);
            formattedDate =
                '${dateFormat.format(fromDate)} - ${dateFormat.format(toDate)}';
          }

          return Chip(
            label: Text(formattedDate),
            backgroundColor: Colors.orange[50],
            labelStyle: const TextStyle(color: Colors.orange),
            side: BorderSide(color: Colors.orange[100]!),
          );
        } catch (e) {
          return Chip(
            label: const Text('Format invalide'),
            backgroundColor: Colors.red[50],
            labelStyle: const TextStyle(color: Colors.red),
          );
        }
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    String createdAt = 'Date inconnue';

    if (widget.car['createdAt'] != null) {
      try {
        if (widget.car['createdAt'] is String) {
          createdAt = dateFormat.format(DateTime.parse(widget.car['createdAt']));
        } else if (widget.car['createdAt'] is Map &&
            widget.car['createdAt']['\$date'] != null) {
          createdAt = dateFormat
              .format(DateTime.parse(widget.car['createdAt']['\$date']));
        } else if (widget.car['createdAt'] is DateTime) {
          createdAt = dateFormat.format(widget.car['createdAt']);
        }
      } catch (e) {
        createdAt = 'Format de date invalide';
      }
    }

    bool hasUnavailableDates = widget.car['unavailableDates'] != null &&
        widget.car['unavailableDates'] is List &&
        widget.car['unavailableDates'].isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Détails de voiture',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _confirmDelete(context),
        backgroundColor: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
        tooltip: 'Supprimer la voiture',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Galerie d'images
            if (widget.car['images'] != null && widget.car['images'] is List)
              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: (widget.car['images'] as List).length,
                    itemBuilder: (context, index) {
                      String imageUrl =
                          "http://127.0.0.1:9098/images/${widget.car['images'][index]}";
                      return Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Prix et informations principales
            Card(
  color: Colors.white,
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prix par jour avec une icône
        Row(
          children: [
          
            SizedBox(width: 8),
            Text(
              "${widget.car['pricePerDay']} TND/jour",
              style: const TextStyle(
                fontSize: 22,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),

        // Informations détaillées avec des icônes
_buildInfoRow('Location:', widget.car['location']['title'], Icons.location_pin),
        _buildInfoRow('Année:', widget.car['year'].toString(), Icons.calendar_today),
        _buildInfoRow('Immatriculation:', widget.car['registrationNumber'], Icons.confirmation_number),
        _buildInfoRow('Couleur:', widget.car['color'], Icons.palette),
        _buildInfoRow('Places:', widget.car['seats'].toString(), Icons.people),
        _buildInfoRow('Transmission:', widget.car['transmission'], Icons.speed),
        _buildInfoRow('Kilométrage:', widget.car['mileagePolicy'], Icons.directions_car),
        _buildInfoRow('Caution:', '${widget.car['deposit']} TND', Icons.monetization_on),
        _buildInfoRow(
            'Disponibilité:',
            widget.car['isAvailable'] ? 'Disponible' : 'Non disponible',
            widget.car['isAvailable'] ? Icons.check_circle : Icons.cancel,
            color: widget.car['isAvailable'] ? Colors.green : Colors.red),
        _buildInfoRow('Ajoutée le:', createdAt, Icons.access_time),
      ],
    ),
  ),
),

            // Dates indisponibles
            if (hasUnavailableDates) ...[
              const SizedBox(height: 20),
           ExpansionTile(
  title: const Text(
    'Dates indisponibles:',
    style: TextStyle(
      
      fontSize: 18,
      fontWeight: FontWeight.bold,
      //color: Colors.blueGrey,
    ),
  ),
  children: [
    Padding(
      padding: const EdgeInsets.all(16.0),
      child: _buildDateChips(widget.car['unavailableDates']),
    ),
  ],
)

            ],

            // Équipements
            const SizedBox(height: 20),
            ExpansionTile(
  title: const Text(
    'Équipements et caractéristiques:',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  children: [
    Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: (widget.car['features'] as List).map<Widget>((feature) {
          return Chip(
            label: Text(
              feature,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }).toList(),
      ),
    ),
  ],
)
,
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}