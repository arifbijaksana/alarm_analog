import 'package:alrm_analog/bloc/hour/hour_bloc.dart';
import 'package:alrm_analog/bloc/minute/minute_bloc.dart';
import 'package:alrm_analog/data/notification_api.dart';
import 'package:alrm_analog/screens/bar_chart.dart';
import 'package:alrm_analog/screens/clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String hour = '0';
  String minute = '0';
  bool isActived = false;
  bool isAm = true;
  List<bool> isSelected = List.generate(2, (index) => false);

  void initState() {
    super.initState();
    NotificationApi.init();
    listenNotification();
    isSelected[0] = true;
  }

  void listenNotification() =>
      NotificationApi.onNotification.stream.listen(onClickNotification);

  void onClickNotification(String? payload) {
    showModalBottomSheet<void>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: BarChart(
            data: [
              TimeOpen(
                payload,
                DateTime.now().difference(DateTime.parse(payload!)).inSeconds,
                charts.ColorUtil.fromDartColor(
                  Colors.amber,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void showSnackBar() {
    String formattedDate = DateFormat('yyyy-MM-dd  hh:mm a').format(
      setDateTime(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alarm active for $formattedDate'),
      ),
    );
  }

  DateTime setDateTime() {
    DateTime now = DateTime.now();
    return DateTime(
        now.year,
        now.month,
        now.hour > (isAm ? int.parse(hour) : int.parse(hour) + 12)
            ? now.day + 1
            : now.hour == (isAm ? int.parse(hour) : int.parse(hour) + 12) &&
                    now.minute >= int.parse(minute) &&
                    now.second > 0
                ? now.day + 1
                : now.day,
        isAm ? int.parse(hour) : int.parse(hour) + 12,
        int.parse(minute));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        elevation: 3,
        centerTitle: false,
        title: Text(
          "Alarm Analog",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.amber,
        actions: [
          Align(
            alignment: Alignment.center,
            child: Text(
              isActived ? 'Active' : 'Off',
              style: TextStyle(
                color: isActived ? Colors.white : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Switch(
              value: isActived,
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  isActived = value;
                  if (isActived) {
                    NotificationApi.showNotificationSchedule(
                        title: 'Alarm',
                        body: 'Your alarm is active',
                        payload: setDateTime().toString(),
                        scheduleDate: setDateTime());
                    Future.delayed(
                        Duration(
                            seconds: setDateTime()
                                .difference(DateTime.now())
                                .inSeconds), () {
                      isActived = false;
                    });
                    showSnackBar();
                  } else {
                    NotificationApi.cancel();
                  }
                });
              })
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BlocBuilder<HourBloc, HourState>(
                  builder: (context, state) {
                    Future.delayed(Duration.zero, () {
                      if (state is LoadedHour) {
                        setState(() {
                          hour = state.hour;
                        });
                      }
                    });
                    return Text(state is LoadedHour ? state.hour : '00',
                        style: TextStyle(
                            fontSize: 54, fontWeight: FontWeight.bold));
                  },
                ),
                SizedBox(
                  width: 5,
                ),
                Text(':',
                    style:
                        TextStyle(fontSize: 54, fontWeight: FontWeight.bold)),
                SizedBox(
                  width: 5,
                ),
                BlocBuilder<MinuteBloc, MinuteState>(
                  builder: (context, state) {
                    Future.delayed(Duration.zero, () {
                      if (state is LoadedMinute) {
                        setState(() {
                          minute = state.minute;
                        });
                      }
                    });
                    return Text(state is LoadedMinute ? state.minute : '00',
                        style: TextStyle(
                            fontSize: 54, fontWeight: FontWeight.bold));
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: ToggleButtons(
                    selectedColor: Colors.white,
                    children: const [
                      Text(
                        'AM',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'PM',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                    onPressed: (int index) {
                      setState(() {
                        for (int buttonIndex = 0;
                            buttonIndex < isSelected.length;
                            buttonIndex++) {
                          if (buttonIndex == index) {
                            isAm = index == 0 ? true : false;
                            isActived = false;
                            isSelected[buttonIndex] = true;
                            NotificationApi.cancel();
                          } else {
                            isSelected[buttonIndex] = false;
                          }
                        }
                      });
                    },
                    isSelected: isSelected,
                  ),
                ),
              ],
            ),
          ),
          Clock(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: null,
        elevation: 3,
        child: Icon(
          Icons.add,
          color: Colors.blue,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: Colors.amber,
        notchMargin: 4,
        clipBehavior: Clip.antiAlias,
        child: BottomNavigationBar(backgroundColor: Colors.amber, items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Menu"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add Alrm"),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: "List Alarm"),
        ]),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
