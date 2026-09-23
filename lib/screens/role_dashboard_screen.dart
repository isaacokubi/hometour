import 'package:flutter/material.dart';
import '../core/domain.dart';
import '../services/global_tours_service.dart';

class RoleDashboardScreen extends StatefulWidget{
  const RoleDashboardScreen({super.key,required this.user,required this.onOpen});
  final Map<String,dynamic> user; final void Function(String) onOpen;
  @override State<RoleDashboardScreen> createState()=>_RoleDashboardScreenState();
}
class _RoleDashboardScreenState extends State<RoleDashboardScreen>{
  final service=GlobalToursService(); DashboardStats? stats; Object? error;
  @override void initState(){super.initState();_load();}
  Future<void> _load()async{try{final value=await service.stats('${widget.user['tenantId']??''}');if(mounted)setState(()=>stats=value);}catch(e){if(mounted)setState(()=>error=e);}}
  @override Widget build(BuildContext c){
    if(stats==null&&error==null)return const Center(child:CircularProgressIndicator());
    if(error!=null)return Center(child:Text('Dashboard error: $error'));
    final s=stats!;
    final cards=<({String title,int value,IconData icon,String route})>[
      (title:'Tours',value:s.tours,icon:Icons.map,route:'tours'),(title:'Bookings',value:s.bookings,icon:Icons.book_online,route:'bookings'),(title:'Customers',value:s.customers,icon:Icons.people,route:'users'),(title:'Destinations',value:s.destinations,icon:Icons.place,route:'destinations'),(title:'Suppliers',value:s.suppliers,icon:Icons.business,route:'suppliers'),(title:'Hotels',value:s.hotels,icon:Icons.hotel,route:'hotels')];
    return RefreshIndicator(onRefresh:_load,child:ListView(padding:const EdgeInsets.all(16),children:[
      Text('Welcome, ${widget.user['name']??'Global Tours user'}',style:Theme.of(c).textTheme.headlineSmall),
      Text(roleLabel(roleFrom('${widget.user['role']}'))),const SizedBox(height:16),
      GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),gridDelegate:const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent:220,mainAxisExtent:125,crossAxisSpacing:12,mainAxisSpacing:12),itemCount:cards.length,itemBuilder:(_,i){final x=cards[i];return Card(child:InkWell(onTap:()=>widget.onOpen(x.route),child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(x.icon),const Spacer(),Text(x.title),Text('${x.value}',style:Theme.of(c).textTheme.headlineSmall)]))));}}),
      Card(child:ListTile(title:const Text('Pending bookings'),trailing:Text('${s.pending}'))),
      Card(child:ListTile(title:const Text('Recorded booking value'),trailing:Text('${widget.user['currency']??'KES'} ${s.revenue.toStringAsFixed(2)}')))
    ]));
  }
}
