import 'package:flutter/material.dart';
import '../core/domain.dart';
import '../services/global_tours_service.dart';

class HospitalityScreen extends StatelessWidget {
  const HospitalityScreen({super.key,required this.user});
  final Map<String,dynamic> user;
  @override Widget build(BuildContext c){
    final tenant='${user['tenantId']??''}';
    return FutureBuilder<List<List<CatalogRecord>>>(
      future:Future.wait([GlobalToursService().list('hotels',tenant),GlobalToursService().list('accommodations',tenant)]),
      builder:(c,s){
        if(s.connectionState!=ConnectionState.done)return const Center(child:CircularProgressIndicator());
        if(s.hasError)return Center(child:Text('Hospitality error: ${s.error}'));
        final all=(s.data??<List<CatalogRecord>>[]).expand((x)=>x).toList();
        return ListView(padding:const EdgeInsets.all(16),children:[Text('Hospitality & Accommodation',style:Theme.of(c).textTheme.headlineSmall),...all.map((x)=>Card(child:ListTile(leading:const Icon(Icons.hotel),title:Text(x.name),subtitle:Text(x.description.isEmpty?x.status:x.description))))]);
      });
  }
}
