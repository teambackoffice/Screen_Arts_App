import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_arts_app/controller/job_order_controller.dart';
import 'package:screen_arts_app/controller/login_controller.dart';
import 'package:screen_arts_app/view/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>(create: (_) => AuthController()),
        ChangeNotifierProvider<JobWorkController>(
          create: (_) => JobWorkController(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
