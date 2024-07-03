import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import 'connection.dart';
import 'connectivity.dart';
import 'deviceInfo.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage();

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<String> shopNames = [];
  List<Map<String, dynamic>> shopDataList = [];
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> allOrders = [];
  String? selectedShopId;
  StreamController<List<String>>? _shopStreamController;
  String? selectedShop;
  final TextEditingController _searchController = TextEditingController();
  late String serialNumber;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      fetchAllOrders().then((_) {
        fetchShopNames();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
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
          title: const Center(
              child: Text('Orders',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
          actions: [
            ConnectivityStatusWidget(
              onConnectionRestored: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const OrdersPage()),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  if (shopNames.isNotEmpty) {
                    _showShopSelectionDialog(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Background color
                ),
                child: SizedBox(
                  width: 80,
                  child: Text(
                    selectedShop ?? 'Select Store',
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.indigoAccent[700]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: Future.delayed(const Duration(seconds: 1), () {}),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              (orders.isEmpty && selectedShopId == null)) {
            return ListView.separated(
              itemCount: 8,
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                return const ShimmerOrderTile();
              },
            );
          }  else {
            return orders.isNotEmpty
                ? ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return OrderTile(order: orders[index]);
              },
            )
                : selectedShopId != null &&
                shopNames.contains(selectedShop ?? '')
                ? Center(
              child: SizedBox(
                height: 500,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/images/no orders.png',
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No orders for the selected store yet!',
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            )
                : allOrders.isNotEmpty
                ? ListView.builder(
              itemCount: allOrders.length,
              itemBuilder: (context, index) {
                return OrderTile(order: allOrders[index]);
              },
            )
                : Center(
              child: SizedBox(
                height: 500,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/images/no orders.png',
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No orders yet!',
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  //Methods
  //For search bar
  void _initializeSearchStream() {
    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      final filteredShops = shopNames
          .where((shop) => shop.toLowerCase().contains(query))
          .toList();
      _shopStreamController!.add(filteredShops);
    });
  }

  //fetching all orders
  Future<void> fetchAllOrders() async {
    try {
      DeviceInfo deviceInfo = DeviceInfo();
      serialNumber = await deviceInfo.fetchDeviceSerialNumber(context);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? employeeId = prefs.getString('E_id');

      final response = await http.get(
        Uri.parse(
            '${Conn.baseUrl}getAllOrders.jsp?employeeId=$employeeId&devId=$serialNumber'),
      );
      print(response.body);
      if (response.statusCode == 200) {
        String jsonResponse = response.body.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
        final List<dynamic> decodedResponse = json.decode(jsonResponse);

        List<Map<String, dynamic>> filteredOrders = List<Map<String, dynamic>>.from(decodedResponse.where((order) => order['S_name'] != '--OPEN ORDER--'));

        setState(() {
          allOrders = filteredOrders;
        });
      } else if (response.statusCode == 403) {
        logger.severe(
            'Error/OrderPage/fetchAllOrders()/: unauthorized access ($serialNumber)');
      } else if (response.statusCode == 400) {
        logger.severe(
            'Error/OrderPage/fetchAllOrders()/: unsanitized parameters');
      } else {
        handleOrdersPageError(
            'Failed to fetch order details!',
            'Error/OrderPage/fetchAllOrders()/: failed to fetch all orders: ${response.body}');
      }
    } catch (error) {
      handleOrdersPageError(
          'Something went wrong. Check your connectivity and try again',
          'Error/OrderPage/fetchAllOrders()/: $error');
    }
  }



  //Fetching shop names
  Future<void> fetchShopNames() async {
    try {
      final response = await http
          .get(Uri.parse('${Conn.baseUrl}viewShop.jsp?devId=$serialNumber'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);

        setState(() {
          shopDataList = jsonResponse.map((dynamic shop) {
            return {
              'shopId': shop['shopId'].toString(),
              'shopName': shop['shopName'].toString(),
            };
          }).toList();

          shopNames = shopDataList
              .map((shopData) => shopData['shopName'].toString())
              .toList();
          _shopStreamController = StreamController<List<String>>.broadcast();
          _shopStreamController!.add(shopNames);
        });
        _initializeSearchStream();
      } else if (response.statusCode == 403) {
        logger.severe(
            'Error/OrderPage/fetchShopNames()/: unauthorized access ($serialNumber)');
      } else if (response.statusCode == 400) {
        logger.severe(
            'Error/OrderPage/fetchShopNames()/: unsanitized parameters');
      } else {
        logger.severe(
            'Error/OrderPage/fetchShopNames()/: failed to fetch shops: ${response.body}');
      }
    } catch (error) {
      handleOrdersPageError(
          'Something went wrong. Check your internet connectivity and try again ',
          'Error/OrderPage/fetchShopNames()/: $error}');

    }
  }

  //shop selection bottom-sheet
  void _showShopSelectionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 400,
                height: 70,
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    filled: true,
                    fillColor: Colors.grey[50],
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<List<String>>(
                  stream: _shopStreamController!.stream,
                  initialData: shopNames,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    List<String> filteredShopNames = snapshot.data!;
                    return ListView.builder(
                      itemCount: filteredShopNames.length,
                      itemBuilder: (context, index) {
                        String shop = filteredShopNames[index];
                        return ListTile(
                          title: Text(shop),
                          onTap: () {
                            Map<String, dynamic> selectedShopData =
                            shopDataList.firstWhere(
                                  (shopData) => shopData['shopName'] == shop,
                            );
                            String shopId =
                            selectedShopData['shopId'].toString();
                            setState(() {
                              selectedShop = shop;
                              selectedShopId = shopId;
                              fetchOrders();
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //Fetching orders for shops
  Future<void> fetchOrders() async {
    try {
      if (selectedShopId == null) {
        return;
      }
      final response = await http.get(
        Uri.parse(
            '${Conn.baseUrl}getOrders.jsp?shopId=$selectedShopId&devId=$serialNumber'),
      );

      if (response.statusCode == 200) {
        String jsonFormatted = response.body.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
        final List<dynamic> jsonResponse = json.decode(jsonFormatted);
        setState(() {
          orders = List<Map<String, dynamic>>.from(jsonResponse);
        });
      } else if (response.statusCode == 403) {
        logger.severe(
            'Error/OrderPage/fetchOrders()/: unauthorized access ($serialNumber)');
      } else if (response.statusCode == 400) {
        logger.severe('Error/OrderPage/fetchOrders()/: unsanitized parameters');
      } else {
        handleOrdersPageError(
            'Failed to fetch order details for the selected shop!',
            'Error/OrderPage/fetchOrders()/: failed to fetch orders for selected shop: ${response.body}');
      }
    } catch (error) {
      handleOrdersPageError(
          'Something went wrong. Check your internet connectivity and try again',
          'Error/OrderPage/fetchOrders()/: $error');

    }
  }

  //Error handling
  void handleOrdersPageError(String errorMessage, String log) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...!',
      text: errorMessage,
    );
    logger.severe(log);
  }
}

class OrderTile extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderTile({super.key, required this.order});

  @override
  _OrderTileState createState() => _OrderTileState();
}

class _OrderTileState extends State<OrderTile> {
  bool _isExpanded = false;
  List<dynamic> _orderDetailsList = [];
  late String serialNumber;

  void handleOrdersPageError(String errorMessage, String log) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      text: errorMessage,
    );
    logger.severe(log);
  }

  Future<void> fetchOrderDetails() async {
    try {
      DeviceInfo deviceInfo = DeviceInfo();
      serialNumber = await deviceInfo.fetchDeviceSerialNumber(context);
      final response = await http.get(
        Uri.parse(
            '${Conn.baseUrl}orderDetails.jsp?orderId=${widget
                .order['O_id']}&devId=$serialNumber'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _orderDetailsList = json.decode(response.body);
        });
      } else if (response.statusCode == 403) {
        logger.severe(
            'Error/OrdersPage/fetchOrderDetails()/: unauthorized access ($serialNumber)');
      } else if (response.statusCode == 400) {
        logger.severe(
            'Error/OrdersPage/fetchOrderDetails()/: unsanitized input parameters');
      } else {
        handleOrdersPageError('Failed to fetch order details!',
            'Error/OrderPage/fetchOrderDetails()/: failed to fetch order details: ${response
                .body}');
      }
    } catch (error) {
      handleOrdersPageError(
          'Something went wrong! Error fetching order details',
          'Error/OrderPage/fetchOrderDetails()/: $error');
    }
  }

  Widget buildOrderDetails() {
    if (_orderDetailsList.isNotEmpty) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _orderDetailsList.map((orderDetail) {
            bool isBilled = orderDetail['bill_status'] == 1;
            return Card(
              color: Colors.white,
              elevation: 2.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(
                  '${orderDetail['product_name']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Qty\n${orderDetail['quantity']}'),
                          Text('Amount\nRs.${orderDetail['amount']}/-'),
                          Text('${orderDetail['tax_name']}\n${orderDetail['tax_perc']}%'),
                        ],
                      ),
                    ),

                    Row(
                      children: [
                        Text('Serviced By: ${orderDetail['employee_name']}'),
                        const Spacer(),
                        if (isBilled)
                          TextButton(
                            onPressed: () {
                              // _showBillDetailsBottomSheet();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Text(
                                  'Billed',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    } else {
      return const Text('No Product list found');
    }
  }


  void _showBillDetailsBottomSheet(BuildContext context, List<String> billIds) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          children: [
            ListTile(
              title: Row(
                children: [
                  const Icon(Icons.assessment_outlined,color: Colors.blue,),
                  const SizedBox(width: 8),
                  Text(
                    'Select a bill',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            ...billIds.map((billId) {
              return ListTile(
                title: Text('Bill ID: $billId'),
                onTap: () {
                  _launchURL(billId);
                },
              );
            }),
          ],
        );
      },
    );
  }


// Function to fetch bill details from the database
  Future<List<Map<String, dynamic>>> fetchBillDetails(
      String orderDetailId) async {
    try {
      DeviceInfo deviceInfo = DeviceInfo();
      String serialNumber = await deviceInfo.fetchDeviceSerialNumber(context);

      final response = await http.get(
        Uri.parse('${Conn
            .baseUrl}getBillDetails.jsp?orderDetailId=$orderDetailId&devId=$serialNumber'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return List<Map<String, dynamic>>.from(jsonResponse);
      } else if (response.statusCode == 403) {
        logger.severe(
            'Error/OrdersPage/fetchBillDetails(): unauthorized access ($serialNumber)');
      } else if (response.statusCode == 400) {
        logger.severe(
            'Error/OrdersPage/fetchBillDetails(): unsanitized input parameters');
      } else {
        logger.severe(
            'Error/OrdersPage/fetchBillDetails(): failed to fetch bill details: ${response
                .body}');
      }
    } catch (error) {
      logger.severe('Error/OrdersPage/fetchBillDetails(): $error');
    }
    return [];
  }

// Function to launch URL
  void _launchURL(String billId) async {
    String url = 'http://localhost:8080/ShopWebapp/ViewBill.jsp?id=$billId';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Random random = Random();

    String formattedDate = DateFormat('dd/MM/yyyy').format(
      DateTime.parse(widget.order['O_date']),
    );

    Color statusColor;
    String statusText;
    Widget? statusButton;

    if (widget.order['O_cstatus'] == '0') {
      statusText = 'Pending';
      statusColor = Colors.orange;
    } else if (widget.order['O_cstatus'] == '1') {
      statusText = 'Incomplete';
      statusColor = Colors.yellow;
      statusButton = TextButton(
        onPressed: () {
          print(widget.order['bill_ids']);
          List<String> billIds = widget.order['bill_ids'].split(',');
          _showBillDetailsBottomSheet(context, billIds);
        },
        child: const Text(
          'Bill Details',
          style: TextStyle(color: Colors.blue),
        ),
      );
    } else if (widget.order['O_cstatus'] == '2') {
      statusText = 'Completed';
      statusColor = Colors.green[400]!;
      statusButton = TextButton(
        onPressed: () {
          List<String> billIds = widget.order['bill_ids'].split(',');
          _showBillDetailsBottomSheet(context, billIds);
        },
        child: const Text(
          'Bill Details',
          style: TextStyle(color: Colors.blue),
        ),
      );
    } else {
      statusText = 'Unknown';
      statusColor = Colors.transparent;
    }



    Color _randomColor() {
      return Color.fromRGBO(
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
        1,
      );
    }

    Color tileColor = _randomColor();

    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 10, right: 10),
      child: Container(
        padding: const EdgeInsets.only(right: 16),
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
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16, bottom: 16),
              child: Container(
                width: 8,
                height: 110, // Adjust height as needed
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                    vertical: 0, horizontal: 0),
                // Adjust the padding here
                trailing: const SizedBox.shrink(),
                title: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order ID: ${widget.order['O_id']}',
                        style: TextStyle(fontWeight: FontWeight.bold,
                            color: Colors.grey[800]),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.order['S_name']}',
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  statusText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            if (statusButton != null) statusButton,

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                onExpansionChanged: (bool expanded) {
                  setState(() {
                    _isExpanded = expanded;
                    if (expanded && _orderDetailsList.isEmpty) {
                      fetchOrderDetails();
                    }
                  });
                },
                children: [
                  buildOrderDetails(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerOrderTile extends StatelessWidget {
  const ShimmerOrderTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 10, right: 10),
      child: Shimmer.fromColors(
        baseColor: Colors.white,
        highlightColor: Colors.grey[300]!,
        child: Card(

          child: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 15,
                  color: Colors.grey[300],
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 15,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 15,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


