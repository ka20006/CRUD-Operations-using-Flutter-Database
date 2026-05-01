// Created by Kavan Patel

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  List<Map<String, dynamic>> students = [];
  int? editIndex;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // LOAD DATA
  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString("students");

    if (data != null) {
      setState(() {
        students = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  // SAVE DATA
  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("students", jsonEncode(students));
  }

  // ADD / UPDATE
  void addOrUpdate() {
    if (nameController.text.isEmpty || ageController.text.isEmpty) return;

    if (editIndex == null) {
      students.add({"name": nameController.text, "age": ageController.text});
    } else {
      students[editIndex!] = {
        "name": nameController.text,
        "age": ageController.text,
      };
    }

    saveData();

    setState(() {
      nameController.clear();
      ageController.clear();
      editIndex = null;
    });
  }

  // DELETE
  void deleteData(int index) {
    setState(() {
      students.removeAt(index);
    });
    saveData();
  }

  // EDIT
  void editData(int index) {
    setState(() {
      nameController.text = students[index]["name"];
      ageController.text = students[index]["age"];
      editIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CRUD App"), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Enter Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Enter Age",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: addOrUpdate,
                  child: Text(editIndex == null ? "Add Data" : "Update Data"),
                ),
              ],
            ),
          ),

          Expanded(
            child: students.isEmpty
                ? Center(
                    child: Text(
                      "No Data Available",
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                : ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          leading: CircleAvatar(child: Text("${index + 1}")),
                          title: Text(students[index]["name"]),
                          subtitle: Text("Age: ${students[index]["age"]}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => editData(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteData(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Created by Kavan Patel",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
