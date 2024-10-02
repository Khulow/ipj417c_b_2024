import 'package:flutter/material.dart';
import 'package:ipj417c_b_2024/viewmodels/user_view_model.dart';
import 'package:ipj417c_b_2024/views/edit_profile_screen.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF0A2540),
        foregroundColor: Colors.white,
      ),
      body: Consumer<UserViewModel>(
        builder: (context, userViewModel, child) {
          if (userViewModel.user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildAvatar(userViewModel),
                const SizedBox(height: 16),
                Text(
                  userViewModel.user!.displayName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  userViewModel.user!.email,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                _buildListTile('Edit Profile', Icons.edit, () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EditProfileScreen()));
                }),
                _buildListTile('Preferences', Icons.settings, () {}),
                _buildListTile('My Listings', Icons.list, () {}),
                _buildListTile('Notifications', Icons.notifications, () {}),
                _buildListTile('Help & Support', Icons.help, () {}),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // Implement log out functionality
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFFFF4081),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Log Out', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(UserViewModel userViewModel) {
    if (userViewModel.user!.profilePictureUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(userViewModel.user!.profilePictureUrl),
      );
    } else {
      return CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey[300],
        child: Text(
          getInitials(userViewModel.user!.displayName),
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600]),
        ),
      );
    }
  }

  Widget _buildListTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  String getInitials(String name) {
    List<String> names = name.split(" ");
    String initials = "";
    int numWords = names.length > 2 ? 2 : names.length;
    for (int i = 0; i < numWords; i++) {
      initials += names[i][0].toUpperCase();
    }
    return initials;
  }
}
