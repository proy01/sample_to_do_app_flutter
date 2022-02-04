import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yocket_flutter_app/models/task_model.dart';
import 'package:yocket_flutter_app/main.dart';

class TaskGrid extends StatefulWidget {
  final Task task;
  final Function delete;

  const TaskGrid({Key? key, required this.task, required this.delete})
      : super(key: key);

  @override
  _TaskGridState createState() => _TaskGridState();
}

class _TaskGridState extends State<TaskGrid> {
  Future<void> deleteTask(Task task) async {
    final db = await connectToDataBase();
    db.delete('tasks', where: 'id = ?', whereArgs: [task.id]);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Column(
        children: [
          TaskGridTimer(
            task: widget.task,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  child: Text(
                    (widget.task.id.toString() + ". " + widget.task.title),
                    style: const TextStyle(fontSize: 16),
                    maxLines: 2,
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    deleteTask(widget.task);
                    widget.delete();
                  },
                  icon: const Icon(Icons.delete)),
            ],
          ),
          Flexible(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.task.description.toString(), maxLines: 1, style: TextStyle(fontSize: 12, color: Colors.grey.shade600),),
          ))
        ],
      ),
    );
  }
}

class TaskGridTimer extends StatefulWidget {
  final Task task;

  TaskGridTimer({Key? key, required this.task}) : super(key: key);

  @override
  _TaskGridTimerState createState() => _TaskGridTimerState();
}

class _TaskGridTimerState extends State<TaskGridTimer> {
  bool play = false;
  Timer? x;
  late bool timeZero;
  List<Icon> playPause = [
    const Icon(Icons.play_arrow),
    const Icon(Icons.pause)
  ];
  int currentIcon = 0;
  var currentStatus;

  timerCounter() async {
    play = !play;
    await updateTask(widget.task);
    if (play) {
      currentIcon = 1;
      setState(() {
        currentStatus = status.inProgress;
      });
    } else {
      currentIcon = 0;
      setState(() {
        if(widget.task.completed == 1){
          currentStatus = status.completed;
        } else {
          currentStatus = status.todo;
        }
      });
    }
    if (play && !timeZero) {
      x = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          widget.task.duration--;
          if (widget.task.duration <= 0) {
            x?.cancel();
            timeZero = true;
            play=true;
            currentIcon = 0;
            currentStatus = status.completed;
            widget.task.completed = 1;
          }
        });
        if(timeZero){
          timerCounter();
        }
      });
    } else {
      x?.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    if(widget.task.completed == 1){
      currentStatus = status.completed;
      timeZero = true;
    } else {
      currentStatus = status.todo;
      timeZero = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          secondToMins(widget.task.duration)[0].toString() +
              "  " +
              secondToMins(widget.task.duration)[1].toString(),
          style: const TextStyle(fontSize: 36),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Builder(
              builder: (context) {
                if (widget.task.completed == 1) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.check_box,
                          color: Colors.green,
                        ),
                        Text("Status:  Completed")
                      ],
                    ),
                  );
                } else if (currentStatus == status.todo && widget.task.completed == 0) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.indeterminate_check_box,
                          color: Colors.grey,
                        ),
                        Text("Status:  ToDo")
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.build_circle,
                          color: Colors.blue,
                        ),
                        Text("Status:  In-Progress")
                      ],
                    ),
                  );
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.indigo.shade100,
                    ),
                    child: IconButton(
                        onPressed: () {
                          timeZero ? null : timerCounter();
                        },
                        icon: playPause[currentIcon]),
                  ),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    x?.cancel();
    super.dispose();
  }
}
