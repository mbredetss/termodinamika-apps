import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:termodinamika_apps/services/storage_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentPage = 0;
  final int _rowsPerPage = 5;
  
  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF1A237E), // Deep Indigo
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white, // White logout icon
            ),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aktivitas Siswa',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E), // Deep Indigo
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('role', isEqualTo: 'siswa')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('Belum ada data siswa'));
                        }

                        final students = snapshot.data!.docs;
                        
                        // Calculate pagination
                        final startIndex = _currentPage * _rowsPerPage;
                        final endIndex = (startIndex + _rowsPerPage < students.length) 
                            ? startIndex + _rowsPerPage 
                            : students.length;
                        
                        // If we're past the available data, show empty state
                        if (startIndex >= students.length && students.isNotEmpty) {
                          return const Center(child: Text('Tidak ada data untuk halaman ini'));
                        }
                        
                        final pageStudents = students.sublist(startIndex, endIndex);

                        return Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAFAFA), // White/Off-White
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE0E0E0), // Light grey border
                                  ),
                                ),
                                child: Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(3), // Student Name column
                                    1: FlexColumnWidth(1), // Status column
                                  },
                                  children: [
                                    // Header row
                                    TableRow(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF5F5F5), // Very light grey background
                                      ),
                                      children: [
                                        _buildTableHeaderCell('Nama Siswa'),
                                        _buildTableHeaderCell('Status'),
                                      ],
                                    ),
                                    // Data rows
                                    ...pageStudents.map((student) {
                                      final name = student.get('name') ?? 'Nama Tidak Diketahui';
                                      final isCompleted = student.get('isCompleted') ?? false;

                                      return TableRow(
                                        children: [
                                          _buildStudentNameCell(name, student.id),
                                          _buildStatusCell(isCompleted),
                                        ],
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            ),
                            // Pagination controls
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_left),
                                    color: Color(0xFF1A237E), // Deep Indigo
                                    onPressed: _currentPage > 0 ? _goToPrevPage : null,
                                  ),
                                  Text(
                                    'Halaman ${_currentPage + 1}',
                                    style: const TextStyle(
                                      color: Color(0xFF212121), // Dark Grey
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_right_alt),
                                    color: const Color(0xFF1A237E), // Deep Indigo
                                    onPressed: endIndex < students.length ? _goToNextPage : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  
  void _goToNextPage() {
    setState(() {
      _currentPage++;
    });
  }
  
  void _goToPrevPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  // Build header cell for table
  Widget _buildTableHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'StackSansText',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF212121), // Dark Grey
        ),
      ),
    );
  }

  // Build cell with student name that shows history when tapped
  Widget _buildStudentNameCell(String name, String userId) {
    return GestureDetector(
      onTap: () => _showStudentHistoryModal(userId),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Text(
          name,
          style: const TextStyle(
            fontFamily: 'StackSansText',
            fontSize: 14,
            decoration: TextDecoration.underline,
            color: Color(0xFF1A237E), // Deep Indigo
          ),
        ),
      ),
    );
  }

  // Build status cell with colored background
  Widget _buildStatusCell(bool isCompleted) {
    Color backgroundColor = isCompleted
        ? const Color(0xFFC8E6C9) // Light green for passed
        : const Color(0xFFFFCDD2); // Light red for failed
    Color borderColor = isCompleted
        ? const Color(0xFF388E3C) // Green for passed
        : const Color(0xFFD32F2F); // Red for failed
    Color textColor = isCompleted
        ? const Color(0xFF388E3C) // Green for passed
        : const Color(0xFFD32F2F); // Red for failed

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Text(
          isCompleted ? 'Lulus' : 'Belum Lulus',
          style: TextStyle(
            fontFamily: 'StackSansText',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }

  // Show student's quiz history modal
  Future<void> _showStudentHistoryModal(String userId) async {
    QuerySnapshot quizHistorySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('quizHistory')
        .orderBy('date', descending: true)
        .get();

    List<Map<String, dynamic>> history = [];
    for (var doc in quizHistorySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Include document ID
      history.add(data);
    }

    // Show the same history modal as in materi_screen
    _showHistoryModal(history);
  }

  // Show history modal similar to materi_screen
  void _showHistoryModal(List<Map<String, dynamic>> quizHistory) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.all(24), // Add padding from edges
          child: Container(
            padding: const EdgeInsets.all(24),
            width: 800, // Increased width for larger screens
            height: 600, // Added fixed height
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Riwayat Kuis',
                      style: TextStyle(
                        fontFamily: 'StackSansText',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121), // Dark Grey
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF9E9E9E), // Medium Grey
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  // Use expanded to fill available space
                  child: SingleChildScrollView(
                    child: _buildHistoryWidget(quizHistory),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFFFF6D00,
                      ), // Energetic Orange
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        fontFamily: 'StackSansText',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build the history section as a widget for modal (similar to materi_screen)
  Widget _buildHistoryWidget(List<Map<String, dynamic>> quizHistory) {
    if (quizHistory.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada riwayat kuis',
          style: TextStyle(
            fontFamily: 'StackSansText',
            fontSize: 16,
            color: Color(0xFF616161), // Medium Grey
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFE0E0E0),
            ), // Light grey border
            borderRadius: BorderRadius.circular(8),
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(4), // Date column - increased width
              1: FlexColumnWidth(2.5), // Percentage column - increased width
              2: FlexColumnWidth(2.5), // Status column - increased width
            },
            children: [
              // Header row
              TableRow(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5), // Very light grey background
                ),
                children: [
                  _buildTableCell('Tanggal', isHeader: true),
                  _buildTableCell('Persentase', isHeader: true),
                  _buildTableCell('Status', isHeader: true),
                ],
              ),
              // Data rows
              ...quizHistory.map((record) {
                final isPassed = record['isPassed'] as bool;
                String dateString = '';
                if (record['date'] != null) {
                  if (record['date'] is Timestamp) {
                    dateString = (record['date'] as Timestamp).toDate().toString();
                  } else if (record['date'] is String) {
                    dateString = record['date'] as String;
                  } else {
                    dateString = record['date'].toString();
                  }
                }
                return TableRow(
                  children: [
                    _buildTableCell(dateString),
                    _buildTableCell('${record['percentage'].round()}%'),
                    _buildStatusCellForHistory(isPassed),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // Build a table cell with value (similar to materi_screen)
  Widget _buildTableCell(String value, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Text(
        value,
        style: TextStyle(
          fontFamily: 'StackSansText',
          fontSize: 12,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
          color: isHeader
              ? const Color(0xFF424242) // Darker grey for headers
              : const Color(0xFF212121), // Dark Grey for content
        ),
      ),
    );
  }

  // Build the status cell with colored box (similar to materi_screen)
  Widget _buildStatusCellForHistory(bool isPassed) {
    Color backgroundColor = isPassed
        ? const Color(0xFFC8E6C9)
        : const Color(
            0xFFFFCDD2,
          ); // Light green for passed, light red for failed
    Color borderColor = isPassed
        ? const Color(0xFF388E3C)
        : const Color(0xFFD32F2F); // Green for passed, red for failed
    Color textColor = isPassed
        ? const Color(0xFF388E3C)
        : const Color(0xFFD32F2F); // Green for passed, red for failed

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Text(
          isPassed ? 'Lulus' : 'Belum Lulus',
          style: TextStyle(
            fontFamily: 'StackSansText',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}