import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'connection.dart';
import 'connectivity.dart';
import 'deviceInfo.dart';
import 'home_page.dart';

import 'package:whatsapp/whatsapp.dart';


class AddCollectionPage extends StatefulWidget {
  final String? shopId;
  final String? shopName;

  const AddCollectionPage({
    Key? key,
    this.shopId,
    this.shopName,
  }) : super(key: key);

  @override
  _AddCollectionPageState createState() => _AddCollectionPageState();
}

class _AddCollectionPageState extends State<AddCollectionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _shopController = TextEditingController();

  Map<String, dynamic> _selectedShopDetails = {};
  final GlobalKey<AutoCompleteTextFieldState<String>> _autoCompleteKey =
  GlobalKey<AutoCompleteTextFieldState<String>>();
  late String serialNumber;
  final List<String> _paymentModes = ['Cash','Bank'];
  String _selectedPaymentMode = 'Cash'; // Default payment mode

  @override
  void initState() {
    super.initState();
    // Set selected shop details and shop controller text if shopId and shopName are provided
    if (widget.shopId != null && widget.shopName != null) {
      _selectedShopDetails = {
        'id': widget.shopId,
        'name': widget.shopName,
      };
      _shopController.text = widget.shopName!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          title: const Text(
            'Collection',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
          ),
          backgroundColor: Colors.indigoAccent[700],
          shape: const ContinuousRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchShops(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return _buildBody(snapshot.data!);
          }
        },
      ),
    );
  }

  Widget _buildBody(List<Map<String, dynamic>> shopList) {
    return Center(
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
          const SizedBox(height: 20,),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0, right: 16, left: 16,),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShopField(shopList),
                      const SizedBox(height: 16),
                      _buildAmountField(),
                      const SizedBox(height: 16),
                      _buildPaymentModeDropdown(),
                      const SizedBox(height: 16),
                      _buildRemarksField(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.indigoAccent[700]!, Colors.indigo],
                ),
                borderRadius: BorderRadius.circular(8), // Rounded edges
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Perform the collection submission logic
                    _submitForm();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0), // Rounded edges
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Add',
                    style: TextStyle(
                        fontSize: 18, color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopField(List<Map<String, dynamic>> shopList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: AutoCompleteTextField<String>(
            key: _autoCompleteKey,
            clearOnSubmit: true,
            suggestions: shopList
                .map((shop) => shop['shopName'].toString())
                .toList(),
            style: const TextStyle(color: Colors.black, fontSize: 16.0),
            decoration: InputDecoration(
              hintText: _selectedShopDetails['name'] ?? 'Shop', // Use selected shop name if available
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.indigo, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            controller: _shopController, // Set the controller
            itemFilter: (String item, String query) {
              return item.toLowerCase().contains(query.toLowerCase());
            },
            itemSorter: (String a, String b) {
              return a.compareTo(b);
            },
            itemSubmitted: (String item) {
              final selectedShop = shopList.firstWhere(
                    (shop) =>
                shop['shopName']
                    .toString()
                    .toLowerCase() ==
                    item.toLowerCase(),
                orElse: () => {'shopId': '', 'shopName': ''},
              );
              setState(() {
                _selectedShopDetails = {
                  'id': selectedShop['shopId'],
                  'name': selectedShop['shopName'],
                };
                _shopController.text = _selectedShopDetails['name']; // Set selected shop name to controller
              });
            },
            itemBuilder: (BuildContext context, String item) {
              return ListTile(
                title: Text(item),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAmountField() {
    return Padding(
      padding: const EdgeInsets.only(top:0),
      child: TextFormField(
        controller: _amountController,
        decoration: InputDecoration(
          labelText: 'Collection Amount',
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.indigo, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _buildRemarksField() {
    return Padding(
      padding: const EdgeInsets.only(top:8),
      child: TextFormField(
        controller: _remarksController,
        decoration: InputDecoration(
          labelText: 'Remarks',
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.indigo, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        maxLines: 3,
      ),
    );
  }

  Widget _buildPaymentModeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(top:8),
      child: DropdownButtonFormField(
        value: _selectedPaymentMode,
        onChanged: (newValue) {
          setState(() {
            _selectedPaymentMode = newValue.toString();
          });
        },
        items: _paymentModes.map((mode) {
          return DropdownMenuItem(
            value: mode,
            child: Text(mode),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: 'Payment Mode',
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.indigo, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }


  //Methods
  //For fetching shop details

  Future<List<Map<String, dynamic>>> _fetchShops() async {
    try {
      DeviceInfo deviceInfo = DeviceInfo();
      serialNumber = await deviceInfo.fetchDeviceSerialNumber(context);
      final response = await http.get(
        Uri.parse('${Conn.baseUrl}fetchShopsTakeOrder.jsp?devId=$serialNumber'), // Replace with your JSP API URL
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);

        List<Map<String, dynamic>> fetchedShops = jsonResponse.map((dynamic shop) {
          return {
            'shopId': shop['shopId'],
            'shopName': shop['shopName'],
            'shopAddress': shop['shopAddress'],
            'shopPhone': shop['shopPhone'],
            'shopEmail': shop['shopEmail'],
          };
        }).toList();

        return fetchedShops; // Return fetched shops here
      }else if(response.statusCode == 403){
        handleAddCollectionPageError('Unauthorized access', 'ERROR/addCollectionPa/_fetchshops()/: Unauthorized access ($serialNumber)');
        return [];
      }else if(response.statusCode == 400){
        handleAddCollectionPageError('Invalid input!', 'ERROR/addCollectionPa/_fetchshops()/:Unsanitized input parameters');
        return [];
      }
      else {
        // Handle API error
        logger.severe('Error/addCollectionPa/_fetchshops()/:Failed to fetch shops. Status code: ${response.body.trim()}');
        return []; // Return an empty list if there's an error
      }
    } catch (error) {
      // Handle other errors
      logger.severe('Error/addCollectionPa/_fetchshops()/:Failed to fetch shops. Status code: $error');
      return []; // Return an empty list if there's an error
    }
  }

  //Form submission

  Future<void> _submitForm() async {
    try {
      if (_selectedShopDetails['id'] != null && _amountController.text != '') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? employeeId = prefs.getString('E_id');
        String url = '${Conn.baseUrl}addCollection.jsp?devId=$serialNumber';

        final response = await http.post(
          Uri.parse(url),
          body: {
            'shopId': _selectedShopDetails['id'],
            'amount': _amountController.text,
            'remarks': _remarksController.text,
            'employeeId': employeeId,
            'paymentMode': _selectedPaymentMode, // Add selected payment mode
          },
        );

        if (response.body.trim() == 'success') {
         await sendMessage();
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Success',
            text: 'Collection recorded successfully!',
          );
          _amountController.clear();
          _remarksController.clear();
          _shopController.clear();
          _formKey.currentState!.reset();
        } else if (response.body.trim() == 'Unauthorized access') {
          handleAddCollectionPageError('Unauthorized Access!', 'Error/addCollectionPage/_submitForm()/: ${response.body}');
        } else {
          handleAddCollectionPageError('Failed to add collection!', 'Error/addCollectionPage/_submitForm()/: failed to add collection : ${response.body}');
        }
      } else {
        if (_selectedShopDetails['id'] == null) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Oops...',
            text: 'Please select a shop!',
          );
        } else if (_amountController.text == '') {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Oops...',
            text: 'Please select a valid amount!',
          );
        }
      }
    } catch (e) {
      print(e);
      handleAddCollectionPageError('Something went wrong. Check your internet connectivity and try again', 'Error/addCollPage/_submitForm()/: $e');
    }
  }

  Future<void> sendMessage() async {
    String apiUrl = 'https://graph.facebook.com/v18.0/272552522609970/messages';

    String accessToken = 'EAAGRUGtgSoYBO6OaAe1c6kSZCZBpXGo5Ueo7ZBjCd7Y54kioPG0b8H659axyZBkBSA6uuCl1kZCsbp996AYWin89X8vQUHVyN4s1mhzUoaXUWOrlHDqxia1r88oa9rvhGioxrVDKxHYQjbyP2xzC5GOJ3baLZCAYhZBaRTmUZAZCYZA5WJN0xtRVZBUPFIHaAxIFIYr0TvufVyeNnjVJDo0yRsZD';

    Map<String, dynamic> messageData = {
      "messaging_product": "whatsapp",
      "to": "919747545946",
      "type": "template",
      "template": {
        "name": "hello_world",
        "language": {"code": "en_US"}
      }
    };

    // Encode message data to JSON
    String jsonData = jsonEncode(messageData);

    try {
      // Make POST request
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonData,
      );

      // Check response status
      if (response.statusCode == 200) {
        print('Message sent successfully');
      } else {
        print('Failed to send message. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }
  //Error message handling

  void handleAddCollectionPageError(String errorMessage, String log) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...!',
      text: errorMessage,
    );
    logger.severe(log);
  }

}
