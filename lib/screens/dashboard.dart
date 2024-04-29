import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mymeds_app/components/language_constants.dart';
import 'package:mymeds_app/screens/add_medication1.dart';
import 'package:mymeds_app/screens/alarm_ring.dart';
import 'package:mymeds_app/screens/chatbot.dart';
import 'package:mymeds_app/screens/homepage2.dart';
import 'package:mymeds_app/screens/medication.dart';
import 'package:mymeds_app/screens/more.dart';
import 'package:mymeds_app/screens/statistic.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final user = FirebaseAuth.instance.currentUser;

  //bottom nav bar
  int _selectedIndex = 0;

  //Floating Action Button
  bool isFABvisible = true;
  bool chatBot = true;

  //alarm list
  late List<AlarmSettings> alarms;

  static StreamSubscription? subscription;

  void loadAlarms() {
    setState(() {
      alarms = Alarm.getAlarms();
      alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    });
  }

//show alarm ring screen
  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    print('Opened ring screen');
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AlarmScreen(alarmSettings: alarmSettings),
        ));
    loadAlarms();
  }

  // // documnet IDs
  // List<String> docIDs = [];

  // //get docIDs
  // Future getDocIDs() async {
  //   await FirebaseFirestore.instance.collection('users').get().then(
  //         (snapshot) => snapshot.docs.forEach(
  //           (documnet) {
  //             print(documnet.reference);
  //             docIDs.add(documnet.reference.id);
  //           },
  //         ),
  //       );
  // }

  @override
  void initState() {
    loadAlarms();
    subscription ??= Alarm.ringStream.stream.listen(
      (alarmSettings) => navigateToRingScreen(alarmSettings),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //pages
    final List<Widget> pages = <Widget>[
      //main page
      const HomePage2(),
      //medication
      const Mediaction(),
      //statistic
      const Statistic(),
      //settings
      const More(),
    ];

    //scaffold
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(),
      ),
      body: SafeArea(
        child: Center(
          child: pages.elementAt(_selectedIndex),
        ),
      ),
      //floating action button
      floatingActionButton: isFABvisible
          ? FloatingActionButton(
              onPressed: () {
                !chatBot
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddMedication1(),
                        ),
                      )
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatBot(),
                        ),
                      );
              },
              // shape: const RoundedRectangleBorder(
              //   borderRadius: BorderRadius.all(
              //     Radius.circular(50.0),
              //   ),
              // ),

              backgroundColor: const Color.fromARGB(255, 14, 149, 173),
              foregroundColor: Theme.of(context).colorScheme.background,
              child: !chatBot
                  ? const Icon(Icons.add)
                  : const Icon(Icons.smart_toy_outlined),
            )
          : null,
      // floatingActionButtonLocation:
      //     FloatingActionButtonLocation.miniCenterDocked,
      //bottom navigation
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color.fromARGB(255, 242, 253, 255),
        destinations: [
          //home
          NavigationDestination(
            icon: const Icon(
              Icons.home_outlined,
            ),
            label: translation(context).home,
            selectedIcon: const Icon(
              Icons.home_rounded,
              color: Color.fromRGBO(7, 82, 96, 1),
            ),
          ),
          //medications
          NavigationDestination(
            icon: const Icon(
              Icons.medication_outlined,
            ),
            label: translation(context).medications,
            selectedIcon: const Icon(
              Icons.medication,
              color: Color.fromRGBO(7, 82, 96, 1),
            ),
          ),
          //history
          NavigationDestination(
            icon: const Icon(
              Icons.analytics_outlined,
            ),
            label: translation(context).statistics,
            selectedIcon: const Icon(
              Icons.analytics_rounded,
              color: Color.fromRGBO(7, 82, 96, 1),
            ),
          ),
          //settings
          NavigationDestination(
            icon: const Icon(
              Icons.dashboard_customize_outlined,
            ),
            label: translation(context).more,
            selectedIcon: const Icon(
              Icons.dashboard_customize_rounded,
              color: Color.fromRGBO(7, 82, 96, 1),
            ),
          ),
        ],
        // unselectedLabelStyle: GoogleFonts.roboto(
        //   fontWeight: FontWeight.w400,
        // ),
        // selectedLabelStyle: GoogleFonts.roboto(
        //   fontWeight: FontWeight.w600,
        // ),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int) {
          switch (int) {
            case 0:
              isFABvisible = true;
              chatBot = true;
              break;
            case 1: //home
              //show FAB in medication page
              isFABvisible = true;
              chatBot = false;
              break;
            case 2:
              isFABvisible = false;
              chatBot = false;
              break;
            case 3:
              chatBot = false;
              isFABvisible = false;
              break;
          }

          setState(() {
            _selectedIndex = int;
          });
        },
      ),
    );
  }
}
