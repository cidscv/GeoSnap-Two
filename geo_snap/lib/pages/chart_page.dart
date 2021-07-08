import 'package:flutter/material.dart';

import 'package:charts_flutter/flutter.dart' as charts;

import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:geo_snap/backend/posts.dart';

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Page that displays the 10 most popular posts on our app based on the amount *
 * of likes they have recieved, sorted from most liked to least liked.         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
class BarChartPage extends StatefulWidget {
  BarChartPage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _BarChartPageState createState() => _BarChartPageState();
}

class _BarChartPageState extends State<BarChartPage> {
  @override
  Widget build(BuildContext context) {
    List<Post> posts = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        appBar: AppBar(
          title: Text("Top 10 Most Popular Posts"),
        ),
        body: barchart(posts));
  }

  Widget barchart(List<Post> postdata) {
    return Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(children: [
          Center(
              child: Text(FlutterI18n.translate(context, "chart.title"),
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                      fontWeight: FontWeight.bold))),
          SizedBox(
              height: 500.0,
              child: charts.BarChart(
                _createUpvoteData(postdata),
                vertical: false,
                animate: true,
                domainAxis: new charts.OrdinalAxisSpec(
                    renderSpec: new charts.SmallTickRendererSpec(
                        labelStyle: new charts.TextStyleSpec(
                            fontSize: 12, color: charts.MaterialPalette.white),
                        lineStyle: new charts.LineStyleSpec(
                            color: charts.MaterialPalette.black))),
                primaryMeasureAxis: new charts.NumericAxisSpec(
                    renderSpec: new charts.GridlineRendererSpec(
                        labelStyle: new charts.TextStyleSpec(
                            fontSize: 12, color: charts.MaterialPalette.white),
                        lineStyle: new charts.LineStyleSpec(
                            color: charts.MaterialPalette.black))),
              ))
        ]));
  }

  static List<charts.Series<Post, String>> _createUpvoteData(
      final List<Post> postdata) {
    return [
      new charts.Series<Post, String>(
        id: 'Post Likes',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Post posts, _) => posts.title,
        measureFn: (Post posts, _) => posts.numlikes,
        data: postdata,
      ),
    ];
  }
}
