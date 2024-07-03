import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../main.dart';
import 'connection.dart';
import 'connectivity.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'deviceInfo.dart';

class CollectionHistoryPage extends StatefulWidget {
  const CollectionHistoryPage({super.key});

  @override
  _CollectionHistoryPageState createState() => _CollectionHistoryPageState();
}

class _CollectionHistoryPageState extends State<CollectionHistoryPage> {
  List<Map<String, String?>> collectionHistory = [];
  List<Map<String, String?>> displayedCollectionHistory = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    ConnectivityStatusWidget(
      onConnectionRestored: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CollectionHistoryPage()),
        );
      },
    );
    return Scaffold(
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text('Collection', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
          centerTitle: true,
        ),
      ),
      body: collectionHistory.isNotEmpty ? Column(
        children: [
          ConnectivityStatusWidget(
            onConnectionRestored: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CollectionHistoryPage()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 400,
              height: 55,
              child: TextField(
                controller: searchController,
                onChanged: (query) => search(query),
                decoration: InputDecoration(
                  hintText: 'Search by store name, date, amount...',
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
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
              child: isLoading
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitDoubleBounce(
                      color: Colors.indigoAccent[700],
                      size: 100.0,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Fetching collection history...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: displayedCollectionHistory.length,
                itemBuilder: (context, index) {
                  return CollectionHistoryTile(data: displayedCollectionHistory[index]);
                },
              ),
            ),
          ),
        ],
      ) : Center(
        child: Text(
          'No collection history found...!',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  //Methods
  //fetching collection data

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? employeeId = prefs.getString('E_id');
      DeviceInfo deviceInfo = DeviceInfo();
      String serialNumber = await deviceInfo.fetchDeviceSerialNumber(context);
      final response = await http.get(
          Uri.parse('${Conn.baseUrl}collectionHistory.jsp?employeeId=$employeeId&devId=$serialNumber'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);

        setState(() {
          collectionHistory = List<Map<String, String?>>.from(
            jsonResponse.map((dynamic data) {
              return {
                'shopName': data['shopName'].toString(),
                'amount': data['C_amt'].toString(),
                'date': _formatDate(data['C_date'].toString()),
                'remarks': data['C_remarks'].toString(),
                'mode': data['C_mode'].toString(),
              };
            }),
          );

          // Initialize displayedCollectionHistory with the original data
          displayedCollectionHistory = List<Map<String, String>>.from(collectionHistory);
        });
      }else if(response.statusCode == 403){
        handleCollectioHistoryPageError('Unauthorized access','Error/collectionHisPage/fetchData()/: Unauthorized access: $serialNumber');
      }else if(response.statusCode == 400){
        handleCollectioHistoryPageError('Failed to fetch your collection','Error/collectionHisPage/fetchData()/:Unsantized input parameters');
      }
      else {
        handleCollectioHistoryPageError('Failed to fetch your collection. Check your internet connectivity and try again','Error/collectionHisPage/fetchData()/: failed to fetch collection history: ${response.body}');
      }
    } catch (error) {
      handleCollectioHistoryPageError( 'Something went wrong. Check your internet connectivity and try again','Error/collectionHisPage/fetchData()/: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to format the date

  String _formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  //function for searchbar

  void search(String query) {
    setState(() {
      // Filter the displayed data based on the search query
      displayedCollectionHistory = collectionHistory
          .where((data) =>
      data['shopName']!.toLowerCase().contains(query.toLowerCase()) ||
          data['amount']!.contains(query) ||
          data['date']!.toLowerCase().contains(query.toLowerCase()) ||
          data['remarks']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  //Error handling

  void handleCollectioHistoryPageError(String errorMessage, String log) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...!',
      text: errorMessage,
    );
    logger.severe(log);
  }
}


class CollectionHistoryTile extends StatelessWidget {
  final Map<String, String?> data;
  final Random random = Random();

  CollectionHistoryTile({super.key, required this.data});

  Color _randomColor() {
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color tileColor = _randomColor();
    return Padding(
      padding: const EdgeInsets.only(left: 2.0, right: 2.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 80, // Adjust height as needed
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Text(
                          data['shopName'] ?? 'N/A',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                        ),
                      ),
                      Text(
                        data['date'] ?? 'N/A',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rs. ${data['amount'] ?? 'N/A'}/-',
                        style: const TextStyle(fontSize: 15),
                      ),
                      Text(
                        'Mode: ${data['mode'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Remarks: ${data['remarks'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}
