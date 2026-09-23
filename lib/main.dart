import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart' as app_firebase;
import 'state/app_state.dart';
import 'core/domain.dart';
import 'screens/bookings_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/tours_screen.dart';
import 'screens/role_workspace_screen.dart';

Future<void> main() async {
 WidgetsFlutterBinding.ensureInitialized();
 try {
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if(kIsWeb){FirebaseFirestore.instance.settings=const Settings(webExperimentalForceLongPolling:true);}
 } catch(error){runApp(FirebaseConfigurationErrorApp(error:error));return;}
 runApp(const HomeTourApp());
}
class FirebaseConfigurationErrorApp extends StatelessWidget{const FirebaseConfigurationErrorApp({super.key,required this.error});final Object error;@override Widget build(BuildContext c)=>MaterialApp(title:'Global Tours',debugShowCheckedModeBanner:false,home:Scaffold(body:Center(child:Padding(padding:const EdgeInsets.all(24),child:Text('Firebase configuration is required. Create .env from .env.example and restart.\n\n$error',textAlign:TextAlign.center)))));}
class HomeTourApp extends StatelessWidget{const HomeTourApp({super.key,this.autoBootstrap=true,this.firebaseService});final bool autoBootstrap;final app_firebase.FirebaseService? firebaseService;@override Widget build(BuildContext c)=>ChangeNotifierProvider(create:(_)=>AppState(firebaseService??app_firebase.FirebaseService()),child:MaterialApp(title:'Global Tours',debugShowCheckedModeBanner:false,theme:ThemeData(useMaterial3:true,colorSchemeSeed:const Color(0xFF15803D)),home:AppShell(autoBootstrap:autoBootstrap)));}
class AppShell extends StatefulWidget{const AppShell({super.key,this.autoBootstrap=true});final bool autoBootstrap;@override State<AppShell> createState()=>_AppShellState();}
class _AppShellState extends State<AppShell>{int index=0;final pages=const[HomeScreen(),ToursScreen(),BookingsScreen(),ProfileScreen()];@override void initState(){super.initState();if(widget.autoBootstrap){WidgetsBinding.instance.addPostFrameCallback((_)=>context.read<AppState>().bootstrap());}}@override Widget build(BuildContext c){final s=context.watch<AppState>();if(s.loading)return const Scaffold(body:Center(child:CircularProgressIndicator()));if(!s.authenticated)return LoginScreen(onLoggedIn:()=>setState((){}));final role=roleFrom('${s.user?['role']}');if(role!=AppRole.customer)return RoleWorkspaceScreen(user:s.user!);return Scaffold(body:IndexedStack(index:index,children:pages),bottomNavigationBar:NavigationBar(selectedIndex:index,onDestinationSelected:(v)=>setState(()=>index=v),destinations:const[NavigationDestination(icon:Icon(Icons.explore_outlined),selectedIcon:Icon(Icons.explore),label:'Explore'),NavigationDestination(icon:Icon(Icons.map_outlined),selectedIcon:Icon(Icons.map),label:'Tours'),NavigationDestination(icon:Icon(Icons.book_outlined),selectedIcon:Icon(Icons.book),label:'Bookings'),NavigationDestination(icon:Icon(Icons.person_outline),selectedIcon:Icon(Icons.person),label:'Profile')]));}}
