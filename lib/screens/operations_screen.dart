import 'package:flutter/material.dart';
import '../services/global_tours_service.dart';

class OperationsScreen extends StatefulWidget {
  const OperationsScreen({super.key,required this.user});
  final Map<String,dynamic> user;
  @override State<OperationsScreen> createState()=>_OperationsScreenState();
}
class _OperationsScreenState extends State<OperationsScreen>{
  final service=GlobalToursService(); List<Map<String,dynamic>> bookings=[]; bool loading=true;
  @override void initState(){super.initState();load();}
  Future<void> load()async{try{bookings=await service.rawList('bookings','${widget.user['tenantId']??''}');}finally{if(mounted)setState(()=>loading=false);}}
  Future<void> status(String id,String value)async{await service.setBookingStatus(id,'${widget.user['tenantId']}',value);setState(()=>loading=true);await load();}
  @override Widget build(BuildContext c){
    if(loading)return const Center(child:CircularProgressIndicator());
    return Scaffold(appBar:AppBar(title:const Text('Travel Operations')),body:ListView.builder(itemCount:bookings.length,itemBuilder:(c,i){
      final x=bookings[i];
      return Card(margin:const EdgeInsets.all(8),child:ListTile(title:Text('${x['tourName']??x['tourId']??'Booking'}'),subtitle:Text('Guests: ${x['numberOfGuests']??0} • ${x['status']??'pending'}'),trailing:PopupMenuButton<String>(onSelected:(v)=>status('${x['id']}',v),itemBuilder:(_)=>const[PopupMenuItem(value:'pending',child:Text('Pending')),PopupMenuItem(value:'confirmed',child:Text('Confirm')),PopupMenuItem(value:'cancelled',child:Text('Cancel')),PopupMenuItem(value:'completed',child:Text('Complete'))])));
    }));
  }
}
