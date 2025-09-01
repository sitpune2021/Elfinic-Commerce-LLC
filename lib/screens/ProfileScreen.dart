import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import 'EditProfileScreen.dart';
import 'OrdersScreen.dart';
import 'SubscriptionsScreen.dart';
import 'WishlistScreen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          // Top profile section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade700, Colors.orange.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile image
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(
                        "https://i.pravatar.cc/150?img=3", // Replace with user image
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 15),
                // Name and membership
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Shubham Chavan",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Private Member",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Joined on August 2025",
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
                const Spacer(),
                // Edit icon
                // Edit icon with click
                GestureDetector(
                  onTap: () {
                    // 👉 Navigate to Edit Profile screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );

                    // Or show a dialog / snackbar instead:
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(content: Text("Edit profile clicked")),
                    // );
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: Icon(Icons.edit, color: Colors.amber.shade700),
                  ),
                ),

                // CircleAvatar(
                //   backgroundColor: Colors.white.withOpacity(0.9),
                //   child: Icon(Icons.edit, color: Colors.amber.shade700),
                // ),
              ],
            ),
          ),

          // White content section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About Me
                  const Text(
                    "About Me",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Lorem ipsum dolor sit amet consectetur. Ornare at commodo pharetra integer hendrerit nibh duis et mi. "
                        "Nisl sed congue ullamcorper nibh nibh ultrices. Elementum convallis nullam euismod gravida.",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),

                  // Account Information
                  const Text(
                    "Account Information",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "See your info & activity as a member of Elfinic.com",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),

                  // // Options list
                  // _buildListTile(LineIcons.users, "Groups"),
                  // _buildListTile(Icons.shopping_bag_outlined, "Orders"),
                  // _buildListTile(Icons.favorite_border, "Wishlist"),
                  // _buildListTile(Icons.star_border, "Rewards"),
                  // _buildListTile(Icons.person_outline, "Subscriptions"),
                  // Options list with navigation
                  _buildListTile(LineIcons.users, "Groups", () {
                    // Navigate to GroupsScreen if you have one
                  }),
                  _buildListTile(Icons.shopping_bag_outlined, "Orders", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => OrdersScreen()),
                    );
                  }),
                  _buildListTile(Icons.favorite_border, "Wishlist", () {
                    // Navigate to WishlistScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => WishlistScreen()),
                    );
                  }),
                  _buildListTile(Icons.star_border, "Rewards", () {
                    // Navigate to RewardsScreen
                  }),
                  _buildListTile(Icons.person_outline, "Subscriptions", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SubscriptionsScreen()),
                    );
                  }),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo.shade900),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }

}
