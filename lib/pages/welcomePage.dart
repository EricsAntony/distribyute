import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:distribution/pages/attendance_page.dart';
import 'package:distribution/pages/route_selection_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'ShopButtonPage.dart';
import 'addShop.dart';
import 'add_collection.dart';
import 'collectionHistory.dart';
import 'connection.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
import 'connectivity.dart';
import 'deviceInfo.dart';
import 'home_page.dart';


class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with WidgetsBindingObserver{
  List<Map<String, dynamic>> routes = [];
  List<Map<String, dynamic>> shopList = []; // List to store shop details
  bool _locationUpdateCalled = false;
  late String? employeeId;
  String? selectedRoute;
  String? currentSelectedRoute;
  final _routeController = StreamController<String>.broadcast();
  List<Map<String, dynamic>> orders = [];
  bool _doubleBackToExitPressedOnce = false;
  late Position? currentLocation;
  bool isLoaded = false;
  late String serialNumber;
  bool alertShown = false;

  @override
  void initState() {
    super.initState();
    _fetchShops();
    WidgetsBinding.instance?.addObserver(this);
    _routeController.stream.listen((String route) {
        setState(() {
          selectedRoute = route;
        });
    });
    getSelectedRoute();
    backgroundLocationProcess();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    List<Color> iconColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.deepPurple,
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ConnectivityStatusWidget(
                onConnectionRestored: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
              ),

              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: 275,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('lib/images/home4.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(top: 25),
                child: Text(
                  selectedRoute != null ? '$selectedRoute' : 'Select route',
                  style: TextStyle(color: Colors.grey[800], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(),
                    _buildButtonRow(
                      context,
                      [
                        _buildButtonCard('Shops', Icons.list, '/view_shop'),
                        _buildButtonCard('Add Shop', Icons.add, '/add_shop_page'),
                        _buildButtonCard('Expense', Icons.account_balance, '/accounts_page'),
                        _buildButtonCard('Collection', Icons.attach_money, ''),

                      ],
                    ),
                    _buildButtonRow(
                      context,
                      [
                        _buildButtonCard('Attendance', Icons.access_time, ''),
                        _buildButtonCard('Return', Icons.reset_tv_outlined, '/return_page'),
                        _buildButtonCard('Orders', Icons.manage_accounts, '/manage_orders'),
                        _buildButtonCard('Route', Icons.location_on, '/route_page'),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 10),
                      child: Text(
                        'Recent Customers',
                        style: TextStyle(color: Colors.grey[800], fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Shop Buttons
                    Center(
                      child: shopList.isEmpty
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(height: 50,),
                              Text(
                                'No recent customers...!',
                                style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey[700],
                                ),
                              ),
                            ],
                          )
                          : SizedBox(
                        height: 320,
                        child: Wrap(
                          spacing: 2,
                          runSpacing: 5,
                          children: List.generate(
                            min(shopList.length, 9),
                                (index) {
                              String shopName = shopList[index]['shopName'];
                              Color iconColor = iconColors[index % iconColors.length];
                              return GestureDetector(
                                onLongPress: () => _showFullProductName(shopList[index]['shopName']),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Map<String, dynamic> selectedShop = shopList[index];
                                    List<Map<String, dynamic>> orders = await _fetchOrders(selectedShop['shopId'].toString());
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ShopButtonPage(
                                          shopDetails: selectedShop,
                                          orders: orders,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: SizedBox(
                                    width: 60,
                                    height: 100,
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.white,
                                            radius: 20,
                                            child: Text(
                                              shopName[0].toUpperCase(),
                                              style: TextStyle(
                                                color: iconColor,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          SizedBox(
                                            width: 80,
                                            child: Center(
                                              child: Text(
                                                shopName.split(' ')[0],
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.grey[800],
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonRow(BuildContext context, List<Widget> buttons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons,
    );
  }

  Widget _buildButtonCard(String text, IconData icon, String route) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 4.4,
      height: 100,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () async {
            if (text == 'Add Shop') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddShopPage(),
                ),
              );
            } else if (text == 'Route') {
              _showRouteSelectionPage(context);
            } else if (text == 'Collection') {
              _showCollectionBottomSheet(context);
            } else if (text == 'Attendance') {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AttendancePage(),
                ),
              );
              // Update selected route after returning from AttendancePage
              SharedPreferences prefs = await SharedPreferences.getInstance();
              setState(() {
                selectedRoute = prefs.getString('$employeeId selectedRoute');
              });
            } else {
              Navigator.of(context).pushNamed(route);
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.blue[800],
                  size: 28,
                ),
                const SizedBox(height: 0),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildCollectionCard(BuildContext context, String text, IconData icon, String imagePath,) {
    return Container(
      width: MediaQuery.of(context).size.width / 2.4,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () {
            if(text == 'Add Collection')
              {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddCollectionPage(),
                  ),
                );
              }
            else if(text == 'Collection History')
              {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CollectionHistoryPage(),
                  ),
                );
              }

          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                  height: 100,
                  width: 100,
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Methods
  //for checking attendance
  Future<void> attendanceCheck() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? fetchDate = prefs.getString('$employeeId attendanceDate');
      bool? isSnackbarShown = prefs.getBool('shown');

      String currentDate = DateTime.now().toString().substring(0, 10);

      if (fetchDate != null && fetchDate != currentDate) {

        if (isSnackbarShown == null || !isSnackbarShown) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Attendance not taken for today! Mark your attendance'),
              backgroundColor: Colors.indigoAccent[700]!,
              duration: const Duration(seconds: 3),
            ),
          );

          prefs.setBool('shown', true);

          Future.delayed(const Duration(minutes: 5), () {
            prefs.remove('shown');
          });
        }
      }
    } catch (e) {
      logger.severe('Error/welPa/attendanceCheck()/: $e');
    }
  }

  //for fetch location periodically
  Future<void> backgroundLocationProcess() async {
    try {
      getSelectedRoute();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? fetchDate = prefs.getString('$employeeId attendanceDate');

      if (!_locationUpdateCalled &&
          fetchDate != null) {
        String? lastUpdateTime = prefs.getString(
            '$employeeId lastLocationUpdateTime').toString();

        if (lastUpdateTime != null) {
          String currentTimeString = DateFormat('HH:mm:ss').format(
              DateTime.now());

          DateTime currentTime = DateFormat('HH:mm:ss').parse(
              currentTimeString);
          DateTime lastUpdateDateTime = DateFormat('HH:mm:ss').parse(
              lastUpdateTime);

          int differenceInMinutes = currentTime
              .difference(lastUpdateDateTime)
              .inMinutes;

          if (differenceInMinutes >= 45 && _locationUpdateCalled == false) {
            _sendLocationToDatabaseInBackground();
            _locationUpdateCalled = true; // Set the flag to true
          }
        } else {
          _sendLocationToDatabaseInBackground();
          _locationUpdateCalled = true; // Set the flag to true
        }
      }
    }
    catch (e)
    {
      logger.severe('Error/welPa/backgroundLocationProcess()/: $e');
    }
  }

  //function to detect app resume to fetch location
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed &&
        !_locationUpdateCalled) {
      attendanceCheck();
      backgroundLocationProcess();
    }
  }

  //Function to fetch shop details
  Future<void> _fetchShops() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      employeeId = prefs.getString('E_id');
      DeviceInfo deviceInfo = DeviceInfo();
      serialNumber = await deviceInfo.fetchDeviceSerialNumber(context);
      final response = await http.get(
        Uri.parse('${Conn.baseUrl}fetchShopsWelcomePage.jsp?devId=$serialNumber'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);

        List<Map<String, dynamic>> fetchedShops = jsonResponse.map((
            dynamic shop) {
          return {
            'shopId': shop['shopId'],
            'shopName': shop['shopName'],
            'shopAddress': shop['shopAddress'],
            'shopPhone': shop['shopPhone'],
            'shopEmail': shop['shopEmail'],
            'shopState': shop['shopState'],
            'shopGst': shop['shopGst'],
          };
        }).toList();
        if (mounted) {
          setState(() {
            shopList = fetchedShops;
          });
        }
      }else if(response.statusCode == 403){
        logger.severe('Error/welPa/_fetchshops()/: Unauthorized access ($serialNumber)');
      }else if(response.statusCode == 400){
        logger.severe('Error/welPa/_fetchshops()/: Invalid input parameters');
      }
      else {
        // Handle API error
        logger.severe('Error/welPa/_fetchshops()/:Failed to fetch shops. Status code: ${response.body.trim()}');
      }
    } catch (error) {
      // Handle other errors
      logger.severe('Error/welPa/_fetchshops()/:Failed to fetch shops. Status code: $error');
    }
  }

  //Function to fetch orders
  Future<List<Map<String, dynamic>>> _fetchOrders(String shopId) async {
    try {
      final response = await http.get(
        Uri.parse('${Conn.baseUrl}getOrders.jsp?shopId=$shopId&devId=$serialNumber'),
      );

      if (response.statusCode == 200) {
        String jsonFormatted = response.body.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
        final List<dynamic> jsonResponse = json.decode(jsonFormatted);
        if(mounted) {
          setState(() {
            orders = List<Map<String, dynamic>>.from(jsonResponse);
          });
        }
      }else if(response.statusCode == 403){
        handleWelcomePageError("Unauthorized access",'Error/welPa/_fetchOrders()/: Unauthorized access ($serialNumber)');
      }else if(response.statusCode == 400){
        handleWelcomePageError("Invalid input",'Error/welPa/_fetchOrders()/: Unsantized input parameters');
      }
      else {
        logger.severe('Error/welPa/_fetchOrders()/: Failed to fetch orders ${response.body.trim()}');
      }
    } catch (error) {
      print(error);
      handleWelcomePageError("Failed to fetch orders.Server error.",'Error/welPa/_fetchOrders()/: $error');
    }
    return orders;
  }

  //bottomsheet for collection(add, view)
  void _showCollectionBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          height: 250, // Set a fixed height
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCollectionCard(context, 'Add Collection', Icons.add, 'lib/images/addCol.webp',),
              _buildCollectionCard(context, 'Collection History', Icons.history, 'lib/images/accounting-book.webp',),
            ],
          ),
        );
      },
    );
  }

  //To navigate route selection page
  Future<void> _showRouteSelectionPage(BuildContext context) async {
    Map<String, dynamic>? selectedRouteData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RouteSelectionPage(),
      ),
    );

    if (selectedRouteData != null) {
      // Extract the route name and route id
      String selectedRouteName = selectedRouteData['routeName'].toString();
      String selectedRouteId = selectedRouteData['routeId'].toString();
      _routeController.add(selectedRouteName);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('$employeeId selectedRoute', selectedRouteName);
      prefs.setString('$employeeId selectedRouteId', selectedRouteId);
    }
  }

  // function to retrieve the selected route from SharedPreferences
  Future<String?> getSelectedRoute() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedRoute = prefs.getString('$employeeId selectedRoute');
    if (selectedRoute == null) {
      if (!alertShown) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          text: 'Please select your route',
        );
        alertShown = true;
      }
    } else {
      return selectedRoute;
    }
    return null;
  }

  Future<bool> _onWillPop() async {
    if (_doubleBackToExitPressedOnce) {
      return true;
    }
    _doubleBackToExitPressedOnce = true;
    Navigator.of(context).popUntil((route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Press back again to exit.'),
        duration: Duration(seconds: 2),
      ),
    );

    Timer(const Duration(seconds: 2), () {
      _doubleBackToExitPressedOnce = false;
    });
    return false;
  }

  //show full name of shop when longpress for recent customers section
  void _showFullProductName(String fullName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(fullName,style: const TextStyle(color: Colors.white),),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.indigoAccent[700],

      ),
    );
  }

  //Save fetched location to database
  Future<void> _sendLocationToDatabaseInBackground() async {
    try {
      Future.microtask(() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        int? attendanceId = prefs.getInt('$employeeId attendanceId');
        String? fetchDate = prefs.getString('$employeeId attendanceDate');

        DateTime attendanceDate = DateTime.parse(fetchDate!);

        DateTime today = DateTime.now();
        String formattedAttendanceDate = DateFormat('yyyy-MM-dd').format(
          attendanceDate,
        );
        String formattedToday = DateFormat('yyyy-MM-dd').format(today);

        if (formattedAttendanceDate == formattedToday) {
          try {
            LocationPermission permission = await Geolocator
                .requestPermission();
            if (permission == LocationPermission.whileInUse ||
                permission == LocationPermission.always) {
              Position currentLocation = await Geolocator.getCurrentPosition();

              String serverUrl = '${Conn.baseUrl}updateLocation.jsp?devId=$serialNumber';
              final Map<String, dynamic> postData = {
                'attendanceId': attendanceId.toString(),
                'latitude': currentLocation.latitude.toString(),
                'longitude': currentLocation.longitude.toString(),
              };

              final response =
              await http.post(Uri.parse(serverUrl), body: postData);

              if (response.body.trim() == 'success') {

                // Store the current time (only time, no date) in SharedPreferences
                String currentTime = DateFormat('HH:mm:ss').format(
                    DateTime.now());
                prefs.setString(
                    '$employeeId lastLocationUpdateTime', currentTime);
              }else if(response.statusCode == 403){
                handleWelcomePageError('Unauthorized access','Error/welPa/_sendLocationToDatabaseInBackground()/: Unauthorized access ($serialNumber)');
              }else if(response.statusCode == 400){
                handleWelcomePageError('Invalid input!','Error/welPa/_sendLocationToDatabaseInBackground()/: Unsanitized input parameters');
              }
              else {
                handleWelcomePageError('Failed to update location. Ensure your location is turned on!','Error/welPa/_sendLocationToDatabaseInBackground()/: Failed to update location: ${response.body.trim()}');
              }
            } else {
              handleWelcomePageError('Failed to fetch location. Ensure your location is turned on and permission is granted!','Error/welPa/_sendLocationToDatabaseInBackground()/: Failed to fetch location: Permission not granted.');
            }
          } catch (e) {
            handleWelcomePageError('Failed to update location.!','Error/welPa/_sendLocationToDatabaseInBackground()/: Failed to update location: $e');
          }
        }
        _locationUpdateCalled = false;
      });
    }
    catch (e)
    {
      handleWelcomePageError('Something went wrong.Restart the app!','Error/welPa/_sendLocationToDatabaseInBackground()/: $e');
    }
  }

  //Error handling
  void handleWelcomePageError(String errorMessage, String log) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...!',
      text: errorMessage,
    );
    logger.severe(log);
  }
}
