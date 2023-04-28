import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/item.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = [];

  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskController = TextEditingController();

  void add() {
    if (newTaskController.text.isEmpty) return;

    setState(() {
      widget.items.add(
        Item(
          title: newTaskController.text,
          done: false,
        ),
      );
      newTaskController.text = "";
      save();
    });
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');

    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();

      setState(() {
        widget.items = result;
      });
    }
  }

  Future save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  _HomePageState() {
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskController,
          keyboardType: TextInputType.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          decoration: const InputDecoration(
            labelText: "Nova tarefa",
            labelStyle: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext ctx, int index) {
          final item = widget.items[index];

          return Dismissible(
              key: Key(item.title),
              background: Container(
                color: Colors.red.withOpacity(0.4),
              ),
              onDismissed: (direction) {
                remove(index);
              },
              child: CheckboxListTile(
                value: item.done,
                title: Text(item.title),
                onChanged: (value) {
                  setState(() {
                    item.done = value;
                    save();
                  });
                },
              ));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add),
      ),
    );
  }
}
