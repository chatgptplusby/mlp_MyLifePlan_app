import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/theme/mlp_design_system.dart';
import 'features/university/mlp_campus_hub.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MLPCampusApp(prefs: prefs));
}

class MLPCampusApp extends StatelessWidget {
  const MLPCampusApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MLP Campus',
      theme: MLPTheme.dark,
      home: MLPCampusHub(prefs: prefs),
    );
  }
}
