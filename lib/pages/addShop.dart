import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../main.dart';
import 'connection.dart';
import 'connectivity.dart';
import 'deviceInfo.dart';

class AddShopPage extends StatefulWidget {
  const AddShopPage({Key? key}) : super(key: key);

  @override
  _AddShopPageState createState() => _AddShopPageState();
}

class _AddShopPageState extends State<AddShopPage> {
  TextEditingController shopNameController = TextEditingController();
  TextEditingController shopAddressController = TextEditingController();
  TextEditingController shopPhoneController = TextEditingController();
  TextEditingController shopEmailController = TextEditingController();
  TextEditingController shopGstController = TextEditingController();
  TextEditingController autoCompleteTextController = TextEditingController();

  List<Map<String, String>> states = [];
  List<String> stateList = [];
  String selectedState = '';
  String selectedStateCode = '';
  final GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  final FocusNode _shopNameFocusNode = FocusNode();


  @override
  void initState() {
    super.initState();
    fetchStates();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_shopNameFocusNode);
    });
  }

  @override
  void dispose() {
    _shopNameFocusNode.dispose();
    super.dispose();
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
          title: const Text(
            'Add Store',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConnectivityStatusWidget(
                      onConnectionRestored: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddShopPage()),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    _buildTextField(shopNameController, 'Shop Name',
                      focusNode: true ? _shopNameFocusNode : null,
                    ),
                    _buildTextField(shopAddressController, 'Address'),
                    _buildContactTextField(shopPhoneController, 'Contact Number'),
                    _buildTextField(shopEmailController, 'E-mail'),
                    _buildStateDropdown(),
                    _buildGstTextField(shopGstController, 'GST Number'),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.indigoAccent[700]!, Colors.indigo],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (_validateForm()) {
                    addShop(context);
                  }
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
                  'Add',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      {FocusNode? focusNode} // Add a nullable FocusNode parameter
      ) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode, // Assign the provided focus node
        decoration: InputDecoration(
          labelText: label,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.indigoAccent[700]!, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildContactTextField(
      TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [LengthLimitingTextInputFormatter(10)],
        decoration: InputDecoration(
          labelText: label,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.indigoAccent[700]!, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildStateDropdown() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: DropdownButtonFormField<String>(
        value: selectedState,
        onChanged: (String? newValue) {
          setState(() {
            selectedState = newValue!;
            selectedStateCode = states
                .firstWhere((state) => state['stateName'] == newValue)['stateCode']!;
          });
        },
        items: stateList.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: 'State',
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.indigoAccent[700]!, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildGstTextField(
      TextEditingController controller,
      String label,
      ) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        controller: controller,
        inputFormatters: [LengthLimitingTextInputFormatter(15)],
        onChanged: (value) {
          controller.value = controller.value.copyWith(
            text: value.toUpperCase(),
            selection: TextSelection.collapsed(offset: value.length),
          );
        },
        decoration: InputDecoration(
          labelText: 'GST number',
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.indigoAccent[700]!,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  //Methods
  //Fetching states

  Future<void> fetchStates() async {
    try {
      final response = await http.get(
          Uri.parse('${Conn.baseUrl}fetchStates.jsp'));

      if (response.statusCode == 200) {
        states.clear(); // Clear the list before adding new states
        for (var state in json.decode(response.body)) {
          states.add({
            'stateName': state['StateName'] as String? ?? '', // Use '' if null
            'stateCode': state['StCode'] as String? ?? '', // Use '' if null
          });
        }
        setState(() {
          stateList.addAll(states.map((state) => state['stateName']!));
          selectedState = stateList.isNotEmpty ? stateList[18] : '';
          selectedStateCode =
          (states.isNotEmpty ? states[18]['stateCode'] ?? '' : '');
          autoCompleteTextController.text = selectedState;
        });
      } else {
        logger.severe(
            'Error/addShop/fetchStates():/Error fetching states: ${response.body}');
      }
    } catch (e) {
      logger.severe('Error/addShop/fetchStates():/ $e');
    }
  }

  //Form submission

  Future<void> addShop(BuildContext context) async {
    try {
      if (shopNameController.text != '' &&
          shopAddressController.text != '' &&
          shopPhoneController.text != '' &&
          shopEmailController.text != '' &&
          shopGstController.text != '') {
        DeviceInfo deviceInfo = DeviceInfo();
        String serialNumber = await deviceInfo.fetchDeviceSerialNumber(context);
        String url = "${Conn.baseUrl}addShop.jsp?devId=$serialNumber";
        var response = await http.post(
          Uri.parse(url),
          body: {
            'shopName': shopNameController.text,
            'shopAddress': shopAddressController.text,
            'shopPhone': shopPhoneController.text,
            'shopEmail': shopEmailController.text,
            'shopState': selectedStateCode,
            'shopGst': shopGstController.text,
          },
        );

        if (response.body.trim() == 'success') {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: 'Store Added Successfully',
            confirmBtnText: 'Ok',
            confirmBtnColor: Colors.green,
            onConfirmBtnTap: () {
              shopNameController.clear();
              shopAddressController.clear();
              shopPhoneController.clear();
              shopEmailController.clear();
              shopGstController.clear();
              setState(() {
                selectedState = stateList.isNotEmpty ? stateList[18] : '';
                selectedStateCode =
                (states.isNotEmpty ? states[18]['stateCode'] ?? '' : '');
                autoCompleteTextController.text = selectedState;
              });
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          );
        } else if (response.statusCode == 403) {
          handleAddShopPageError(
              'Unauthorized access', 'Error/addShop/addShop()/: Unauthoirzed access');
        } else if (response.statusCode == 400) {
          handleAddShopPageError(
              'Invalid inputs', 'Error/addShop/addShop()/: Unsanitized input parameters recieved');
        } else {
          handleAddShopPageError(
              'Failed to add shop', 'Error/addShop/addShop()/: ${response.body}');
        }
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'All fields are required!',
        );
      }
    } catch (e) {
      handleAddShopPageError('Something went wrong!',
          'Error/addShop/addShop()/: $e');
    }
  }

  //Validation

  bool _validateForm() {
    if (shopNameController.text.isEmpty ||
        shopAddressController.text.isEmpty ||
        shopPhoneController.text.isEmpty ||
        shopEmailController.text.isEmpty ||
        shopGstController.text.isEmpty) {
      // Show an error message if any field is empty
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'All fields are required!',
      );
      return false;
    }

    // Validate contact number format
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(shopPhoneController.text)) {
      // Show an error message for invalid contact number
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Invalid contact number!',
      );
      return false;
    }

    // Validate email format
    if (!RegExp(
        r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
        .hasMatch(shopEmailController.text)) {
      // Show an error message for invalid email
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Invalid email address!',
      );
      return false;
    }

    // Validate GST number format (alphanumeric)
    if (!RegExp(r'^[A-Za-z0-9]{15}$')
        .hasMatch(shopGstController.text) ||
        !RegExp(r'[A-Za-z]').hasMatch(shopGstController.text) ||
        !RegExp(r'[0-9]').hasMatch(shopGstController.text)) {
      // Show an error message for invalid GST number
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Invalid GST number! Must be alphanumeric with 15-digits.',
      );
      return false;
    }
    return true;
  }

  //Error handling

  void handleAddShopPageError(String errorMessage, String log) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...!',
      text: errorMessage,
    );
    logger.severe(log);
  }
}
