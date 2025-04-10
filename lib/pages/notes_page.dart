import 'package:flutter/material.dart';
import 'package:pop/pages/info_page.dart';
import 'package:pop/pages/setting_page.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pop/db/database_helper.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => NotesPageState();
}

class NotesPageState extends State<NotesPage> with WidgetsBindingObserver {
  List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refreshLogs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    refreshLogs();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    if (mounted) setState(() {});
    super.didChangePlatformBrightness();
  }

  Future<void> refreshLogs() async {
    final logs = await DatabaseHelper().getLogs();
    if (mounted) {
      setState(() {
        _logs = logs;
      });
    }
  }

  Future<void> _deleteLog(int id) async {
    await DatabaseHelper().deleteLog(id);
    refreshLogs();
  }

  @override
  Widget build(BuildContext context) {
    // Force rebuild on theme change
    Theme.of(context);
    
    return ValueListenableBuilder(
      valueListenable: ValueNotifier<ThemeMode>(
        Theme.of(context).brightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
      ),
      builder: (context, ThemeMode themeMode, child) {
        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                toolbarHeight: 45,
                title: const Text("Breath Work Logs"),
                titleTextStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color.fromARGB(255, 31, 57, 95)
                      : Colors.blue.shade100,
                  fontSize: 20,
                ),
                backgroundColor: Colors.transparent,
                floating: true,
                snap: true,
                leading: IconButton(
                  padding: const EdgeInsets.only(left: 35),
                  icon: const Icon(Icons.info_outline, size: 25),
                  color: const Color.fromARGB(255, 191, 191, 191),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const InfoPage()),
                    );
                  },
                ),
                actions: [
                  IconButton(
                    padding: const EdgeInsets.only(right: 35),
                    icon: const Icon(Icons.settings_outlined),
                    color: const Color.fromARGB(255, 191, 191, 191),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingPage()),
                      );
                    },
                  ),
                ],
              ),
            ],
            body: _logs.isEmpty
                ? const Center(
                    child: Text("No pops yet.", style: TextStyle(fontSize: 16)))
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return AnimatedTheme(
                        duration: const Duration(milliseconds: 300),
                        data: Theme.of(context),
                        child: Slidable(
                          key: ValueKey(log['id']),
                          endActionPane: ActionPane(
                            motion: const StretchMotion(),
                            extentRatio: 0.25,
                            children: [
                              CustomSlidableAction(
                                onPressed: (context) => _deleteLog(log['id']),
                                backgroundColor: Colors.transparent,
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Theme.of(context).brightness == Brightness.light
                                ? Colors.blue.shade50
                                : const Color.fromARGB(255, 30, 45, 65),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          log['date'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context).brightness == Brightness.light
                                                ? const Color.fromARGB(255, 31, 57, 95)
                                                : Colors.blue.shade100,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Duration: ${log['totalTime']}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context).brightness == Brightness.light
                                                ? Colors.blue.shade900.withOpacity(0.7)
                                                : Colors.blue.shade200.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Theme.of(context).brightness == Brightness.light
                                                ? Colors.blue.shade900.withOpacity(0.7)
                                                : Colors.blue.shade200.withOpacity(0.7),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${log['startTime']} - ${log['endTime']}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context).brightness == Brightness.light
                                                ? Colors.blue.shade900.withOpacity(0.7)
                                                : Colors.blue.shade200.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).brightness == Brightness.light
                                              ? Colors.green.shade100
                                              : const Color.fromARGB(255, 20, 50, 30),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              size: 14,
                                              color: Theme.of(context).brightness == Brightness.light
                                                  ? Colors.green.shade700
                                                  : Colors.green.shade300,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "Completed",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context).brightness == Brightness.light
                                                  ? Colors.green.shade700
                                                  : Colors.green.shade300,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
