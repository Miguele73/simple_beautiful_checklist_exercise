import 'package:flutter/material.dart';
import 'package:simple_beautiful_checklist_exercise/data/database_repository.dart';

import 'package:simple_beautiful_checklist_exercise/src/app.dart';
import 'package:simple_beautiful_checklist_exercise/data/shared_preferences_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferencesRepository sharedPrefsRepository =
      SharedPreferencesRepository();
  await sharedPrefsRepository.initialize();
  final DatabaseRepository repository = sharedPrefsRepository;

  runApp(App(repository: repository));
}
