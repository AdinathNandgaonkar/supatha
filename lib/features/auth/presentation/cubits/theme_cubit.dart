// theme_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { light, dark, system } // Added 'system' mode

class ThemeCubit extends Cubit<AppTheme> {
  final SharedPreferences prefs;

  ThemeCubit(this.prefs) : super(_getInitialTheme(prefs));

  static AppTheme _getInitialTheme(SharedPreferences prefs) {
    final savedMode = prefs.getString('themeMode');
    return AppTheme.values.firstWhere(
      (e) => e.name == savedMode,
      orElse: () => AppTheme.system, // Default to system
    );
  }

  void changeTheme(AppTheme newTheme) {
    prefs.setString('themeMode', newTheme.name);
    emit(newTheme);
  }
}
