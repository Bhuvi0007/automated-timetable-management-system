import 'package:flutter/material.dart';
import '../services/data_reset_service.dart';

class ResetDataDialog extends StatelessWidget {
  const ResetDataDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset App Data'),
      content: const Text(
        'Are you sure you want to reset all app data? This will delete all teachers, courses, sections, and mappings. This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          onPressed: () async {
            try {
              await DataResetService.resetAllData();
              if (context.mounted) {
                Navigator.of(context).pop();
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data has been reset successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Navigate to login screen
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error resetting data: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: const Text('Reset All Data'),
        ),
      ],
    );
  }
}
