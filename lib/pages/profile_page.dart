import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../main.dart';
import '../models/cart.dart';
import 'connection.dart';
import 'connectivity.dart';
import 'deviceInfo.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> userData = {};
  bool isPasswordVisible = false;
  bool isEditing = false;
  late String employeeId;

  late TextEditingController addressController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController designationController;
  late TextEditingController joiningDateController;
  late TextEditingController passwordController;
  late String serialNumber;

  @override
  void initState() {
    super.initState();
    fetchData();
    initializeControllers();
  }

  @override
  void dispose() {
    addressController.dispose();
    emailController.dispose();
    phoneController.dispose();
    designationController.dispose();
    joiningDateController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
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
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('lib/images/avtar.webp'),
                ),
                const SizedBox(height: 10),
                Text(
                  userData['name'] ?? '',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: isEditing
                      ? _buildEditableContent()
                      : _buildNonEditableContent(),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: isEditing ? saveChanges : toggleEditing,
                    child: Text(isEditing ? 'Save Changes' : 'Edit Profile'),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.confirm,
                  text: 'Do you want to logout',
                  confirmBtnText: 'Yes',
                  cancelBtnText: 'No',
                  confirmBtnColor: Colors.green,
                  onConfirmBtnTap: () {
                    handleLogout(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNonEditableContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DetailTile(title: 'Address', value: userData['address'] ?? ''),
        DetailTile(title: 'Email', value: userData['email'] ?? ''),
        DetailTile(title: 'Phone', value: userData['phone'] ?? ''),
        DetailTile(title: 'Designation', value: userData['designation'] ?? ''),
        DetailTile(title: 'Joining Date', value: _formatDate(userData['joiningDate'] ?? '')),
        PasswordTile(
          title: 'Password',
          value: passwordController.text,
          isPasswordVisible: isPasswordVisible,
          togglePasswordVisibility: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
        ),
      ],
    );
  }

  Widget _buildEditableContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEditableField('Address', addressController),
        _buildEditableField('Email', emailController),
        _buildEditableField('Phone', phoneController),
        _buildEditableField('Designation', designationController),
        _buildEditableField('Joining Date', joiningDateController),
        _buildEditableField('Password', passwordController),
      ],
    );
  }

  Widget _buildEditableField(String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        title == 'Joining Date'
            ? Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                style: const TextStyle(fontSize: 14),
                enabled: false,
              ),
            ),
            TextButton(
              onPressed: () => _selectDate(context, controller),
              child: const Icon(Icons.calendar_today),
            ),
          ],
        )
            : title == 'Password'
            ? TextFormField(
          controller: passwordController, // Use passwordController here
          style: const TextStyle(fontSize: 14),
          obscureText: !isPasswordVisible,
        )
            : TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  //Methods
  //Initializing controllers
  void initializeControllers() {
    addressController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    designationController = TextEditingController();
    joiningDateController = TextEditingController();
    passwordController = TextEditingController();
  }

  //format date
  String _formatDate(String date) {
    if (date.isNotEmpty) {
      // Parse the joining date into a DateTime object
      DateTime parsedDate = DateTime.parse(date);

      // Format the parsed date using DateFormat from intl package
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } else {
      return '';
    }
  }

  //selecting date
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime currentDate = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: currentDate,
    );

    if (pickedDate != null && pickedDate != currentDate) {
      String formattedDate =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      controller.text = formattedDate;
    }
  }

  //fetching user data
  Future<void> fetchData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      employeeId = prefs.getString('E_id')!;
      DeviceInfo deviceInfo = DeviceInfo();
      serialNumber = await deviceInfo.fetchDeviceSerialNumber(context);
      final response = await http.get(
          Uri.parse('${Conn.baseUrl}getUserData.jsp?empid=$employeeId&devId=$serialNumber'));

      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(response.body);
          initializeControllers();
          setAddressController();
          setEmailController();
          setPhoneController();
          setDesignationController();
          setJoiningDateController();
          setPasswordController();
        });
      }else if(response.statusCode == 403){
        logger.severe('Error/profilePage/fetchData()/: unauthorized access ($serialNumber)');
      }else if(response.statusCode == 400){
        logger.severe('Error/profilePage/fetchData()/: unsanitized input parameters');
      }
      else {
        handleProfilePageError(
            'Failed to fetch user details. Check your connectivity and try again!',
            'Error/profilePage/fetchData()/: failed to fetch user data: ${response.body}');
      }
    } catch (e) {
      handleProfilePageError('Something went wrong. Please try again',
          'Error/profilePage/fetchData()/: $e');
    }
  }

  //Setting fetched data to the controllers
  void setAddressController() {
    addressController.text = userData['address'] ?? '';
  }

  void setEmailController() {
    emailController.text = userData['email'] ?? '';
  }

  void setPhoneController() {
    phoneController.text = userData['phone'] ?? '';
  }

  void setDesignationController() {
    designationController.text = userData['designation'] ?? '';
  }

  void setJoiningDateController() {
    String joiningDate = userData['joiningDate'] ?? '';
    if (joiningDate.isNotEmpty) {
      DateTime parsedJoiningDate = DateTime.parse(joiningDate);
      String formattedDate = DateFormat('dd-MM-yyyy').format(parsedJoiningDate);

      joiningDateController.text = formattedDate;
    } else {
      joiningDateController.text = '';
    }
  }

  void setPasswordController() {
    passwordController.text = userData['password'] ?? '';
  }


  //save button function
  Future<void> saveChanges() async {
    if (_validateFields()) {
      updateUserData();
      toggleEditing();
    }
  }

  //calling validations
  bool _validateFields() {
    if (_validateField(addressController, 'Address') &&
        _validateField(emailController, 'Email') &&
        _validateField(phoneController, 'Phone') &&
        _validateField(designationController, 'Designation') &&
        _validateField(joiningDateController, 'Joining Date') &&
        _validateField(passwordController, 'Password')) {
      return true;
    } else {
      return false;
    }
  }

  //Validation
  bool _validateField(TextEditingController controller, String fieldName) {
    String value = controller.text.trim();
    if (value.isEmpty) {
      _showValidationError('$fieldName is required');
      return false;
    }

    if (fieldName == 'Phone' && !RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      _showValidationError('Invalid phone number! Should contain 10 digits');
      return false;
    }

    if (fieldName == 'Email' &&
        !RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
      _showValidationError('Invalid email address');
      return false;
    }

    return true;
  }

  //update user data
  Future<void> updateUserData() async {
    String apiUrl = 'updateUserData.jsp?devId=$serialNumber';
    Map<String, String> requestBody = {
      'address': addressController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'designation': designationController.text,
      'joiningDate': joiningDateController.text,
      'password': passwordController.text,
      'employeeId': employeeId,
    };

    try {
      final response = await http.post(
        Uri.parse(Conn.baseUrl + apiUrl),
        body: requestBody,
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = {
            ...userData,
            'address': addressController.text,
            'email': emailController.text,
            'phone': phoneController.text,
            'designation': designationController.text,
            'joiningDate': joiningDateController.text,
            'password': passwordController.text,
          };
        });
      }else if(response.statusCode == 403){
        handleProfilePageError(
            'Unauthorized access!',
            'Error/profilePage/updateUserData()/:unauthorized access ($serialNumber)');
      }else if(response.statusCode == 400){
        handleProfilePageError(
            'Invalid inputs!',
            'Error/profilePage/updateUserData()/: unsanitized input parameters');
      }
      else {
        handleProfilePageError(
            'Failed to update user details.!',
            'Error/profilePage/updateUserData()/: failed to update user data: ${response.body}');
      }
    } catch (error) {
      handleProfilePageError('Something went wrong. Please check your connectivity and try again',
          'Error/profilePage/updateUserData()/: $error');
    }
  }

  //changing the state of isEditing variable
  void toggleEditing() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  //validation error notifications
  void _showValidationError(String message) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      text: message,
    );
  }

  //handling error
  void handleProfilePageError(String errorMessage, String log) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...!',
      text: errorMessage,
    );
    logger.severe(log);
  }

  //logout function
  Future<void> handleLogout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('E_id');
    await prefs.remove('E_name');
    Provider.of<Cart>(context, listen: false).clearCart();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}

class DetailTile extends StatelessWidget {
  final String title;
  final String value;

  const DetailTile({Key? key, required this.title, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class PasswordTile extends StatelessWidget {
  final String title;
  final String value;
  final bool isPasswordVisible;
  final VoidCallback togglePasswordVisibility;

  const PasswordTile({Key? key, required this.title, required this.value, required this.isPasswordVisible, required this.togglePasswordVisibility})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  isPasswordVisible ? value : '********',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: togglePasswordVisibility,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
