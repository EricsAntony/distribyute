import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../components/shoe_tile.dart';
import '../main.dart';
import '../models/cart.dart';
import '../models/shoe.dart';
import 'connection.dart';
import 'cart_page.dart';
import 'connectivity.dart';
import 'deviceInfo.dart';
import 'home_page.dart';

class ShopPage extends StatefulWidget {
  final String shopId;
  final String shopName;

  const ShopPage({Key? key,required this.shopId,required this.shopName}) : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  late List<Shoe> shoeList = [];
  late List<Shoe> filteredShoeList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.indigoAccent[700]!, Colors.indigo],
            ),
          ),
          child: AppBar(
            title: Stack(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Center(
                        child: Text(
                          'Select Items',
                          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 5,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartPage(shopId: widget.shopId, shopName: widget.shopName),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 40,
                      child: Stack(
                        children: [
                          const Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                          ),
                          Positioned(
                            left: 15,
                            top: 5,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                Provider.of<Cart>(context).getTotalCartItems().toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            //centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(15),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          ConnectivityStatusWidget(
            onConnectionRestored: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: TextField(
                onChanged: (query) => filterShoes(query),
                decoration: InputDecoration(
                  hintText: 'Search...',
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
                  suffixIcon: const Icon(Icons.search),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredShoeList.length,
              itemBuilder: (context, index) {
                final shoe = filteredShoeList[index];
                return Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  height: 155,
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
                  child: ShoeTile(
                    shoe: shoe,
                    onAddToCart: (shoe, quantity) => addShoeToCart(shoe, quantity),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //Methods
  //fetch products to display
  Future<void> fetchData() async {
    try {
      DeviceInfo deviceInfo = DeviceInfo();
      String serialNumber = await deviceInfo.fetchDeviceSerialNumber(context);
      final response = await http.get(Uri.parse('${Conn.baseUrl}allProducts.jsp?devId=$serialNumber'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if(mounted) {
          setState(() {
            shoeList = data.map((item) => Shoe.fromJson(item)).toList();
            filteredShoeList = List.from(shoeList);
          });
        }
      }else if(response.statusCode == 403){
        handleShopPageError('Unauthorized access','Error/shop_page/fetchData()/:unauthorized access: $serialNumber');
      }else if(response.statusCode == 400){
        handleShopPageError('Invalid inputs!','Error/shop_page/fetchData()/: Unsanitized input parameters');
      }
      else {
        handleShopPageError('Failed to load products. Check your connectivity and try again!','Error/shop_page/fetchData()/: failed to fetch all products: ${response.body}');
      }
    } catch (e) {
      handleShopPageError('Something went wrong. Check your connectivity and try again!','Error/shop_page/fetchData()/: $e');

    }
  }

  //add to cart function
  void addShoeToCart(Shoe shoe, int quantity) {
    Provider.of<Cart>(context, listen: false).addItemToCart(shoe, quantity, context);
  }

  //for searchbar
  void filterShoes(String query) {
    setState(() {
      filteredShoeList = shoeList
          .where((shoe) => shoe.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  //Error handling
  void handleShopPageError(String errorMessage, String log) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...!',
      text: errorMessage,
    );
    logger.severe(log);
  }
}
