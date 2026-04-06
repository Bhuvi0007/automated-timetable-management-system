import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
import '../../../../core/constants/colors.dart';

class BasicConfiguration extends StatefulWidget {
  final int semesterId;
  final VoidCallback onContinue;

  const BasicConfiguration({
    super.key,
    required this.semesterId,
    required this.onContinue,
  });

  @override
  State<BasicConfiguration> createState() => _BasicConfigurationState();
}

class _BasicConfigurationState extends State<BasicConfiguration> {
  int _numberOfSections = 2;
  int _numberOfRooms = 2;
  int _numberOfLabRooms = 2;

  @override
  void initState() {
    super.initState();
    _loadBasicConfiguration();
  }

  Future<void> _loadBasicConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _numberOfSections = prefs.getInt('sections_${widget.semesterId}') ?? 2;
      _numberOfRooms = prefs.getInt('rooms_${widget.semesterId}') ?? 2;
      _numberOfLabRooms = prefs.getInt('labRooms_${widget.semesterId}') ?? 2;
    });
  }

  void _saveBasicConfiguration() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('sections_${widget.semesterId}', _numberOfSections);
    await prefs.setInt('rooms_${widget.semesterId}', _numberOfRooms);
    await prefs.setInt('labRooms_${widget.semesterId}', _numberOfLabRooms);

    print('--- Saved Configuration ---');
    print('Semester ID: ${widget.semesterId}');
    print('Sections: $_numberOfSections');
    print('Rooms: $_numberOfRooms');
    print('Lab Rooms: $_numberOfLabRooms');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Configuration saved for Semester : ${widget.semesterId}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Basic Configuration',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Configure the basic settings for this semester',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(height: 24),

                  /// Sections, Rooms, Lab Rooms
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCounterInput(
                          'Number of Sections', _numberOfSections, () {
                        if (_numberOfSections > 1) {
                          setState(() => _numberOfSections--);
                        }
                      }, () => setState(() => _numberOfSections++)),
                      const SizedBox(width: 32),
                      _buildCounterInput('Number of Rooms', _numberOfRooms, () {
                        if (_numberOfRooms > 1) {
                          setState(() => _numberOfRooms--);
                        }
                      }, () => setState(() => _numberOfRooms++)),
                      const SizedBox(width: 32),
                      _buildCounterInput(
                          'Number of Lab Rooms', _numberOfLabRooms, () {
                        if (_numberOfLabRooms > 1) {
                          setState(() => _numberOfLabRooms--);
                        }
                      }, () => setState(() => _numberOfLabRooms++)),
                    ],
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(
              color: Color(0xFFEAEAEA),
              thickness: 0.7,
              height: 1,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _saveBasicConfiguration,
                  icon: const Icon(
                    Icons.save_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                  label: const Text('Save and Continue',
                      style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterInput(
    String label,
    int value,
    VoidCallback onDecrement,
    VoidCallback onIncrement,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildCounterButton(icon: Icons.remove, onPressed: onDecrement),
              const SizedBox(width: 8),
              Container(
                width: 60,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('$value', style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 8),
              _buildCounterButton(icon: Icons.add, onPressed: onIncrement),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton(
      {required IconData icon, VoidCallback? onPressed}) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
