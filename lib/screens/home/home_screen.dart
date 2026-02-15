import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:termodinamika_apps/screens/relax/relax_screen.dart';
import 'package:termodinamika_apps/services/platform_storage_service.dart';
import '../materi/materi_screen.dart';
import '../materi/components/materi_data.dart';
import '../materi/components/module_list_screen.dart';
import '../profile/profile_screen.dart'; // Add import for Profile screen
import '../../services/storage_service.dart';
import '../../services/tutorial_service.dart';
import 'components/background_wrapper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  double _progressValue = 0.0;
  final List<Map<String, dynamic>> _completedSubMateri = [];
  final List<Map<String, dynamic>> _incompleteSubMateri = [];
  bool _tutorialCompleted = false;

  // Keys for UI elements that will be highlighted in the tutorial
  final GlobalKey _greetingKey = GlobalKey();
  final GlobalKey _progressKey = GlobalKey();
  final GlobalKey _continueLearningKey = GlobalKey();
  final GlobalKey _quickAccessKey = GlobalKey();
  final GlobalKey _bottomNavKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _checkTutorialStatus();
    _loadUserName();
    _loadProgressFromStorage();
    
    // Check if user has avatar, if not show avatar selection dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowAvatarSelection();
    });
  }
  
  Future<void> _checkAndShowAvatarSelection() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
          
      if (userDoc.exists) {
        Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
        if (userData != null && userData.containsKey('avatar')) {
          String? userAvatar = userData['avatar'];
          if (userAvatar == null || userAvatar.isEmpty) {
            // User doesn't have an avatar, show selection dialog
            _showAvatarSelectionDialog();
          } else {
            // Save avatar to local storage for immediate use
            await getStorageService().setItem('user_avatar', userAvatar);
          }
        } else {
          // Avatar field doesn't exist, show selection dialog
          _showAvatarSelectionDialog();
        }
      }
    }
  }

  Future<void> _checkTutorialStatus() async {
    bool completed = await TutorialService.isTutorialCompleted();
    setState(() {
      _tutorialCompleted = completed;
    });
  }

  Future<void> _loadUserName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          String? userName = userDoc.get('name');
          if (userName != null && userName.isNotEmpty) {
            setState(() {
              _userName = userName;
            });

            // If user has a name but hasn't completed the tutorial, show it after UI is built
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_tutorialCompleted) {
                _showTutorial();
              }
            });
          }
        }
      }
    } catch (e) {
      print('Error loading user name: $e');
    }
  }

  Future<void> _showAvatarSelectionDialog() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String selectedAvatar = 'assets/images/avatar-1.png'; // Default avatar

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false, // Prevent back button from dismissing the dialog
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: const Text('Selamat Datang!'),
                content: SizedBox(
                  height: 300,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Pilih avatar untuk memulai belajar:',
                      ),
                      const SizedBox(height: 16),
                      const Text('Pilih Avatar:'),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: Column(
                          children: [
                            // First row of avatars (avatars 1-3)
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  for (int i = 1; i <= 3; i++)
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedAvatar =
                                                'assets/images/avatar-$i.png';
                                          });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color:
                                                  selectedAvatar ==
                                                      'assets/images/avatar-$i.png'
                                                  ? const Color(
                                                      0xFFFF6D00,
                                                    ) // Energetic Orange
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: Image.asset(
                                              'assets/images/avatar-$i.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Second row of avatars (avatars 4-6)
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  for (int i = 4; i <= 6; i++)
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedAvatar =
                                                'assets/images/avatar-$i.png';
                                          });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color:
                                                  selectedAvatar ==
                                                      'assets/images/avatar-$i.png'
                                                  ? const Color(
                                                      0xFFFF6D00,
                                                    ) // Energetic Orange
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: Image.asset(
                                              'assets/images/avatar-$i.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Show tutorial when user presses 'Batal'
                      Navigator.of(context).pop(); // Close without saving
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!_tutorialCompleted) {
                          _showTutorial();
                        }
                      });
                    },
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save avatar to Firestore
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .update({
                        'avatar': selectedAvatar,
                      });
                      
                      // Also save to local storage for immediate use
                      await getStorageService().setItem('user_avatar', selectedAvatar);
                      
                      Navigator.of(context).pop();

                      // Show tutorial after user saves their information
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!_tutorialCompleted) {
                          _showTutorial();
                        }
                      });
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
          ),
        );
      },
    );
  }

  Future<void> _loadProgressFromStorage() async {
    // First, load saved progress from storage to update the dataMateri
    List<Map<String, dynamic>>? savedData = await StorageService.loadProgress();
    if (savedData != null && savedData.isNotEmpty) {
      // Update the global dataMateri with saved progress
      for (int i = 0; i < dataMateri.length && i < savedData.length; i++) {
        var savedMateri = savedData[i];
        if (savedMateri.containsKey('isDoneMateri')) {
          dataMateri[i]['isDoneMateri'] = savedMateri['isDoneMateri'] ?? false;
        }

        var savedSubMateriList = savedMateri['subMateri'] as List?;
        var currentSubMateriList = dataMateri[i]['subMateri'] as List?;

        if (savedSubMateriList != null && currentSubMateriList != null) {
          for (
            int j = 0;
            j < currentSubMateriList.length && j < savedSubMateriList.length;
            j++
          ) {
            var savedSubMateri = savedSubMateriList[j] as Map<String, dynamic>?;
            if (savedSubMateri != null &&
                savedSubMateri.containsKey('isDone')) {
              currentSubMateriList[j]['isDone'] =
                  savedSubMateri['isDone'] ?? false;
            }
          }
        }
      }
    }

    // Now calculate the actual progress values
    _calculateProgress();
  }

  void _calculateProgress() {
    int totalSubMateri = 0;
    int completedSubMateri = 0;

    _completedSubMateri.clear();
    _incompleteSubMateri.clear();

    for (var materi in dataMateri) {
      var subMateriList = materi['subMateri'] as List;
      totalSubMateri += subMateriList.length;

      for (var subMateri in subMateriList) {
        var subMateriWithMateri = Map<String, dynamic>.from(subMateri);
        subMateriWithMateri['materiName'] = materi['namaMateri'];

        if (subMateri['isDone'] == true) {
          completedSubMateri++;
          _completedSubMateri.add(subMateriWithMateri);
        } else {
          _incompleteSubMateri.add(subMateriWithMateri);
        }
      }
    }

    if (totalSubMateri == 0) {
      _progressValue = 0.0;
    } else {
      _progressValue = (completedSubMateri / totalSubMateri) * 100;
    }

    // Update the UI after loading progress
    if (mounted) {
      setState(() {});
    }
  }

  // Find the first incomplete sub materi to suggest to the user
  Map<String, dynamic>? _findNextIncompleteSubMateri() {
    if (_incompleteSubMateri.isNotEmpty) {
      return _incompleteSubMateri.first;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    int totalSubMateri = 0;
    int completedSubMateri = 0;

    // Calculate current progress based on dataMateri (already updated from storage)
    for (var materi in dataMateri) {
      var subMateriList = materi['subMateri'] as List;
      totalSubMateri += subMateriList.length;

      for (var subMateri in subMateriList) {
        if (subMateri['isDone'] == true) {
          completedSubMateri++;
        }
      }
    }

    Map<String, dynamic>? nextSubMateri = _findNextIncompleteSubMateri();

    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Top section with greeting and progress
                Container(
                  key: _greetingKey,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF212121,
                    ).withValues(alpha: 0.7), // Dark Grey with transparency
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Halo, $_userName! 👋',
                          style: const TextStyle(
                            fontFamily: 'StackSansText',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFAFAFA), // White/Off-White
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Progres Keseluruhan:',
                                  style: const TextStyle(
                                    fontFamily: 'StackSansText',
                                    fontSize: 16,
                                    color: Color(0xFFFAFAFA),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  key: _progressKey,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: _progressValue / 100,
                                      minHeight: 10,
                                      backgroundColor: const Color(
                                        0xFF651FFF,
                                      ), // Electric Violet
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Color(
                                              0xFFFF6D00,
                                            ), // Energetic Orange
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A237E), // Deep Indigo
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_progressValue.toInt()}%',
                              style: const TextStyle(
                                fontFamily: 'StackSansText',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFAFAFA),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kamu telah menyelesaikan $completedSubMateri/$totalSubMateri materi',
                        style: const TextStyle(
                          fontFamily: 'StackSansText',
                          fontSize: 14,
                          color: Color(0xFFFAFAFA),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Main CTA Card
                Container(
                  key: _continueLearningKey,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF212121,
                    ).withValues(alpha: 0.7), // Dark Grey with transparency
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A237E), // Deep Indigo
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Lanjut Belajar',
                            style: TextStyle(
                              fontFamily: 'StackSansText',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFAFAFA),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (nextSubMateri != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nextSubMateri['nama'] ?? 'Materi Baru',
                              style: const TextStyle(
                                fontFamily: 'StackSansText',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFFAFAFA),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () {
                                _navigateToMateriScreen(
                                  nextSubMateri['isiMateri'],
                                  nextSubMateri['nama'],
                                );
                              },
                              icon: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Mulai Belajar',
                                style: TextStyle(
                                  fontFamily: 'StackSansText',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFFFF6D00,
                                ), // Energetic Orange
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kamu telah menyelesaikan semua materi! 🎉',
                              style: TextStyle(
                                fontFamily: 'StackSansText',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFFAFAFA),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ModuleListScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.school,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Lihat Semua Materi',
                                style: TextStyle(
                                  fontFamily: 'StackSansText',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFFFF6D00,
                                ), // Energetic Orange
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Quick Access Section
                        Container(
                          key: _quickAccessKey,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF212121,
                            ).withValues(alpha: 0.7), // Dark Grey with transparency
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Akses Cepat',
                                style: TextStyle(
                                  fontFamily: 'StackSansText',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFAFAFA),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildQuickAccessItem(
                                    icon: Icons.school,
                                    label: 'Semua Materi',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ModuleListScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  _buildQuickAccessItem(
                                    icon: Icons.calculate,
                                    label: 'Daftar Rumus',
                                    onTap: () {
                                      // Placeholder for formulas page
                                      _showFormulaScreen();
                                    },
                                  ),
                                  _buildQuickAccessItem(
                                    icon: Icons.person,
                                    label: 'Profil',
                                    onTap: () {
                                      // Placeholder for profile page
                                      _showProfileScreen();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Interesting Fact Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF212121,
                            ).withValues(alpha: 0.7), // Dark Grey with transparency
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Fakta Menarik',
                                style: TextStyle(
                                  fontFamily: 'StackSansText',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFAFAFA),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A237E).withValues(alpha: 0.5), // Deep Indigo with transparency
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '"Tahukah Anda bahwa mesin Carnot adalah mesin termal ideal yang memiliki efisiensi maksimum?"',
                                  style: TextStyle(
                                    fontFamily: 'StackSansText',
                                    fontSize: 14,
                                    color: Color(0xFFFAFAFA),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          key: _bottomNavKey,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF212121), // Dark Grey
          selectedItemColor: const Color(0xFFFF6D00), // Energetic Orange
          unselectedItemColor: const Color(0xFFFAFAFA), // White/Off-White
          selectedLabelStyle: const TextStyle(
            fontFamily: 'StackSansText',
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'StackSansText',
            fontSize: 12,
          ),
          currentIndex: 0, // Home is selected by default
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Materi'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
          onTap: (index) {
            // Handle navigation based on index
            switch (index) {
              case 0:
                // Already on Home
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ModuleListScreen(),
                  ),
                );
                break;
              case 2:
                _showProfileScreen();
                break;
            }
          },
        ),
      ),
    );
  }

  Widget _buildQuickAccessItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A237E), // Deep Indigo
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFFFAFAFA), // White/Off-White
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'StackSansText',
                fontSize: 12,
                color: Color(0xFFFAFAFA),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToMateriScreen(String? content, String? title) async {
    // Load saved progress before determining which content to navigate to
    List<Map<String, dynamic>>? savedData = await StorageService.loadProgress();
    if (savedData != null && savedData.isNotEmpty) {
      // Update the global dataMateri with saved progress
      for (int i = 0; i < dataMateri.length && i < savedData.length; i++) {
        var savedMateri = savedData[i];
        if (savedMateri.containsKey('isDoneMateri')) {
          dataMateri[i]['isDoneMateri'] = savedMateri['isDoneMateri'] ?? false;
        }

        var savedSubMateriList = savedMateri['subMateri'] as List?;
        var currentSubMateriList = dataMateri[i]['subMateri'] as List?;

        if (savedSubMateriList != null && currentSubMateriList != null) {
          for (
            int j = 0;
            j < currentSubMateriList.length && j < savedSubMateriList.length;
            j++
          ) {
            var savedSubMateri = savedSubMateriList[j] as Map<String, dynamic>?;
            if (savedSubMateri != null &&
                savedSubMateri.containsKey('isDone')) {
              currentSubMateriList[j]['isDone'] =
                  savedSubMateri['isDone'] ?? false;
            }
          }
        }
      }
    }

    // Check if all content is completed before navigating
    bool allDone = true;
    for (int materiIndex = 0; materiIndex < dataMateri.length; materiIndex++) {
      var materi = dataMateri[materiIndex];
      if (materi['isDoneMateri'] == false) {
        allDone = false;
        break;
      }

      var subMateriList = materi['subMateri'] as List;
      for (int subIndex = 0; subIndex < subMateriList.length; subIndex++) {
        var subMateri = subMateriList[subIndex];
        if (subMateri['isDone'] == false) {
          allDone = false;
          break;
        }
      }

      if (!allDone) break;
    }

    if (allDone) {
      // If all content is done, navigate directly to materi screen
      String? lastCompletedContent;
      String? lastCompletedTitle;

      // Find the last completed content
      for (
        int materiIndex = 0;
        materiIndex < dataMateri.length;
        materiIndex++
      ) {
        var materi = dataMateri[materiIndex];
        var subMateriList = materi['subMateri'] as List;

        // If this materi was completed, update last completed content to the ujianAkhir of this materi
        if (materi['isDoneMateri'] == true) {
          // The last subMateri in the list should be the ujianAkhir
          if (subMateriList.isNotEmpty) {
            var lastSubMateri = subMateriList.last;
            lastCompletedContent = lastSubMateri['isiMateri'] as String?;
            lastCompletedTitle = lastSubMateri['nama'] as String?;
          }
        }
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MateriScreen(
            initialContent: lastCompletedContent,
            bottomAppBarTitle: lastCompletedTitle ?? 'Prasyarat Kemampuan',
          ),
        ),
      );
    } else {
      // Navigate to RelaxScreen instead of directly to materi screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RelaxScreen()),
      );
    }
  }

  void _showFormulaScreen() {
    // This will be implemented later
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Daftar Rumus'),
          content: const Text('Fitur ini akan segera hadir!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showProfileScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
    // Reload user data and refresh the UI after returning from profile screen
    _loadUserName();
    _loadProgressFromStorage();
  }

  void _showTutorial() {
    // Create tutorial steps with element keys and descriptions
    List<Map<String, dynamic>> tutorialSteps = [
      {
        'key': _greetingKey,
        'title': 'Selamat Datang!',
        'description':
            'Ini adalah halaman utama aplikasi. Di sini kamu bisa melihat sapaan dan informasi pengguna.',
      },
      {
        'key': _progressKey,
        'title': 'Progres Belajar',
        'description':
            'Bagian ini menunjukkan seberapa banyak materi yang sudah kamu pelajari. Progres ini akan terus diperbarui saat kamu menyelesaikan materi.',
      },
      {
        'key': _continueLearningKey,
        'title': 'Lanjut Belajar',
        'description':
            'Kartu ini menunjukkan materi berikutnya yang harus kamu kerjakan. Kamu bisa langsung melanjutkan belajar dengan mengetuk tombol ini.',
      },
      {
        'key': _quickAccessKey,
        'title': 'Akses Cepat',
        'description':
            'Akses cepat ke berbagai fitur penting seperti daftar materi, kumpulan rumus, dan profil pengguna.',
      },
      {
        'key': _bottomNavKey,
        'title': 'Navigasi',
        'description':
            'Gunakan menu bawah ini untuk berpindah antar halaman utama aplikasi.',
      },
    ];

    _showTutorialStep(tutorialSteps, 0);
  }

  void _showTutorialStep(
    List<Map<String, dynamic>> steps,
    int currentStepIndex,
  ) {
    if (currentStepIndex >= steps.length) {
      // Tutorial completed
      TutorialService.setTutorialCompleted();
      setState(() {
        _tutorialCompleted = true;
      });
      return;
    }

    Map<String, dynamic> currentStep = steps[currentStepIndex];
    GlobalKey key = currentStep['key'];

    // Wait for the widget to be rendered before getting its position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox? overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox?;
      RenderBox? targetBox =
          key.currentContext?.findRenderObject() as RenderBox?;

      if (targetBox == null || overlay == null) {
        // If the target is not found, proceed to next step
        _showTutorialStep(steps, currentStepIndex + 1);
        return;
      }

      // Calculate target position
      var targetLocalPos = targetBox.localToGlobal(
        Offset.zero,
        ancestor: overlay,
      );
      var targetSize = targetBox.size;

      // Calculate the position for the tutorial card
      double cardTop;
      double cardLeft = targetLocalPos.dx;

      // Special positioning for the quick access and bottom navigation sections to position the card above the elements
      if (key == _quickAccessKey || key == _bottomNavKey) {
        // Position the card above the element
        cardTop = targetLocalPos.dy - 200; // 200px above the target
        if (cardTop < 20) {
          // If it would be off-screen, position it below instead
          cardTop = targetLocalPos.dy + targetSize.height + 20;
        }
      } else {
        // Standard positioning: below the target element
        cardTop = targetLocalPos.dy + targetSize.height + 20;
      }

      // Ensure the card stays within screen bounds
      double screenWidth = MediaQuery.of(context).size.width;
      if (cardLeft + 300 > screenWidth) {
        cardLeft = screenWidth - 320; // 300 for card width + 20 margin
      }

      // Display the tutorial overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        useSafeArea: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Stack(
                children: [
                  // The normal screen content remains visible (no dark overlay)

                  // Highlighted area around the target element
                  Positioned(
                    left: targetLocalPos.dx - 10,
                    top: targetLocalPos.dy - 10,
                    width: targetSize.width + 20,
                    height: targetSize.height + 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6D00).withValues(alpha: 0.1), // Subtle orange background
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFFF6D00), // Energetic Orange
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6D00).withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tutorial information card
                  Positioned(
                    top: cardTop,
                    left: cardLeft,
                    width: 300,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A237E), // Deep Indigo
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentStep['title'],
                              style: const TextStyle(
                                fontFamily: 'StackSansText',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF6D00), // Energetic Orange
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentStep['description'],
                              style: const TextStyle(
                                fontFamily: 'StackSansText',
                                fontSize: 14,
                                color: Color(0xFFFAFAFA), // White/Off-White
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (currentStepIndex > 0)
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _showTutorialStep(
                                        steps,
                                        currentStepIndex - 1,
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(
                                        0xFFFAFAFA,
                                      ), // White/Off-White
                                    ),
                                    child: const Text(
                                      'Sebelumnya',
                                      style: TextStyle(
                                        fontFamily: 'StackSansText',
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _showTutorialStep(
                                      steps,
                                      currentStepIndex + 1,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFFFF6D00,
                                    ), // Energetic Orange
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(
                                    currentStepIndex == steps.length - 1
                                        ? 'Selesai'
                                        : 'Lanjut',
                                    style: const TextStyle(
                                      fontFamily: 'StackSansText',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    });
  }
}
