// reservation_page.dart
import 'package:dumum_tergo/constants/colors.dart';
import 'package:dumum_tergo/models/reservation_model.dart';
import 'package:dumum_tergo/services/reservation_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReservationPage extends StatefulWidget {
  final String? authToken;

  const ReservationPage({super.key, this.authToken});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  late Future<List<Reservation>> futureReservations;

  @override
  void initState() {
    super.initState();
    futureReservations = _loadReservations();
  }

  Future<List<Reservation>> _loadReservations() async {
    try {
      final data = await ReservationService().getUserReservations();
      return data.map((json) => Reservation.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réservations'),
      ),
      body: FutureBuilder<List<Reservation>>(
        future: futureReservations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune réservation trouvée'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final reservation = snapshot.data![index];
              return ReservationCard(reservation: reservation);
            },
          );
        },
      ),
    );
  }
}

class ReservationCard extends StatelessWidget {
  final Reservation reservation;

  const ReservationCard({super.key, required this.reservation});

   String getTranslatedStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration = reservation.endDate.difference(reservation.startDate).inDays;
    final dateFormat = DateFormat('dd/MM/yyyy');

final priceFormat = NumberFormat.currency(locale: 'fr_TN', symbol: 'TND', decimalDigits: 2);

    return Container(
        decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    
                  ),
                  
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec modèle de voiture et statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Flexible(
                  child: Text(
                    '${reservation.car.brand} ${reservation.car.model}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: getStatusColor(reservation.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: getStatusColor(reservation.status),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    getTranslatedStatus(reservation.status).toUpperCase(),
                    style: TextStyle(
                      color: getStatusColor(reservation.status),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // Informations loueur et lieu
            Text(
              'Loueur: ${reservation.vendor.businessName}',
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              'Lieu: ${reservation.location}',
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            
            // Période de location
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    '${dateFormat.format(reservation.startDate)} - ${dateFormat.format(reservation.endDate)}',
                  ),
                ),
                const SizedBox(width: 10),
                Text('($duration jours)'),
              ],
            ),
            const SizedBox(height: 10),
            
            // Prix
            Row(
              children: [
              //  const Icon(Icons.euro, size: 16),
                const SizedBox(width: 5),
                Text(
                  'Prix: ${priceFormat.format(reservation.totalPrice)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 15),
            
            // Informations conducteur
            const Text(
              'Informations conducteur:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('${reservation.driverDetails.firstName} ${reservation.driverDetails.lastName}'),
            Text(reservation.driverDetails.email),
            Text(reservation.driverDetails.phoneNumber),
            const SizedBox(height: 15),
            
            // Boutons d'action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              
                if (reservation.status == 'pending') ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Annulationfr
                      },
                      style: ElevatedButton.styleFrom(

                          backgroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      child: const Text('Annuler'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
