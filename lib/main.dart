import 'dart:async';
import 'dart:io';
import 'package:distribution/pages/deviceInfo.dart';
import 'package:distribution/pages/sales_return.dart';
import 'package:http/http.dart' as http;
import 'package:distribution/pages/attendance_page.dart';
import 'package:distribution/pages/connection.dart';
import 'package:distribution/pages/expenseHistory.dart';
import 'package:distribution/pages/home_page.dart';
import 'package:distribution/pages/login_page.dart';
import 'package:distribution/pages/orders_Page.dart';
import 'package:distribution/pages/requestAccess.dart';
import 'package:distribution/pages/view_shops.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'models/cart.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logging/logging.dart';

final Logger logger = Logger('MyApp');
bool hasInternet = true;

Future<void> main() async {
  runZonedGuarded(() async {
    try {
      hasInternet = true;
      WidgetsFlutterBinding.ensureInitialized();
      await checkAndRequestLocationPermission();
      await initializeLogging();

      FlutterError.onError = (FlutterErrorDetails details) {
        Logger.root.severe('Unhandled Flutter error: ${details.exception}', details.exception, details.stack);
      };

      runApp(const MyApp());
    } catch (e) {
      runApp(MyErrorApp(e));
    }
  }, (Object error, StackTrace stackTrace) {
    print('Caught error: $error');
    print(stackTrace);
  });
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Cart(),
      builder: (context, child) => MaterialApp(
        theme: ThemeData(fontFamily: 'OpenSans'),
        debugShowCheckedModeBanner: false,
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const LoginPage(),
          );
        },
        home: const SplashScreen(),
        initialRoute: "/loading",
        routes: {
          "/loading": (context) => const SplashScreen(),
          "/login": (context) => const LoginPage(),
          "/home": (context) => const HomePage(),
          '/view_shop': (context) => const ViewShop(),
          '/attendance_page': (context) => const AttendancePage(),
          "/manage_orders": (context) => const OrdersPage(),
          '/accounts_page': (context) => const ExpenseHistoryPage(),
          '/request_access': (context) => const RequestAccessPage(),
          '/return_page': (context) => const AddSalesReturnPage(), // Add route for RequestAccessPage

        },
      ),
    );
  }
}


class MyErrorApp extends StatelessWidget {
  final Object error;

  const MyErrorApp(this.error, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Oops'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load. Please try again'),
              ElevatedButton(
                onPressed: () {
                  main();
                },
                child: const Text('Reload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer _timer;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  @override
  void dispose() {
    _timer.cancel();
    _isVisible = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/images/logo.png',
                    width: 200,
                    height: 200,
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Distribyute',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Methods
  //decide what to do after splash screen
  Future<void> _initApp() async {
    _timer = Timer(const Duration(seconds: 2), () async {
      if (_isVisible) {
        bool isDeviceRegistered = await checkDeviceRegistration(context);
        bool isUserLoggedIn = await initializeApp();
        if(!hasInternet){
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
          );
        }
        else if (!isDeviceRegistered) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const RequestAccessPage()),
                (Route<dynamic> route) => false,
          );
        } else {
          if (isUserLoggedIn) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
                  (Route<dynamic> route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
            );
          }
        }
      }
    });
  }
}

//Methods
//for checking location permission
Future<bool> checkAndRequestLocationPermission() async {
  try {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        logger.severe('Error/checkAndRequestLocationPermission()/: Location permission denied');
        return false;
      }
    }
    return true;
  } catch (e) {
    logger.severe('Error/checkAndRequestLocationPermission()/: checking/requesting location permissions: $e');
    return false;
  }
}

//gets internet connectivity
Future<bool> checkInternetConnectivity() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi;
}

//to check internet connectivity
Future<bool> initializeApp() async {
  try {
    bool hasInternetConnectivity = await checkInternetConnectivity();

    if (!hasInternetConnectivity) {
      hasInternet = false;
      logger.severe('Error/initializeApp()/: No internet connectivity');
      return false;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    return isLoggedIn;
  } catch (e) {
    logger.severe('Error/initializeApp()/: $e');
    return false;
  }
}

//to check whether the device is registered or not
Future<bool> checkDeviceRegistration(context) async {
  try {
    DeviceInfo deviceInfo = DeviceInfo();
    String serialNumber = await deviceInfo.fetchDeviceSerialNumber(context);

    String url = "${Conn.baseUrl}authorized.jsp";
    var response = await http.post(
      Uri.parse(url),
      body: {
        'dev_num': serialNumber,
      },
    );

    if (response.body.trim() == 'success') {
      return true;
    }
    else
    {
      return false;
    }

  } catch (e) {
    logger.severe('ERROR:/main/checkDeviceRegistration()/: $e');
  }
  return false;
}

//to log the errors into a file
Future<void> initializeLogging() async {
  final Directory? externalDir = await getExternalStorageDirectory();
  final File logFile = File('${externalDir?.path}/app_log.txt');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? employeeName = prefs.getString('E_name');

  employeeName ??= 'Not known';

  Logger.root.clearListeners();
  Logger.root.onRecord.listen((record) {
    logFile.writeAsStringSync('--------------------------------------------------------------------------------------------------------\n', mode: FileMode.append);

    logFile.writeAsStringSync('${record.level.name}: \t${record.time}: \t$employeeName: \n${record.message}\n', mode: FileMode.append);

    logFile.writeAsStringSync('--------------------------------------------------------------------------------------------------------\n', mode: FileMode.append);
    logFile.writeAsStringSync('\n\n\n', mode: FileMode.append);
  });

  Logger.root.onRecord.listen((record) {
    if (record.error != null) {
      Logger.root.severe('Unhandled Dart error: ${record.error}', record.error, record.stackTrace);
    }
  });
}