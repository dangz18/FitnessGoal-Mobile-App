import 'package:flutter/material.dart';
import 'package:fitness_goal_android_app/models/graphPoint.dart';
//To use graph
import 'package:syncfusion_flutter_charts/charts.dart';

class LineChartGraph extends StatelessWidget{
  final List<GraphPoint> points;
  final String units;
  final List<Color> gradient = [Colors.lightBlue, Color(0xFFDF5658)];

  LineChartGraph(this.points, this.units, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      child: SfCartesianChart(
        trackballBehavior: TrackballBehavior(
          enable: true,
        ),
        enableAxisAnimation: true,
        primaryXAxis: DateTimeAxis(
          title: AxisTitle(
            text: "Date",
            textStyle: TextStyle(fontSize: 15, fontFamily: 'calibri'),
          ),
        ),
        primaryYAxis: NumericAxis(
          labelFormat: "{value} ${units}"
        ),
        series: [
          LineSeries(
            isVisible: true,
            animationDuration: 2000,
            animationDelay: 5000,
            color: Colors.red,
            width: 3,
            dataSource: points,
            xValueMapper: (GraphPoint point,_)=>point.x,
            yValueMapper: (GraphPoint point,_)=>point.y,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
            ),
            enableTooltip: true,
          ),
        ],
      ),
    );
  }
}