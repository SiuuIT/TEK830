import 'package:flutter/material.dart';
//this is the usable widget
class StatisticsAreaWidget extends StatefulWidget{
  const StatisticsAreaWidget({super.key});
  @override
  State<StatisticsAreaWidget> createState() => _StatisticsAreaWidgetState();

}

class _StatisticsAreaWidgetState extends State<StatisticsAreaWidget>{
  bool showStats = false; 
  int counter = 0;
  // toggles between beeing loaded and not loaded
  @override
  void initState(){
    super.initState();
    showStats = true; 
    counter++;
  }
  
  @override
  Widget build(BuildContext context){
    return Container(
      decoration:BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.all(8.0),
      child:Center( 
        child: Text('Main Statistics Area')
      ),
    );
  }
}