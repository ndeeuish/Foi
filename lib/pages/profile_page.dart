import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foi/auth/database/firestore.dart';
import 'package:foi/auth/services/auth_service.dart';
import 'package:foi/auth/services/delivery_service.dart';
import 'package:foi/auth/services/geocoding_service.dart';
import 'package:foi/components/my_change_password_dialog.dart';
import 'package:foi/components/my_profile_details.dart';
import 'package:foi/components/profile_header.dart';
import 'package:foi/models/restaurant.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  // Khai báo các service sẽ được khởi tạo sau
  late DeliveryService _deliveryService;
  late Restaurant _restaurant;
  late GeocodingService _geocodingService;
  bool _servicesInitialized = false;

  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  String? _errorMessage;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Khởi tạo services ngay khi context có sẵn
    if (!_servicesInitialized) {
      try {
        _deliveryService = Provider.of<DeliveryService>(context, listen: false);
        _restaurant = Provider.of<Restaurant>(context, listen: false);
        _geocodingService =
            Provider.of<GeocodingService>(context, listen: false);
        _servicesInitialized = true;
      } catch (e) {
        print('Error initializing services: $e');
        setState(() {
          _errorMessage = 'Failed to initialize services: $e';
          _isLoading = false;
        });
      }
    }
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
    if (!_servicesInitialized) {
      setState(() {
        _errorMessage = 'Services not initialized. Please try again.';
        _isSaving = false;
      });
      return;
    }

    try {
      setState(() {
        _isSaving = true;
        _errorMessage = null;
      });

      final user = _authService.getCurrentUser();
      if (user != null) {
        // Cập nhật thông tin cơ bản trước
        await _firestoreService.updateUserProfile(user.uid, {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
        });

        // Sau đó cập nhật thông tin giao hàng
        if (context.mounted) {
          final newAddress = _addressController.text.trim();

          try {
            if (newAddress.isNotEmpty) {
              // Sử dụng biến instance thay vì đọc từ context
              // Geocode address
              final customerLocation =
                  await _geocodingService.getCoordinatesFromAddress(newAddress);

              // Calculate fee and time
              final results =
                  await _deliveryService.calculateDeliveryFeeAndTime(
                _deliveryService.defaultRestaurantLocation,
                customerLocation,
              );

              final fee = (results['fee'] as int).toDouble();
              final time = results['time'] as String;

              // Update Restaurant
              _restaurant.setDeliveryFee(fee);
              _restaurant.setEstimatedTime(time);
              _restaurant.updateDeliveryAddress(newAddress);

              // Update DeliveryService
              await _deliveryService.updateDeliveryDetailsWithLatLng(
                  newAddress, customerLocation);

              print(
                  'ProfilePage - Updated address: $newAddress, fee: ${_restaurant.formatPrice(fee)}, time: $time');
            } else {
              // Reset if address is empty
              _restaurant.setDeliveryFee(12000);
              _restaurant.setEstimatedTime("N/A");
              _restaurant.updateDeliveryAddress("");
              await _deliveryService.updateDeliveryDetails("");
            }
          } catch (deliveryError) {
            print('Error updating delivery details: $deliveryError');
            // Thêm log lỗi nhưng không dừng việc lưu profile
          }
        }

        await _fetchUserProfile();
        if (context.mounted) {
          setState(() {
            _isEditing = false;
            _isSaving = false;
          });
        }
      }
    } catch (e, stackTrace) {
      print('Error saving profile: $e');
      print('Stack trace: $stackTrace');
      if (context.mounted) {
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
          _isSaving = false;
        });
      }
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
      body: _isLoading || _isSaving
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
                                  style: TextStyle(color: Colors.black),
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
                                  style: TextStyle(color: Colors.black),
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
