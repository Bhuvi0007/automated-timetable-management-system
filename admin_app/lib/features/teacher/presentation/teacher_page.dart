import 'dart:convert';

import 'package:firedart/firestore/firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'teacher_management.dart';

class TeacherPage extends StatelessWidget {
  const TeacherPage({super.key});

  Future<void> _saveToFirestore(BuildContext context) async {
    try {
      // Get teachers from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final teachersJson = prefs.getString('teachers');

      if (teachersJson == null) {
        throw Exception('No teachers data found');
      }

      final teachersCollection = Firestore.instance.collection('Teachers');
      final List<dynamic> decodedTeachers = jsonDecode(teachersJson);

      // Check if documents already exist
      final existingDocs = await teachersCollection.get();

      if (existingDocs.isNotEmpty) {
        // Update existing documents
        for (var doc in existingDocs) {
          await teachersCollection.document(doc.id).delete();
        }
      }

      // Add new documents
      for (int i = 0; i < decodedTeachers.length; i++) {
        final teacher = decodedTeachers[i];
        // Format tId with leading zeros (001, 002, etc.)
        final String formattedTId = (i + 1).toString().padLeft(3, '0');

        final teacherData = {
          'department': 'Computer Science',
          'name': teacher['name'],
          'email': teacher['email'],
          'password': teacher['phone'],
          'tId': formattedTId, // Using formatted incremental ID
          'designation':
              teacher['designation'], // Keep designation as separate field
        };

        await teachersCollection.add(teacherData);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Teachers data saved to database'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving teachers: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving teachers: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(
            child: TeacherManagement(),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            color: Colors.indigo[50],
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => _saveToFirestore(context),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Submit'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: const Color.fromRGBO(77, 182, 172, 1),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
