import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:readmore/readmore.dart';


class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // int quantity = 1;
  // int selectedSize = 32;
  bool showProductDetails = true;
  bool showSizeChart = true;

  final PageController _pageController = PageController();
  int activeIndex = 0;

  // State variable
  int? selectedSize;

  final List<String> productImages = [
    "assets/images/w1.png",
    "assets/images/w2.png",
    "assets/images/w3.png",
  ];
  bool isAddedToCart = false;
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with badge + fav + share
            Padding(
              padding: const EdgeInsets.all(12.0), // outer padding
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: [
                    // Product Images PageView
                    SizedBox(
                      height: 350,
                      width: double.infinity,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: productImages.length,
                        onPageChanged: (index) {
                          setState(() => activeIndex = index);
                        },
                        itemBuilder: (context, index) {
                          return Image.asset(
                            productImages[index],
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),

                    // Discount Badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "20% Off",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Page Indicator
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Empty box just to balance left side
                const SizedBox(width: 90),

                // Center indicator
                Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: productImages.length,
                    effect: const ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: Colors.orange,
                      dotColor: Colors.grey,
                    ),
                  ),
                ),

                // Right side icons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.black),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.black),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),

            // Title + Rating + Stock
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Lorem ipsum dolor sit amet consectetur.",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 18),
                      const SizedBox(width: 4),
                      const Text("4.8 (451,444 Ratings)"),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text("In stock", style: TextStyle(color: Colors.green)),
                      )
                    ],
                  ),
                ],
              ),
            ),
// Quantity Selector
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               child: Row(
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       children: [
//                         IconButton(
//                           onPressed: () {
//                             if (quantity > 1) setState(() => quantity--);
//                           },
//                           icon: const Icon(Icons.remove),
//                         ),
//                         Text(quantity.toString(),
//                             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//                         IconButton(
//                           onPressed: () => setState(() => quantity++),
//                           icon: const Icon(Icons.add),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                 ],
//               ),
//             ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              isAddedToCart
                  ? Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() => quantity--);
                        } else {
                          // If quantity is 1 and user clicks remove, reset to Add to Cart
                          setState(() {
                            isAddedToCart = false;
                            quantity = 1;
                          });
                        }
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      quantity.toString(),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      onPressed: () => setState(() => quantity++),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              )
                  : ElevatedButton(
                onPressed: () {
                  setState(() {
                    isAddedToCart = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Add to Cart",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),


// Size Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Text(
                    "Size: ${selectedSize != null ? selectedSize.toString() : ""}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  // TextButton(
                  //   onPressed: () {},
                  //   child: const Text(
                  //     "Size Chart",
                  //     style: TextStyle(color: Colors.blue),
                  //   ),
                  // ),

                ],
              ),
            ),

// Sizes List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  ...[26, 28, 30, 32, 34, 36].map((size) {
                    return GestureDetector(
                      onTap: () => setState(() => selectedSize = size),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          color: selectedSize == size ? Colors.orange : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          size.toString(),
                          style: TextStyle(
                            color: selectedSize == size ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),


    const SizedBox(height: 10),

            // Description
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),


            const Padding(
              padding: EdgeInsets.all(12),
              child: ReadMoreText(
                "Discover timeless elegance with the Raymond Men Slim Fit Solid Formal Shirt, perfect for the discerning gentleman. Crafted from Pure Cotton.",
                trimLines: 2,
                colorClickableText: Colors.blue,
                trimMode: TrimMode.Line,
                trimCollapsedText: ' Read more',
                trimExpandedText: ' Read less',
                style: TextStyle(fontSize: 14, color: Colors.black87),
                moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
                lessStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),


    // Product Details expandable
            ExpansionTile(
              title: const Text(
                "Product Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              children: [
                ProductDetailsTable(
                  details: {
                    "Pack of": "1",
                    "Style Code": "RMSX12869-B3",
                    "Fit": "Slim",
                    "Fabric": "Pure Cotton",
                    "Sleeve": "Full Sleeve",
                    "Pattern": "Solid",
                  },
                ),
              ],
            ),

            // Size Chart expandable
            ExpansionTile(
              initiallyExpanded: showSizeChart,
              title:
              const Text("Size Chart", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("Size")),
                      DataColumn(label: Text("Chart")),
                      DataColumn(label: Text("Brand Size")),
                      DataColumn(label: Text("Shoulder")),
                      DataColumn(label: Text("Length")),
                    ],
                    rows: List.generate(
                      5,
                          (index) => const DataRow(cells: [
                        DataCell(Text("38")),
                        DataCell(Text("40.94")),
                        DataCell(Text("XS")),
                        DataCell(Text("17.52")),
                        DataCell(Text("26.54")),
                      ]),
                    ),
                  ),
                )
              ],
            ),

            // Reviews
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  children: [
                    const Text("Reviews & feedback",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Row(
                      children: const [
                        Icon(Icons.star, color: Colors.orange),
                        SizedBox(width: 5),
                        Text("4.5 out of 5"),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name & Email Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Name*", style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        TextField(
                          decoration: InputDecoration(
                            hintText: "Name",
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

                            // default border (when not focused)
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                            ),

                            // focused border (when you tap inside)
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                            ),

                            // error border (optional)
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.red, width: 1.5),
                            ),

                            // focused error border
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Email*", style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        TextField(
                          decoration: InputDecoration(
                            hintText: "Email",
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

                            // default border (when not focused)
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                            ),

                            // focused border (when you tap inside)
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                            ),

                            // error border (optional)
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.red, width: 1.5),
                            ),

                            // focused error border
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Review Field
              const Text("Review*", style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Write here",
                  alignLabelWithHint: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),

                  // default border (when not focused)
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                  ),

                  // focused border (when you tap inside)
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                  ),

                  // error border (optional)
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),

                  // focused error border
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Publish Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.indigo.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Publish",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),

              ]),
            ),

            // Similar Products
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  const Text("Similar Products",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  TextButton(onPressed: () {}, child: const Text("View All"))
                ],
              ),
            ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header


            // Horizontal Product List
            SizedBox(
              height: 270,
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 12, right: 12),
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    width: 180,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image with Wishlist Button
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12)),
                              child: Image.asset(
                                "assets/images/w1.png", // change to your image
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  icon: const Icon(Icons.favorite_border,
                                      color: Colors.orange),
                                  onPressed: () {},
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Product Info
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Lorem ipsum dolor sit amet consectetur.",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: const [
                                  Text("₹4,148.00",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          decoration: TextDecoration.lineThrough)),
                                  SizedBox(width: 6),
                                  Text("₹2,996.50",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: const [
                                  Icon(Icons.star,
                                      size: 16, color: Colors.orange),
                                  SizedBox(width: 4),
                                  Text("4.8", style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Social Icons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _socialButton(Icons.facebook, Colors.blue),
                const SizedBox(width: 20),
                _socialButton(Icons.apple, Colors.black),
                const SizedBox(width: 20),
                _socialButton(Icons.g_mobiledata, Colors.red),
              ],
            )
          ],
        ),


            const SizedBox(height: 50),

          ],
        ),

      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("₹2,996.50",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text("₹4,148",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text("BUY NOW"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            )
          ],
        ),
      ),


    );
  }
}

