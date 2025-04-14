import 'package:flutter/material.dart';
import 'package:foi/auth/database/firestore.dart';
import 'package:foi/auth/services/auth_service.dart';
import 'package:foi/components/my_change_password_dialog.dart';
import 'package:foi/components/my_profile_details.dart';
import 'package:foi/components/profile_header.dart';
import 'package:foi/models/restaurant.dart';
import 'package:foi/auth/services/delivery_service.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  bool _isEditing = false;
  String? _errorMessage;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final profile = await _authService.getUserProfile();
      setState(() {
        _userProfile = profile;
        _nameController.text = profile['name'] ?? '';
        _phoneController.text = profile['phone'] ?? '';
        _addressController.text = profile['address'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final user = _authService.getCurrentUser();
      if (user != null) {
        await _firestoreService.updateUserProfile(user.uid, {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
        });

        // Update delivery address in Restaurant and DeliveryService
        if (context.mounted) {
          context
              .read<Restaurant>()
              .updateDeliveryAddress(_addressController.text);
          context
              .read<DeliveryService>()
              .updateDeliveryDetails(_addressController.text);
        }

        await _fetchUserProfile();
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Error: $_errorMessage",
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchUserProfile,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                            child: ProfileHeader(userProfile: _userProfile!)),
                        const SizedBox(height: 20),
                        ProfileDetails(
                          userProfile: _userProfile!,
                          isEditing: _isEditing,
                          nameController: _nameController,
                          phoneController: _phoneController,
                          addressController: _addressController,
                          onChangePassword: () {
                            showDialog(
                              context: context,
                              builder: (context) => ChangePasswordDialog(
                                  authService: _authService),
                            );
                          },
                        ),
                        if (_isEditing) ...[
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _saveProfile,
                                child: const Text(
                                  "Save",
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = false;
                                    _nameController.text =
                                        _userProfile?['name'] ?? '';
                                    _phoneController.text =
                                        _userProfile?['phone'] ?? '';
                                    _addressController.text =
                                        _userProfile?['address'] ?? '';
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey),
                                child: const Text(
                                  "Cancel",
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }
}
