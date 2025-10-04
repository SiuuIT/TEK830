import 'package:flutter/material.dart';
import 'widgets/statisicAreaWidget.dart';
void main() {
  runApp(const MyHomePage());
}
class MyHomePage extends StatefulWidget { 
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage>  {
  bool showStats = false;
  int refresher = 0; //variable for refreshing the statistics area
  void toggleOrRefresh(){
    setState((){
      if (!showStats){
        showStats = true; 
        refresher = 1; 
      }
      else{
        refresher++;
      }
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ikea App',
      
      home:Scaffold(
        backgroundColor: Colors.white,  
        
        body: Row(
          children: [
            Expanded(
              
              child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Control Area'),

                  Container(
                    decoration:BoxDecoration(
                    ),
                    padding: EdgeInsets.all(8.0),
                    margin: EdgeInsets.all(8.0),
                    child:ElevatedButton(
                      onPressed: toggleOrRefresh, 
                      child: Text(showStats ? 'Refresh Statistics Area' : 'Load Statistics Area')
                    ),
                ),
               ],
               
              ),
              
                
            ),
            Expanded(
              flex: 4,
              child:Container(
                decoration:BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                padding: EdgeInsets.all(8.0),
                margin: EdgeInsets.all(8.0),
                width: double.infinity,
                height: double.infinity,
                child:Center( 
                  // by sending a new key, the widget is rebuilt from scratch
                  child: showStats ? StatisticsAreaWidget(key: ValueKey(refresher)) : Text('Main Area')
                ),
              ),
            ),
          ],
        ),
      )
      
    );
  }
}
