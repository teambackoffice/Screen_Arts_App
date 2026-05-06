import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_arts_app/controller/check_in_out_controller.dart';
import 'package:screen_arts_app/controller/get_check_controller.dart';
import 'package:screen_arts_app/controller/job_order_controller.dart';
import 'package:screen_arts_app/controller/job_work_controller.dart';
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
        ChangeNotifierProvider<EMPLOYEEJobWorkController>(
          create: (_) => EMPLOYEEJobWorkController(),
        ),
        ChangeNotifierProvider<JobWorkProvider>(
          create: (_) => JobWorkProvider(),
        ),
        ChangeNotifierProvider<CheckinController>(
          create: (_) => CheckinController(),
        ),
        ChangeNotifierProvider<CheckinStatusController>(
          create: (_) => CheckinStatusController(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
