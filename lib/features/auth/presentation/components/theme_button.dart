// theme_selector_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supatha_shuttles/features/auth/presentation/cubits/theme_cubit.dart';

class ThemeSelectorButton extends StatelessWidget {
  const ThemeSelectorButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, AppTheme>(
      builder: (context, currentTheme) {
        return PopupMenuButton<AppTheme>(
          icon: Icon(_getThemeIcon(currentTheme)),
          itemBuilder: (context) => [
            _buildThemeMenuItem(
                AppTheme.light, 'Light', Icons.light_mode, currentTheme),
            _buildThemeMenuItem(
                AppTheme.dark, 'Dark', Icons.dark_mode, currentTheme),
            _buildThemeMenuItem(
                AppTheme.system, 'System', Icons.phone_android, currentTheme),
          ],
          onSelected: (theme) {
            // Use read with listen: false here
            context.read<ThemeCubit>().changeTheme(theme);
          },
        );
      },
    );
  }

  PopupMenuItem<AppTheme> _buildThemeMenuItem(
      AppTheme theme, String text, IconData icon, AppTheme currentTheme) {
    return PopupMenuItem<AppTheme>(
      value: theme,
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Text(text),
          if (currentTheme == theme) ...[
            const Spacer(),
            const Icon(Icons.check, size: 20),
          ],
        ],
      ),
    );
  }

  IconData _getThemeIcon(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return Icons.light_mode;
      case AppTheme.dark:
        return Icons.dark_mode;
      case AppTheme.system:
        return Icons.phone_android;
    }
  }
}
