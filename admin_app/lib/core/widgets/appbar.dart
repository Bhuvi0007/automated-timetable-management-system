import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/routes.dart';

import 'reset_data_dialog.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Row(
        children: [
          SizedBox(width: 16),
          Icon(Icons.school_outlined, color: AppColors.primary, size: 27),
          SizedBox(width: 8),
          Text(
            'College Timetable Admin',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const ResetDataDialog(),
                );
              },
              borderRadius: BorderRadius.circular(6),
              hoverColor: const Color.fromARGB(255, 172, 190, 209),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.refresh,
                      color: Color.fromARGB(255, 84, 84, 84),
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Reset Data",
                      style: TextStyle(
                          color: Color.fromARGB(255, 84, 84, 84), fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.login,
                  (route) => false,
                );
              },
              borderRadius: BorderRadius.circular(6),
              hoverColor: const Color.fromARGB(255, 172, 190, 209),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Color.fromARGB(255, 84, 84, 84),
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Logout",
                      style: TextStyle(
                          color: Color.fromARGB(255, 84, 84, 84), fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 50),
      ],
      backgroundColor: AppColors.surface,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFDCDCDC),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
