import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _boxName = 'settings';
  static const String _themeKey = 'theme_mode';

  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final box = await Hive.openBox(_boxName);
      final themeIndex = box.get(_themeKey, defaultValue: 0);
      emit(ThemeMode.values[themeIndex]);
    } catch (e) {
      print('Error loading theme: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_themeKey, mode.index);
      emit(mode);
    } catch (e) {
      print('Error saving theme: $e');
    }
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setThemeMode(newMode);
  }

  bool get isDarkMode => state == ThemeMode.dark;
}
