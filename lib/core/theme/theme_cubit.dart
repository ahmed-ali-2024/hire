import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.dark); // Dark mode by default for premium hacker aesthetics

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      emit(ThemeMode.light);
    } else {
      emit(ThemeMode.dark);
    }
  }

  void setTheme(ThemeMode mode) {
    emit(mode);
  }

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    final index = json['theme_mode'] as int?;
    return index != null ? ThemeMode.values[index] : ThemeMode.dark;
  }

  @override
  Map<String, dynamic>? toJson(ThemeMode state) {
    return {'theme_mode': state.index};
  }
}
