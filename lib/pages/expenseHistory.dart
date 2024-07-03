import 'dart:math';
import 'dart:io' show File;
import 'package:distribution/pages/addExpense.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../main.dart';
import 'connection.dart';
import 'connectivity.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'deviceInfo.dart';

class ExpenseHistoryPage extends StatefulWidget {
  const ExpenseHistoryPage({Key? key});

  @override
  _ExpenseHistoryPageState createState() => _ExpenseHistoryPageState();
}

class _ExpenseHistoryPageState extends State<ExpenseHistoryPage> {
  List<Map<String, String?>> expenseHistory = [];
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
          MaterialPageRoute(builder: (context) => const ExpenseHistoryPage()),
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
          title: const Text('Expenses', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
          centerTitle: true,
        ),
      ),
      body: expenseHistory.isNotEmpty ? Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 400,
              height: 55,
              child: TextField(
                controller: searchController,
                onChanged: (query) => search(query),
                decoration: InputDecoration(
                  hintText: 'Search by type, date, amount...',
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
                      'Fetching your expenses...',
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
                  return ExpenseHistoryTile(
                    data: displayedCollectionHistory[index],
                    onViewFile: (file) {
                      _showFileNamesBottomSheet(file!.split(','));
                    },
                  );
                },
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.only(bottom: 30))
        ],
      ) :  Center(
        child: Text(
          'No expenses found...!',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 65,
        height: 65,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddExpensePage(refreshData: refreshData), // Pass the refreshData function
              ),
            );
          },
          backgroundColor: Colors.indigoAccent[700],
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  //Methods
  //fetch expense data
  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? employeeId = prefs.getString('E_id');
      DeviceInfo deviceInfo = DeviceInfo();
      String serialNumber = await deviceInfo.fetchDeviceSerialNumber(context);
      print('passed');
      final response = await http.get(
          Uri.parse('${Conn.baseUrl}expenseHistory.jsp?employeeId=$employeeId&devId=$serialNumber'));
      print(response.body);
      if (response.statusCode == 200 && response.body.trim() != 'Unauthorized access') {
        final List<dynamic> jsonResponse = json.decode(response.body);

        setState(() {
          expenseHistory = List<Map<String, String?>>.from(
            jsonResponse.map((dynamic data) {
              return {
                'type': data['type'].toString(),
                'amount': data['amount'].toString(),
                'date': _formatDate(data['date'].toString()),
                'remarks': data['remarks'].toString(),
                'file': data['file'].toString(),
              };
            }),
          );

          displayedCollectionHistory = List<Map<String, String>>.from(expenseHistory);
        });
      }else if(response.body.trim() == 'Unauthorized access'){
        handleExpenseHistoryPageError('Unauthorized access','Error/expenseHisPage/fetchData()/: ${response.body}');
      }
      else {
        handleExpenseHistoryPageError('Failed to load your expenses. Check your internet connectivity and try again','Error/expenseHisPage/fetchData()/: failed to fetch collection history: ${response.body}');
      }
    } catch (error) {
      print(error);
      handleExpenseHistoryPageError( 'Something went wrong. Check your internet connectivity and try again','Error/expenseHisPage/fetchData()/: $error');
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

  //For searchbar
  void search(String query) {
    setState(() {
      displayedCollectionHistory = expenseHistory
          .where((data) =>
      data['type']!.toLowerCase().contains(query.toLowerCase()) ||
          data['amount']!.contains(query) ||
          data['date']!.toLowerCase().contains(query.toLowerCase()) ||
          data['remarks']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  //refresh the data when new expense is added
  void refreshData() {
    fetchData(); // Call the fetchData method to reload the data
  }

  //Error handling
  void handleExpenseHistoryPageError(String errorMessage, String log) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...!',
      text: errorMessage,
    );
    logger.severe(log);
  }

  // Function to view file
  Future<void> viewFile(String? fileUrl) async {
    if (fileUrl == null) return;

    String extension = fileUrl.split('.').last.toLowerCase();
    try {
      final response = await http.get(Uri.parse('https://arbv2728.co.in/shopimg/expense_bills/$fileUrl'));

      // Create a temporary file to store the fetched data
      final tempFile = File('${(await getTemporaryDirectory()).path}/temp.$extension');
      await tempFile.writeAsBytes(response.bodyBytes);

      await OpenFile.open(tempFile.path);
    } catch (e) {
      // Handle error
      print('Error: $e');
    }
  }

  // Function to show bottom sheet with file names
  void _showFileNamesBottomSheet(List<String> fileNames) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.file_copy_rounded,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 10,),
                  Text(
                    'Expense bill attached',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                itemCount: fileNames.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(fileNames[index]),
                    subtitle: const Divider(),
                    onTap: () {
                      viewFile(fileNames[index]);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class ExpenseHistoryTile extends StatelessWidget {
  final Map<String, String?> data;
  final Function(String?) onViewFile;
  final Random random = Random();
  ExpenseHistoryTile({super.key, required this.data, required this.onViewFile});

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
              height: 80,
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
                      Text(
                        data['type'] ?? 'N/A',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                      ),
                      Text(
                        data['date'] ?? 'N/A',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
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
                      data['file'] != 'null' ?
                      GestureDetector(
                        onTap: () {
                          onViewFile(data['file']);
                        },
                        child: const Icon(
                          Icons.visibility,
                          color: Colors.blue,
                        ),
                      )
                          : Container(),
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
