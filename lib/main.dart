import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:yocket_flutter_app/widgets/task_card.dart';
import 'package:yocket_flutter_app/widgets/task_grid.dart';
import 'widgets/list_to_card.dart';
import 'widgets/new_task.dart';
import 'models/task_model.dart';

enum status {
  todo,
  inProgress,
  completed,
} // Defines the status for individual tasks.

bool globalView = false; // Checker for Listview vs. Globalview

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const MyHomePage(title: 'A To-Do Application'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  resetScreen() {
    setState(() {});
  } //This function can be passed to child widgets to setState for parent widget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Colors.indigo.shade100,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListToCard(
              parentState: resetScreen,
            ),
          ),
          FutureBuilder(
            future: getTasks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data.toString() != '[]') {
                  var tasks = snapshot.data as List<Task>;
                  var allCards = <Widget>[];
                  if (!globalView) {
                    for (var element in tasks) {
                      allCards
                          .add(TaskCard(task: element, delete: resetScreen));
                    }
                    return ListView(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      children: allCards,
                    );
                  } else {
                    for (var element in tasks) {
                      allCards.add(TaskGrid(
                        task: element,
                        delete: resetScreen,
                      ));
                    }
                    return GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      children: allCards,
                      childAspectRatio: 1 /
                          1.2, //This is to fit all the information within the card.
                    );
                  }
                } else {
                  return const Center(
                    child: Text(
                        "No Tasks Available, click the '+' button to create a new task"),
                  );
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
              context: context, builder: (context) => const NewTask());
          setState(() {});
        },
        tooltip: 'Create New Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<Database> connectToDataBase() async {
  final database = openDatabase(
    join(await getDatabasesPath(), 'tasks.db'),
    onCreate: (db, version) {
      return db.execute(
          "CREATE TABLE tasks(id INTEGER PRIMARY KEY NOT NULL, title TEXT, description TEXT, duration INTEGER, completed INTEGER)");
    },
    version: 1,
  );
  return database;
} // A function that sets up connection to database.

Future<void> createTask(
    String title, String? description, String minutes, String seconds) async {
  final db = await connectToDataBase();

  Task task = Task(
    id: await getLast(),
    title: title,
    description: description,
    duration: timeConverterToInt(minutes, seconds),
  );
  await db.insert(
    'tasks',
    task.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
} // Stores a newly created task in the database.

int timeConverterToInt(String minutes, String seconds) {
  if (int.parse(minutes) == 0) {
    if (int.parse(seconds) == 0) {
      return 0;
    }
    return int.parse(seconds);
  } else {
    int min = int.parse(minutes) * 60;
    int sec = int.parse(seconds);
    return min + sec;
  }
} //This is to keep duration as a single total seconds time unit so that the synchronization is kept.

Future<void> updateTask(Task task) async {
  final db = await connectToDataBase();
  await db.update(
    'tasks',
    task.toMap(),
    where: 'id = ?',
    whereArgs: [task.id],
  );
} // So that new timer counts can be updated.

Future<List<Task>> getTasks() async {
  final db = await connectToDataBase();
  final List<Map<String, dynamic>> tasks = await db.query('tasks');
  return List.generate(tasks.length, (i) {
    return Task(
        id: tasks[i]['id'],
        title: tasks[i]['title'],
        description: tasks[i]['description'],
        duration: tasks[i]['duration'],
        completed: tasks[i]['completed']);
  });
}  // Gets data from the table in database

showPickerArray(BuildContext context, TextEditingController minuteController,
    TextEditingController secondController) {
  Picker(
      adapter: NumberPickerAdapter(data: [
        const NumberPickerColumn(begin: 0, end: 10),
        const NumberPickerColumn(begin: 0, end: 60)
      ]),
      // delimiter: PickerDelimiter,
      // headerDecoration: ,
      hideHeader: true,
      selecteds: [10, 0],
      title: Column(
        children: [
          const Text("Pick duration"),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [Text("Minutes"), Text("Seconds")],
          ),
        ],
      ),
      selectedTextStyle: const TextStyle(color: Colors.orange),
      cancel: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel")),
      onConfirm: (Picker picker, List value) {
        var minutes = picker.getSelectedValues()[0];
        var seconds = picker.getSelectedValues()[1];
        minuteController.text = minutes.toString();
        secondController.text = seconds.toString();
      }).showDialog(context);
}// Helps pick timer

Future<int> getLast() async {
  final db = await connectToDataBase();
  final List<Map<String, dynamic>> tasks = await db.query('tasks');
  int len = tasks.length;
  return len + 1;
} //Gets the ID for the next Task

List<int> secondToMins(int seconds) {
  if (seconds < 60) {
    return [0, seconds];
  } else {
    return [seconds ~/ 60, seconds % 60];
  }
} // duration split
