import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  // Multi-select sets
  Set<String> selectedSortBy = {"Most Popular"};
  Set<String> selectedBrands = {"Apple"};
  Set<String> selectedPayments = {"COD"};

  String category = "Electronics";
  String color = "White";
  String size = "L";
  double price = 1000;
  double maxPrice = 2000;
  String rating = "4.5+";
// Example brand data with counts
  final Map<String, int> brandCounts = {
    "Apple": 225,
    "Samsung": 180,
    "Sony": 95,
    "LG": 120,
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 28),
                  ),
                  const Text(
                    "Filters",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 28),
                ],
              ),
            ),

            const Divider(),

            // Scrollable Filter Sections
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Sort By - Grid Checkboxes
                    const Text("Sort By",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 4,
                      children: [
                        "Most Popular",
                        "Lowest Price",
                        "Highest Price",
                        "Newest",
                        "Best Rating",
                        "Offers"
                      ].map((item) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            checkboxTheme: CheckboxThemeData(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6), // ✅ rounded checkbox
                              ),
                              fillColor: MaterialStateProperty.resolveWith<Color>(
                                    (states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return const Color(0xFFFF6B57); // ✅ background when checked
                                  }
                                  return Colors.white; // background when unchecked
                                },
                              ),
                            ),
                          ),
                          child: CheckboxListTile(
                            value: selectedSortBy.contains(item),
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  selectedSortBy.add(item);
                                } else {
                                  selectedSortBy.remove(item);
                                }
                              });
                            },
                            title: Text(item, style: const TextStyle(fontSize: 14)),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Categories (unchanged)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Categories",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("See All",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        "All Categories",
                        "Electronics",
                        "Fashion",
                        "Home & Living",
                        "Beauty & Personal Care",
                        "Accessories",
                        "Sports & Outdoor"
                      ].map((item) {
                        final isSelected = category == item;
                        return ChoiceChip(
                          label: Text(
                            item,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.blue.shade900, // ✅ text color
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Colors.blue.shade900, // ✅ background when selected
                          backgroundColor: Colors.white, // ✅ background when not selected
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // ✅ rounded shape
                            side: BorderSide(color: Colors.blue.shade900), // ✅ blue border
                          ),
                          showCheckmark: false, // ✅ removes default check icon
                          onSelected: (_) => setState(() => category = item),
                        );
                      }).toList(),
                    )


                    ,

                    const SizedBox(height: 20),

                    // ✅ Brand - Grid Checkboxes
                    const Text("Brand",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),


                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 4,
                      children: brandCounts.keys.map((brand) {
                        final count = brandCounts[brand]!;
                        return Theme(
                          data: Theme.of(context).copyWith(
                            checkboxTheme: CheckboxThemeData(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6), // ✅ rounded checkbox
                              ),
                              fillColor: MaterialStateProperty.resolveWith<Color>(
                                    (states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return const Color(0xFFFF6B57); // ✅ background when checked
                                  }
                                  return Colors.white; // background when unchecked
                                },
                              ),
                              checkColor: MaterialStateProperty.all<Color>(Colors.white), // ✅ white tick
                            ),
                          ),
                          child: CheckboxListTile(
                            value: selectedBrands.contains(brand),
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  selectedBrands.add(brand);
                                } else {
                                  selectedBrands.remove(brand);
                                }
                              });
                            },
                            title: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: brand,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: " ($count)",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey, // ✅ gray count
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        );
                      }).toList(),
                    ),


                    const SizedBox(height: 20),

                    // Color (unchanged)
                    const Text("Color",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),


                    Wrap(
                      spacing: 10,
                      children: [
                        Colors.black,
                        Colors.white,
                        Colors.orange,
                        Colors.blue,
                        Colors.brown,
                        Colors.red,
                      ].map((clr) {
                        bool isSelected = color == clr.toString();

                        return GestureDetector(
                          onTap: () {
                            setState(() => color = clr.toString());
                          },
                          child: Container(
                            width: 36, // fixed size for all circles
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: clr,
                              border: Border.all(
                                color: clr == Colors.white ? Colors.grey : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: isSelected
                                ? Icon(
                              Icons.check,
                              size: 20,
                              color: clr == Colors.white ? Colors.green : Colors.white,
                            )
                                : null,
                          ),
                        );
                      }).toList(),
                    )
,
                    const SizedBox(height: 20),

                    // Variants (unchanged)
                    const Text("Variants",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: ["XS", "S", "M", "L", "XL", "XXL"]
                          .map((sizeOption) {
                        return ChoiceChip(
                          label: Text(sizeOption),
                          selected: size == sizeOption,
                          onSelected: (_) =>
                              setState(() => size = sizeOption),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Price Range (unchanged)
                    const Text("Price Range",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Slider(
                      value: price,
                      min: 0,
                      max: maxPrice,
                      divisions: 20,
                      activeColor: Colors.orange,
                      label: "\$${price.toStringAsFixed(0)}",
                      onChanged: (value) =>
                          setState(() => price = value),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("\$0"),
                        Text("\$2000"),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Rating (unchanged)
                    const Text("Rating",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 10,
                      children: ["5.0", "4.5+", "4.0+", "3.5+"].map((item) {
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.orange, size: 16),
                              const SizedBox(width: 4),
                              Text(item),
                            ],
                          ),
                          selected: rating == item,
                          onSelected: (_) =>
                              setState(() => rating = item),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ✅ Payment Method - Grid Checkboxes
                    const Text("Payment Method",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 4,
                      children: [
                        "COD",
                        "Google Pay",
                        "Credit Card",
                        "Debit Card",
                        "Pay Later"
                      ].map((item) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            checkboxTheme: CheckboxThemeData(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6), // ✅ rounded checkbox
                              ),
                              fillColor: MaterialStateProperty.resolveWith<Color>(
                                    (states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return const Color(0xFFFF6B57); // ✅ background when checked
                                  }
                                  return Colors.white; // background when unchecked
                                },
                              ),
                              checkColor: MaterialStateProperty.all<Color>(Colors.white), // ✅ white tick
                            ),
                          ),
                          child: CheckboxListTile(
                            value: selectedPayments.contains(item),
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  selectedPayments.add(item);
                                } else {
                                  selectedPayments.remove(item);
                                }
                              });
                            },
                            title: Text(item, style: const TextStyle(fontSize: 14)),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        );
                      }).toList(),
                    ),

                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedSortBy.clear();
                          selectedBrands.clear();
                          selectedPayments.clear();
                          category = "";
                          color = "";
                          size = "";
                          price = 1000;
                          rating = "";
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side:  BorderSide(
                          color: Colors.blue.shade900, // border color
                          width: 1.5,         // border thickness
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // rounded corners
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child:  Text(
                        "CLEAR ALL",
                        style: TextStyle(
                          color: Colors.indigo[900], // text color matches border
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )

                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[900],
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "APPLY FILTER",
                        style: const TextStyle(
                          color: Colors.white, // ✅ white text
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )

                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}
class _FiltersScreenState extends State<FiltersScreen> {
  // Instead of a single String, use Sets for multi-select checkboxes
  Set<String> selectedSortBy = {"Most Popular"};
  Set<String> selectedBrands = {"Apple"};
  Set<String> selectedPayments = {"COD"};

  String category = "Electronics";
  String color = "White";
  String size = "L";
  double price = 1000;
  double maxPrice = 2000;
  String rating = "4.5+";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 28),
                  ),
                  const Text(
                    "Filters",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 28), // spacing for symmetry
                ],
              ),
            ),

            const Divider(),

            // Scrollable Filter Sections
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Sort By - Checkbox Format
                    const Text("Sort By",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Column(
                      children: [
                        "Most Popular",
                        "Lowest Price",
                        "Highest Price",
                        "Newest",
                        "Best Rating",
                        "Offers"
                      ].map((item) {
                        return CheckboxListTile(
                          value: selectedSortBy.contains(item),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                selectedSortBy.add(item);
                              } else {
                                selectedSortBy.remove(item);
                              }
                            });
                          },
                          title: Text(item),
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Categories (still chips)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Categories",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("See All",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        "All Categories",
                        "Electronics",
                        "Fashion",
                        "Home & Living",
                        "Beauty & Personal Care",
                        "Accessories",
                        "Sports & Outdoor"
                      ].map((item) {
                        return ChoiceChip(
                          label: Text(item),
                          selected: category == item,
                          onSelected: (_) => setState(() => category = item),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ✅ Brand - Checkbox Format
                    const Text("Brand",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Column(
                      children: [
                        "Apple",
                        "Samsung",
                        "Sony",
                        "LG"
                      ].map((item) {
                        return CheckboxListTile(
                          value: selectedBrands.contains(item),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                selectedBrands.add(item);
                              } else {
                                selectedBrands.remove(item);
                              }
                            });
                          },
                          title: Text(item),
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Color (keep as before)
                    const Text("Color",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: [
                        Colors.black,
                        Colors.white,
                        Colors.orange,
                        Colors.blue,
                        Colors.brown,
                        Colors.red
                      ].map((clr) {
                        return GestureDetector(
                          onTap: () {
                            setState(() => color = clr.toString());
                          },
                          child: CircleAvatar(
                            backgroundColor: clr,
                            radius: 18,
                            child: color == clr.toString()
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Variants (keep as chips)
                    const Text("Variants",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: ["XS", "S", "M", "L", "XL", "XXL"]
                          .map((sizeOption) {
                        return ChoiceChip(
                          label: Text(sizeOption),
                          selected: size == sizeOption,
                          onSelected: (_) =>
                              setState(() => size = sizeOption),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Price Range
                    const Text("Price Range",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Slider(
                      value: price,
                      min: 0,
                      max: maxPrice,
                      divisions: 20,
                      activeColor: Colors.orange,
                      label: "\$${price.toStringAsFixed(0)}",
                      onChanged: (value) =>
                          setState(() => price = value),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("\$0"),
                        Text("\$2000"),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Rating (keep as chips with stars)
                    const Text("Rating",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 10,
                      children: ["5.0", "4.5+", "4.0+", "3.5+"].map((item) {
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.orange, size: 16),
                              const SizedBox(width: 4),
                              Text(item),
                            ],
                          ),
                          selected: rating == item,
                          onSelected: (_) =>
                              setState(() => rating = item),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ✅ Payment Method - Checkbox Format
                    const Text("Payment Method",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Column(
                      children: [
                        "COD",
                        "Google Pay",
                        "Credit Card",
                        "Debit Card",
                        "Pay Later"
                      ].map((item) {
                        return CheckboxListTile(
                          value: selectedPayments.contains(item),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                selectedPayments.add(item);
                              } else {
                                selectedPayments.remove(item);
                              }
                            });
                          },
                          title: Text(item),
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedSortBy.clear();
                          selectedBrands.clear();
                          selectedPayments.clear();
                          category = "";
                          color = "";
                          size = "";
                          price = 1000;
                          rating = "";
                        });
                      },
                      child: const Text("CLEAR ALL"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[900],
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("APPLY FILTER"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/


