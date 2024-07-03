import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../main.dart';
import 'connection.dart';
import 'connectivity.dart';
import 'deviceInfo.dart';
import 'login_page.dart';

class RequestAccessPage extends StatefulWidget {
  const RequestAccessPage({Key? key}) : super(key: key);

  @override
  _RequestAccessPageState createState() => _RequestAccessPageState();
}

class _RequestAccessPageState extends State<RequestAccessPage> {
  bool _isAccessRequested = false; // Track if access is requested
  late String serialNumber;
  String? _generatedCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDeviceRequested(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConnectivityStatusWidget(
              onConnectionRestored: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const RequestAccessPage()),
                );
              },
            ),
            // Image and text
            Padding(
              padding: const EdgeInsets.all(20.0),

              child: Column(
                children: [
                  Image.asset(
                    'lib/images/requestAccess.webp',
                    width: 700,
                    height: 500,
                  ),
                  Text(
                    'OOPS...!',
                    style: TextStyle(color: Colors.grey[800], fontSize: 24),
                  ),
                  const SizedBox(height: 10,),
                  Text(
                    'You need authorization to access the app',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),

                  Text(
                    _isAccessRequested
                        ?  _generatedCode != null?'Code: $_generatedCode':''
                        : '',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[800],
                    ),
                  ),
                  if(_isAccessRequested)
                    IconButton(
                      onPressed: _reload,
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.indigoAccent[700],
                        size: 30,
                      ), // Icon for reload
                    ),
                ],
              ),
            ),

            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity, // Full width
                    decoration: BoxDecoration(
                      color: _isAccessRequested ? Colors.grey : null,
                      gradient: !_isAccessRequested ? LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Colors.indigoAccent[700]!, Colors.indigo],
                      ) : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton(
                      onPressed: _isAccessRequested
                          ? null
                          : () {
                        _requestAccess(context);
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
                      child: Text(
                        _isAccessRequested ? 'Requested' : 'Request Access',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Methods
  //checking whether the device is already requested
  Future<void> _checkDeviceRequested(BuildContext context) async {
    try {
      DeviceInfo deviceInfo = DeviceInfo();
      serialNumber = await deviceInfo.fetchDeviceSerialNumber(context);
      String url = "${Conn.baseUrl}checkDeviceRequested.jsp";
      var response = await http.post(
        Uri.parse(url),
        body: {
          'dev_num': serialNumber,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        String status = jsonResponse['status'];

        if (status == 'requested') {
          // Device is already requested
          setState(() {
            _isAccessRequested = true;
            _generatedCode = jsonResponse['dev_code'];
          });
        }
      }
      else {
        logger.severe('ERROR:/requestAccessPa/_checkDeviceRequested()/: ${response.statusCode}');
      }

    } catch (e) {
      logger.severe('ERROR:/requestAccessPa/_checkDeviceRequested()/: $e');
    }
  }


  //requesting access
  Future<void> _requestAccess(BuildContext context) async {
    try {
      _generatedCode = _generateRandomCode();
      setState(() {
        _generatedCode = _generatedCode;
      });

      String url = "${Conn.baseUrl}requestAuth.jsp";
      var response = await http.post(
        Uri.parse(url),
        body: {
          'dev_num': serialNumber,
          'code': _generatedCode!,
        },
      );

      if (response.body.trim() == 'success') {
        setState(() {
          _isAccessRequested = true;
        });
      } else {
        logger.severe('ERROR:/requestAccessPa/_requestAccess()/: ${response.body}');
      }
    } catch (e) {
      logger.severe('ERROR:/requestAccessPa/_requestAccess()/: $e');
    }
  }

  //reload button
  void _reload() {
    checkDeviceRegistration(context).then((result) {
      if (result) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: 'Oops...!',
          text: 'Access not yet granted. Try again after sometime.',
        );
      }
    });
  }

  //generating random code
  String _generateRandomCode() {
    Random random = Random();
    int min = 1000;
    int max = 9999;
    int code = min + random.nextInt(max - min);
    return code.toString();
  }

}
