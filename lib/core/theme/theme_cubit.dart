import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light); // Light mode by default as requested

  void toggleTheme() {
    // Disabled theme toggling, keeping it light
    emit(ThemeMode.light);
  }

  void setTheme(ThemeMode mode) {
    // Always force light mode
    emit(ThemeMode.light);
  }

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    // Force Light mode even if a previous state was saved
    return ThemeMode.light;
  }

  @override
  Map<String, dynamic>? toJson(ThemeMode state) {
    return {'theme_mode': ThemeMode.light.index};
  }
}
