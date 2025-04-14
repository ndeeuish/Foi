import 'package:flutter/material.dart';

class ProfileDetails extends StatelessWidget {
  final Map<String, dynamic> userProfile;
  final bool isEditing;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final VoidCallback? onChangePassword;

  const ProfileDetails({
    super.key,
    required this.userProfile,
    required this.isEditing,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    this.onChangePassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Profile details",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                AnimatedCrossFade(
                  firstChild: _buildProfileField(
                    "Name",
                    userProfile['name'] ?? "N/A",
                    Icons.person,
                    context,
                  ),
                  secondChild: _buildEditableField(
                    "Name",
                    nameController,
                    Icons.person,
                    context,
                  ),
                  crossFadeState: isEditing
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
                const Divider(height: 24),
                _buildProfileField(
                  "Email",
                  userProfile['email'] ?? "N/A",
                  Icons.email,
                  context,
                ),
                const Divider(height: 24),
                AnimatedCrossFade(
                  firstChild: _buildProfileField(
                    "Phone",
                    userProfile['phone'] ?? "N/A",
                    Icons.phone,
                    context,
                  ),
                  secondChild: _buildEditableField(
                    "Phone",
                    phoneController,
                    Icons.phone,
                    context,
                  ),
                  crossFadeState: isEditing
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
                const Divider(height: 24),
                AnimatedCrossFade(
                  firstChild: _buildProfileField(
                    "Address",
                    userProfile['address'] ?? "N/A",
                    Icons.location_on,
                    context,
                  ),
                  secondChild: _buildEditableField(
                    "Address",
                    addressController,
                    Icons.location_on,
                    context,
                  ),
                  crossFadeState: isEditing
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
                if (!isEditing && userProfile['loginMethod'] == 'email') ...[
                  const Divider(height: 24),
                  ListTile(
                    leading: const Icon(
                      Icons.lock,
                      color: Colors.grey,
                      size: 28,
                    ),
                    title: const Text(
                      "Change Password",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 16,
                    ),
                    onTap: onChangePassword,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileField(
      String label, String value, IconData icon, BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
        size: 28,
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller,
      IconData icon, BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
        size: 28,
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
