import 'package:flutter/material.dart';
import '../services/global_tours_service.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key,required this.user});
  final Map<String,dynamic> user;
  @override Widget build(BuildContext c){
    return FutureBuilder<List<Map<String,dynamic>>>(
      future:GlobalToursService().rawList('payments','${user['tenantId']??''}'),
      builder:(c,s){
        if(s.connectionState!=ConnectionState.done)return const Center(child:CircularProgressIndicator());
        if(s.hasError)return Center(child:Text('Finance error: ${s.error}'));
        final rows=s.data??<Map<String,dynamic>>[];
        final total=rows.fold<double>(0,(sum,x){final v=x['amount'];return sum+(v is num?v.toDouble():double.tryParse('$v')??0);});
        return ListView(padding:const EdgeInsets.all(16),children:[
          Text('Finance & Payments',style:Theme.of(c).textTheme.headlineSmall),
          Card(child:ListTile(title:const Text('Recorded payments'),trailing:Text('${rows.length}'))),
          Card(child:ListTile(title:const Text('Payment value'),trailing:Text('${user['currency']??'KES'} ${total.toStringAsFixed(2)}'))),
          ...rows.map((x)=>Card(child:ListTile(title:Text('${x['reference']??x['provider']??'Payment'}'),subtitle:Text('${x['status']??'unknown'} • ${x['method']??x['paymentMethod']??''}'),trailing:Text('${x['amount']??0}'))))
        ]);
      });
  }
}
