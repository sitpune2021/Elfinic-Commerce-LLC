import 'package:flutter/material.dart';






// ------------------- SUBSCRIPTIONS SCREEN -------------------

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  bool isActive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF8F2),
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
        title: const Text(
          "Subscriptions",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _tabButton("ACTIVE", isActive, () {
                  setState(() => isActive = true);
                }),
                const SizedBox(width: 12),
                _tabButton("EXPIRED", !isActive, () {
                  setState(() => isActive = false);
                }),
              ],
            ),
          ),
          const Spacer(),
          const Text(
            "No Active Subscriptions Yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Once a subscription is active, it will appear here.",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD39A4A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            onPressed: () {},
            child: const Text("CHECK SUBSCRIPTIONS",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _tabButton(String text, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFD39A4A) : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.black12),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

