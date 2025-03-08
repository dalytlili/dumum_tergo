// viewmodels/profile_viewmodel.dart
import '../models/user_model.dart';

class ProfileViewModel {
  User _user = User(
    name: 'Nate Samson',
    email: 'nate@email.con',
    mobileNumber: '+216 Your mobile number',
    gender: 'Male',
    address: 'Address',
    password: 'password'

  );

  User get user => _user;
}