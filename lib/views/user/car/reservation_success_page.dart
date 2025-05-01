// lib/views/user/reservation_success_page.dart
import 'package:dumum_tergo/views/user/home_view.dart';
import 'package:flutter/material.dart';
class ReservationSuccessPage extends StatelessWidget {
  final Map<String, dynamic> reservationData;

  const ReservationSuccessPage({Key? key, required this.reservationData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Vérifiez d'abord la structure des données reçues
    final car = reservationData['car'] is Map ? reservationData['car'] : {};
    final brand = car['brand']?.toString() ?? 'Inconnu';
    final model = car['model']?.toString() ?? 'Inconnu';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation de réservation'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text(
              'Réservation confirmée!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            _buildDetailRow('Référence', reservationData['_id']?.toString() ?? ''),
            _buildDetailRow('Véhicule', '$brand $model'),
            _buildDetailRow('Période', '${_formatDate(reservationData['startDate'])} - ${_formatDate(reservationData['endDate'])}'),
            _buildDetailRow('Lieu', reservationData['location']?.toString() ?? ''),
            _buildDetailRow('Prix total', '${reservationData['totalPrice']?.toString() ?? '0'} TND'),
            const Spacer(),
            Center(
              child: ElevatedButton(
  onPressed: () {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeView()),
      (Route<dynamic> route) => false,
    );
  },
  style: ElevatedButton.styleFrom(
    minimumSize: const Size(200, 50),
  ),
  child: const Text("Retour à l'accueil"),
)

            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('$label : ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    try {
      if (date is String) {
        final parsedDate = DateTime.parse(date);
        return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
      }
      return 'Date inconnue';
    } catch (e) {
      return 'Date inconnue';
    }
  }
}