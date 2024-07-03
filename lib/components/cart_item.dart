import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../models/cart.dart';
import '../models/shoe.dart';

class CartItem extends StatefulWidget {
  final Shoe shoe;
  final Cart cart;

  const CartItem({
    Key? key,
    required this.shoe,
    required this.cart,
  }) : super(key: key);

  @override
  _CartItemState createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late double _totalPrice;
  final FocusNode _quantityFocusNode = FocusNode();
  final FocusNode _priceFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: widget.shoe.User_quantity.toString());
    _priceController = TextEditingController(text: widget.shoe.userEnteredPrice.toString());
    _totalPrice = (widget.shoe.User_quantity * widget.shoe.userEnteredPrice) + (widget.shoe.User_quantity * widget.shoe.userEnteredPrice * (double.parse(widget.shoe.tax)/100));
    _quantityFocusNode.addListener(_onQuantityFocusChange);
    _priceFocusNode.addListener(_onPriceFocusChange);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _quantityFocusNode.removeListener(_onQuantityFocusChange);
    _priceFocusNode.removeListener(_onPriceFocusChange);
    _quantityFocusNode.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
      child: Dismissible(
        key: Key(widget.shoe.id),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          widget.cart.removeItemFromCart(widget.shoe);
          _updateTotal();
        },
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.delete, color: Colors.white),
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                // Image in a Column
                Image.network(
                  'https://arbv2728.co.in/shopimg/${widget.shoe.imagePath}',
                  height: 70,
                  width: 70,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'lib/images/default.webp',
                      fit: BoxFit.contain,
                      height: 70,
                      width: 70,
                    );
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.shoe.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800]),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 90,
                            child: TextField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              focusNode: _priceFocusNode,
                              onEditingComplete: () {
                                _updatePrice();
                              },
                              decoration: const InputDecoration(
                                labelText: 'PRICE',
                                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                                isDense: true,
                                border:InputBorder.none,
                              ),
                            ),
                          ),
                          Text(
                            'GST\n ${widget.shoe.tax}%',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            child: TextField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              focusNode: _quantityFocusNode,
                              onEditingComplete: () {
                                if(int.parse(_quantityController.text.trim()) > 0)
                                  {
                                    _updateQuantity();
                                  }
                                else {
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    title: 'Invalid quantity!',
                                    text: 'The quantity should freater than zero!',
                                  );
                                  _quantityController.text = widget.shoe.User_quantity.toString();
                                }
                              },
                              decoration: const InputDecoration(
                                labelText: 'QTY',
                                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                                isDense: true,
                                border:InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Text(
                            'TOTAL: Rs.${_totalPrice.toStringAsFixed(2)}/- (incl. gst)',
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }




  void _updatePrice() {
    final String value = _priceController.text.trim();
    if (value.isNotEmpty) {
      double enteredPrice = double.tryParse(value) ?? 0.0;
      if (enteredPrice >= double.parse(widget.shoe.minPrice) &&
          enteredPrice <= double.parse(widget.shoe.maxPrice)) {
        widget.shoe.userEnteredPrice = enteredPrice;
        setState(() {
          _priceController.text = value;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_outlined, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Price should be between ${widget.shoe.minPrice} and ${widget.shoe.maxPrice}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.shoe.userEnteredPrice = double.parse(widget.shoe.maxPrice);
      }
      widget.cart.updatePriceManually(widget.shoe, widget.shoe.userEnteredPrice);
      _updateTotal();
    }
  }

  void _updateQuantity() {
    final String enteredValue = _quantityController.text.trim();
    if(enteredValue.isEmpty || enteredValue == '')
      {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_outlined, color: Colors.white),
                const SizedBox(width: 8),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    'Invalid quantity\nProduct: ${widget.shoe.name} \nElse the order will execute with the previous quantity',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.grey[700],
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    else if (enteredValue.isNotEmpty) {
      final int quantity = int.tryParse(enteredValue) ?? 0;
        widget.cart.updateQuantityManually(widget.shoe, quantity);
        setState(() {
          _totalPrice = quantity * widget.shoe.userEnteredPrice;
        });
        _updateControllerValues();
    }
  }

  void _onPriceFocusChange() {
    if (!_priceFocusNode.hasFocus) {
      _updatePrice();
    }
  }

  void _onQuantityFocusChange() {
    if (!_quantityFocusNode.hasFocus) {
      _updateQuantity();
    }
  }

  void _updateControllerValues() {
    _quantityController.text = widget.shoe.User_quantity.toString();
  }

  void _updateTotal() {
    print('entered');
    double price = widget.shoe.userEnteredPrice;
    int quantity = widget.shoe.User_quantity;
    double taxPercentage = double.parse(widget.shoe.tax) / 100;
    double totalPrice = (price * quantity) + (price * quantity * taxPercentage);

    setState(() {
      _totalPrice = totalPrice;
    });
  }
}
