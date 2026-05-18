import 'package:flutter/material.dart';

/// AppTheme - Centraliza e distribui a identidade visual escura por herança orientada a objetos
class AppTheme {
  AppTheme._();

  /// Retorna a configuração completa do tema escuro homologado para o ecossistema do app
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Definição semântica da paleta escura (Propaga automaticamente para os widgets)
      colorScheme: ColorScheme.dark(
        primary: const Color(0xff2196f3),      // Azul operacional padrão do ServiceFlow
        secondary: const Color(0xff1e88e5),
        background: const Color(0xff121212),   // Fundo preto profundo imersivo
        surface: const Color(0xff1e1e1e),      // Superfície para cartões e diálogos
        error: const Color(0xffcf6679),
        onPrimary: Colors.white,
        onBackground: const Color(0xffe0e0e0), // Texto claro sobre fundo escuro
        onSurface: const Color(0xffffffff),
      ),

      // Customização centralizada das caixas de entrada (CustomTextField herdará automaticamente)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xff2c2c2c),
        labelStyle: const TextStyle(color: Color(0xffb0b0b0)),
        prefixIconColor: const Color(0xff2196f3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xff2196f3), width: 1.5),
        ),
      ),

      // Customização centralizada do AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xff1e1e1e),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}