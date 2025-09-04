import 'package:flutter/material.dart';

import '../utils/BaseScreen.dart';
import 'ShippingScreen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {


  // ✅ Cart items stored in a list with quantities
  List<Map<String, dynamic>> cartItems = [
    {
      "selected": true,
      "image": "assets/images/w1.png",
      "name": "Lorem ipsum dolor sit amet consectetur.",
      "oldPrice": "₹4,148.00",
      "price": 2000,
      "size": "09",
      "quantity": 2,
    },
    {
      "selected": false,
      "image": "assets/images/w1.png",
      "name": "Lorem ipsum dolor sit amet consectetur.",
      "oldPrice": "₹4,148.00",
      "price": 1500,
      "size": "09",
      "quantity": 1,
    },
    {
      "selected": false,
      "image": "assets/images/w1.png",
      "name": "Lorem ipsum dolor sit amet consectetur.",
      "oldPrice": "₹4,148.00",
      "price": 1500,
      "size": "09",
      "quantity": 1,
    },
  ];


  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Scaffold(
        backgroundColor: const Color(0xfffdf6ef),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text("₹4,000.00",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Subtotal", style: TextStyle(color: Colors.grey)),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ShippingScreen()),
                  );
                },
                child: const Text(
                  "CHECKOUT (1 item)",
                  style: TextStyle(fontSize: 16, color: Colors.white,fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children:  [
                    // Icon(Icons.close, size: 26),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.black,
                        // size: screenWidth * 0.07,
                      ),
                      onPressed: () {
                        Navigator.pop(context); // go back to previous screen
                      },
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Cart (3 items)",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Text("Select all items",
                        style: TextStyle(color: Colors.orange)),
                  ],
                ),
              ),
      
              Expanded(
                child: Column(
                  children: [
                    // Cart Items List
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          _cartItem(
                              selected: true,
                              image: "assets/images/w1.png",
                              name: "Lorem ipsum dolor sit amet consectetur.",
                              oldPrice: "₹4,148.00",
                              price: "₹2,000.00",
                              size: "09",
                              quantity: 2,
                              total: "₹4,000.00"),
                          _cartItem(
                              selected: false,
                              image: "assets/images/w1.png",
                              name: "Lorem ipsum dolor sit amet consectetur.",
                              oldPrice: "₹4,148.00",
                              price: "₹1,500.00",
                              size: "09",
                              quantity: 1,
                              total: "₹1,500.00"),
                          _cartItem(
                              selected: false,
                              image: "assets/images/w1.png",
                              name: "Lorem ipsum dolor sit amet consectetur.",
                              oldPrice: "₹4,148.00",
                              price: "₹1,500.00",
                              size: "09",
                              quantity: 1,
                              total: "₹1,500.00"),
                        ],
                      ),
                    ),
      
                    const Divider(thickness: 1),
      
                    // Promo Code + Add Note Section (separate from cart list)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Promo Code
                          Row(
                            children: const [
                              Icon(Icons.star, color: Colors.black54),
                              SizedBox(width: 8),
                              Text("Promo Code",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child:TextField(
                                  decoration: InputDecoration(
                                    hintText: "e.g. SAVE50",
                                    hintStyle: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white, // background color
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide:  BorderSide(color: Colors.blue.shade300, width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide:  BorderSide(color: Colors.blue.shade300, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide:  BorderSide(color: Colors.blue.shade300, width: 1),
                                    ),
                                    suffixIcon: const Icon(
                                      Icons.local_offer_outlined,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.done,
                                )
      
                                // TextField(
                                //   decoration: InputDecoration(
                                //     hintText: "e.g. SAVE50",
                                //     contentPadding: EdgeInsets.symmetric(
                                //         horizontal: 16, vertical: 12),
                                //     border: OutlineInputBorder(
                                //         borderRadius: BorderRadius.all(Radius.circular(30)),
                                //         borderSide: BorderSide(color: Colors.grey)),
                                //   ),
                                // ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF050040),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 22, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: () {},
                                child: const Text(
                                  "APPLY",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
      
                          const SizedBox(height: 20),
      
                          // Add Note
                          Row(
                            children: const [
                              Icon(Icons.note_add_outlined, color: Colors.black54),
                              SizedBox(width: 8),
                              Text("Add Note",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: "e.g. Leave outside the door",
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide:  BorderSide(color: Colors.blue.shade300, width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide:  BorderSide(color: Colors.blue.shade300, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide:  BorderSide(color: Colors.blue.shade300, width: 1),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              )
      
            ],
          ),
        ),
      ),
    );
  }

  // Cart Item Widget
  Widget _cartItem({
    required bool selected,
    required String image,
    required String name,
    required String oldPrice,
    required String price,
    required String size,
    required int quantity,
    required String total,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))
          ]),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: selected,
                onChanged: (val) {},
                // shape: const CircleBorder(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4), // square corners
                ),
                activeColor: const Color(0xFFE8240A), // replace with Brand/400 color
                checkColor: Colors.white,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(image, height: 70, width: 70, fit: BoxFit.cover),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    Row(
                      children: [
                        Text(oldPrice,
                            style: const TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough)),
                        const SizedBox(width: 6),
                        Text(price,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    Text("Size: $size"),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {

                  _showDeleteBottomSheet(context, name);
                },
                icon: const Icon(Icons.delete, color: Colors.red),
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Quantity Selector
              SizedBox(width: 50,),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() {
                            quantity--;
                          });
                        }
                      },
                    ),
                    Text(
                      quantity.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Text(total,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          )
        ],
      ),
    );
  }
}

void _showDeleteBottomSheet(BuildContext context, String itemName) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            const Text(
              "Want to remove item?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "Are you sure to remove the product from cart?",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side:  BorderSide(color: Colors.blue.shade900), // ✅ border color
                      foregroundColor: Colors.blue.shade900,               // ✅ text + ripple color
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close bottom sheet
                    },
                    child: const Text("No"),
                  ),
                ),

                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {
                      // ✅ Delete action
                      // setState(() {
                      //   cartItems.removeWhere((item) => item["name"] == itemName);
                      // });
                      Navigator.pop(context); // Close bottom sheet
                    },
                    child: const Text(
                      "Yes, Delete",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )

                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

