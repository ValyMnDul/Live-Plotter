import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:csv/csv.dart';
import 'blueprints.dart';
import 'dart:async';
import 'package:syncfusion_flutter_charts/charts.dart';

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

  int pointsIndex = 0;
  List<Point> displayPoints = [];
  Timer? timer;

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
        displayPoints.clear();
        timer?.cancel();

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

  void startSimulation() {
    if (points.isEmpty == true) {
      return;
    }

    pointsIndex = 0;
    displayPoints.clear();
    timer?.cancel();

    timer = Timer.periodic(Duration(milliseconds: 30), (t) {
      setState(() {
        if (pointsIndex < points.length) {
          displayPoints.add(points[pointsIndex]);
          pointsIndex++;

          if (displayPoints.length > 40) {
            displayPoints.removeAt(0);
          }
        } else {
          timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
        padding: EdgeInsets.fromLTRB(20, 80, 20, 50),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: loadFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                ),
                child: Text(
                  "Upload File",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: startSimulation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                ),
                child: Text(
                  "Start",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              SizedBox(height: 40),
              Expanded(
                child: displayPoints.isEmpty
                    ? Center(
                        child: Text(
                          points.isEmpty ? "No File Loaded" : "Press Start",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 40, 0),
                        child: SfCartesianChart(
                          primaryXAxis: const NumericAxis(
                            title: AxisTitle(
                              text: "Time (s)",
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontSize: 15,
                              ),
                            ),
                            majorGridLines: MajorGridLines(
                              width: 0.5,
                              color: Colors.white,
                            ),
                          ),
                          primaryYAxis: const NumericAxis(
                            minimum: -2.0,
                            maximum: 4.0,
                            interval: 1,
                            title: AxisTitle(
                              text: "Value",
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontSize: 15,
                              ),
                            ),
                            majorGridLines: MajorGridLines(
                              width: 0.5,
                              color: Colors.white,
                            ),
                          ),
                          series: <CartesianSeries<Point, double>>[
                            LineSeries<Point, double>(
                              animationDuration: 0,
                              dataSource: displayPoints,
                              xValueMapper: (Point data, _) => data.x,
                              yValueMapper: (Point data, _) => data.y,
                              color: Colors.greenAccent,
                              width: 2.5,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
