import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class LocaleCubit extends HydratedCubit<Locale> {
  LocaleCubit() : super(const Locale('en'));

  void toggleLocale() {
    if (state.languageCode == 'en') {
      emit(const Locale('ar'));
    } else {
      emit(const Locale('en'));
    }
  }

  void setLocale(Locale locale) {
    emit(locale);
  }

  @override
  Locale? fromJson(Map<String, dynamic> json) {
    final code = json['language_code'] as String?;
    return code != null ? Locale(code) : const Locale('en');
  }

  @override
  Map<String, dynamic>? toJson(Locale state) {
    return {'language_code': state.languageCode};
  }
}
