import 'package:flutter/material.dart';
import 'package:termodinamika_apps/screens/relax/relax_screen.dart';
import 'package:termodinamika_apps/services/platform_storage_service.dart';
import '../materi/materi_screen.dart';
import '../materi/components/materi_data.dart';
import '../materi/components/module_list_screen.dart';
import '../profile/profile_screen.dart'; // Add import for Profile screen
import '../../services/storage_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadProgressFromStorage();
  }

  Future<void> _loadUserName() async {
    String? savedName = await getStorageService().getItem('user_name');
    if (savedName != null && savedName.isNotEmpty) {
      setState(() {
        _userName = savedName;
      });
    } else {
      _showNameInputDialog();
    }
  }

  Future<void> _showNameInputDialog() async {
    String? enteredName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final controller = TextEditingController();
        String selectedAvatar = 'assets/images/avatar-1.png'; // Default avatar

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Selamat Datang!'),
              content: SizedBox(
                height: 350,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Masukkan nama kamu dan pilih avatar untuk memulai belajar:'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Nama kamu...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(16.0),
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          Navigator.of(context).pop(value.trim());
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Pilih Avatar:'),
                    const SizedBox(height: 8),
                    Container(
                      height: 120,
                      child: Column(
                        children: [
                          // First row of avatars (avatars 1-3)
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                for (int i = 1; i <= 3; i++)
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedAvatar = 'assets/images/avatar-$i.png';
                                        });
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: selectedAvatar == 'assets/images/avatar-$i.png'
                                                ? const Color(0xFFFF6D00) // Energetic Orange
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
                                  ),
                              ],
                            ),
                          ),
                          // Second row of avatars (avatars 4-6)
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                for (int i = 4; i <= 6; i++)
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedAvatar = 'assets/images/avatar-$i.png';
                                        });
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: selectedAvatar == 'assets/images/avatar-$i.png'
                                                ? const Color(0xFFFF6D00) // Energetic Orange
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
                    Navigator.of(context).pop(); // Close without saving
                  },
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      // Save both name and avatar to storage
                      getStorageService().setItem('user_name', controller.text.trim());
                      getStorageService().setItem('user_avatar', selectedAvatar);
                      Navigator.of(context).pop(controller.text.trim());
                    }
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
      },
    );

    if (enteredName != null && enteredName.isNotEmpty) {
      setState(() {
        _userName = enteredName;
      });
    }
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
          for (int j = 0; j < currentSubMateriList.length && j < savedSubMateriList.length; j++) {
            var savedSubMateri = savedSubMateriList[j] as Map<String, dynamic>?;
            if (savedSubMateri != null && savedSubMateri.containsKey('isDone')) {
              currentSubMateriList[j]['isDone'] = savedSubMateri['isDone'] ?? false;
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212121).withOpacity(0.7), // Dark Grey with transparency
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
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: _progressValue / 100,
                                    minHeight: 10,
                                    backgroundColor: const Color(0xFF651FFF), // Electric Violet
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      Color(0xFFFF6D00), // Energetic Orange
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
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212121).withOpacity(0.7), // Dark Grey with transparency
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
                                _navigateToMateriScreen(nextSubMateri['isiMateri'], nextSubMateri['nama']);
                              },
                              icon: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Mulai Kerjakan',
                                style: TextStyle(
                                  fontFamily: 'StackSansText',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6D00), // Energetic Orange
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                                    builder: (context) => const ModuleListScreen(),
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
                                backgroundColor: const Color(0xFFFF6D00), // Energetic Orange
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF212121).withOpacity(0.7), // Dark Grey with transparency
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
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildQuickAccessItem(
                                    icon: Icons.school,
                                    label: 'Semua Materi',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ModuleListScreen(),
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
                            color: const Color(0xFF212121).withOpacity(0.7), // Dark Grey with transparency
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
                                  color: const Color(0xFF1A237E).withOpacity(0.5), // Deep Indigo with transparency
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
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: 'Materi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
          onTap: (index) {
            // Handle navigation based on index
            switch(index) {
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

  Widget _buildQuickAccessItem({required IconData icon, required String label, required VoidCallback onTap}) {
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
          for (int j = 0; j < currentSubMateriList.length && j < savedSubMateriList.length; j++) {
            var savedSubMateri = savedSubMateriList[j] as Map<String, dynamic>?;
            if (savedSubMateri != null && savedSubMateri.containsKey('isDone')) {
              currentSubMateriList[j]['isDone'] = savedSubMateri['isDone'] ?? false;
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
      for (int materiIndex = 0; materiIndex < dataMateri.length; materiIndex++) {
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
        MaterialPageRoute(
          builder: (context) => const RelaxScreen(),
        ),
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
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
    // Reload user data and refresh the UI after returning from profile screen
    _loadUserName();
    _loadProgressFromStorage();
  }
}