import 'package:flutter/material.dart';
import 'materi_data.dart';
import '../materi_screen.dart';
import '../../../services/progress_tracking_service.dart';
import '../../../services/learning_path_service.dart';

class ModuleListScreen extends StatefulWidget {
  final String? currentSubMateriName;

  const ModuleListScreen({super.key, this.currentSubMateriName});

  @override
  State<ModuleListScreen> createState() => _ModuleListScreenState();
}

class _ModuleListScreenState extends State<ModuleListScreen>
    with TickerProviderStateMixin {
  List<bool> _isExpanded = [];
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _isExpanded = List.generate(dataMateri.length, (index) => false);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Check if the subMateri at the given indices is accessible
  Future<bool> isSubMateriAccessible(int materiIndex, int subMateriIndex) async {
    var materi = dataMateri[materiIndex];
    var subMateriList = materi['subMateri'] as List;
    var subMateri = subMateriList[subMateriIndex];

    String materiName = materi['namaMateri'];
    String subMateriName = subMateri['nama'];

    return await LearningPathService.canAccessSubMateri(
      materiName: materiName,
      subMateriName: subMateriName,
    );
  }

  // Get status of all sub-materi for a given materi
  Future<Map<String, bool>> _getSubMateriStatus(String materiName) async {
    Map<String, bool> status = {};

    for (var materi in dataMateri) {
      if (materi['namaMateri'] == materiName) {
        var subMateriList = materi['subMateri'] as List;

        for (var subMateri in subMateriList) {
          String subMateriName = subMateri['nama'];
          bool isCompleted = await ProgressTrackingService.getSubMateriProgress(
            materiName: materiName,
            subMateriName: subMateriName,
          );
          status['${materiName}_$subMateriName'] = isCompleted;
        }
        break;
      }
    }

    return status;
  }

  // Calculate progress based on completed subMateri
  Future<double> calculateProgress() async {
    int totalSubMateri = 0;
    int completedSubMateri = 0;

    for (var materi in dataMateri) {
      var subMateriList = materi['subMateri'] as List;
      String materiName = materi['namaMateri'];
      totalSubMateri += subMateriList.length;

      for (var subMateri in subMateriList) {
        String subMateriName = subMateri['nama'];
        bool isCompleted = await ProgressTrackingService.getSubMateriProgress(
          materiName: materiName,
          subMateriName: subMateriName,
        );
        if (isCompleted) {
          completedSubMateri++;
        }
      }
    }

    if (totalSubMateri == 0) return 0.0;
    return (completedSubMateri / totalSubMateri) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF303F9F), // Deep Indigo (primary)
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white, // White icon for contrast
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Daftar Modul',
          style: TextStyle(
            fontFamily: 'StackSansText',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white, // White text for contrast
          ),
        ),
      ),
      body: FutureBuilder<double>(
        future: calculateProgress(),
        builder: (context, snapshot) {
          double progress = snapshot.data ?? 0.0;
          return Container(
            color: Colors.white, // White background
            child: SlideTransition(
              position: _animation.drive(
                Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
              ),
              child: Column(
                children: [
                  // Progress bar with label
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Text(
                          '${progress.round()}% Selesai',
                          style: const TextStyle(
                            fontFamily: 'StackSansText',
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: LinearProgressIndicator(
                              value: progress / 100,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF303F9F), // Deep Indigo color for progress
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Accordion list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: dataMateri.length,
                      itemBuilder: (context, index) {
                        var materi = dataMateri[index];
                        var subMateriList = materi['subMateri'] as List;

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(
                                  materi['namaMateri'] as String,
                                  style: const TextStyle(
                                    fontFamily: 'StackSansText',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                trailing: Icon(
                                  _isExpanded[index]
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down,
                                  color: const Color(0xFF303F9F), // Deep Indigo color
                                ),
                                onTap: () {
                                  setState(() {
                                    _isExpanded[index] = !_isExpanded[index];
                                  });
                                },
                              ),
                              if (_isExpanded[index])
                                FutureBuilder<Map<String, bool>>(
                                  future: _getSubMateriStatus(materi['namaMateri']),
                                  builder: (context, snapshot) {
                                    Map<String, bool> subMateriStatus = snapshot.data ?? {};

                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: subMateriList.length,
                                      itemBuilder: (context, subIndex) {
                                        var subMateri = subMateriList[subIndex];
                                        String materiName = materi['namaMateri'];
                                        String subMateriName = subMateri['nama'];

                                        bool isCompleted = subMateriStatus['${materiName}_$subMateriName'] ?? false;

                                        return FutureBuilder<bool>(
                                          future: isSubMateriAccessible(index, subIndex),
                                          builder: (context, accessSnapshot) {
                                            bool isAccessible = accessSnapshot.data ?? false;

                                            return ListTile(
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 24,
                                                vertical: 4,
                                              ),
                                              leading: Icon(
                                                isCompleted
                                                    ? Icons.check_circle
                                                    : Icons.radio_button_unchecked,
                                                color: isCompleted
                                                    ? const Color(0xFF388E3C) // Deep green for completed
                                                    : isAccessible
                                                        ? const Color(0xFF303F9F) // Deep Indigo for accessible
                                                        : const Color(0xFF757575), // Gray for not accessible
                                              ),
                                              title: Text(
                                                subMateri['nama'] as String,
                                                style: TextStyle(
                                                  fontFamily: 'StackSansText',
                                                  fontSize: 14,
                                                  fontWeight: (widget.currentSubMateriName != null &&
                                                              subMateri['nama'] == widget.currentSubMateriName)
                                                              ? FontWeight.bold
                                                              : FontWeight.normal,
                                                  color: isCompleted
                                                      ? Colors.grey
                                                      : isAccessible
                                                          ? Colors.black87
                                                          : Colors.grey.shade500, // Less prominent for inaccessible
                                                  decoration: isCompleted
                                                      ? TextDecoration.lineThrough
                                                      : null,
                                                ),
                                              ),
                                              enabled: isAccessible,
                                              onTap: isAccessible ? () {
                                                // Navigate to the materi screen with the selected content
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => MateriScreen(
                                                      initialContent:
                                                          subMateri['isiMateri'] as String,
                                                      bottomAppBarTitle: subMateri['nama'] as String,
                                                    ),
                                                  ),
                                                );
                                              } : null,
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
