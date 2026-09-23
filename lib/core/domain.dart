import 'package:cloud_firestore/cloud_firestore.dart';

enum AppRole { customer, agent, guide, driver, manager, admin, superAdmin }
AppRole roleFrom(String? value){switch((value??'').toLowerCase().replaceAll('-','_')){case'agent':return AppRole.agent;case'guide':return AppRole.guide;case'driver':return AppRole.driver;case'manager':case'tour_manager':return AppRole.manager;case'admin':return AppRole.admin;case'superadmin':case'super_admin':case'platform_owner':return AppRole.superAdmin;default:return AppRole.customer;}}
String roleLabel(AppRole r){switch(r){case AppRole.customer:return'Customer';case AppRole.agent:return'Agent';case AppRole.guide:return'Guide';case AppRole.driver:return'Driver';case AppRole.manager:return'Tour Manager';case AppRole.admin:return'Administrator';case AppRole.superAdmin:return'Super Administrator';}}
DateTime? dateValue(dynamic v){if(v is Timestamp)return v.toDate();if(v is DateTime)return v;return DateTime.tryParse(v?.toString()??'');}
double numberValue(dynamic v)=>v is num?v.toDouble():double.tryParse(v?.toString()??'')??0;
class CatalogRecord{CatalogRecord({required this.id,required this.collection,required this.data});final String id,collection;final Map<String,dynamic> data;String get name=>'${data['name']??data['title']??data['destinationName']??id}';String get status=>'${data['status']??'active'}';double get price=>numberValue(data['price']??data['sellingPrice']??data['unitPrice']);String get description=>'${data['description']??data['summary']??''}';}
class DashboardStats{const DashboardStats({this.tours=0,this.bookings=0,this.customers=0,this.revenue=0,this.pending=0,this.suppliers=0,this.hotels=0,this.destinations=0});final int tours,bookings,customers,pending,suppliers,hotels,destinations;final double revenue;}
