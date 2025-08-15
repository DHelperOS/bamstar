import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:socialPixel/components/auth_textfields.dart';
import 'package:socialPixel/components/primary_text_button.dart'; // Required for File

class FillYourProfileScreen extends StatefulWidget {
  const FillYourProfileScreen({super.key});

  @override
  State<FillYourProfileScreen> createState() => _FillYourProfileScreenState();
}

class _FillYourProfileScreenState extends State<FillYourProfileScreen> {
  // Placeholder for profile image file
  String? _profileImageUrl = 'https://picsum.photos/200/200?random=42';

  final TextEditingController _fullNameController = TextEditingController(
    text: 'John Doe',
  );
  final TextEditingController _usernameController = TextEditingController(
    text: 'john_doe',
  );
  final TextEditingController _dobController = TextEditingController(
    text: '12/27/1995',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'john_doe@yourdomain.com',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '+1 111 467 378 399',
  );
  final TextEditingController _professionController = TextEditingController(
    text: 'UI/UX Designer',
  );

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  // Function to show the image selection dialog (reused from ProfileScreen)
  void _showImagePickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(
                  'Capture from Camera',
                  style: GoogleFonts.plusJakartaSans(fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(bc); // Close the bottom sheet
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(
                  'Pick from Gallery',
                  style: GoogleFonts.plusJakartaSans(fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(bc); // Close the bottom sheet
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 10), // Add some space at the bottom
            ],
          ),
        );
      },
    );
  }

  // Function to pick image using image_picker (reused from ProfileScreen)
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _profileImageUrl = image.path; // Update image URL with local path
        });
        // In a real app, you'd upload this image to a server and update the profile with the returned URL.
      } else {}
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  // Custom Input Field Widget (emulating search_field style)
  Widget _buildCustomInputField({
    required TextEditingController controller,
    String? hintText,
    bool readOnly = false,
    Widget? suffixIcon,
    VoidCallback? onTap,
    TextInputType? keyboardType,
  }) {
    return Ink(
      decoration: BoxDecoration(
        color: Colors.white, // Lighter grey background as per UIKit template
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: .5,
          color: Colors.grey.withValues(alpha: 0.5),
        ),
        // Slightly rounded corners
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: Colors.grey.withValues(alpha: 0.07),
        splashColor: Colors.grey.withValues(alpha: 0.1),
        highlightColor: Colors.grey.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            keyboardType: keyboardType,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.plusJakartaSans(
                color: Colors.grey,
                fontSize: 16,
              ),
              border: InputBorder.none,
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    );
  }

  // Custom Phone Input Field Widget (emulating the specific phone field in the image)

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // Back arrow icon
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.black, // Set icon color to black explicitly
        ),
        title: Text(
          'Fill Your Profile',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700, // Semi-bold as per existing app bars
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: false, // Align title to the left
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Avatar and Edit Icon
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60, // Larger avatar
                      backgroundImage:
                          _profileImageUrl!.startsWith('http')
                              ? NetworkImage(_profileImageUrl!) as ImageProvider
                              : FileImage(
                                File(_profileImageUrl!),
                              ), // Use FileImage for local paths
                      backgroundColor: Colors.grey[300],
                    ),
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showImagePickerDialog(context),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                primaryColor, // Use primaryColor for edit icon
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ), // White border
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.edit, // Edit icon
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Full Name
                AuthTextfields().buildTextField(
                  controller: _fullNameController,
                  labelText: "Name",
                ),
                const SizedBox(height: 16),

                // Username
                AuthTextfields().buildTextField(
                  controller: _usernameController,
                  labelText: "Username",
                ),
                const SizedBox(height: 16),

                // Date of Birth
                _buildCustomInputField(
                  controller: _dobController,
                  hintText: '12/27/1995',
                  readOnly: true,
                  suffixIcon: Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey[400],
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime(1995, 12, 27),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: primaryColor, // header background color
                              onPrimary: Colors.white, // header text color
                              onSurface: Colors.black, // body text color
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    primaryColor, // button text color
                              ),
                            ),
                            textTheme: GoogleFonts.plusJakartaSansTextTheme(
                              Theme.of(context).textTheme,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dobController.text =
                            "${pickedDate.month}/${pickedDate.day}/${pickedDate.year}";
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Email
                AuthTextfields().buildTextField(
                  controller: _emailController,
                  labelText: "Email",
                ),
                const SizedBox(height: 16),

                // Phone Number
                // AuthTextfields().buildTextField(
                //   controller: _phoneController,
                //   labelText: "Phone Number With Code",
                // ),
                Row(
                  children: [
                    // Country code text field
                    SizedBox(
                      width: 80,
                      child: AuthTextfields().buildTextField(
                        controller: TextEditingController(),
                        labelText: "Code",
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: AuthTextfields().buildTextField(
                        controller: TextEditingController(),
                        labelText: "Number",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Profession
                AuthTextfields().buildTextField(
                  controller: _professionController,
                  labelText: "Profession",
                ),
                const SizedBox(
                  height: 100,
                ), // Space for the fixed button at the bottom
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.white,
              child: PrimaryTextButton(text: "Continue"),
            ),
          ),
        ],
      ),
    );
  }
}
