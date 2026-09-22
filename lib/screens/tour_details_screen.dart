import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/tour.dart';
import '../state/app_state.dart';

class TourDetailsScreen extends StatefulWidget {
  const TourDetailsScreen({super.key,required this.tour}); final Tour tour;
  @override State<TourDetailsScreen> createState()=>_TourDetailsScreenState();
}
class _TourDetailsScreenState extends State<TourDetailsScreen>{
  DateTime date=DateTime.now().add(const Duration(days:1)); int travellers=1; bool busy=false;
  @override Widget build(BuildContext context){final t=widget.tour;return Scaffold(appBar:AppBar(title:Text(t.title)),body:ListView(padding:const EdgeInsets.all(20),children:[
    Container(height:190,decoration:BoxDecoration(borderRadius:BorderRadius.circular(22),color:Theme.of(context).colorScheme.primaryContainer),child:const Center(child:Icon(Icons.photo_camera_back,size:70))),
    const SizedBox(height:20),Text(t.title,style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.bold)),Text(t.location),
    const SizedBox(height:12),Text(t.description.isEmpty?'Experience an unforgettable Kenyan journey with Global Tours.':t.description),
    const SizedBox(height:20),Text('KES '+t.price.toStringAsFixed(0)+' per traveller',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.bold)),
    const SizedBox(height:20),ListTile(title:const Text('Travel date'),subtitle:Text(DateFormat.yMMMd().format(date)),trailing:const Icon(Icons.calendar_month),onTap:()async{final d=await showDatePicker(context:context,firstDate:DateTime.now(),lastDate:DateTime.now().add(const Duration(days:730)),initialDate:date);if(d!=null)setState(()=>date=d);}}),
    Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('Travellers'),Row(children:[IconButton(onPressed:travellers>1?()=>setState(()=>travellers--):null,icon:const Icon(Icons.remove_circle_outline)),Text(travellers.toString()),IconButton(onPressed:()=>setState(()=>travellers++),icon:const Icon(Icons.add_circle_outline))])]),
    const SizedBox(height:20),FilledButton(onPressed:busy?null:()async{setState(()=>busy=true);final ok=await context.read<AppState>().createBooking(t.id,date,travellers);if(mounted){setState(()=>busy=false);ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(ok?'Booking created successfully':'Booking failed')));if(ok)Navigator.pop(context);}},child:Text(busy?'Creating booking...':'Book now')),
  ]);}
}
