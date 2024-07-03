import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'connectivity.dart';
import 'deviceInfo.dart';
import 'home_page.dart';
import 'connection.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  DeviceInfo deviceInfo = DeviceInfo();
  late String serialNumber;
  DateTime? _lastPressedTime;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        DateTime currentTime = DateTime.now();
        // Exit the app if the back button is pressed twice within 2 seconds
        if (_lastPressedTime == null || currentTime.difference(_lastPressedTime!) > const Duration(seconds: 2)) {
          _lastPressedTime = currentTime;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ConnectivityStatusWidget(
                  onConnectionRestored: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: Center(
                    child: Image.asset(
                      'lib/images/Mobile login.gif',
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Center(
                          child: Text(
                            "LET'S GO IN...!",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          'Sign in with your credentials',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30,),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Center(
                          child: SizedBox(
                            height: 70,
                            child: TextField(
                              keyboardType: TextInputType.emailAddress,
                              controller: usernameController,
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText: 'Username',
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
                                suffixIcon: const Icon(Icons.account_circle),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Center(
                          child: SizedBox(
                            height: 70,
                            child: TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: 'Password',
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
                                suffixIcon: const Icon(Icons.password_outlined),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                      onPressed: () {
                        loginUser(context);
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
                        'Sign In',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }


  //Methods
  //To check the login details and accept or decline login
  Future<void> loginUser(BuildContext context) async {
    try {
      serialNumber = await deviceInfo.fetchDeviceSerialNumber(context);

      if(usernameController.text != '' && passwordController.text != '') {
        final username = usernameController.text;
        final password = passwordController.text;

        String url = "${Conn.baseUrl}login.jsp?devId=$serialNumber";
        final response = await http.post(
          Uri.parse(url),
          body: {
            'username': username,
            'password': password,
          },
        );
        final List<String> parts = response.body.trim().split(',');

        if (parts[0] == 'success') {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLoggedIn', true);
          prefs.setString('E_id', parts[1]);
          prefs.setString('E_name', parts[2]);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else if (response.statusCode == 403) {
          handleLoginError('Unauthorized access',
              'Error/loginPage/loginUser()/: Unauthorized access ($serialNumber)');
        } else if (response.statusCode == 400) {
          handleLoginError('Invalid input',
              'Error/loginPage/loginUser()/:Unsantitized input parameters');
        } else {
          handleLoginError('Login failed. Check your login credentials!',
              'Error/loginPage/loginUser()/: Failed to login: ${response.body
                  .trim()} UN: ${usernameController
                  .text}, PW: ${passwordController.text}');
        }
      }
      else{
        handleLoginError('Enter credentials', 'Error/loginPage/loginUser()/');

      }
    } catch (e) {
      handleLoginError('Something went wrong!', 'Error/loginPage/loginUser()/: $e');
    }
  }

  //Error handling
  void handleLoginError(String errorMessage, String log) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...!',
      text: errorMessage,
    );
    logger.severe(log);
  }
}
