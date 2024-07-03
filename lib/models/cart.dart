import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'shoe.dart';

class Cart extends ChangeNotifier {
  List<Shoe> shoeShop = [];
  List<Shoe> userCart = [];

  List<Shoe> getShoeList() {
    return shoeShop;
  }

  List<Shoe> getUserCart() {
    return userCart;
  }

  void clearCart() {
    userCart.clear();
    notifyListeners();
  }

  int getTotalCartItems() {
    return userCart.length;
  }

  void addItemToCart(Shoe shoe, int quantity, BuildContext context) {
    var existingItem = userCart.firstWhere(
          (item) => item.id == shoe.id,
      orElse: () => Shoe(id: '', name: '', minPrice: '', description: '', imagePath: '', maxPrice: '', minQty: '', userEnteredPrice: 0.0,),
    );
    //if(existingItem.User_quantity < shoe.available_quantity) {
    if (existingItem.id.isNotEmpty) {
      existingItem.User_quantity += quantity;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Quantity added!',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      shoe.userEnteredPrice = double.parse(shoe.maxPrice);
      userCart.add(shoe..User_quantity = quantity);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Successfully added!',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    notifyListeners();
  }

  void removeItemFromCart(Shoe shoe) {
    userCart.removeWhere((item) => item.id == shoe.id);
    notifyListeners();
  }

  void increaseQuantity(Shoe shoe) {
    var existingItem = userCart.firstWhere(
          (item) => item.id == shoe.id,
      orElse: () => Shoe(id: '', name: '', minPrice: '', description: '', imagePath: '', maxPrice: '', minQty: '', userEnteredPrice: 0.0,),
    );

    //if(existingItem.User_quantity < shoe.available_quantity) {
      if (existingItem.id.isNotEmpty) {
        existingItem.User_quantity += 1;
      }
   // }

    notifyListeners();
  }

  void decreaseQuantity(Shoe shoe) {
    var existingItem = userCart.firstWhere(
          (item) => item.id == shoe.id,
      orElse: () => Shoe(id: '', name: '', minPrice: '', description: '', imagePath: '', maxPrice: '', minQty: '', userEnteredPrice: 0.0,),
    );

    if (existingItem.id.isNotEmpty && existingItem.User_quantity > 1) {
      existingItem.User_quantity -= 1;
    } else {
      userCart.removeWhere((item) => item.id == shoe.id);
    }

    notifyListeners();
  }

  void updateQuantityManually(Shoe shoe, int newQuantity) {
    var existingItem = userCart.firstWhere(
          (item) => item.id == shoe.id,
      orElse: () => Shoe(id: '', name: '', minPrice: '', description: '', imagePath: '', maxPrice: '', minQty: '', userEnteredPrice: 0.0,),
    );

    if (existingItem.id.isNotEmpty) {
      existingItem.User_quantity = newQuantity;
    }

    notifyListeners();
  }

  void updatePriceManually(Shoe shoe, double newPrice) {
    var existingItem = userCart.firstWhere(
          (item) => item.id == shoe.id,
      orElse: () => Shoe(id: '', name: '', minPrice: '', description: '', imagePath: '', maxPrice: '', minQty: '', userEnteredPrice: 0.0,),
    );

    if (existingItem.id.isNotEmpty) {
      existingItem.userEnteredPrice = newPrice;
    }
    notifyListeners();
  }


  Future<double> calculateTotalPrice() async {
    double total = 0;
    for (var item in userCart) {
      total += item.User_quantity * item.userEnteredPrice + (item.User_quantity * item.userEnteredPrice * (double.tryParse(item.tax)!/100));
    }
    return total;
  }
}
