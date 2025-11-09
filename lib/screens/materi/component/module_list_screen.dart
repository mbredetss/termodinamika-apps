import 'package:flutter/material.dart';
import 'materi_data.dart';
import '../materi_screen.dart';

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
  bool isSubMateriAccessible(int materiIndex, int subMateriIndex) {
    // If it's the first subMateri of the first materi, it's always accessible
    if (materiIndex == 0 && subMateriIndex == 0) {
      return true;
    }

    // Check if it's the first subMateri of a materi
    if (subMateriIndex == 0) {
      // It's accessible if the previous materi is completed
      if (materiIndex > 0) {
        var previousMateri = dataMateri[materiIndex - 1];
        return previousMateri['isDoneMateri'] == true;
      }
      return false;
    } else {
      // It's a subMateri within the same materi, check if the previous subMateri is done
      var currentMateri = dataMateri[materiIndex];
      var subMateriList = currentMateri['subMateri'] as List;
      
      // Check if the previous subMateri is completed
      var previousSubMateri = subMateriList[subMateriIndex - 1];
      return previousSubMateri['isDone'] == true;
    }
  }

  // Calculate progress based on completed subMateri
  double calculateProgress() {
    int totalSubMateri = 0;
    int completedSubMateri = 0;

    for (var materi in dataMateri) {
      var subMateriList = materi['subMateri'] as List;
      totalSubMateri += subMateriList.length;

      for (var subMateri in subMateriList) {
        if (subMateri['isDone'] == true) {
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF555555), // Dark gray
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SlideTransition(
        position: _animation.drive(
          Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
        ),
        child: Column(
          children: [
            // Tab with "Daftar Modul"
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  'Daftar Modul',
                  style: const TextStyle(
                    fontFamily: 'StackSansText',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Progress bar with label
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    '${calculateProgress().round()}% Selesai',
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
                        value: calculateProgress() / 100,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.cyan,
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
                            ),
                          ),
                          trailing: Icon(
                            _isExpanded[index]
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                          ),
                          onTap: () {
                            setState(() {
                              _isExpanded[index] = !_isExpanded[index];
                            });
                          },
                        ),
                        if (_isExpanded[index])
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: subMateriList.length,
                            itemBuilder: (context, subIndex) {
                              var subMateri = subMateriList[subIndex];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 4,
                                ),
                                leading: Icon(
                                  subMateri['isDone'] == true
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: subMateri['isDone'] == true
                                      ? Colors.green
                                      : Colors.grey,
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
                                    color: subMateri['isDone'] == true
                                        ? Colors.grey
                                        : Colors.black87,
                                    decoration: subMateri['isDone'] == true
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                onTap: () {
                                  // Check if the selected subMateri is accessible
                                  if (isSubMateriAccessible(index, subIndex)) {
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
                                  } else {
                                    // Show warning that this subMateri is not accessible yet
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                            'Warning',
                                            style: TextStyle(
                                              fontFamily: 'StackSansText',
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                          content: const Text(
                                            'Maaf, Anda belum bisa membuka modul ini. Mohon pastikan semua modul sebelumnya (termasuk latihan soal) sudah diselesaikan.',
                                            style: TextStyle(fontFamily: 'StackSansText', fontSize: 16),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Close the modal
                                              },
                                              child: const Text(
                                                'OK',
                                                style: TextStyle(
                                                  fontFamily: 'StackSansText',
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
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
  }
}
