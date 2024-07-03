import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../components/cart_item.dart';
import '../main.dart';
import '../models/cart.dart';
import '../models/shoe.dart';
import 'connection.dart';
import 'connectivity.dart';
import 'deviceInfo.dart';
import 'home_page.dart';

class CartPage extends StatefulWidget {
  final String shopId;
  final String shopName;
  const CartPage({Key? key, required this.shopId, required this.shopName}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<String> shopNames = [];
  List<Map<String, dynamic>> shopDataList = []; // List to store shop names and IDs
  String? selectedShop;
  String? selectedShopId;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120), // Adjust height if necessary
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.indigoAccent[700]!, Colors.indigo],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: const Text(
                  'My Cart',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                shape: const ContinuousRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                centerTitle: true,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Text(
                  widget.shopName,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: Stack(
        children: [
          ConnectivityStatusWidget(
            onConnectionRestored: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          FutureBuilder<double>(
            future: Provider.of<Cart>(context).calculateTotalPrice(),
            builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ListView.builder(
                          itemCount: Provider.of<Cart>(context).getUserCart().length,
                          itemBuilder: (context, index) {
                            Shoe individualShoe = Provider.of<Cart>(context).getUserCart()[index];
                            return CartItem(shoe: individualShoe, cart: Provider.of<Cart>(context));
                          },
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        width: double.infinity, // Full width
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.indigoAccent[700]!, Colors.indigo],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            String? E_id = await getEid();
                            _placeOrder(context, E_id, Provider.of<Cart>(context, listen: false));
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Place order',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }


  //Methods
  //Getting employeeId

  Future<String?> getEid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('E_id');
  }

  //place order

  Future<void> _placeOrder(BuildContext context, String? E_id, Cart cart) async {
    try {
      selectedShopId = widget.shopId;
      selectedShop = widget.shopName;
      if (selectedShopId == null) {
        // Prompt the user to select a shop
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text('Shop not selected'),
            content: Text('Please select a shop before placing an order.'),
          ),
        );
        return;
      }

      if (cart.getUserCart().isEmpty) {
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text('Cart is empty'),
            content: Text('Please add items to your cart before placing an order.'),
          ),
        );
        return;
      }

      double totalPrice = await cart.calculateTotalPrice();
      bool orderConfirmed = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Estimated price',style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.indigoAccent[700],
          content: Text('Rs: $totalPrice/-(incl. gst)\n\nThe price quoted may vary from actual bill',
            style: TextStyle(color: Colors.white, fontSize: 16),),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel',style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm',style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      );

      if (orderConfirmed) {
        int? confirmed = await _sendOrderToServer(E_id, selectedShop, cart.getUserCart());
        if (confirmed == 1) {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_done_sharp, color: Colors.indigoAccent[700], size: 100),
                    SizedBox(height: 20),
                    Text(
                      'Order Placed Successfully...!',
                      style: TextStyle(color: Colors.grey[700], fontSize: 16),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.indigoAccent[700]!),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
          cart.clearCart();
        }
      }

    } catch (e) {
      handleCartPageError('Failed to place order. Check your internet connectivity and try again', 'Error/cartPage/_placeOrder()/: $e');
    }
  }

  //send order details to sever
  Future<int?> _sendOrderToServer(String? E_id, String? selectedShop, List<Shoe> cartItems) async {
    String oDate = DateTime.now().toString();
    DeviceInfo deviceInfo = DeviceInfo();
    String serialNumber = await deviceInfo.fetchDeviceSerialNumber(context);

    List<Map<String, dynamic>> orderDetails = [];

    for (var item in cartItems) {
      Map<String, dynamic> orderDetail = {
        'P_id': item.id,
        'O_qty': item.User_quantity,
        'P_amt': item.userEnteredPrice,
      };
      orderDetails.add(orderDetail);
    }

    String jsonBody = json.encode({
      'E_id': E_id,
      'S_id': selectedShopId,
      'O_date': oDate,
      'orderDetails': orderDetails,
    });

    // Make the HTTP request
    final response = await http.post(
      Uri.parse('${Conn.baseUrl}placeOrder.jsp?devId=$serialNumber'),
      headers: {'Content-Type': 'application/json'},
      body: jsonBody,
    );
    if (response.body.trim() == 'success') {
      return 1;
    }else if(response.statusCode == 403){
      handleCartPageError('Unauthorized access','Error/cartPage/_sentOrderToServer()/: Unauthorized access $serialNumber');
    }
    else {

      handleCartPageError('Failed to place order. Check your internet connectivity and try again','Error/cartPage/_sentOrderToServer()/: failed to save order to db: ${response.body.trim()}');
    }
    return null;
  }

  //Error handling

  void handleCartPageError(String errorMessage, String log) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...!',
      text: errorMessage,
    );
    logger.severe(log);
  }

}
