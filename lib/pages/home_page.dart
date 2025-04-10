import 'package:flutter/material.dart';
import 'breathing_page.dart';
import 'notes_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final _notesKey = GlobalKey<NotesPageState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          BreathingPage(
            key: UniqueKey(),
            onLogAdded: () {
              // Trigger refresh of logs when a new log is added
              final notesState = _notesKey.currentState;
              if (notesState != null) {
                notesState.refreshLogs();
              }
            },
          ),
          NotesPage(key: _notesKey),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 80),
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            navigationBarTheme: NavigationBarThemeData(
              indicatorColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            backgroundColor: const Color.fromARGB(0, 255, 0, 0),
            elevation: 0,
            indicatorColor: Colors.transparent,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: [
              NavigationDestination(
                icon: Icon(
                  Icons.bubble_chart_outlined,
                  color: _selectedIndex == 0
                      ? const Color.fromARGB(255, 31, 57, 95)
                      : Colors.blue.shade300,
                ),
                label: '',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.edit_note_outlined,
                  color: _selectedIndex == 1
                      ? const Color.fromARGB(255, 31, 57, 95)
                      : Colors.blue.shade300,
                ),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
