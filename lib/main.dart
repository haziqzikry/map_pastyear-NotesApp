import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:map_exam/firebase_options.dart';

import 'routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final NavigatorState navigator = navigatorKey.currentState!;
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

final ScaffoldMessengerState scaffoldMessenger =
    scaffoldMessengerKey.currentState!;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const App());
}

final ThemeData theme = ThemeData(
  primarySwatch: Colors.blue,
);

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAP Exam',
      theme: theme,
      initialRoute: Routes.login,
      routes: Routes.routes,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
    );
  }
}
