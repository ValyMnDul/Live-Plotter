import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:csv/csv.dart';
import 'blueprints.dart';

void main() {
  runApp(MaterialApp(home: Home(), debugShowCheckedModeBanner: false));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Point> points = [];

  Future<void> loadFile() async {
    final typeGroup = XTypeGroup(
      label: 'CSV Files',
      extensions: <String>['csv'],
    );

    final XFile? file = await openFile(
      acceptedTypeGroups: <XTypeGroup>[typeGroup],
    );

    if (file != null) {
      String content = await file.readAsString();

      List<List<dynamic>> rows = Csv().decode(content);

      setState(() {
        points.clear();

        for (int i = 1; i < rows.length; i++) {
          if (rows[i].length < 2) continue;

          points.add(
            Point(
              double.parse(rows[i][0].toString()),
              double.parse(rows[i][1].toString()),
            ),
          );
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Live plotter",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30.0,
            fontFamily: "Poppins",
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[700],
      ),
      backgroundColor: Colors.grey[800],
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: loadFile, child: Text("Upload File")),
              SizedBox(height: 20),
              Text(
                points.isEmpty
                    ? "No data yet"
                    : "${points[1].x} by ${points[1].y}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
