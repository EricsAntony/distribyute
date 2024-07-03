import 'dart:async';
import 'dart:convert';
import 'package:distribution/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../main.dart';
import 'connection.dart';
import 'connectivity.dart';
import 'deviceInfo.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime _selectedDate = DateTime.now();
  late String employeeId;
  late String formattedSelectedDate;
  //late LocationData? currentLocation;
  bool isLocationFetched = false;
  late int statusMessage = 0;
  late int attendanceId = -1;
  List<DateTime> leaveDates = [];
  Map<String, dynamic>? attendanceDetails;
  late String serialNumber;
  bool attendanceSuccess = false;
  List<Map<String, dynamic>> _routes = [];
  List<Map<String, dynamic>> _filteredRoutes = [];
  String selectedRouteName = ''; // Variable to hold the selected route name
  String selectedRouteId = ''; // Variable to hold the selected route ID

  Location location = Location();

  @override
  void initState() {
    super.initState();
    _initAttendancePage();
  }

  Future<void> _initAttendancePage() async {
    await _loadEmployeeId();
    await _fetchLeaveDates();
    _fetchRoutes();
    _loadSelectedRoute();
    setState(() {
      isLocationFetched = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLocationFetched) {
      // Show a modern loader animation
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpinKitDoubleBounce(
                color: Colors.indigoAccent[700],
                size: 100.0,
              ),
              const SizedBox(height: 20),
              Text(
                'Fetching up details for you...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0), // Set your preferred height
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.indigoAccent.shade700,
                Colors.indigo,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text(
              'Attendance',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            titleSpacing: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                _selectRoute();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, color: Colors.indigo),
                    const SizedBox(width: 8),
                    Flexible( // Wrap the Text widget with Flexible
                      child: Text(
                        selectedRouteName, // Replace with actual selected route
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.indigo,
                        ),
                        overflow: TextOverflow.visible, // Handle overflow
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.indigo),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            _buildMonthYearPicker(),
            _buildWeekDays(),
            _buildCalendarGrid(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _markAttendance();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Mark Attendance',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            if (attendanceDetails != null)
              _buildAttendanceDetails(), // Display attendance details
          ],
        ),
      ),
    );
  }


  Widget _buildAttendanceDetails() {
    String formattedDate = DateFormat('dd-MM-yyyy').format(_selectedDate);
    String rawAttendanceTime = attendanceDetails!['AttendanceTime'] ?? '';
    String formattedAttendanceTime = DateFormat('dd-MM-yyyy HH:mm:ss').format(
        DateTime.parse(rawAttendanceTime));
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Route', attendanceDetails!['Route'] ?? 'N/A'),
            _buildDetailItem('Attendance Time', formattedAttendanceTime),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:  ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.indigoAccent[700],
              ),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthYearPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_left),
          onPressed: () {
            if (mounted) {
              setState(() {
                _selectedDate =
                    DateTime(_selectedDate.year, _selectedDate.month - 1);
              });
            }
          },
        ),
        GestureDetector(
          onTap: () {
            _selectDate(context);
          },
          child: Text(
            '${_getMonthName(_selectedDate.month)} ${_selectedDate
                .day}, ${_selectedDate.year}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_right),
          onPressed: () {
            if (mounted) {
              setState(() {
                _selectedDate =
                    DateTime(_selectedDate.year, _selectedDate.month + 1);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildWeekDays() {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      children: weekDays
          .map(
            (day) =>
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                child: Text(
                  day,
                  style: TextStyle(
                    color: Colors.indigoAccent[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    // Calculate the number of days in the selected month
    final daysInMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    // Calculate the day of the week for the first day of the month
    final firstDayOfWeek =
        DateTime(_selectedDate.year, _selectedDate.month, 1).weekday;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: daysInMonth + firstDayOfWeek - 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index < firstDayOfWeek - 1) {
          // Empty space before the first day of the month
          return Container();
        }

        final day = index - firstDayOfWeek + 2;
        final currentDate =
        DateTime(_selectedDate.year, _selectedDate.month, day);
        bool isOnLeave = leaveDates.contains(currentDate);

        return GestureDetector(
          onTap: () {
            if (mounted) {
              setState(() {
                _selectedDate = currentDate;
                _updateFormattedDate(); // Update formattedSelectedDate
                _fetchAttendanceDetails(); // Fetch attendance details on date tap
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: _selectedDate.day == day
                  ? Colors.indigoAccent[200]
                  : null,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: isOnLeave
                      ? Colors.red
                      : (_selectedDate.day == day
                      ? Colors.white
                      : null),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  //Methods
  //To get months

  String _getMonthName(int month) {
    final monthNames = [
      '', // No month with index 0
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return monthNames[month];
  }

  //fetching routes
  Future<void> _fetchRoutes() async {
    try {
      DeviceInfo deviceInfo = DeviceInfo();
      String serialNumber = await deviceInfo.fetchDeviceSerialNumber(context);
      final response = await http.get(Uri.parse('${Conn.baseUrl}viewRoutes.jsp?devId=$serialNumber'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          _routes = List<Map<String, dynamic>>.from(jsonResponse);
          _filteredRoutes = List<Map<String, dynamic>>.from(_routes);
        });
      }else if(response.statusCode == 403){
        handleAttendancePageError('Unauthorized access!', 'Error/attendancePage/_fetchRoutes()/: unauthorized access ($serialNumber)');
      }else if(response.statusCode == 400){
        handleAttendancePageError('Invalid inputs!', 'Error/attendancePage/_fetchRoutes()/: Invalid input parameters');
      }
      else {
        handleAttendancePageError('Failed to fetch routes. Check your internet connectivity!', 'Error/attendancePage/_fetchRoutes()/: ${response.body}');
      }
    } catch (error) {
      handleAttendancePageError('Something went wrong. Please restart the app.', 'Error/attendancePage/_fetchRoutes()/: ${error.toString()}');
    }
  }

  //load the selected route initially
  Future<void> _loadSelectedRoute() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedRouteName = prefs.getString('$employeeId selectedRoute') ?? 'No route selected';
      selectedRouteId = prefs.getString('$employeeId selectedRouteId') ?? '';
    });
  }

  //update selected route
  Future<void> _updateSelectedRoute(String routeName, String routeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('$employeeId selectedRoute', routeName);
    await prefs.setString('$employeeId selectedRouteId', routeId);
    setState(() {
      selectedRouteName = routeName;
      selectedRouteId = routeId;
    });
  }

  //select route dialog
  Future<void> _selectRoute() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Route'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _routes.map((route) {
                return ListTile(
                  title: Text(route['routeName']),
                  onTap: () {
                    _updateSelectedRoute(route['routeName'], route['routeId']);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  //Fetching leave dates

  Future<void> _fetchLeaveDates() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? employeeId = prefs.getString('E_id');
      DeviceInfo deviceInfo = DeviceInfo();
      serialNumber = await deviceInfo.fetchDeviceSerialNumber(context);
      final response = await http.get(Uri.parse(
          '${Conn.baseUrl}attendanceDates.jsp?employeeId=$employeeId&devId=$serialNumber'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          leaveDates = List<DateTime>.from(jsonResponse.map((dynamic date) {
            return DateTime.parse(date);
          }));
        });
      }else if(response.statusCode == 403){
        logger.severe(
            'Error/attendancePa/_fetchLeaveDates()/: Unauthorized access ($serialNumber)');
      }
      else if(response.statusCode == 400){
        logger.severe(
            'Error/attendancePa/_fetchLeaveDates()/: Unsanitized input parameter');
      }
      else {
        logger.severe(
            'Error/attendancePa/_fetchLeaveDates()/: failed to fetch leave dates: ${response
                .body}');
      }
    } catch (error) {
      handleAttendancePageError('Something went wrong. Check your internet connectivity and try again','Error/attendancePa/_fetchLeaveDates()/: $error');
    }
  }

  Future<void> _loadEmployeeId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        employeeId = prefs.getString('E_id') ?? '';
      });
    }
  }

  //select date

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      // Extract only the date part from picked
      if (mounted) {
        setState(() {
          _selectedDate = DateTime(picked.year, picked.month, picked.day);
          _fetchAttendanceDetails();
        });
      }
    }
  }

  //Fetching attendance details

  Future<void> _fetchAttendanceDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? employeeId = prefs.getString('E_id');

      final response = await http.get(Uri.parse(
          '${Conn
              .baseUrl}attendanceDetails.jsp?employeeId=$employeeId&date=$formattedSelectedDate&devId=$serialNumber'));

      if (response.statusCode == 200) {
        if (json.decode(response.body) != null &&
            json.decode(response.body).isNotEmpty) {
          setState(() {
            attendanceDetails = json.decode(response.body);
          });
        } else {
          setState(() {
            attendanceDetails = null;
          });
        }
      }else if(response.statusCode == 403){
        logger.severe(
            'Error/attendancePa/ _fetchAttendanceDetails()/: unauthorized access ($serialNumber)');
      }
      else {
        logger.severe(
            'Error/attendancePa/ _fetchAttendanceDetails()/: ${response.body}');
      }
    } catch (error) {
      logger.severe('Error/attendancePa/ _fetchAttendanceDetails()/:$error');
    }
  }

  //Format date

  void _updateFormattedDate() {
    formattedSelectedDate =
        DateFormat('yyyy-MM-dd').format(_selectedDate); // Customize the format
  }

  //checking location enabled or not and prompting the user to enable it.
  Future<void> _initLocationTracking() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    try {
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          // Navigate to the shop details page, passing the shop details and orders
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => const HomePage()
            ),
          );
          return;
        }
      }
      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          _showLocationSettingsDialog();
          return;
        }
      }
    } catch (e) {
      logger.severe('Error/attendancePa/_initLocationTracking()/: $e');
    }
  }

  //showing Location setting dialog

  Future<void> _showLocationSettingsDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Access Required'),
          content:
          const Text('Please enable location services to mark attendance.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  //Marking the attendance
  Future<void> _markAttendance() async {
    try {
      attendanceSuccess = false;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? routeId = prefs.getString('$employeeId selectedRouteId');
      if (routeId == null) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'Please select your route in the homePage!',
        );
        return;
      }

      _updateFormattedDate();
      DateTime selectedDate =
      DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

      final String DateToUpload =
      DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
      final String today = DateFormat('yyy-MM-dd').format(DateTime.now());
      if (formattedSelectedDate == today) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Material(
              type: MaterialType.transparency,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Marking your attendance. Please wait...',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        await _initLocationTracking();
        LocationData? currentLocation = await location.getLocation();
        // Hide loading indicator
        Navigator.pop(context);
        if (mounted) {
          String serverUrl =
              '${Conn.baseUrl}markAttendance.jsp?devId=$serialNumber';
          final Map<String, dynamic> data = {
            'employeeId': employeeId,
            'attendanceDate': DateFormat('yyyy-MM-dd').format(selectedDate),
            'attendanceTime': DateToUpload,
            'latitude': currentLocation!.latitude.toString(),
            'longitude': currentLocation!.longitude.toString(),
            'routeId': routeId,
          };

          final response = await http.post(
            Uri.parse(serverUrl),
            body: data,
          );

          List<String> responseParts = response.body.trim().split(';');
          if (responseParts.length == 2) {
            statusMessage = int.tryParse(responseParts[0]) ?? 0;
            attendanceId = int.tryParse(responseParts[1]) ?? -1;
          } else {
            statusMessage = int.tryParse(response.body.trim()) ?? 0;
          }

          if (statusMessage == 1) {
            await prefs.setInt('$employeeId attendanceId', attendanceId);
            await prefs.setString(
                '$employeeId attendanceDate',
                DateFormat('yyyy-MM-dd')
                    .format(DateTime.now()));
            await prefs.setString(
                '$employeeId lastLocationUpdateTime',
                DateFormat('HH:mm:ss')
                    .format(DateTime.now()));
            attendanceSuccess = true;
            QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              text: 'Attendance marked!',
            );
          } else if (statusMessage == 2) {
            attendanceSuccess = true;
            QuickAlert.show(
              context: context,
              type: QuickAlertType.info,
              text: 'Attendance already marked!',
            );
          } else if (response.statusCode == 403) {
            attendanceSuccess = true;
            handleAttendancePageError(
                'Unauthorized access!',
                'Error/attendnacePa/markAttendance()/: unauthorized access $serialNumber');
          } else if (response.statusCode == 400) {
            attendanceSuccess = true;
            handleAttendancePageError(
                'Failed to add attendance!', 'unsanitized input parameters');
          } else {
            attendanceSuccess = true;
            handleAttendancePageError(
                'Failed to add attendance! ${response.body.trim()}',
                'Error/attendnacePa/markAttendance()/: ${response.body.trim()}');
          }
        }
      } else {
        // Notify the user to select the current date
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'Invalid date. You can only mark attendance for the current date!',
        );
      }
    } catch (e) {
      handleAttendancePageError(
          'Something went wrong!', 'Error/attendnacePa/markAttendance()/: $e');
    }
  }

  //Error handling

  void handleAttendancePageError(String errorMessage, String log) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...!',
      text: errorMessage,
    );
    logger.severe(log);
  }
}
