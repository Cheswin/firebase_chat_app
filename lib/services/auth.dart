import 'package:firebase_auth/firebase_auth.dart';

class Authmethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return await auth.currentUser;
  }
}
