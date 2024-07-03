import 'package:distribution/pages/sales_return.dart';
import 'package:distribution/pages/shop_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'dart:convert';
import '../components/shoe_tile.dart';
import '../main.dart';
import 'add_collection.dart';
import 'connection.dart';
import 'connectivity.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'deviceInfo.dart';

class ViewShop extends StatefulWidget {
  const ViewShop({Key? key}) : super(key: key);

  @override
  _ViewShopState createState() => _ViewShopState();
}

class _ViewShopState extends State<ViewShop> {
  late List<Map<String, String?>> originalShops;
  late List<Map<String, String?>> displayedShops;
  final TextEditingController searchController = TextEditingController();
  late bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

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
          title: const Text(
            'Store List',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      body: isLoading?Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitDoubleBounce(
                    color: Colors.indigoAccent[700],
                    size: 100.0,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Please wait...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ):
             ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                ),
                child: Column(
                  children: [
                    ConnectivityStatusWidget(
                      onConnectionRestored: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const ViewShop()),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 400,
                        height: 55,
                        child: TextField(
                          controller: searchController,
                          onChanged: (query) => search(query),
                          decoration: InputDecoration(
                            hintText: 'Search by name, address, email, phone...',
                            filled: true,
                            fillColor: Colors.grey[50],
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.grey),
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
                      child: ListView.builder(
                        itemCount: displayedShops.length,
                        itemBuilder: (context, index) {
                          return ShopTile(shop: displayedShops[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
             )
    );
  }

  //Methods
  //Fetch all shops
  Future<void> fetchData() async {
    try {
      DeviceInfo deviceInfo = DeviceInfo();
      String serialNumber = await deviceInfo.fetchDeviceSerialNumber(context);
      final response = await http.get(Uri.parse('${Conn.baseUrl}viewShop.jsp?devId=$serialNumber'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);

        setState(() {
          originalShops = List<Map<String, String?>>.from(jsonResponse.map((dynamic shop) {
            return {
              'shopId' : shop['shopId'].toString(),
              'shopName': shop['shopName'].toString(),
              'address': shop['address'].toString(),
              'contactNumber': shop['contactNumber'].toString(),
              'shopEmail': shop['shopEmail'].toString(),
              'shopState': shop['shopState'].toString(),
              'shopGst': shop['shopGst'].toString(),
            };
          }));
          displayedShops = List<Map<String, String>>.from(originalShops);
          isLoading = false;
        });
      }else if(response.statusCode == 403){
        displayedShops = [];
        handleFetchError('Unauthorized access!','Error/viewShopsPa/fetchData()/: Unauthorized access ($serialNumber)');
        setState(() {
          isLoading = false;
        });
      }else if(response.statusCode == 400){
        displayedShops = [];
        handleFetchError('Invalid input data!','Error/viewShopsPa/fetchData()/: Unsantized input data');
        setState(() {
          isLoading = false;
        });
      }
      else {
        displayedShops = [];
        handleFetchError('Failed to load data. Please try again!', 'Failed to load data from db: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      displayedShops = [];
      handleFetchError('Something went wrong!','Error/viewShopsPa/fetchData()/: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  //for searchbar
  void search(String query) {
    setState(() {
      displayedShops = originalShops
          .where((shop) =>
      shop['shopName']!.toLowerCase().contains(query.toLowerCase()) ||
          shop['address']!.toLowerCase().contains(query.toLowerCase()) ||
          shop['contactNumber']!.contains(query))
          .toList();
    });
  }

  //Error handling
  void handleFetchError(String errorMessage, String log) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...!',
      text: errorMessage,
    );
    logger.severe(log);
  }
}


class ShopTile extends StatefulWidget {
  final Map<String, String?> shop;

  const ShopTile({super.key, required this.shop});

  @override
  State<ShopTile> createState() => _ShopTileState();
}

class _ShopTileState extends State<ShopTile> {
  double _dragStartPosition = 0.0;
  double _currentPosition = 0.0;

  @override
  Widget build(BuildContext context) {
    String firstLetter = widget.shop['shopName']!.substring(0, 1).toUpperCase();
    Color iconColor = Colors.primaries[widget.shop['shopName']!.hashCode %
        Colors.primaries.length];

    // Define the action text
    String actionText = _currentPosition < 0
        ? 'Sales Return'
        : 'Add Collection';

    return Stack(
      children: [
        // Add Collection Hint
        if (_currentPosition > 0)
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: MediaQuery.of(context).size.width / 2,
            child: Container(
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.5),
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
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Add Collection',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Add Sales Return Hint
        if (_currentPosition < 0)
          Positioned(
            top: 0,
            bottom: 0,
            left: MediaQuery.of(context).size.width / 2,
            right: 0,
            child: Container(
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.5),
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
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Sales Return',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.refresh, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),

        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ShopPage(
                      shopId: widget.shop['shopId']!,
                      shopName: widget.shop['shopName']!,
                    ),
              ),
            );
          },
          onHorizontalDragStart: (details) {
            _dragStartPosition = details.localPosition.dx;
          },
          onHorizontalDragUpdate: (details) {
            double newPosition = _currentPosition +
                details.localPosition.dx -
                _dragStartPosition;
            setState(() {
              _currentPosition = newPosition;
            });
          },
          onHorizontalDragEnd: (details) {
            if (_currentPosition.abs() >
                MediaQuery
                    .of(context)
                    .size
                    .width / 2) {
              if (_currentPosition < 0) {
                // Swiped from right to left
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddSalesReturnPage(
                          shopId: widget.shop['shopId'],
                          shopName: widget.shop['shopName'],
                        ),
                  ),
                );
              } else {
                // Swiped from left to right
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddCollectionPage(
                          shopId: widget.shop['shopId'],
                          shopName: widget.shop['shopName'],
                        ),
                  ),
                );
              }
              setState(() {
                _currentPosition = 0.0;
              });
            } else {
              _animateBackToOriginalPosition();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.translationValues(_currentPosition, 0, 0),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                SizedBox(
                  height: MediaQuery.of(context).size.width / 2.2, // Set the height dynamically
                  child: Container(
                    width: 40,
                    decoration: BoxDecoration(
                      color: iconColor,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        firstLetter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.shop['shopName'] != null)
                        Text(
                          widget.shop['shopName']!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (widget.shop['address'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.shop['address']!,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                      if (widget.shop['shopState'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.shop['shopState']!,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                      if (widget.shop['shopEmail'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.shop['shopEmail']!,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                      if (widget.shop['shopGst'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'GSTIN: ${widget.shop['shopGst']}',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                      if (widget.shop['contactNumber'] != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.shop['contactNumber']!,
                              style: const TextStyle(fontSize: 15),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    makePhoneCall(
                                        widget.shop['contactNumber']!);
                                  },
                                  icon: const Icon(Icons.phone),
                                  color: Colors.green,
                                ),
                                IconButton(
                                  onPressed: () {
                                    sendMessage(widget.shop['contactNumber']!);
                                  },
                                  icon: const Icon(Icons.message),
                                  color: Colors.blue,
                                ),
                                IconButton(
                                  onPressed: () {
                                    sendWhatsAppMessage(
                                        widget.shop['contactNumber']!);
                                  },
                                  icon: Image.asset(
                                      'lib/images/whatapp.webp', width: 24,
                                      height: 24),
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  void _animateBackToOriginalPosition() {
    setState(() {
      _currentPosition = 0.0;
    });
  }


  //Methods
  void makePhoneCall(String phoneNumber) async {
    try {
      Uri phoneCallUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneCallUri)) {
        await launchUrl(phoneCallUri);
      } else {
        logger.severe(
            'Error/viewShopsPa/makePhoneCall()/: Could not launch phone app');
      }
    } catch (e) {
      logger.severe('Error/viewShopsPa/makePhoneCall()/: $e');
    }
  }

  //function to open message app
  void sendMessage(String phoneNumber) async {
    try {
      String messageUrl = 'sms:$phoneNumber';
      if (await canLaunchUrl(Uri.parse(messageUrl))) {
        await launchUrl(Uri.parse(messageUrl));
      } else {
        logger.severe(
            'Error/viewShopsPa/sendMessage()/: Could not launch message app');
      }
    } catch (e) {
      logger.severe('Error/viewShopsPa/sendMessage()/: $e');
    }
  }

  //function to open whatsapp
  void sendWhatsAppMessage(String phoneNumber) async {
    try {
      String whatsappUrl = 'whatsapp://send?phone=$phoneNumber';
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        logger.severe(
            'Error/viewShopsPa/sendWhatsAppMessage()/: Could not launch WhatsApp app');
      }
    } catch (e) {
      logger.severe('Error/viewShopsPa/sendWhatsAppMessage()/: $e');
    }
  }
}