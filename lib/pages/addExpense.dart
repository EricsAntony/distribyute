import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:open_file/open_file.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'connection.dart';
import 'connectivity.dart';
import 'deviceInfo.dart';
import 'expenseHistory.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;


class AddExpensePage extends StatefulWidget {
  final VoidCallback refreshData;

  const AddExpensePage({Key? key, required this.refreshData}) : super(key: key);

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  TextEditingController typeController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  final TextEditingController _fileController = TextEditingController();
  String? _fileName;
  String _selectedFilePath = '';
  List<String> _fileNames = [];
  List<String> _filePaths = [];


  List<String> expenseTypes = ['Travel', 'Food', 'miscellaneous'];
  late String serialNumber;
  final GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fileName = 'No file selected';
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
            'Add Expense',
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConnectivityStatusWidget(
                onConnectionRestored: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ExpenseHistoryPage()),
                  );
                },
              ),
              const SizedBox(height: 20,),
              _buildDropdownField(typeController, 'Expense Type', expenseTypes),
              _buildTextField(amountController, 'Amount', TextInputType.number),
              _buildDateField(context, dateController, 'Date'),
              _buildRemarksField(remarksController, 'Remarks (optional)', TextInputType.multiline),
              buildUploadButton(context),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
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
            onPressed: () {
              if(_validateForm()) {
                addExpense(context);
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
    );
  }

  Widget _buildDropdownField(
      TextEditingController controller, String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: DropdownButtonFormField(
        value: controller.text.isNotEmpty ? controller.text : null,
        onChanged: (newValue) {
          setState(() {
            controller.text = newValue.toString();
          });
        },
        items: options.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(type),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.indigoAccent[700]!, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(
      BuildContext context, TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: () async {
          final DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2015, 8),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            setState(() {
              controller.text = pickedDate.toString().split(' ')[0];
            });
          }
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              labelText: label,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.indigoAccent[700]!, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, TextInputType? keyboardType) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
         labelText: label,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.indigoAccent[700]!, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildRemarksField(
      TextEditingController controller, String label, TextInputType? keyboardType) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.indigoAccent[700]!, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        maxLines: 3,

      ),
    );
  }

  Widget buildUploadButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: _pickAndSetFile,
            icon: const Icon(Icons.upload),
            label: const Text('Upload Bill'),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: _fileNames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_fileNames[index], style: TextStyle(color: Colors.grey[700]),),
                  trailing: IconButton(
                    icon: const Icon(Icons.highlight_remove, color: Colors.red,),
                    onPressed: () {
                      setState(() {
                        _fileNames.removeAt(index);
                        _filePaths.removeAt(index);
                      });
                    },
                  ),
                  onTap: () => OpenFile.open(_filePaths[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _pickAndSetFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true, // Enable multiple file selection
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'], // Allowed file types
    );
    if (result != null) {
      List<File> validFiles = [];
      result.files.forEach((file) {
        String extension = path.extension(file.name).toLowerCase();
        if (['.pdf', '.jpg', '.jpeg', '.png'].contains(extension)) {
          setState(() {
            _fileNames.add(file.name);
            _filePaths.add(file.path!);
            validFiles.add(File(file.path!));
          });

        } else {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Invalid file format',
            text: 'Only PDF, JPG, JPEG, and PNG files are allowed.',
          );
        }
      });
    }
  }



  //Methods
  //Form submission

  Future<void> addExpense(BuildContext context) async {
    try {
      String base64Files = '';
      String delimiter = '###END_OF_FILE###';

      DeviceInfo deviceInfo = DeviceInfo();
      serialNumber = await deviceInfo.fetchDeviceSerialNumber(context);

      if (typeController.text.isNotEmpty &&
          amountController.text.isNotEmpty &&
          dateController.text.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? employeeId = prefs.getString('E_id');

        String fileNamesCombined = '';
        for (int i = 0; i < _fileNames.length; i++) {
          String fileName = _fileNames[i];
          String fileExtension = fileName.split('.').last; // Get file extension
          fileNamesCombined += '${DateTime.now().millisecondsSinceEpoch}_${i+1}.$fileExtension'; // Append extension to file name
          if (i != _fileNames.length - 1) {
            fileNamesCombined += ',';
          }
        }

        for (String filePath in _filePaths) {
          List<int> fileBytes = await File(filePath).readAsBytes();
          base64Files += base64Encode(fileBytes) + delimiter;
        }
        print(base64Files);
        print(fileNamesCombined);

        // Construct the JSON payload
        Map<String, dynamic> payload = {
          'devId': serialNumber,
          'type': typeController.text,
          'amount': amountController.text,
          'employeeId': employeeId,
          'remarks': remarksController.text,
          'date': dateController.text,
          'files': base64Files,
          'fileName': fileNamesCombined,
        };

        String jsonPayload = jsonEncode(payload);

        var response = await http.post(
          Uri.parse("${Conn.baseUrl}addExpense.jsp"),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonPayload,
        );
        print(response.body);
        if (response.body.trim() == 'success') {
          // Handle success response
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: 'Expenses added successfully!',
            confirmBtnText: 'Ok',
            confirmBtnColor: Colors.green,
            onConfirmBtnTap: () => {
              typeController.clear(),
              amountController.clear(),
              remarksController.clear(),
              dateController.clear(),
              widget.refreshData(),
              Navigator.of(context).pop(),
              Navigator.of(context).pop(),
            },
          );
        } else {
          handleAddExpensePageError(
              'Failed to add expense',
              'Error/addExpense/addExpense()/: ${response.body.trim()}');
        }
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'Expense type, amount, and date fields are required!',
        );
      }
    } catch (e) {
      handleAddExpensePageError(
          'Something went wrong!', 'Error/addExpense/addExpense()/: $e');
      print(e);
    }
  }




  //Validation

  bool _validateForm() {
    if (typeController.text.isEmpty ||
        amountController.text.isEmpty ||
        dateController.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'All fields are required except Remarks!',
      );
      return false;
    } else if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(amountController.text)) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Please enter a valid amount!',
      );
      return false;
    }
    return true;
  }

  //Error handling

  void handleAddExpensePageError(String errorMessage, String log) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...!',
      text: errorMessage,
    );
    logger.severe(log);
  }
}
