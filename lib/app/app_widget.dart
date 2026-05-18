import 'package:flutter/material.dart';
import 'package:serviceflow/app/app_routes.dart';
import 'package:serviceflow/app/core/theme/app_theme.dart'; // Importação do tema centralizado

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ServiceFlow',
      
      debugShowCheckedModeBanner: false,
            
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.dark,
      
      initialRoute: '/splash',
      routes: AppRoutes.routes,
    );
  }
}