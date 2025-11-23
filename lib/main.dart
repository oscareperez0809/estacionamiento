import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lbtbdcmvlqpwiulnobcc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxidGJkY212bHFwd2l1bG5vYmNjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM1ODY0NjcsImV4cCI6MjA3OTE2MjQ2N30.Iwb_tWsgUnqs1xTkVsZPzgUbB3-Mxylu1k6V4UJA6OA',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estacionamiento',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {'/': (context) => LoginPage(), '/home': (context) => HomePage()},
    );
  }
}
