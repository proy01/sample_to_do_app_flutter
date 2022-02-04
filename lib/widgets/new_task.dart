import 'package:flutter/material.dart';
import '../main.dart';

class NewTask extends StatefulWidget {
  const NewTask({Key? key}) : super(key: key);

  @override
  State<NewTask> createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      scrollable: true,
      insetPadding: EdgeInsets.fromLTRB(75, 100, 75, 75),
      title: Text("Create Task"),
      content: NewTaskForm(),
    );
  }
}

class NewTaskForm extends StatefulWidget {
  const NewTaskForm({Key? key}) : super(key: key);

  @override
  _NewTaskFormState createState() => _NewTaskFormState();
}

class _NewTaskFormState extends State<NewTaskForm> {
  final _taskFromKey = GlobalKey<FormState>();
  final _taskTitle = TextEditingController();
  final _taskDescription = TextEditingController();
  final _taskMinutes = TextEditingController();
  final _taskSeconds = TextEditingController();

  @override
  void initState() {
    super.initState();
    _taskMinutes.text = '10';
    _taskSeconds.text = '0';
  }

  Future<void> create() async {
    await createTask(_taskTitle.text, _taskDescription.text, _taskMinutes.text,
        _taskSeconds.text);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _taskFromKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: "Enter a Task title",
            ),
            controller: _taskTitle,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: "Enter a Task Description (optional)"),
            controller: _taskDescription,
          ),
          const SizedBox(height: 20,),
          const Text("Duration:"),
          TextFormField(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: "Minutes"
            ),
            enabled: false,
            controller: _taskMinutes,
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: "Seconds",
            ),
            enabled: false,
            controller: _taskSeconds,
            keyboardType: TextInputType.number,
            validator: (value){
              if(_taskMinutes.text == '0'){
                if(int.parse(_taskSeconds.text) < 1){
                  return 'Please enter a proper duration';
                }
              }
              return null;
            },
          ),
          IconButton(
            onPressed: () {
              showPickerArray(context, _taskMinutes, _taskSeconds);
            },
            icon: const Icon(Icons.edit),
            tooltip: "Edit the duration",
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () async {
                    if(_taskFromKey.currentState!.validate()){
                      await create();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    "Create",
                    style: TextStyle(color: Colors.blue),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}