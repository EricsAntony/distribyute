import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../main.dart';
import 'connection.dart';
import 'connectivity.dart';
import 'deviceInfo.dart';
import 'home_page.dart';

class ShopButtonPage extends StatefulWidget {
  final Map<String, dynamic> shopDetails;
  final List<Map<String, dynamic>> orders;

  const ShopButtonPage({Key? key, required this.shopDetails, required this.orders}) : super(key: key);

  @override
  _ShopButtonPageState createState() => _ShopButtonPageState();
}

class _ShopButtonPageState extends State<ShopButtonPage> {
  late String serialNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
          'Placed Orders',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConnectivityStatusWidget(
              onConnectionRestored: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
            Center(
              child: Text(
                '${widget.shopDetails['shopName']}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text('${widget.shopDetails['shopAddress']}', style: const TextStyle(fontSize: 16)),
            ),
            Center(
              child: Text('${widget.shopDetails['shopState']}', style: const TextStyle(fontSize: 16)),
            ),
            Center(
              child: Text('${widget.shopDetails['shopEmail']}', style: const TextStyle(fontSize: 16)),
            ),
            Center(
              child: Text('${widget.shopDetails['shopPhone']}', style: const TextStyle(fontSize: 16)),
            ),
            Center(
              child: Text('GSTIN: ${widget.shopDetails['shopGst']}', style: const TextStyle(fontSize: 16)),
            ),
            const Divider(),
            const Text('Orders:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<List<Map<String, dynamic>>>>(
                future: Future.wait(widget.orders.map((order) => _fetchOrderDetails(order['O_id']))),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Text('Error loading order details');
                  } else {
                    return ListView.builder(
                      itemCount: widget.orders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderTile(widget.orders[index], snapshot.data![index]);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTile(Map<String, dynamic> order, List<Map<String, dynamic>> orderDetailsList) {
    final orderId = order['O_id'];
    final orderDate = order['O_date'];
    return Padding(
      padding: const EdgeInsets.only(top:5),
      child: Container(
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
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: ExpansionTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order ID: $orderId',),
              Text(_formatDateTime(orderDate), style: const TextStyle(fontSize: 16)),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order['O_cstatus']),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_getStatusText(order['O_cstatus']), style: const TextStyle(fontSize: 14, color: Colors.white)),
                ),
                if(order['O_cstatus'] == '1' || order['O_cstatus'] == '2')
                  TextButton(
                  onPressed: () {
                    _showBillDetailsBottomSheet(order['O_id']);
                  },
                  child: const Text(
                  'Bill Details',
                  style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: orderDetailsList.map((orderDetails) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${orderDetails['product_name']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Qty\n${orderDetails['quantity']}', style: const TextStyle(fontSize: 16)),
                              Text('Amount\nRs.${orderDetails['amount']}/-', style: const TextStyle(fontSize: 16)),
                              Text('${orderDetails['tax_name']}\n ${orderDetails['tax_perc']}%', style: const TextStyle(fontSize: 16)),

                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items to the extremes
                          children: [
                            Text('Serviced By: ${orderDetails['employee_name']}', style:TextStyle(fontSize: 16,color: Colors.grey[700])),
                            if (orderDetails['bill_status'] == 1)
                              Container(
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
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Methods
  //Fetch orderdetails for the shop
  Future<List<Map<String, dynamic>>> _fetchOrderDetails(String orderId) async {
    try {
      DeviceInfo deviceInfo = DeviceInfo();
      serialNumber = await deviceInfo.fetchDeviceSerialNumber(context);
      final response = await http.get(Uri.parse('${Conn.baseUrl}orderDetails.jsp?orderId=$orderId&devId=$serialNumber'));
      print(response.body);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      }else if(response.statusCode == 403){
        logger.severe('Error/shopButtonPage/_fetchOrderDetails()/: unauthorized access ($serialNumber)');
        return [];
      }else if(response.statusCode == 400){
        logger.severe('Error/shopButtonPage/_fetchOrderDetails()/: Unsanitized input parameter');
        return [];
      }
      else {
        _handleError('Something went wrong. Check your internet connectivity!', 'Error/shopButtonPage/fetchOrderDetails()/: failed loading data ${response.body}');
        return [];
      }
    } catch (error) {
      _handleError('Something went wrong. Restart the app!', 'Error/shopButtonPage/fetchOrderDetails()/: $error');
      return [];
    }
  }

  //function to format date
  String _formatDateTime(String inputDateTime) {
    try {
      final dateTime = DateTime.parse(inputDateTime);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (error) {
      logger.severe('Error/shopButtonPage/formatDateTime()/: $error');
      return inputDateTime;
    }
  }

  //color for pending and completed text
  Color _getStatusColor(String status) {
    switch (status) {
      case '0':
        return Colors.orange;
      case '1':
        return Colors.yellow;
      case '2':
        return Colors.green;
      default:
        return Colors.transparent;
    }
  }

  //to get pending or completed text
  String _getStatusText(String status) {
    switch (status) {
      case '0':
        return 'Pending';
      case '1':
        return 'Incomplete';
      case '2':
        return 'Completed';
      default:
        return '';
    }
  }

  void _showBillDetailsBottomSheet(String orderId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FutureBuilder(
          future: fetchBillDetails(orderId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}"),
              );
            } else {
              // Extract bill details from snapshot
              var billDetails = snapshot.data;

              return Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(80),
                  child: AppBar(
                    automaticallyImplyLeading: false,
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
                    title: const Padding(
                      padding: EdgeInsets.only(top: 35),
                      child: Center(
                          child: Text('Bill Details',
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold))),                   ),
                    actions: [
                      ConnectivityStatusWidget(
                        onConnectionRestored: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HomePage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Center(
                            child: Text(
                              "${widget.shopDetails['shopName']}",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700]
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              "${widget.shopDetails['shopAddress']}",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700]
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              "${widget.shopDetails['shopEmail']}",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700]
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              "${widget.shopDetails['shopPhone']}",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700]
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Center(
                                child: Text(
                                  "Order ID: $orderId",
                                  style: const TextStyle(
                                      fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                        ],
                      ),

                      Expanded(
                        child: ListView.builder(
                          itemCount: billDetails?.length,
                          itemBuilder: (context, index) {
                            var bill = billDetails?[index];
                            // Format the date
                            var formattedDate = DateFormat('dd/MM/yyyy').format(
                                DateTime.parse(bill?['B_date']));
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Card(
                                elevation: 4,
                                margin: const EdgeInsets.all(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Bill ID: ${bill?['B_id']}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(formattedDate),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Column(
                                        children: bill?['products']
                                            .map<Widget>((product) => ListTile(
                                          title: Text(
                                            "${product['P_name']}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Qty\n ${product['B_qty']}"),
                                              Text(
                                                  "Price\n Rs.${product['B_rate']}/-"),
                                              Text("GST\n${product['B_tax']}%"),
                                            ],
                                          ),
                                        ))
                                            .toList(),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Discount: Rs.${bill?['B_discount']}/-"),
                                          Text("Total: Rs.${bill?['B_total']}/-"),
                                        ],
                                      ),
                                      Text("Mode: ${bill?['B_payMode']}"),
                                      Text("Paid: Rs.${bill?['B_pay']}/-"),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
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
