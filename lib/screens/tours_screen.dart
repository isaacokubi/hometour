import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'tour_details_screen.dart';

class ToursScreen extends StatelessWidget {
  const ToursScreen({super.key});
  @override Widget build(BuildContext context) {
    final s=context.watch<AppState>();
    return Scaffold(appBar:AppBar(title:const Text('Tours'),actions:[IconButton(onPressed:s.loadTours,icon:const Icon(Icons.refresh))]),body:RefreshIndicator(onRefresh:s.loadTours,child:ListView.builder(padding:const EdgeInsets.all(16),itemCount:s.tours.length,itemBuilder:(_,i){final t=s.tours[i];return Card(child:ListTile(title:Text(t.title),subtitle:Text(t.location+' • '+t.durationDays.toString()+' day(s) • KES '+t.price.toStringAsFixed(0)),trailing:const Icon(Icons.arrow_forward_ios,size:16),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>TourDetailsScreen(tour:t))));})));
  }
}
