import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

class HomeWidgetPage extends StatefulWidget {
  final String title;
  const HomeWidgetPage({Key? key, required this.title}) : super(key: key);

  @override
  HomeWidgetPageState createState() => HomeWidgetPageState();
}

class HomeWidgetPageState extends State<HomeWidgetPage> {
  int _counter = 0;

  // @override
  // void initState() {
  //   super.initState();
  //   HomeWidget.widgetClicked.listen((Uri? uri) => loadData());
  //   loadData(); // This will load data from widget every time app is opened
  // }

  // void loadData() async {
  //   await HomeWidget.getWidgetData<int>('_counter', defaultValue: 0)
  //       .then((value) {
  //     _counter = value!;
  //   });
  //   setState(() {});
  // }

  // Future<void> updateAppWidget() async {
  //   await HomeWidget.saveWidgetData<int>('_counter', _counter);
  //   await HomeWidget.updateWidget(
  //       name: 'HomeScreenWidgetProvider', iOSName: 'HomeScreenWidgetProvider');
  // }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    // updateAppWidget();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              // style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
