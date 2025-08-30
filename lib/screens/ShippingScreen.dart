import 'package:flutter/material.dart';





// ------------------- Shipping Screen -------------------
class ShippingScreen extends StatefulWidget {
  const ShippingScreen({super.key});

  @override
  State<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<ShippingScreen> {
  final _formKey = GlobalKey<FormState>();
  String? gstOption;
  bool useBillingAddress = false;

  String? selectedCity;
  String? selectedRegion;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffdf6ef),
      appBar: AppBar(
        backgroundColor: const Color(0xfffdf6ef),
        surfaceTintColor:Color(0xfffdf6ef),
        elevation: 0,
        // leading: const Icon(Icons.arrow_back, color: Colors.black),
        leading:  IconButton(
          icon: Icon(
            Icons.arrow_back_sharp,
            color: Colors.black,
            // size: screenWidth * 0.07,
          ),
          onPressed: () {
            Navigator.pop(context); // go back to previous screen
          },
        ),
        title: const Text("Checkout",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("₹299,38",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Estimated Total",
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  stepBox("1 SHIPPING", true),
                  stepBox("2 DELIVERY", false),
                  stepBox("3 REVIEW", false),
                ],
              ),
              const SizedBox(height: 20),
              _label("First Name*"),
              _textField(hint: "Shubham"),

              _label("Last Name*"),
              _textField(hint: "Shubham"),
              _label("Mobile Number"),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      children: [
                        Text("+91"),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _textField(hint: "Mobile Number")),
                ],
              ),

              _label("Do you have GST Number*"),
              _dropdown(["Yes", "No"], gstOption, (val) {
                setState(() => gstOption = val);
              }),
              _label("Company Name*"),
              _textField(hint: "Shubham"),

              _label("Enter your GST Number*"),
              _textField(hint: "Shubham"),
              const SizedBox(height: 20),
              const Text(
                "Residential Details",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              _label("Country/ Region*"),
              _dropdown(["India(IN)"], "India(IN)", (val) {}),

              _label("Address*"),
              _textField(
                hint: "Satara Road, Pune",
                suffixIcon: const Icon(Icons.location_on_outlined),
              ),

              _label("Address Line 2*"),
              _textField(),

              _label("City*"),
              _dropdown(["Pune", "Mumbai", "Delhi"], selectedCity, (val) {
                setState(() => selectedCity = val);
              }),

              _label("Region*"),
              _dropdown(["Maharashtra", "Karnataka"], selectedRegion, (val) {
                setState(() => selectedRegion = val);
              }),

              _label("Zip/ Postal Code*"),
              _textField(hint: "411038"),


              Row(
                children: [
                  Checkbox(
                    value: useBillingAddress,
                    onChanged: (val) {
                      setState(() => useBillingAddress = val!);
                    },
                  ),
                  const Text("Use as Billing Address"),
                ],
              ),
              const SizedBox(height: 20),
              mainButton("CONTINUE", () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DeliveryScreen()));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF160042),
        ),
      ),
    );
  }

  Widget _textField({String? hint, Widget? suffixIcon}) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.black87, width: 1.2),
        ),
      ),
    );
  }



  Widget _dropdown(
      List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        hint: const Text("Select Option"),
        items: items
            .map((e) => DropdownMenuItem(
          value: e,
          child: Text(e),
        ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// ------------------- Delivery Screen -------------------
class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  String delivery = "Standard";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffdf6ef),
      appBar: AppBar(
        backgroundColor: const Color(0xfffdf6ef),
        surfaceTintColor:Color(0xfffdf6ef),
        elevation: 0,
        // leading: const Icon(Icons.arrow_back, color: Colors.black),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_sharp,
            color: Colors.black,
            // size: screenWidth * 0.07,
          ),
          onPressed: () {
            Navigator.pop(context); // go back to previous screen
          },
        ),
        title: const Text("Checkout",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("₹299,38",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Estimated Total",
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                stepBox("1 SHIPPING", false),
                stepBox("2 DELIVERY", true),
                stepBox("3 REVIEW", false),
              ],
            ),
            const SizedBox(height: 20),

            RadioListTile(
              value: "Standard",
              groupValue: delivery,
              onChanged: (val) => setState(() => delivery = val.toString()),
              title: const Text("Standard Shipping"),
              subtitle: const Text("6-7 Business Days"),
              secondary: const Text("₹99.00",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            RadioListTile(
              value: "Express",
              groupValue: delivery,
              onChanged: (val) => setState(() => delivery = val.toString()),
              title: const Text("Express Delivery"),
              subtitle: const Text("1-2 Business Days"),
              secondary: const Text("₹299.00",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            const Spacer(),
            mainButton("REVIEW YOUR ORDER", () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ReviewScreen()));
            }),
          ],
        ),
      ),
    );
  }
}

