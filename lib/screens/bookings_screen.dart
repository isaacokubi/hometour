import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class BookingsScreen extends StatelessWidget { const BookingsScreen({super.key});
@override Widget build(BuildContext context){final s=context.watch<AppState>();return Scaffold(appBar:AppBar(title:const Text('My bookings'),actions:[IconButton(onPressed:s.loadBookings,icon:const Icon(Icons.refresh))]),body:RefreshIndicator(onRefresh:s.loadBookings,child:s.bookings.isEmpty?const ListView(children:[SizedBox(height:220),Center(child:Text('No bookings yet. Explore a tour to get started.'))]):ListView.builder(padding:const EdgeInsets.all(16),itemCount:s.bookings.length,itemBuilder:(_,i){final b=s.bookings[i];return Card(child:ListTile(title:Text(b.tourName),subtitle:Text(b.travelDate+'\nKES '+b.total.toStringAsFixed(0)),isThreeLine:true,trailing:Chip(label:Text(b.status)));})));}}
