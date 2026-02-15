import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current authenticated user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign in with email and password
  static Future<UserCredential?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      throw e;
    }
  }

  // Register new user
  static Future<UserCredential?> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store additional user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'riwayatNilaiUjian': [],
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      throw e;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Get user data from Firestore
  static Future<DocumentSnapshot> getUserData(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }
  
  // Get user avatar from Firestore with fallback
  static Future<String> getUserAvatar(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
        // Check if the avatar field exists in the document
        if (userData != null && userData.containsKey('avatar')) {
          String? userAvatar = userData['avatar'];
          if (userAvatar != null && userAvatar.isNotEmpty) {
            return userAvatar;
          }
        }
      }
    } catch (e) {
      print('Error getting user avatar: $e');
    }
    
    // Return default avatar if not found
    return 'assets/images/avatar-1.png';
  }

  // Update user profile
  static Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? avatar,
  }) async {
    Map<String, dynamic> updateData = {};
    
    if (name != null) updateData['name'] = name;
    if (avatar != null) updateData['avatar'] = avatar;
    
    await _firestore.collection('users').doc(userId).update(updateData);
  }

  // Update user completion status
  static Future<void> updateUserCompletionStatus({
    required String userId,
    required bool isCompleted,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'isCompleted': isCompleted,
    });
  }

  // Add quiz attempt to user's history
  static Future<void> addQuizAttempt({
    required String userId,
    required String materiName,
    required int correctAnswers,
    required int totalQuestions,
    required bool isPassed,
    required DateTime date,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('quizHistory')
        .add({
      'materiName': materiName,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'isPassed': isPassed,
      'percentage': (correctAnswers / totalQuestions) * 100,
      'date': date.toIso8601String(),
    });
  }

  // Get user's quiz history
  static Future<List<Map<String, dynamic>>> getUserQuizHistory({
    required String userId,
    required String materiName,
  }) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('quizHistory')
        .where('materiName', isEqualTo: materiName)
        .orderBy('date', descending: true)
        .get();

    List<Map<String, dynamic>> history = [];
    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Include document ID
      history.add(data);
    }

    return history;
  }
}