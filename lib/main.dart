import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenditure_app/pages/login_page.dart';
import 'package:expenditure_app/services/auth_services.dart' as auth;
import 'package:expenditure_app/services/database_service.dart';
import 'package:expenditure_app/pages/home_page.dart';
import 'package:expenditure_app/pages/loan.dart';
import 'package:expenditure_app/pages/borrow_screen.dart';
import 'package:expenditure_app/model/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final databaseService = DatabaseService();
  await databaseService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserModel()),
        ChangeNotifierProxyProvider<UserModel, auth.AuthService>(
          create: (context) => auth.AuthService(context.read<UserModel>()),
          update: (context, userModel, previousAuthService) =>
              previousAuthService ?? auth.AuthService(userModel),
        ),
        Provider<DatabaseService>.value(value: databaseService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expenditure Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Consumer<auth.AuthService>(
        builder: (context, authService, _) {
          return authService.isAuthenticated
              ? const MainScreen()
              : const LoginPage();
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    LoanScreen(),
    BorrowScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money),
            label: 'Loan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Borrow',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
