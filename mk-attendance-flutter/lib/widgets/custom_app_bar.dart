import 'package:flutter/material.dart';
import '../utils/ethiopian_date.dart';
import '../utils/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showDate;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.now().toIso8601String().split('T')[0];
    final ethiopianDate = EthiopianDateUtils.formatDate(currentDate);

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showDate)
            Text(
              ethiopianDate,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
      ),
      actions: actions,
      elevation: 2,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}