// Social Button Widget
Widget _socialButton(IconData icon, Color color) {
  return CircleAvatar(
    radius: 22,
    backgroundColor: color.withOpacity(0.1),
    child: Icon(icon, color: color, size: 28),
  );
}



class ProductDetailsTable extends StatelessWidget {
  final Map<String, String> details;

  const ProductDetailsTable({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(3), // key column
          1: FlexColumnWidth(5), // value column
        },
        children: details.entries.map((entry) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  entry.key,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  entry.value,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}


// class ProductDetailPage extends StatelessWidget {
//   const ProductDetailPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const [
//                 Text("₹2,996.50",
//                     style: TextStyle(
//                         fontSize: 18, fontWeight: FontWeight.bold)),
//                 Text("₹4,148",
//                     style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                         decoration: TextDecoration.lineThrough)),
//               ],
//             ),
//             ElevatedButton.icon(
//               onPressed: () {},
//               icon: const Icon(Icons.shopping_cart_outlined),
//               label: const Text("BUY NOW"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orange,
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 28, vertical: 14),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12)),
//               ),
//             )
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Image Section
//             Stack(
//               children: [
//                 SizedBox(
//                   height: 350,
//                   child: PageView(
//                     children: [
//                       Image.asset("assets/images/w2.png",
//                           fit: BoxFit.cover),
//                     ],
//                   ),
//                 ),
//                 Positioned(
//                   top: 40,
//                   left: 10,
//                   child: const BackButton(color: Colors.black),
//                 ),
//                 Positioned(
//                   top: 40,
//                   right: 10,
//                   child: CircleAvatar(
//                     backgroundColor: Colors.white,
//                     child: IconButton(
//                       icon: const Icon(Icons.shopping_cart_outlined),
//                       onPressed: () {},
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: 20,
//                   right: 20,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.redAccent,
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: const Text("20% Off",
//                         style: TextStyle(color: Colors.white)),
//                   ),
//                 ),
//               ],
//             ),
//
//             // Product Title
//             ListTile(
//               title: const Text("Lorem ipsum dolor sit amet consectetur."),
//               subtitle: Row(
//                 children: const [
//                   Icon(Icons.star, color: Colors.orange, size: 16),
//                   Text(" 4.8 (451,444 Rating)"),
//                 ],
//               ),
//               trailing: Container(
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                     color: Colors.green.shade100,
//                     borderRadius: BorderRadius.circular(6)),
//                 child: const Text("In stock",
//                     style: TextStyle(color: Colors.green)),
//               ),
//             ),
//
//             // Quantity
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 IconButton(
//                     onPressed: () {},
//                     icon: const Icon(Icons.remove_circle_outline)),
//                 const Text("1", style: TextStyle(fontSize: 16)),
//                 IconButton(
//                     onPressed: () {},
//                     icon: const Icon(Icons.add_circle_outline)),
//               ],
//             ),
//
//             // Sizes
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Row(
//                 children: [
//                   const Text("Size: 32"),
//                   const Spacer(),
//                   TextButton(
//                     onPressed: () {},
//                     child: const Text("Size Chart"),
//                   )
//                 ],
//               ),
//             ),
//             Wrap(
//               spacing: 10,
//               children: List.generate(6, (index) {
//                 List<int> sizes = [26, 28, 30, 32, 34, 36];
//                 bool isSelected = sizes[index] == 32;
//                 return ChoiceChip(
//                   label: Text("${sizes[index]}"),
//                   selected: isSelected,
//                   selectedColor: Colors.orange.shade100,
//                   onSelected: (_) {},
//                 );
//               }),
//             ),
//
//             // Description
//             const Padding(
//               padding: EdgeInsets.all(12.0),
//               child: Text(
//                 "Discover timeless elegance with the Raymond Men Slim Fit Solid Formal Shirt, perfect for the discerning gentleman. Crafted from pure cotton.",
//                 style: TextStyle(color: Colors.black54),
//               ),
//             ),
//
//             ExpansionTile(
//               title: const Text("Product Details"),
//               children: const [
//                 ListTile(
//                   title: Text("Pack of"),
//                   trailing: Text("1"),
//                 ),
//                 ListTile(
//                   title: Text("Style Code"),
//                   trailing: Text("RMSX12869-B3"),
//                 ),
//                 ListTile(
//                   title: Text("Fit"),
//                   trailing: Text("Slim"),
//                 ),
//                 ListTile(
//                   title: Text("Fabric"),
//                   trailing: Text("Pure Cotton"),
//                 ),
//               ],
//             ),
//
//             ExpansionTile(
//               title: const Text("Size Chart"),
//               children: [
//                 DataTable(columns: const [
//                   DataColumn(label: Text("Size")),
//                   DataColumn(label: Text("Chart")),
//                   DataColumn(label: Text("Brand Size")),
//                   DataColumn(label: Text("Shoulder")),
//                   DataColumn(label: Text("Length")),
//                 ], rows: List.generate(5, (index) {
//                   return const DataRow(cells: [
//                     DataCell(Text("38")),
//                     DataCell(Text("40.94")),
//                     DataCell(Text("XS")),
//                     DataCell(Text("17.52")),
//                     DataCell(Text("26.54")),
//                   ]);
//                 })),
//               ],
//             ),
//
//             // Reviews
//             const Padding(
//               padding: EdgeInsets.all(12.0),
//               child: Text("Reviews & feedback",
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: const [
//                 Icon(Icons.star, color: Colors.orange),
//                 Icon(Icons.star, color: Colors.orange),
//                 Icon(Icons.star, color: Colors.orange),
//                 Icon(Icons.star, color: Colors.orange),
//                 Icon(Icons.star_half, color: Colors.orange),
//                 SizedBox(width: 5),
//                 Text("4.5 out of 5"),
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 children: [
//                   TextField(
//                     decoration: InputDecoration(
//                         labelText: "Name", border: OutlineInputBorder()),
//                   ),
//                   const SizedBox(height: 10),
//                   TextField(
//                     decoration: InputDecoration(
//                         labelText: "Email", border: OutlineInputBorder()),
//                   ),
//                   const SizedBox(height: 10),
//                   TextField(
//                     maxLines: 3,
//                     decoration: InputDecoration(
//                         labelText: "Review", border: OutlineInputBorder()),
//                   ),
//                   const SizedBox(height: 10),
//                   ElevatedButton(
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.deepPurple),
//                       child: const Text("Publish"))
//                 ],
//               ),
//             ),
//
//             // Similar Products
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Row(
//                 children: [
//                   const Text("Similar Products",
//                       style:
//                       TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                   const Spacer(),
//                   TextButton(onPressed: () {}, child: const Text("View All"))
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 250,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: 3,
//                 itemBuilder: (context, index) {
//                   return Container(
//                     width: 160,
//                     margin: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade200),
//                         borderRadius: BorderRadius.circular(12)),
//                     child: Column(
//                       children: [
//                         Image.asset("assets/images/w2.png",
//                             height: 150, fit: BoxFit.cover),
//                         const Text("Lorem ipsum dolor sit amet",
//                             maxLines: 1, overflow: TextOverflow.ellipsis),
//                         const Text("₹2,996.50",
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black)),
//                         const Text("₹4,148",
//                             style: TextStyle(
//                                 decoration: TextDecoration.lineThrough,
//                                 color: Colors.grey)),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
