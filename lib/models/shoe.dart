class Shoe {
  String id; // Add a unique identifier, e.g., product ID
  String name;
  String minPrice;
  String maxPrice;
  String minQty;
  String description;
  String imagePath;
  int User_quantity;
  int available_quantity;
  double userEnteredPrice;
  String tax;


  Shoe({
    required this.id,
    required this.name,
    required this.minPrice,
    required this.maxPrice,
    required this.minQty,
    required this.description,
    required this.imagePath,
    this.tax = '',
    this.User_quantity = 1,
    this.available_quantity = 1,
    this.userEnteredPrice = 0.0,



  });
  double get totalPrice => User_quantity * userEnteredPrice;

  factory Shoe.fromJson(Map<String, dynamic> json) {
    return Shoe(
      id: json['id'].toString(),
      name: json['name'],
      minPrice: json['pMinPrice'],
      maxPrice: json['pMaxPrice'],
      minQty: json['minQty'],
      description: json['description'],
      imagePath: json['imagePath'],
      available_quantity: int.parse(json['quantity']),
      tax: json['tax'],
    );
  }
}
