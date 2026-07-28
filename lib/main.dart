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
  final GlobalKey<TooltipState> tooltipKey = GlobalKey<TooltipState>();

  List<Point> points = [];
  int pointsIndex = 0;

  List<Point> displayPoints = [];
  Timer? timer;

  double axisMin = 0;
  double axisMax = 0;

  ChartSeriesController? controller;

  bool over = true;

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

      timer?.cancel();
      controller = null;

      setState(() {
        points.clear();
        displayPoints.clear();

        for (int i = 1; i < rows.length; i++) {
          if (rows[i].length < 2) continue;

          points.add(
            Point(
              double.parse(rows[i][0].toString()),
              double.parse(rows[i][1].toString()),
            ),
          );
        }

        startSimulation();
      });
    }
  }

  void startSimulation() {
    if (points.isEmpty) {
      return;
    }

    over = false;
    pointsIndex = 0;
    displayPoints.clear();
    timer?.cancel();
    controller = null;

    timer = Timer.periodic(Duration(milliseconds: 20), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }

      if (pointsIndex < points.length) {
        displayPoints.add(points[pointsIndex]);

        if (displayPoints.length > 100) {
          displayPoints.removeAt(0);
          controller?.updateDataSource(
            addedDataIndexes: <int>[displayPoints.length - 1],
            removedDataIndexes: <int>[0],
          );
        } else {
          controller?.updateDataSource(
            addedDataIndexes: <int>[displayPoints.length - 1],
          );
        }

        axisMin = displayPoints.first.x;
        axisMax = displayPoints.last.x;

        pointsIndex++;

        setState(() {});
      } else {
        timer?.cancel();
        setState(() {
          over = true;
        });
      }
    });
  }

  void cancelSimulation() {
    timer?.cancel();
    controller = null;
    setState(() {
      over = true;
      displayPoints.clear();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    controller = null;
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
        padding: EdgeInsets.fromLTRB(20, 50, 20, 50),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: over ? loadFile : cancelSimulation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                    ),
                    child: Text(
                      over ? "Upload File" : "Cancel",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Tooltip(
                    key: tooltipKey,
                    triggerMode: TooltipTriggerMode.manual,
                    message:
                        "Chosen file must be a CSV file with two columns. The first column is the x value and the second column is the y value.",
                    child: IconButton(
                      onPressed: () {
                        tooltipKey.currentState?.ensureTooltipVisible();
                      },
                      icon: Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: displayPoints.isEmpty
                    ? Center(
                        child: Text(
                          "No File Loaded",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 40, 0),
                        child: SfCartesianChart(
                          key: ValueKey(
                            pointsIndex > 0 && displayPoints.length <= 1
                                ? DateTime.now()
                                : 'chart',
                          ),
                          primaryXAxis: NumericAxis(
                            minimum: axisMin,
                            maximum: axisMax,
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
                            interval: 2,
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
                              onRendererCreated: (ChartSeriesController c) {
                                controller = c;
                              },
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
