import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../main.dart';
import 'connection.dart';
import 'deviceInfo.dart';

class RouteSelectionPage extends StatefulWidget {
  const RouteSelectionPage({Key? key}) : super(key: key);

  @override
  _RouteSelectionPageState createState() => _RouteSelectionPageState();
}

class _RouteSelectionPageState extends State<RouteSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _routes = [];
  List<Map<String, dynamic>> _filteredRoutes = [];

  final List<Color> _iconColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _fetchRoutes();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.indigoAccent[700]!, Colors.indigo],
              ),
            ),
          ),
          title: const Text(
            'Select your route',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 400,
              height: 55,
              child: TextField(
                controller: _searchController,
                onChanged: _filterRoutes,
                decoration: InputDecoration(
                  hintText: 'Search by place...',
                  filled: true,
                  fillColor: Colors.grey[50],
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.indigoAccent[700]!),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: const Icon(Icons.search),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredRoutes.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> route = _filteredRoutes[index];
                Color iconColor = _iconColors[index % _iconColors.length];

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: iconColor,
                    ),
                    title: Text(route['routeName'].toString()),
                    onTap: () {
                      Navigator.pop(context, route);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //Methods
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
        _handleError('Unauthorized access!', 'Error/routeselectionPage/_fetchRoutes()/: unauthorized access ($serialNumber)');
      }else if(response.statusCode == 400){
        _handleError('Invalid inputs!', 'Error/routeselectionPage/_fetchRoutes()/: Invalid input parameters');
      }
      else {
        _handleError('Failed to fetch routes. Check your internet connectivity!', 'Error/routeselectionPage/_fetchRoutes()/: ${response.body}');
      }
    } catch (error) {
      _handleError('Something went wrong. Please restart the app.', 'Error/routeselectionPage/_fetchRoutes()/: ${error.toString()}');
    }
  }

  //searchbar function
  void _filterRoutes(String query) {
    setState(() {
      _filteredRoutes = _routes
          .where((route) => route['routeName'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  //Error handling
  void _handleError(String errorMessage, String log) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...!',
      text: errorMessage,
    );
    logger.severe(log);
  }

}
