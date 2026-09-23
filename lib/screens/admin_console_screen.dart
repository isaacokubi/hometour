import 'package:flutter/material.dart';
import '../core/domain.dart';
import '../services/global_tours_service.dart';

class AdminConsoleScreen extends StatefulWidget {
  const AdminConsoleScreen({super.key, required this.user, required this.collection, required this.title});
  final Map<String, dynamic> user;
  final String collection;
  final String title;
  @override State<AdminConsoleScreen> createState()=>_AdminConsoleScreenState();
}
class _AdminConsoleScreenState extends State<AdminConsoleScreen>{
  final service=GlobalToursService(); List<CatalogRecord> rows=[]; bool loading=true; String? error;
  @override void initState(){super.initState();_load();}
  Future<void> _load() async {setState(()=>loading=true);try{rows=await service.list(widget.collection,'${widget.user['tenantId']??''}');error=null;}catch(e){error='$e';}if(mounted)setState(()=>loading=false);}
  Future<void> _add() async {
    final name=TextEditingController(), desc=TextEditingController();
    final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:Text('Create ${widget.title}'),content:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:name,decoration:const InputDecoration(labelText:'Name / title')),TextField(controller:desc,decoration:const InputDecoration(labelText:'Description'))]),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Save'))]));
    if(ok==true&&name.text.trim().isNotEmpty){await service.create(widget.collection,'${widget.user['tenantId']}',{'name':name.text.trim(),'description':desc.text.trim(),'status':'active'});await _load();}
  }
  @override Widget build(BuildContext c){
    Widget body;
    if(loading){body=const Center(child:CircularProgressIndicator());}
    else if(error!=null){body=Center(child:Text(error!));}
    else {body=RefreshIndicator(onRefresh:_load,child:ListView.separated(padding:const EdgeInsets.all(12),itemCount:rows.length,separatorBuilder:(_,__)=>const SizedBox(height:8),itemBuilder:(c,i){final r=rows[i];return Card(child:ListTile(title:Text(r.name),subtitle:Text(r.description.isEmpty?r.status:r.description),trailing:Text(r.price>0?'${widget.user['currency']??'KES'} ${r.price.toStringAsFixed(0)}':r.status)));}}));}
    return Scaffold(appBar:AppBar(title:Text(widget.title),actions:[IconButton(onPressed:_add,icon:const Icon(Icons.add))]),body:body);
  }
}
