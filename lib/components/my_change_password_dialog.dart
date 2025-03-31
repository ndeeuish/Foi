import 'package:flutter/material.dart';
import 'package:foi/auth/services/auth_service.dart';

class ChangePasswordDialog extends StatefulWidget {
  final AuthService authService;

  const ChangePasswordDialog({super.key, required this.authService});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Change Password"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _currentPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Current Password",
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "New Password",
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _confirmNewPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Confirm New Password",
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _currentPasswordController.clear();
            _newPasswordController.clear();
            _confirmNewPasswordController.clear();
            Navigator.pop(context);
          },
          child: const Text(
            "Cancel",
            style: const TextStyle(color: Colors.black),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            String currentPassword = _currentPasswordController.text.trim();
            String newPassword = _newPasswordController.text.trim();
            String confirmNewPassword =
                _confirmNewPasswordController.text.trim();

            if (currentPassword.isEmpty ||
                newPassword.isEmpty ||
                confirmNewPassword.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please fill in all fields")),
              );
              return;
            }

            if (newPassword.length < 6) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text("New password must be at least 6 characters")),
              );
              return;
            }

            if (newPassword != confirmNewPassword) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("New passwords do not match")),
              );
              return;
            }

            try {
              await widget.authService
                  .changePassword(currentPassword, newPassword);
              if (mounted) {
                Navigator.pop(context);
                _currentPasswordController.clear();
                _newPasswordController.clear();
                _confirmNewPasswordController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Password changed successfully!")),
                );
              }
            } catch (e) {
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          "Error: ${e.toString().replaceAll("Exception: ", "")}")),
                );
              }
            }
          },
          child: const Text(
            "Change",
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}
