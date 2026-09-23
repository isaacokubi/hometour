import 'package:flutter/material.dart';
import '../services/global_tours_service.dart';

class SuperAdminScreen extends StatelessWidget{
  const SuperAdminScreen({super.key,required this.user});
  final Map<String,dynamic> user;
  @override Widget build(BuildContext c){
    return FutureBuilder<List<Map<String,dynamic>>>(
      future:GlobalToursService().rawList('tenants',''),
      builder:(c,s){
        if(s.connectionState!=ConnectionState.done)return const Center(child:CircularProgressIndicator());
        if(s.hasError)return Center(child:Text('Platform error: ${s.error}'));
        final rows=s.data??<Map<String,dynamic>>[];
        return ListView(padding:const EdgeInsets.all(16),children:[
          Text('Global Tours Platform',style:Theme.of(c).textTheme.headlineSmall),
          const SizedBox(height:12),const Text('Tenant administration and platform governance'),
          ...rows.map((x)=>Card(child:ListTile(title:Text('${x['name']??x['id']}'),subtitle:Text('${x['slug']??''}'),trailing:Icon(x['active']==false?Icons.pause_circle:Icons.check_circle))))
        ]);
      });
  }
}
