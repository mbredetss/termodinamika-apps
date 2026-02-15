import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../materi/components/materi_data.dart';
import '../../services/storage_service.dart';
import '../../services/streak_service.dart';
import '../../services/progress_tracking_service.dart';
import '../home/components/background_wrapper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = '';
  String _userAvatar = 'assets/images/avatar-1.png';
  int _totalMateri = 0;
  int _completedMateri = 0;
  int _passedEssays = 0;
  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateStatistics();
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
            
        if (userDoc.exists) {
          Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
          String? userName = userData?['name'];
          
          if (userName != null && userName.isNotEmpty) {
            setState(() {
              _userName = userName;
            });
          }

          // Check if the avatar field exists in the document
          if (userData != null && userData.containsKey('avatar')) {
            String? userAvatar = userData['avatar'];
            if (userAvatar != null && userAvatar.isNotEmpty) {
              setState(() {
                _userAvatar = userAvatar;
              });
              
              // Also save to local storage for immediate use
              await getStorageService().setItem('user_avatar', userAvatar);
            } else {
              // Set default avatar if none exists
              setState(() {
                _userAvatar = 'assets/images/avatar-1.png';
              });
            }
          } else {
            // Avatar field doesn't exist, set default
            setState(() {
              _userAvatar = 'assets/images/avatar-1.png';
            });
          }
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> _calculateStatistics() async {
    // Calculate total and completed materi using the new progress tracking service
    _totalMateri = 0;
    _completedMateri = 0;
    _passedEssays = 0;

    for (var materi in dataMateri) {
      String materiName = materi['namaMateri'];
      var subMateriList = materi['subMateri'] as List;
      _totalMateri += subMateriList.length;

      // Count completed sub-materi for this materi
      int completedSubMateriForThisMateri = 0;
      for (var subMateri in subMateriList) {
        String subMateriName = subMateri['nama'];
        bool isCompleted = await ProgressTrackingService.getSubMateriProgress(
          materiName: materiName,
          subMateriName: subMateriName,
        );
        if (isCompleted) {
          _completedMateri++;
          completedSubMateriForThisMateri++;
        }
      }

      // If all sub-materi in this materi are completed, increment passed essays
      if (completedSubMateriForThisMateri == subMateriList.length) {
        _passedEssays++;
      }
    }

    // Update streak using the new StreakService
    await StreakService.updateStreak();
    _currentStreak = await StreakService.getCurrentStreak();

    setState(() {});
  }

  Future<void> _editProfile() async {
    // Create a controller with the current name
    final nameController = TextEditingController(text: _userName);

    // Show avatar selection dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Avatar'),
          content: StatefulBuilder(
            builder: (BuildContext context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      hintText: 'Masukkan nama kamu',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int i = 1; i <= 6; i++)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _userAvatar = 'assets/images/avatar-$i.png';
                              });
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      _userAvatar ==
                                          'assets/images/avatar-$i.png'
                                      ? const Color(
                                          0xFFFF6D00,
                                        ) // Energetic Orange
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/images/avatar-$i.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // Update user data in Firestore
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({
                      'name': nameController.text,
                      'avatar': _userAvatar,
                    });

                    // Also save to local storage for immediate use
                    await getStorageService().setItem(
                      'user_name',
                      nameController.text,
                    );
                    await getStorageService().setItem('user_avatar', _userAvatar);

                    setState(() {
                      _userName = nameController.text;
                    });
                  }
                } catch (e) {
                  print('Error updating user profile: $e');
                  // Show error message to user
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal memperbarui profil: ${e.toString()}')),
                  );
                }

                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E), // Deep Indigo
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi? Semua progress belajar Anda akan terhapus'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Clear local storage
                await getStorageService().clear();
                
                // Sign out from Firebase
                await FirebaseAuth.instance.signOut();
                
                // Navigate back to login screen
                if (mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              } catch (e) {
                print('Error during logout: $e');
                if (mounted) {
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal logout. Silakan coba lagi.')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E), // Deep Indigo
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFFFAFAFA), // White/Off-White
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Navigate back to previous screen
            },
          ),
          title: const Text(
            'Profil Pengguna',
            style: TextStyle(
              fontFamily: 'StackSansText',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFAFAFA), // White/Off-White
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.logout,
                color: Color(0xFFFAFAFA), // Energetic Orange
              ),
              onPressed: _logout,
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User Profile Section - Now scrollable too
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF212121,
                      ).withValues(alpha: 0.7), // Dark Grey with transparency
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _editProfile,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(
                                  0xFFFF6D00,
                                ), // Energetic Orange
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                _userAvatar,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _userName,
                          style: const TextStyle(
                            fontFamily: 'StackSansText',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFAFAFA), // White/Off-White
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _editProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF651FFF,
                            ), // Electric Violet
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Edit Profil',
                            style: TextStyle(
                              fontFamily: 'StackSansText',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Learning Statistics
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF212121,
                      ).withValues(alpha: 0.7), // Dark Grey with transparency
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Statistik Belajar Anda',
                            style: TextStyle(
                              fontFamily: 'StackSansText',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFAFAFA), // White/Off-White
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCard(
                              title: 'Materi Selesai',
                              value: '$_completedMateri / $_totalMateri',
                              icon: Icons.school,
                            ),
                            _buildStatCard(
                              title: 'Esai Lulus',
                              value: '$_passedEssays',
                              icon: Icons.article,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          title: '🔥 Streak',
                          value: '$_currentStreak Hari',
                          icon: Icons.local_fire_department,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Achievements Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF212121,
                      ).withValues(alpha: 0.7), // Dark Grey with transparency
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pencapaian',
                              style: TextStyle(
                                fontFamily: 'StackSansText',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFAFAFA), // White/Off-White
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigate to achievements screen
                                _showAllAchievements();
                              },
                              child: Text(
                                'Lihat Semua',
                                style: TextStyle(
                                  fontFamily: 'StackSansText',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFAFAFA), // White/Off-White
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 100,
                          child: _buildAchievementsList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24), // Add some space at the bottom
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E), // Deep Indigo
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFFFF6D00), // Energetic Orange
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'StackSansText',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFAFAFA), // White/Off-White
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'StackSansText',
              fontSize: 12,
              color: Color(0xFFFAFAFA), // White/Off-White
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList() {
    // Determine which achievements the user has unlocked based on progress
    List<Map<String, dynamic>> achievements = [];

    // Achievement: First Material
    if (_completedMateri > 0) {
      achievements.add({
        'icon': Icons.emoji_events,
        'title': 'Materi Pertama',
        'subtitle': 'Selesai materi pertama',
        'unlocked': true,
      });
    } else {
      achievements.add({
        'icon': Icons.lock_outline,
        'title': 'Materi Pertama',
        'subtitle': 'Selesaikan materi pertama',
        'unlocked': false,
      });
    }

    // Achievement: Complete Law I
    bool lawIOneComplete = false;
    for (var materi in dataMateri) {
      if (materi['namaMateri'] == 'Gas Ideal') {
        var subMateriList = materi['subMateri'] as List;
        for (var subMateri in subMateriList) {
          if (subMateri['nama'] == 'Hukum I Termodinamika' &&
              subMateri['isDone'] == true) {
            lawIOneComplete = true;
            break;
          }
        }
        break;
      }
    }

    if (lawIOneComplete) {
      achievements.add({
        'icon': Icons.lightbulb,
        'title': 'Hukum I',
        'subtitle': 'Lulus esai materi Hukum I',
        'unlocked': true,
      });
    } else {
      achievements.add({
        'icon': Icons.lock_outline,
        'title': 'Hukum I',
        'subtitle': 'Lulus esai materi Hukum I',
        'unlocked': false,
      });
    }

    // Achievement: 5-Day Streak
    if (_currentStreak >= 5) {
      achievements.add({
        'icon': Icons.local_fire_department,
        'title': 'Streak 5 Hari',
        'subtitle': 'Login 5 hari berturut-turut',
        'unlocked': true,
      });
    } else {
      achievements.add({
        'icon': Icons.lock_outline,
        'title': 'Streak 5 Hari',
        'subtitle': 'Login 5 hari berturut-turut',
        'unlocked': false,
      });
    }

    // Achievement: Complete All
    if (_completedMateri == _totalMateri) {
      achievements.add({
        'icon': Icons.library_books,
        'title': 'Cendekia',
        'subtitle': 'Selesaikan semua materi',
        'unlocked': true,
      });
    } else {
      achievements.add({
        'icon': Icons.lock_outline,
        'title': 'Cendekia',
        'subtitle': 'Selesaikan semua materi',
        'unlocked': false,
      });
    }

    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(), // Prevents the ListView from handling scrolls in a conflicting way
        children: achievements.map((achievement) {
          return _buildAchievementBadge(
            icon: achievement['icon'],
            title: achievement['title'],
            subtitle: achievement['subtitle'],
            unlocked: achievement['unlocked'],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAchievementBadge({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool unlocked,
  }) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: unlocked
            ? const Color(0xFF1A237E) // Deep Indigo for unlocked
            : const Color(0xFF616161), // Grey for locked
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: unlocked
                ? const Color(0xFFFF6D00) // Energetic Orange for unlocked
                : const Color(0xFFBDBDBD), // Light grey for locked
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'StackSansText',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: unlocked
                  ? const Color(0xFFFAFAFA) // White/Off-White for unlocked
                  : const Color(0xFFBDBDBD), // Light grey for locked
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'StackSansText',
              fontSize: 8,
              color: unlocked
                  ? const Color(0xFFFAFAFA) // White/Off-White for unlocked
                  : const Color(0xFFBDBDBD), // Light grey for locked
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAllAchievements() {
    // Show all achievements in a dialog
    List<Map<String, dynamic>> allAchievements = [
      {
        'icon': Icons.emoji_events,
        'title': 'Materi Pertama',
        'subtitle': 'Selesai materi pertama',
        'unlocked': _completedMateri > 0,
      },
      {
        'icon': Icons.lightbulb,
        'title': 'Hukum I',
        'subtitle': 'Lulus esai materi Hukum I',
        'unlocked': _evaluateHukumIOne(),
      },
      {
        'icon': Icons.local_fire_department,
        'title': 'Streak 5 Hari',
        'subtitle': 'Login 5 hari berturut-turut',
        'unlocked': _currentStreak >= 5,
      },
      {
        'icon': Icons.library_books,
        'title': 'Cendekia',
        'subtitle': 'Selesaikan semua materi',
        'unlocked': _completedMateri == _totalMateri,
      },
      {
        'icon': Icons.rocket_launch,
        'title': 'Peluncur',
        'subtitle': 'Selesaikan 3 materi pertama',
        'unlocked': _completedMateri >= 3,
      },
      {
        'icon': Icons.school,
        'title': 'Sarjana',
        'subtitle': 'Selesaikan 75% dari materi',
        'unlocked':
            _totalMateri > 0 && (_completedMateri / _totalMateri) >= 0.75,
      },
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Semua Pencapaian'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: allAchievements.length,
              itemBuilder: (context, index) {
                var achievement = allAchievements[index];
                bool unlocked = achievement['unlocked'];

                return ListTile(
                  leading: Icon(
                    achievement['icon'],
                    color: unlocked
                        ? const Color(
                            0xFFFF6D00,
                          ) // Energetic Orange for unlocked
                        : const Color(0xFFBDBDBD), // Light grey for locked
                  ),
                  title: Text(
                    achievement['title'],
                    style: TextStyle(
                      color: unlocked
                          ? const Color(
                              0xFFFAFAFA,
                            ) // White/Off-White for unlocked
                          : const Color(0xFFBDBDBD), // Light grey for locked
                    ),
                  ),
                  subtitle: Text(
                    achievement['subtitle'],
                    style: TextStyle(
                      color: unlocked
                          ? const Color(
                              0xFFFAFAFA,
                            ) // White/Off-White for unlocked
                          : const Color(0xFFBDBDBD), // Light grey for locked
                    ),
                  ),
                  trailing: unlocked
                      ? const Icon(
                          Icons.check_circle,
                          color: Color(0xFF4CAF50), // Green for unlocked
                        )
                      : const Icon(
                          Icons.lock,
                          color: Color(0xFFBDBDBD), // Light grey for locked
                        ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  bool _evaluateHukumIOne() {
    if (dataMateri.isNotEmpty) {
      var firstMateri = dataMateri[0];
      return firstMateri['isDoneMateri'] == true;
    }
    return false;
  }
}