// ------------------- Review Screen -------------------
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffdf6ef),
      appBar: AppBar(
        surfaceTintColor:Color(0xfffdf6ef),
        backgroundColor: const Color(0xfffdf6ef),
        elevation: 0,
        // leading: const Icon(Icons.arrow_back, color: Colors.black),
        leading:  IconButton(
          icon: Icon(
            Icons.arrow_back_sharp,
            color: Colors.black,
            // size: screenWidth * 0.07,
          ),
          onPressed: () {
            Navigator.pop(context); // go back to previous screen
          },
        ),

        title: const Text("Checkout",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("₹299,38",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Estimated Total",
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                stepBox("1 SHIPPING", false),
                stepBox("2 DELIVERY", false),
                stepBox("3 REVIEW", true),
              ],
            ),
            const SizedBox(height: 20),

            const Text("Order Summary",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(
              leading: Image.asset("assets/images/w1.png"),
              title: const Text("Lorem ipsum dolor sit amet consectetur."),
              subtitle: const Text("Size: 09"),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text("₹1,500.00",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("₹4,148.00",
                      style: TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey)),
                ],
              ),
            ),
            const Divider(),

            const Text("Promo Code"),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: inputDecoration("e.g. SAVE50"),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400),
                  onPressed: () {},
                  child: const Text("APPLY"),
                )
              ],
            ),
            const SizedBox(height: 20),

            const Text("Add Note"),
            TextFormField(
              decoration:
              inputDecoration("e.g. Leave outside the door"),
            ),
            const SizedBox(height: 20),

            const Text("Payment Detail",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            summaryRow("Subtotal", "₹1,823.90"),
            summaryRow("Shipment Fee", "Free", color: Colors.green),
            summaryRow("GST", "₹344.59"),
            const Divider(),
            summaryRow("Total Payment", "₹2,485.23",
                isBold: true, fontSize: 18),

            const SizedBox(height: 20),
            CheckboxListTile(
              value: false,
              onChanged: (v) {},
              title: const Text.rich(TextSpan(children: [
                TextSpan(text: "I agree to the "),
                TextSpan(
                    text: "Terms & Conditions, Privacy Policy, Return Policy",
                    style: TextStyle(color: Colors.blue)),
                TextSpan(text: " and "),
                TextSpan(
                    text: "Contact Seller",
                    style: TextStyle(color: Colors.blue)),
              ])),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              value: false,
              onChanged: (v) {},
              title: const Text(
                  "Send me marketing communications via email and SMS"),
              controlAffinity: ListTileControlAffinity.leading,
            ),

            const SizedBox(height: 20),
            mainButton("CONTINUE TO PAYMENT", () {
              showDialog(
                context: context,
                builder: (context) => const OrderSuccessDialog(),
              );

            }),
          ],
        ),
      ),
    );
  }
}


class OrderSuccessDialog extends StatelessWidget {
  const OrderSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFDF6EF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Green check icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                shape: BoxShape.circle,
              ),
              child:  Icon(
                Icons.check,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              "Order Placed Successful!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Subtitle
            const Text(
              "You have successfully placed order",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: const BorderSide(color: Colors.black87, width: 1.5),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "EXPLORE MORE",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12), // gap between buttons
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "VIEW ORDER",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            )

          ],
        ),
      ),
    );
  }
}


// ------------------- Widgets -------------------
Widget stepBox(String text, bool active) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: active ? Colors.amber : Colors.white,
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
          child: Text(text,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: active ? Colors.white : Colors.black))),
    ),
  );
}

InputDecoration inputDecoration(String label, {Widget? suffixIcon}) {
  return InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
    suffixIcon: suffixIcon,
  );
}

Widget buildTextField(String label, String value, {String prefix = "", Widget? suffixIcon}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: TextFormField(
      decoration: inputDecoration(label, suffixIcon: suffixIcon).copyWith(
        hintText: value,
        prefixText: prefix,
      ),
    ),
  );
}

Widget mainButton(String text, VoidCallback onPressed) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo.shade900,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: onPressed,
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );
}

Widget summaryRow(String title, String value,
    {bool isBold = false, double fontSize = 14, Color? color}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: fontSize)),
        Text(value,
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: fontSize,
                color: color ?? Colors.black)),
      ],
    ),
  );
}
