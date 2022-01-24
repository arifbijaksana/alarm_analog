import 'package:alrm_analog/bloc/hour/hour_bloc.dart';
import 'package:alrm_analog/bloc/minute/minute_bloc.dart';
import 'package:alrm_analog/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  tz.initializeTimeZones();
  runApp(MultiBlocProvider(providers: [
    BlocProvider<HourBloc>(
      create: (context) => HourBloc(),
    ),
    BlocProvider<MinuteBloc>(
      create: (context) => MinuteBloc(),
    ),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}
