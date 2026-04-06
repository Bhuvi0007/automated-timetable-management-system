import 'package:firedart/firedart.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/models/timetable_model.dart';
import '../regeneration/regeneration.dart';
import 'timetable_display.dart';

class TimetablePage extends StatefulWidget {
  final int semesterId;
  final int numberOfSections;
  final String selectedSection;
  final TimetableModel timetable;
  final VoidCallback onBack;

  const TimetablePage({
    super.key,
    required this.semesterId,
    required this.numberOfSections,
    required this.selectedSection,
    required this.timetable,
    required this.onBack,
  });

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  late String _currentSection;
  List<List<String>> timetableData = [];
  List<List<String>> teacherData = [];

  final List<String> _days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];

  final List<String> _timeSlots = [
    "8:30-9:30",
    "9:30-10:30",
    "11:00-12:00",
    "12:00-1:00",
    "2:00-3:00",
    "3:00-4:00",
  ];

  @override
  void initState() {
    super.initState();
    _currentSection = widget.selectedSection;
    _populateData(_currentSection);
  }

  void _populateData(String section) {
    timetableData = List.generate(
        _timeSlots.length, (_) => List.generate(_days.length, (_) => ""));
    teacherData = List.generate(
        _timeSlots.length, (_) => List.generate(_days.length, (_) => ""));

    final timetable = widget.timetable.timetable;

    for (int col = 0; col < _days.length; col++) {
      for (int row = 0; row < _timeSlots.length; row++) {
        final day = _days[col];
        final time = _timeSlots[row];
        final slot = timetable[section]?[day]?[time];

        if (slot != null) {
          final course = slot.course.trim();
          final teacher = slot.teacher.trim();

          timetableData[row][col] = course == "None" ? "Free" : course;
          teacherData[row][col] = teacher;
        } else {
          timetableData[row][col] = "Free";
          teacherData[row][col] = "";
          debugPrint("No slot found for $section on $day at $time");
        }
      }
    }
  }

  void _changeSection(String section) {
    setState(() {
      _currentSection = section;
      _populateData(section);
    });
  }

  List<Widget> _buildSectionButtons() {
    return List.generate(widget.numberOfSections, (index) {
      String section = 'Section ${String.fromCharCode(65 + index)}';
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: _buildSectionButton(section, _currentSection == section),
      );
    });
  }

  Widget _buildSectionButton(String section, bool isSelected) {
    return ElevatedButton(
      onPressed: () => _changeSection(section),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor:
            isSelected ? const Color(0xFF3F51B5) : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shadowColor: Colors.transparent,
      ),
      child: Text(section),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shadowColor: Colors.transparent,
      ),
    );
  }

  Future<void> _printTimetable() async {
    final pdf = pw.Document();

    // Store current section to restore later
    String currentSection = _currentSection;

    for (int i = 0; i < widget.numberOfSections; i++) {
      final sectionName = 'Section ${String.fromCharCode(65 + i)}';

      // Load the specific section's data
      _populateData(sectionName);

      // Create timetable data for this specific section
      List<List<String>> sectionTimetableData = List.generate(
          _timeSlots.length, (_) => List.generate(_days.length, (_) => ""));
      List<List<String>> sectionTeacherData = List.generate(
          _timeSlots.length, (_) => List.generate(_days.length, (_) => ""));

      // Populate section-specific data
      final timetable = widget.timetable.timetable;
      for (int col = 0; col < _days.length; col++) {
        for (int row = 0; row < _timeSlots.length; row++) {
          final day = _days[col];
          final time = _timeSlots[row];
          final slot = timetable[sectionName]?[day]?[time];

          if (slot != null) {
            final course = slot.course.trim();
            final teacher = slot.teacher.trim();
            sectionTimetableData[row][col] = course == "None" ? "Free" : course;
            sectionTeacherData[row][col] = teacher;
          } else {
            sectionTimetableData[row][col] = "Free";
            sectionTeacherData[row][col] = "";
          }
        }
      }
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) => pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Semester ${widget.semesterId} - $sectionName Timetable',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Table(
                  border:
                      pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(80),
                    for (int i = 1; i <= _days.length; i++)
                      i: const pw.FlexColumnWidth(),
                  },
                  defaultVerticalAlignment:
                      pw.TableCellVerticalAlignment.middle,
                  children: [
                    // Header row
                    pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Center(
                              child: pw.Text('Time Slot',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold))),
                        ),
                        ..._days.map((day) => pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Center(
                                  child: pw.Text(day,
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold))),
                            )),
                      ],
                    ),
                    // Data rows using section-specific data
                    for (int row = 0; row < _timeSlots.length; row++)
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Center(
                                child: pw.Text(_timeSlots[row],
                                    style: const pw.TextStyle(fontSize: 10))),
                          ),
                          ...List.generate(_days.length, (col) {
                            final course = sectionTimetableData[row][col];
                            final teacher = sectionTeacherData[row][col];
                            return pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Center(
                                child: pw.Text(
                                  teacher.isNotEmpty
                                      ? '$course\n$teacher'
                                      : course,
                                  style: const pw.TextStyle(fontSize: 9),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) => pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Semester ${widget.semesterId} - $sectionName Timetable',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Table(
                border:
                    pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
                columnWidths: {
                  0: const pw.FixedColumnWidth(80),
                  for (int i = 1; i <= _days.length; i++)
                    i: const pw.FlexColumnWidth(),
                },
                defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: [
                  // Header row
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Center(
                            child: pw.Text('Time Slot',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold))),
                      ),
                      ..._days.map((day) => pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Center(
                                child: pw.Text(day,
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold))),
                          )),
                    ],
                  ),
                  // Data rows
                  for (int row = 0; row < _timeSlots.length; row++)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Center(
                              child: pw.Text(_timeSlots[row],
                                  style: const pw.TextStyle(fontSize: 10))),
                        ),
                        ...List.generate(_days.length, (col) {
                          final course = timetableData[row][col];
                          final teacher = teacherData[row][col];
                          return pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Center(
                              child: pw.Text(
                                teacher.isNotEmpty
                                    ? '$course\n$teacher'
                                    : course,
                                style: const pw.TextStyle(fontSize: 9),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Restore original section state
    _populateData(currentSection);

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _saveToFirestore() async {
    try {
      final teachersCollection = Firestore.instance.collection('Teachers');
      final timetableCollection =
          Firestore.instance.collection('Original_TimeTable');
      final modifiedCollection =
          Firestore.instance.collection('Modified_TimeTable');

      // Delete all existing documents in both collections
      final existingOriginalDocs = await timetableCollection
          .where('semester', isEqualTo: widget.semesterId)
          .get();
      final existingModifiedDocs = await modifiedCollection
          .where('semester', isEqualTo: widget.semesterId)
          .get();

      // Delete all existing documents first
      for (var doc in existingOriginalDocs) {
        // Get all subcollections
        final dayCollections = [
          'monday',
          'tuesday',
          'wednesday',
          'thursday',
          'friday',
          'saturday'
        ];
        for (var day in dayCollections) {
          final subCollection = Firestore.instance
              .collection('Original_TimeTable/${doc.id}/$day');
          final subDocs = await subCollection.get();
          // Delete all documents in subcollection
          for (var subDoc in subDocs) {
            await subDoc.reference.delete();
          }
        }
        // Delete main document
        await timetableCollection.document(doc.id).delete();
      }

      // Do the same for modified collection
      for (var doc in existingModifiedDocs) {
        final dayCollections = [
          'monday',
          'tuesday',
          'wednesday',
          'thursday',
          'friday',
          'saturday'
        ];
        for (var day in dayCollections) {
          final subCollection = Firestore.instance
              .collection('Modified_TimeTable/${doc.id}/$day');
          final subDocs = await subCollection.get();
          for (var subDoc in subDocs) {
            await subDoc.reference.delete();
          }
        }
        await modifiedCollection.document(doc.id).delete();
      }

      // Create a map to store teacher assignments
      Map<String, List<Map<String, dynamic>>> teacherAssignments = {};

      // Save current section state
      String previousSection = _currentSection;

      // Iterate through all sections
      for (int i = 0; i < widget.numberOfSections; i++) {
        String section = 'Section ${String.fromCharCode(65 + i)}';

        // Switch to this section and populate its data
        _populateData(section);

        // Go through timetable data to collect assignments
        for (String day in _days) {
          for (int row = 0; row < _timeSlots.length; row++) {
            final int dayIndex = _days.indexOf(day);
            final String course = timetableData[row][dayIndex];
            final String teacher = teacherData[row][dayIndex];

            if (teacher.isNotEmpty && course != "Free") {
              if (!teacherAssignments.containsKey(teacher)) {
                teacherAssignments[teacher] = [];
              }

              // Check if subject already exists in assignments
              bool subjectExists = teacherAssignments[teacher]!.any(
                  (assignment) =>
                      assignment['subject'] == course &&
                      assignment['semester'] == widget.semesterId);

              if (!subjectExists) {
                // Add new assignment
                teacherAssignments[teacher]!.add({
                  'subject': course,
                  'sections': [section],
                  'semester': widget.semesterId,
                });
              } else {
                // Update existing assignment by adding section if not already present
                var assignment = teacherAssignments[teacher]!.firstWhere(
                    (assignment) =>
                        assignment['subject'] == course &&
                        assignment['semester'] == widget.semesterId);

                if (!assignment['sections'].contains(section)) {
                  assignment['sections'].add(section);
                }
              }
            }
          }
        }
      }

      // Restore original section state
      _populateData(previousSection);

      // Update teacher documents in Firestore
      final teacherDocs = await teachersCollection.get();
      for (var doc in teacherDocs) {
        final teacherData = doc.map;
        final teacherName = teacherData['name'];

        if (teacherAssignments.containsKey(teacherName)) {
          await teachersCollection.document(doc.id).update({
            'assignment': teacherAssignments[teacherName],
          });
        }
      }

      // Create subcollections for each day
      Map<String, Map<String, Map<String, String>>> dayData = {};
      for (String day in _days) {
        Map<String, Map<String, String>> timeSlotData = {};

        for (int row = 0; row < _timeSlots.length; row++) {
          final int dayIndex = _days.indexOf(day);
          timeSlotData[_timeSlots[row]] = {
            'course': timetableData[row][dayIndex],
            'teacher': teacherData[row][dayIndex],
          };
        }
        dayData[day.toLowerCase()] = timeSlotData;
      }

      for (int i = 0; i < widget.numberOfSections; i++) {
        String section = 'Section ${String.fromCharCode(65 + i)}';
        _populateData(section); // Switch to this section's data

        // Create document structure for this section
        Map<String, dynamic> sectionData = {
          'department': 'Computer Science',
          'semester': widget.semesterId,
          'section': section,
        };

        // Save to Original_TimeTable
        final originalDoc = await timetableCollection
            .where('semester', isEqualTo: widget.semesterId)
            .where('section', isEqualTo: section)
            .get();

        if (originalDoc.isEmpty) {
          // Create new document for this section
          final docRef = await timetableCollection.add(sectionData);

          // Add subcollections for each day
          for (String day in _days) {
            final dayCollection = Firestore.instance.collection(
                'Original_TimeTable/${docRef.id}/${day.toLowerCase()}');

            Map<String, Map<String, String>> timeSlots = {};
            for (int row = 0; row < _timeSlots.length; row++) {
              final dayIndex = _days.indexOf(day);
              timeSlots[_timeSlots[row]] = {
                'course': timetableData[row][dayIndex],
                'teacher': teacherData[row][dayIndex],
              };
            }
            await dayCollection.add(timeSlots);
          }
        } else {
          // Update existing document
          final docId = originalDoc.first.id;
          await Firestore.instance
              .document('Original_TimeTable/$docId')
              .update(sectionData);

          // Update subcollections
          for (String day in _days) {
            final dayCollection = Firestore.instance
                .collection('Original_TimeTable/$docId/${day.toLowerCase()}');

            // Delete existing documents
            final existingDocs = await dayCollection.get();
            for (var doc in existingDocs) {
              await doc.reference.delete();
            }

            // Add new data
            Map<String, Map<String, String>> timeSlots = {};
            for (int row = 0; row < _timeSlots.length; row++) {
              final dayIndex = _days.indexOf(day);
              timeSlots[_timeSlots[row]] = {
                'course': timetableData[row][dayIndex],
                'teacher': teacherData[row][dayIndex],
              };
            }
            await dayCollection.add(timeSlots);
          }
        }

        // Do the same for Modified_TimeTable
        final modifiedDoc = await modifiedCollection
            .where('semester', isEqualTo: widget.semesterId)
            .where('section', isEqualTo: section)
            .get();

        if (modifiedDoc.isEmpty) {
          final docRef = await modifiedCollection.add(sectionData);
          for (String day in _days) {
            final dayCollection = Firestore.instance.collection(
                'Modified_TimeTable/${docRef.id}/${day.toLowerCase()}');

            Map<String, Map<String, String>> timeSlots = {};
            for (int row = 0; row < _timeSlots.length; row++) {
              final dayIndex = _days.indexOf(day);
              timeSlots[_timeSlots[row]] = {
                'course': timetableData[row][dayIndex],
                'teacher': teacherData[row][dayIndex],
              };
            }
            await dayCollection.add(timeSlots);
          }
        } else {
          final docId = modifiedDoc.first.id;
          await Firestore.instance
              .document('Modified_TimeTable/$docId')
              .update(sectionData);

          for (String day in _days) {
            final dayCollection = Firestore.instance
                .collection('Modified_TimeTable/$docId/${day.toLowerCase()}');

            final existingDocs = await dayCollection.get();
            for (var doc in existingDocs) {
              await doc.reference.delete();
            }

            Map<String, Map<String, String>> timeSlots = {};
            for (int row = 0; row < _timeSlots.length; row++) {
              final dayIndex = _days.indexOf(day);
              timeSlots[_timeSlots[row]] = {
                'course': timetableData[row][dayIndex],
                'teacher': teacherData[row][dayIndex],
              };
            }
            await dayCollection.add(timeSlots);
          }
        }
      }

      // Restore original section state
      _populateData(previousSection);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Timetable saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving timetable: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving timetable: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _regenerateTimetable() async {
    try {
      final newJson =
          await RegenerationService.regenerateTimetable(widget.semesterId);
      final newModel = TimetableModel.fromJson({'timetable': newJson});

      setState(() {
        widget.timetable.timetable.clear();
        widget.timetable.timetable.addAll(newModel.timetable);
        _populateData(_currentSection);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Timetable regenerated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to regenerate timetable: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Semester ${widget.semesterId} Timetable',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'View and manage timetables for all sections',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: _buildSectionButtons(),
                  ),
                ),
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.refresh,
                      label: 'Regenerate',
                      onPressed: _regenerateTimetable,
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.print,
                      label: 'Print',
                      onPressed: _printTimetable,
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.arrow_back_outlined,
                      label: 'Return',
                      onPressed: widget.onBack,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TimetableDisplay(
                section: _currentSection,
                timetableData: timetableData,
                teacherData: teacherData,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: _buildActionButton(
                icon: Icons.check_circle_outline,
                label: 'Submit',
                onPressed: () async {
                  try {
                    await _saveToFirestore();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
