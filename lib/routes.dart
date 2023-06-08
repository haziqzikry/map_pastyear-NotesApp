import 'package:flutter/material.dart';
import 'package:map_exam/edit_screen.dart';
import 'package:map_exam/home_screen.dart';
import 'package:map_exam/login_screen.dart';

class Routes {
  static const String login = '/login';
  static const String home = '/home';
  static const String edit = '/edit';

  static final Map<String, WidgetBuilder> routes = {
    login: LoginScreen.route(),
    home: HomeScreen.route(),
    edit: EditScreen.route(),
  };
}
