import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/shoe.dart';

class ShoeTile extends StatefulWidget {
  final Shoe shoe;
  final void Function(Shoe, int) onAddToCart;

  const ShoeTile({
    Key? key,
    required this.shoe,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  _ShoeTileState createState() => _ShoeTileState();
}

class _ShoeTileState extends State<ShoeTile> {
  int quantity = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              GestureDetector(
                onTap: () => _showImageDialog(widget.shoe.imagePath),
                child: SizedBox(
                  width: 80,
                  height: 80,

                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                      'https://arbv2728.co.in/shopimg/${widget.shoe.imagePath}',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'lib/images/default.webp',
                          fit: BoxFit.contain,
                          height: 80,
                          width: 80,
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 60,
                height: 40,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    int? newQuantity = int.tryParse(value);
                    if (newQuantity != null && newQuantity > 0) {
                      setState(() {
                        quantity = newQuantity;
                      });
                    } else {
                      setState(() {
                        quantity = 0;
                      });
                    }
                  },
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Qty',
                    hintStyle: TextStyle(color: Colors.grey[700]),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.indigoAccent[700]!),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 10),
          // Right side - Other details
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shoe name
                GestureDetector(
                  onLongPress: () => _showFullProductName(widget.shoe.name),
                  onTap: () => _showShoeDetailsBottomSheet(),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Tooltip(
                      message: widget.shoe.name,
                      child: Text(
                        _getShortenedName(widget.shoe.name),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                // Price
                GestureDetector(
                  onTap: () => _showShoeDetailsBottomSheet(),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rs: ${widget.shoe.maxPrice}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),

                        Text(
                          'gst: ${widget.shoe.tax}%',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Add to Cart button
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton.icon(
                      onPressed: quantity > 0
                          ? () {
                        widget.onAddToCart(widget.shoe, quantity);
                      }
                          : null,
                      icon: const Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Add to cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //Methods
// Function to show the bottom sheet with shoe details
  void _showShoeDetailsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.2, // Set a fixed height
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _showImageDialog(widget.shoe.imagePath),
                  child: SizedBox(
                    height: 80,
                    width: 80,
                    child: Image.network(
                      'https://arbv2728.co.in/shopimg/${widget.shoe.imagePath}',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'lib/images/default.webp',
                          fit: BoxFit.cover,
                          height: 80,
                          width: 80,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Other details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Product Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(widget.shoe.name),
                      Text('Max Price: ${widget.shoe.maxPrice}'),
                      Text('Min Price: ${widget.shoe.minPrice}'),
                      Text(
                          'Available Quantity: ${widget.shoe
                              .available_quantity}'),
                      // Add other details as needed
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Function to show enlarged image in a dialog
  void _showImageDialog(String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Image.network(
            'https://arbv2728.co.in/shopimg/$imagePath',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'lib/images/default.webp',
                fit: BoxFit.contain,
                height: 400,
                width: 400,
              );
            },
          ),
        );
      },
    );
  }

  String _getShortenedName(String fullName) {
    const int maxVisibleChars = 25; // Adjust the maximum visible characters as needed
    if (fullName.length > maxVisibleChars) {
      return '${fullName.substring(0, maxVisibleChars)}...';
    } else {
      return fullName;
    }
  }

  void _showFullProductName(String fullName) {
    // Implement your logic to display the full product name directly (e.g., in a Snackbar)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(fullName),
        duration: const Duration(seconds: 2),
      ),
    );
  }

}