import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'connection.dart';
import 'connectivity.dart';
import 'deviceInfo.dart';


class AddSalesReturnPage extends StatefulWidget {
  final String? shopId;
  final String? shopName;

  const AddSalesReturnPage({
    Key? key,
    this.shopId,
    this.shopName,
  }) : super(key: key);

  @override
  _AddSalesReturnPageState createState() => _AddSalesReturnPageState();
}

class _AddSalesReturnPageState extends State<AddSalesReturnPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController secondPaneQuantityController = TextEditingController();
  final TextEditingController _billController = TextEditingController();
  final TextEditingController _shopController = TextEditingController();
  final TextEditingController _shopControllerForSecondPane = TextEditingController();
  final TextEditingController _productControllerForSecondPane = TextEditingController();
  final TextEditingController priceControllerForSecondPane = TextEditingController();
  final TextEditingController taxControllerForSecondPane = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<AutoCompleteTextFieldState<String>> _autoCompleteKey =
  GlobalKey<AutoCompleteTextFieldState<String>>();
  final GlobalKey<AutoCompleteTextFieldState<String>> _autoCompleteBillKey =
  GlobalKey<AutoCompleteTextFieldState<String>>();
  final GlobalKey<
      AutoCompleteTextFieldState<String>> _autoCompleteKeyForSecondPane =
  GlobalKey<AutoCompleteTextFieldState<String>>();
  final GlobalKey<
      AutoCompleteTextFieldState<String>> _autoCompleteKeyForThirdPane =
  GlobalKey<AutoCompleteTextFieldState<String>>();
  final GlobalKey<
      AutoCompleteTextFieldState<String>> _autoCompleteKeyForProducts =
  GlobalKey<AutoCompleteTextFieldState<String>>();

  late String serialNumber;
  List<String> billIds = [];
  String? _selectedBillId;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> productsSecondPane = [];
  List<Map<String, dynamic>> returnedItems = [];
  Map<String, dynamic> _selectedShopDetails = {};
  Map<String, dynamic> _selectedShopDetailsForSecondPane = {};
  Map<String, dynamic> _selectedShopDetailsForThirdPane = {};
  List<Map<String, dynamic>> selectedProducts = [];
  String _selectedProductIdForSecondPane = '';
  String _selectedProductNameForSecondPane = '';
  List<Map<String, dynamic>> filteredItems = [];
  final Random random = Random();
  Color _randomColor() {
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }


  @override
  void initState() {
    super.initState();
    if (widget.shopId != null && widget.shopName != null) {

      _selectedShopDetails = {
        'id': widget.shopId,
        'name': widget.shopName,
      };
      _selectedShopDetailsForSecondPane = {
        'id': widget.shopId,
        'name': widget.shopName,
      };
      _selectedShopDetailsForThirdPane = {
        'id': widget.shopId,
        'name': widget.shopName,
      };
      _shopController.text = widget.shopName!;
      _shopControllerForSecondPane.text = widget.shopName!;
      prepareForReturn();
    }
    _tabController = TabController(
        length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
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
            'Return',
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
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                child: Text('With Bill',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              Tab(
                child: Text('Without Bill',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              Tab(
                child: Text('History',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
            indicatorColor: Colors.white,
          ),

        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
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

          _buildSecondPaneTab(),
          _buildThirdPaneTab(), // Placeholder for the second tab
        ],
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
                MaterialPageRoute(builder: (context) => const AddSalesReturnPage()),
              );
            },
          ),
          const SizedBox(height: 20,),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 16.0, right: 16, left: 16,),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          _buildShopField(shopList),
                          const SizedBox(height: 8),
                          _buildBillField(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_selectedBillId != null) _buildProductTable(),
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
                    'Return',
                    style: TextStyle(
                        fontSize: 18, color: Colors.white), // White text
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
    return SizedBox(
      width: double.infinity, // Specify the desired width
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: AutoCompleteTextField<String>(
              key: _autoCompleteKey,
              clearOnSubmit: true,
              suggestions: shopList.map((shop) => shop['shopName'].toString())
                  .toList(),
              style: const TextStyle(color: Colors.black, fontSize: 16.0),
              decoration: InputDecoration(
                hintText: _selectedShopDetails['name'] ?? 'Shop',
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.indigo, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              controller: _shopController,
              itemFilter: (String item, String query) {
                return item.toLowerCase().contains(query.toLowerCase());
              },
              itemSorter: (String a, String b) {
                return a.compareTo(b);
              },
              itemSubmitted: (String item) async {
                final selectedShop = shopList.firstWhere(
                      (shop) =>
                  shop['shopName'].toString().toLowerCase() ==
                      item.toLowerCase(),
                  orElse: () => {'shopId': '', 'shopName': ''},
                );

                setState(() {
                  _selectedShopDetails = {
                    'id': selectedShop['shopId'],
                    'name': selectedShop['shopName'],
                  };
                  _shopController.text = _selectedShopDetails['name'];
                  products.clear();
                  _selectedBillId = null;
                  _billController.clear();
                });
                billIds = await _fetchBills(selectedShop['shopId']);
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
      ),
    );
  }

  Widget _buildBillField() {
    return SizedBox(
      width: double.infinity, // Specify the desired width
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (billIds.isNotEmpty)
            AutoCompleteTextField<String>(
              key: _autoCompleteBillKey,
              clearOnSubmit: true,
              suggestions: billIds,
              style: const TextStyle(color: Colors.black, fontSize: 16.0),
              decoration: InputDecoration(
                hintText: _selectedBillId ?? 'Bill id',
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.indigo, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              controller: _billController,
              itemFilter: (String item, String query) {
                return item.toLowerCase().contains(query.toLowerCase());
              },
              itemSorter: (String a, String b) {
                return a.compareTo(b);
              },
              itemSubmitted: (String item) async {
                setState(() {
                  _selectedBillId = item;
                  _billController.text = item;
                });
                await _fetchProductsForBill(item);
              },
              itemBuilder: (BuildContext context, String item) {
                return ListTile(
                  title: Text(item),
                );
              },
            ),
          if (billIds.isEmpty && _selectedShopDetails.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Text(
                  'No bills found for the selected shop...!',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildProductTable() {
    if (_selectedBillId != null && products.isNotEmpty) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Products to return',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> product = products[index];
                TextEditingController quantityController = TextEditingController();
                quantityController.text = product['controller'].text;
                return Material(
                  borderRadius: BorderRadius.circular(12),
                  elevation: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 0),
                        ),
                      ],
                      color: Colors.white,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                          child: Container(
                            width: 8,
                            height: 160,
                            decoration: BoxDecoration(
                              color: _randomColor(),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(
                              product['p_name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Rs: ${calculatePrice(double.parse(product['bill_rate']), double.parse(product['bill_tax']))}/- (incl.gst)',
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle, size: 30,),
                                            onPressed: () {
                                              setState(() {
                                                products.removeAt(index);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 110,
                                      child: TextField(
                                        controller: quantityController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'Qty to return ',
                                        ),
                                        enableInteractiveSelection: false,
                                        onChanged: (value) {
                                          product['controller'].text = value;
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${product['bill_qty']} Nos',
                                        style: TextStyle(
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }


  //For second tab
  Widget _buildSecondPaneTab() {
    try {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchShops(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Other widgets in your UI
                        _buildShopFieldForSecondPane(snapshot.data!),
                        if(selectedProducts.isNotEmpty)
                          _buildSelectedProducts(),
                        // Display the selected products
                      ],
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
                        if (selectedProducts.isNotEmpty) {
                          _addReturnNoBill();
                        }
                        else {
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.warning,
                            title: 'Select item',
                            text: 'Select atleast one item to return',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12.0), // Rounded edges
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Return',
                          style: TextStyle(
                              fontSize: 18, color: Colors.white), // White text
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      );
    } catch (e) {
      return Container();
    }
  }

  Widget _buildShopFieldForSecondPane(List<Map<String, dynamic>> shopList) {
    try {
      return SizedBox(
        width: 500, // Specify the desired width
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: AutoCompleteTextField<String>(
                key: _autoCompleteKeyForSecondPane,
                clearOnSubmit: true,
                suggestions: shopList.map((shop) => shop['shopName'].toString())
                    .toList(),
                style: const TextStyle(color: Colors.black, fontSize: 16.0),
                decoration: InputDecoration(
                  hintText: _selectedShopDetailsForSecondPane != null
                      ? _selectedShopDetailsForSecondPane['name'] ?? 'Shop'
                      : 'Shop',
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Colors.indigo, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // controller: _shopControllerForSecondPane,
                itemFilter: (String item, String query) {
                  return item.toLowerCase().contains(query.toLowerCase());
                },
                itemSorter: (String a, String b) {
                  return a.compareTo(b);
                },
                itemSubmitted: (String item) async {
                  final selectedShop = shopList.firstWhere(
                        (shop) =>
                    shop['shopName'].toString().toLowerCase() ==
                        item.toLowerCase(),
                    orElse: () => {'shopId': '', 'shopName': ''},
                  );

                  setState(() {
                    _selectedShopDetailsForSecondPane = {
                      'id': selectedShop['shopId'],
                      'name': selectedShop['shopName'],
                    };
                    _shopControllerForSecondPane.text =
                    _selectedShopDetailsForSecondPane['name'];
                  });

                  productsSecondPane = await fetchProducts();
                  // Perform any additional actions upon selecting a shop
                },
                itemBuilder: (BuildContext context, String item) {
                  return ListTile(
                    title: Text(item),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            _buildProductSelectionRow(productsSecondPane),
          ],
        ),
      );
    }
    catch (e) {
      return Container();
    }
  }

  Widget _buildProductSelectionRow(List<Map<String, dynamic>> productList) {
    List<String> productNames = [];
    List<String> productIds = [];

    for (var product in productList) {
      productNames.add(product['name']);
      productIds.add(product['id']);
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AutoCompleteTextField<String>(
                  key: _autoCompleteKeyForProducts,
                  clearOnSubmit: true,
                  suggestions: productNames,
                  style: const TextStyle(color: Colors.black, fontSize: 16.0),
                  decoration: InputDecoration(
                    hintText: _selectedProductNameForSecondPane != ''
                        ? _selectedProductNameForSecondPane
                        : 'Product',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.indigo, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  itemFilter: (String item, String query) {
                    return item.toLowerCase().contains(query.toLowerCase());
                  },
                  itemSorter: (String a, String b) {
                    return a.compareTo(b);
                  },
                  controller: _productControllerForSecondPane,
                  itemSubmitted: (String item) {
                    int index = productNames.indexOf(item);
                    if (index != -1) {
                      setState(() {
                        _selectedProductIdForSecondPane = productIds[index];
                        _selectedProductNameForSecondPane = item;
                        _productControllerForSecondPane.text = item;
                      });
                    }
                  },
                  itemBuilder: (BuildContext context, String item) {
                    return ListTile(
                      title: Text(item),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: const Key('quantity_input'),
                  controller: secondPaneQuantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Quantity',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.indigo, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  key: const Key('price_input'),
                  controller: priceControllerForSecondPane,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Price',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.indigo, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  key: const Key('tax_input'),
                  controller: taxControllerForSecondPane,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Tax',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.indigo, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () {
                    _addProductToSelectedList(productNames, productIds);
                  },
                  icon: Icon(
                    Icons.add_circle,
                    color: Colors.indigoAccent[700],
                    size: 35,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedProducts() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
            child: Text(
              'Products to return',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: selectedProducts.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> product = selectedProducts[index];
              Color tileColor = _randomColor();
              return Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 12, right: 12),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 80,
                          decoration: BoxDecoration(
                            color: tileColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${product['productName']}',
                                softWrap: true,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Returned price: Rs.${product['rate']}/-',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Tax: ${product['tax']}%',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Qty: ${product['quantity']} Nos',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Handle remove item action
                            setState(() {
                              selectedProducts.removeAt(index);
                            });
                          },
                          child: Icon(
                            Icons.remove_circle,
                            color: Colors.grey[800],
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  //For third tab
  Widget _buildThirdPaneTab() {
    try {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchShops(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildShopFieldForThirdPane(snapshot.data!),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      );
    } catch (e) {
      return Container();
    }
  }

  Widget _buildShopFieldForThirdPane(List<Map<String, dynamic>> shopList) {
    try {
      return SizedBox(
        width: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: AutoCompleteTextField<String>(
                key: _autoCompleteKeyForThirdPane,
                clearOnSubmit: true,
                suggestions: shopList.map((shop) => shop['shopName'].toString()).toList(),
                style: const TextStyle(color: Colors.black, fontSize: 16.0),
                decoration: InputDecoration(
                  hintText: _selectedShopDetailsForThirdPane != null ? _selectedShopDetailsForThirdPane['name'] ?? 'Shop' : 'Shop',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.indigo, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                itemFilter: (String item, String query) {
                  return item.toLowerCase().contains(query.toLowerCase());
                },
                itemSorter: (String a, String b) {
                  return a.compareTo(b);
                },
                itemSubmitted: (String item) async {
                  final selectedShop = shopList.firstWhere(
                        (shop) => shop['shopName'].toString().toLowerCase() == item.toLowerCase(),
                    orElse: () => {'shopId': '', 'shopName': ''},
                  );

                  setState(() {
                    _selectedShopDetailsForThirdPane = {
                      'id': selectedShop['shopId'],
                      'name': selectedShop['shopName'],
                    };
                  });

                  returnedItems = await _fetchReturn();
                  filteredItems = returnedItems;

                },
                itemBuilder: (BuildContext context, String item) {
                  return ListTile(
                    title: Text(item),
                  );
                },
              ),
            ),
            if (_selectedShopDetailsForThirdPane != null && returnedItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 47,
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by Bill ID',
                      filled: true,
                      fillColor: Colors.grey[50],
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.indigo, width: 2),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),

                      ),
                      suffixIcon: SizedBox(
                        width: 100,
                        height: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            search(searchController.text);
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.indigoAccent[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Text(
                            'Search',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
             _buildReturnedItems(filteredItems),
          ],
        ),
      );
    } catch (e) {
      return Container();
    }
  }

  Widget _buildReturnedItems(List<Map<String, dynamic>> returnedItems) {
    if (returnedItems.isEmpty) {
      return Center(
        child: Column(
          children: [
            Text(
              'No return history found...!',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    Map<String, List<Map<String, dynamic>>> groupedItems = {};
    for (var item in returnedItems) {
      String billId = item['billId'].toString();
      if (!groupedItems.containsKey(billId)) {
        groupedItems[billId] = [];
      }
      groupedItems[billId]!.add(item);
    }

    // Build list view with tiles
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedItems.length,
      itemBuilder: (context, index) {
        String billId = groupedItems.keys.elementAt(index);
        List<Map<String, dynamic>> items = groupedItems[billId]!;
        Color tileColor = _randomColor();

        // Calculate total amount for the bill
        double totalAmount = 0.0;
        items.forEach((item) {
          double returnedPrice = double.parse(item['rate']);
          double tax = double.parse(item['tax']);
          int quantityReturned = int.parse(item['quantityReturned']);
          totalAmount += (returnedPrice + (returnedPrice * tax / 100)) * quantityReturned;
        });

        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          child: ExpansionTile(
            leading: Container(
              width: 8,
              height: 40,
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            title: int.parse(billId) == 0
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Without bill',
                      style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                      ),
                    ),
                    Text(
                        'Rs.${totalAmount.toStringAsFixed(2)} (incl. tax)',
                        style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bill ID: $billId',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  'Rs.${totalAmount.toStringAsFixed(2)} (incl. tax)',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            children: items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15, bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['productName'],
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Returned price: Rs.${item['rate']}/-',
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tax: ${item['tax']}%',
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    subtitle: SizedBox(
                      width: 160,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Qty Returned: ${item['quantityReturned']} Nos',
                                style: TextStyle(
                                  color: Colors.green[700],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 22.0),
                              child: Text(
                                DateFormat('dd/MM/yyyy').format(DateTime.parse(item['date'])),
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }



  //METHODS
  // loading all the necessary data if the return page is loaded from viewshops page
  Future<void> prepareForReturn() async {
    billIds = await _fetchBills(widget.shopId!);
    productsSecondPane = await fetchProducts();
    returnedItems = await _fetchReturn();
    filteredItems = returnedItems;
  }

  //Methods for first pane
  //fetching shops
  Future<List<Map<String, dynamic>>> _fetchShops() async {
    try {
      DeviceInfo deviceInfo = DeviceInfo();
      serialNumber = await deviceInfo.fetchDeviceSerialNumber(context);
      final response = await http.get(
        Uri.parse('${Conn
            .baseUrl}fetchShopsTakeOrder.jsp?devId=$serialNumber'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);

        List<Map<String, dynamic>> fetchedShops = jsonResponse.map((
            dynamic shop) {
          return {
            'shopId': shop['shopId'],
            'shopName': shop['shopName'],
            'shopAddress': shop['shopAddress'],
            'shopPhone': shop['shopPhone'],
            'shopEmail': shop['shopEmail'],
          };
        }).toList();
        return fetchedShops;
      } else if (response.statusCode == 403) {
        handleAddCollectionPageError('Unauthorized access',
            'ERROR/addCollectionPa/_fetchshops()/: Unauthorized access ($serialNumber)');
        return [];
      } else if (response.statusCode == 400) {
        handleAddCollectionPageError('Invalid input!',
            'ERROR/addCollectionPa/_fetchshops()/:Unsanitized input parameters');
        return [];
      }
      else {
        logger.severe(
            'Error/addCollectionPa/_fetchshops()/:Failed to fetch shops. Status code: ${response
                .body.trim()}');
        return [];
      }
    } catch (error) {
      logger.severe(
          'Error/addCollectionPa/_fetchshops()/:Failed to fetch shops. Status code: $error');
      return [];
    }
  }

  //fetching bills for the selected shop
  Future<List<String>> _fetchBills(String shopId) async {
    try {
      final response = await http.get(
        Uri.parse('${Conn
            .baseUrl}fetchBills.jsp?shopId=$shopId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        // Extract bill IDs from the response
        List<String> billIds = jsonResponse.map((bill) =>
            bill['billId'].toString()).toList();

        return billIds;
      } else {
        logger.severe(
            'Error/_fetchBills(): Failed to fetch bills. Status code: ${response
                .statusCode}');
        return [];
      }
    } catch (error) {
      logger.severe('Error/_fetchBills(): Failed to fetch bills: $error');
      return [];
    }
  }

  //Fetching products billed in the selected bill
  Future<List<Map<String, dynamic>>> _fetchProductsForBill(
      String billId) async {
    try {
      setState(() {
        products
            .clear();
      });
      final response = await http.get(
        Uri.parse('${Conn
            .baseUrl}fetchBillProducts.jsp?billId=$_selectedBillId'),
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        jsonResponse.forEach((product) {
          TextEditingController controller = TextEditingController();
          Map<String, dynamic> productDetails = {
            'bill_qty': product['bill_qty'],
            'bill_rate': product['bill_rate'],
            'bill_tax': product['bill_tax'],
            'p_id': product['p_id'],
            'p_name': product['p_name'],
            'controller': controller,
          };
          products.add(productDetails);
        });

        return products;
      } else {
        logger.severe(
            'Error/_fetchProductsForBill(): Failed to fetch bill products. Status code: ${response
                .statusCode}');
        return [];
      }
    } catch (error) {
      logger.severe(
          'Error/_fetchProductsForBill(): Failed to fetch bill products: $error');
      return [];
    }
  }

  //Submit first pane(with bill)
  void _submitForm() async {
    try {
      List<Map<String, dynamic>> selectedProducts = [];
      var count = 0;
      var greaterQuantity = 0;

      products.forEach((product) {
        String quantity = (product['controller']?.text ?? '').trim();
        int quantityValue = quantity.isEmpty ? 0 : int.parse(quantity);
        if (quantityValue > int.parse(product['bill_qty'])) {
          greaterQuantity++;
        }
        if (quantity.isNotEmpty && double.parse(quantity) > 0) {
          selectedProducts.add({
            'p_id': product['p_id'],
            'qty': quantityValue.toString(),
            'bill_rate': product['bill_rate'],
            'bill_tax' : product['bill_tax'],
          });
        } else {
          count++;
        }
      });

      if (selectedProducts.isEmpty) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          title: 'Select item',
          text: 'Please enter quantity for at least one product.',
        );
        count = 0;
        return;
      }

      if (greaterQuantity > 0) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Invalid quantity', style: TextStyle(color: Colors.white,),),
              backgroundColor: Colors.indigoAccent[700],

              content: Text('You have ${greaterQuantity == 1
                  ? '$greaterQuantity item'
                  : '$greaterQuantity items'} where the return quantity is greater than billed quantity.',
                style: const TextStyle(color: Colors.white, fontSize: 16),),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                        false);
                  },
                  child: const Text(
                    'Ok', style: TextStyle(color: Colors.white, fontSize: 14),),
                ),
              ],
            );
          },
        );
        return;
      }

      if (count > 0) {
        bool? proceed = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Warning',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.indigoAccent[700],
              content: Text(
                'You have ${count == 1 ? '$count item' : '$count items'} where the quantity is not mentioned or is empty. Those items will not be saved. Do you want to continue?',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text(
                    'Continue',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            );
          },
        );

        if (proceed == null || !proceed) {
          return;
        }
      }

      // Calculate estimated total
      double estimatedTotal = 0;
      for (var product in products) {
        String priceString = calculatePrice(double.parse(product['bill_rate']),
            double.parse(product['bill_tax']));
        double price = double.parse(priceString);
        int quantity = int.tryParse(product['controller'].text) ??
            0;
        estimatedTotal += price * quantity;
      }

      // Show dialog with estimated total
      bool? confirmed = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Estimated Total',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Rs. ${estimatedTotal.toStringAsFixed(2)}/-\nPress continue to place return order?',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            backgroundColor: Colors.indigoAccent[700],
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          );
        },
      );

      if (confirmed == null || !confirmed) {
        return;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? employeeId = prefs.getString('E_id');
      String url = "${Conn.baseUrl}addSalesReturn.jsp?devId=$serialNumber";
      var response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          'billId': _selectedBillId,
          'shopId': _selectedShopDetails['id'],
          'employeeId': employeeId,
          'products': jsonEncode(selectedProducts),
          'total' : estimatedTotal,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.body.trim() == 'success') {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Success',
          text: 'Return order placed',
        );
        setState(() {
          _selectedBillId = null;
          _selectedShopDetails = {};
          products = [];
          billIds = [];
          _billController.clear();
          quantityController.clear();
        });
      } else if (response.statusCode == 403) {
        handleAddCollectionPageError('Unauthorized Access',
            'ERROR/salesReturnPa/_submitForm(): Unauthorized access $serialNumber');
      } else if (response.statusCode == 400) {
        handleAddCollectionPageError('Invalid input!',
            'ERROR/salesReturnPa/_submitForm(): Unsanitized input parameters ');
      }
      else {
        handleAddCollectionPageError('Failed to return products',
            'ERROR/salesReturnPa/_submitForm(): Failed to return details.');
      }
    } catch (error) {
      handleAddCollectionPageError('Failed to save details',
          'ERROR/salesReturnPa/_submitForm(): Failed to save details.  $error');
    }
  }

  //calculate the total price of returned items
  String calculatePrice(double billRate, double billTax) {
    double totalPrice = billRate + (billRate * billTax / 100);
    return totalPrice.toStringAsFixed(2);
  }


  //Methods for second pane
  //fetching products for second pane
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${Conn.baseUrl}allProducts.jsp?devId=$serialNumber'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);

        List<Map<String, dynamic>> products = jsonResponse.map((product) {
          return {
            'id': product['id'],
            'name': product['name'],
          };
        }).toList();
        return products;
      } else if (response.statusCode == 403) {
        handleAddCollectionPageError('Unauthorized access',
            'Error:/sales_returnPa/fetchProducts(). Unauthorized access $serialNumber');
        return [];
      }
      else if (response.statusCode == 400) {
        handleAddCollectionPageError('Invalid input',
            'Error:/sales_returnPa/fetchProducts(). Unsanitized input parameters');
        return [];
      }
      else {
        handleAddCollectionPageError('Failed to load products',
            'Error:/sales_returnPa/fetchProducts(). unable to load data: ${response
                .body.trim()}');
        return [];
      }
    } catch (error) {
      handleAddCollectionPageError('Something went wrong',
          'Error:/sales_returnPa/fetchProducts(). $error}');
      return [];
    }
  }

  //add product to selected list
  void _addProductToSelectedList(List<String> productNames, List<String> productIds) {
    String selectedProductName = _selectedProductNameForSecondPane;
    String selectedProductId = _selectedProductIdForSecondPane;
    String quantity = secondPaneQuantityController.text;
    String price = priceControllerForSecondPane.text;
    String tax = taxControllerForSecondPane.text;

    if (selectedProductName.isNotEmpty &&
        selectedProductId.isNotEmpty &&
        quantity.isNotEmpty &&
        int.tryParse(quantity) != null &&
        int.parse(quantity) > 0 &&
        price.isNotEmpty && double.tryParse(price) != null &&
        tax.isNotEmpty && double.tryParse(tax) != null){
      int existingIndex = selectedProducts.indexWhere((product) =>
      product['productName'] == selectedProductName &&
          product['productId'] == selectedProductId);

      if (existingIndex != -1) {
        // Product already exists, update the quantity
        setState(() {
          int currentQuantity = int.parse(selectedProducts[existingIndex]['quantity']);
          int newQuantity = currentQuantity + int.parse(quantity);
          selectedProducts[existingIndex]['quantity'] = newQuantity.toString();
          _productControllerForSecondPane.clear();
          secondPaneQuantityController.clear();
        });
      } else {
        setState(() {
          selectedProducts.add({
            'productName': selectedProductName,
            'productId': selectedProductId,
            'quantity': quantity,
            'rate' : price,
            'tax' : tax,
          });
          _productControllerForSecondPane.clear();
          secondPaneQuantityController.clear();
          priceControllerForSecondPane.clear();
          taxControllerForSecondPane.clear();
        });
      }
      _buildSelectedProducts();
    }
  }


  //form submission(without bill)
  void _addReturnNoBill() async {
    try {
      double totalPrice = 0.0;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? employeeId = prefs.getString('E_id');

      // Calculate total price
      selectedProducts.forEach((product) {
        int productQuantity = int.parse(product['quantity']);
        double productPrice = double.parse(product['rate']);
        double productTax = double.parse(product['tax']);

        totalPrice += (productQuantity * productPrice) + (productQuantity * productPrice * productTax / 100);
      });

      // Show dialog with estimated total
      bool? confirmed = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Estimated Amount ',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Rs. ${totalPrice.toStringAsFixed(2)}/- (incl. gst)\nPress continue to place return order?',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            backgroundColor: Colors.indigoAccent[700],
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          );
        },
      );

      if (confirmed == null || !confirmed) {
        return;
      }

      String url = "${Conn
          .baseUrl}addSalesReturnNoBill.jsp?devId=$serialNumber";
      var response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          'shopId': _selectedShopDetailsForSecondPane['id'],
          'employeeId': employeeId,
          'products': jsonEncode(selectedProducts),
          'total' : totalPrice,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.body.trim() == 'success') {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Success',
          text: 'Return order placed',
        );
        setState(() {
          _selectedShopDetailsForSecondPane = {};
          productsSecondPane.clear();
          selectedProducts.clear();
          _productControllerForSecondPane.clear();
          secondPaneQuantityController.clear();
          _selectedProductNameForSecondPane = '';
          _selectedProductIdForSecondPane = '';
        });
      } else if (response.statusCode == 403) {
        handleAddCollectionPageError('Unauthorized access',
            'ERROR/salesReturnPa/_addReturnNoBill(): Unauthorized access $serialNumber');
      }
      else if (response.statusCode == 400) {
        handleAddCollectionPageError('Invalid input',
            'ERROR/salesReturnPa/_addReturnNoBill(): Unsantized input parameters');
      }
      else {
        handleAddCollectionPageError('Failed to return products :',
            'ERROR/salesReturnPa/_addReturnNoBill(): Failed to return details.');
      }
    } catch (error) {
      handleAddCollectionPageError('Failed to save details',
          'ERROR/salesReturnPa/_addReturnNoBill(): Failed to save details. $error');
    }
  }

  //Methods for third pane
  //Searchbar function
  void search(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredItems = returnedItems;
      });
    } else {
      setState(() {
        filteredItems = returnedItems.where((item) {
          String billId = item['billId'].toString();
          return billId.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  //Fetch return details of selected shop
  Future<List<Map<String, dynamic>>> _fetchReturn() async {
    try {
      DeviceInfo deviceInfo = DeviceInfo();
      serialNumber = await deviceInfo.fetchDeviceSerialNumber(context);
      final response = await http.get(
        Uri.parse('${Conn.baseUrl}fetchReturn.jsp?devId=$serialNumber&shopId=${_selectedShopDetailsForThirdPane['id']}'), // Replace with your JSP API URL
      );


      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);

        List<Map<String, dynamic>> fetchedShops = jsonResponse.map((dynamic shop) {
          return {
            'employeeName': shop['employeeName'],
            'quantityReturned': shop['quantityReturned'],
            'productName': shop['productName'],
            'billId': shop['billId'],
            'rate': shop['returnedPrice'],
            'tax': shop['tax'],
            'date': shop['date'],
            'total': shop['total'],
          };
        }).toList();

        return fetchedShops;
      }else if(response.statusCode == 403){
        handleAddCollectionPageError('Unauthorized access', 'ERROR/addCollectionPa/_fetchshops()/: Unauthorized access ($serialNumber)');
        return [];
      }else if(response.statusCode == 400){
        handleAddCollectionPageError('Invalid input!', 'ERROR/addCollectionPa/_fetchshops()/:Unsanitized input parameters');
        return [];
      }
      else {
        logger.severe('Error/addCollectionPa/_fetchshops()/:Failed to fetch shops. Status code: ${response.body.trim()}');
        return [];
      }
    } catch (error) {
      logger.severe('Error/addCollectionPa/_fetchshops()/:Failed to fetch shops. Status code: $error');
      return [];
    }
  }

  //Error handling
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
