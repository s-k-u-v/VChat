import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import '../providers/authentication_provider.dart';
import '../services/cloud_storage_service.dart';
import '../services/media_service.dart';
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';
import 'package:file_picker/file_picker.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final _registerFormKey = GlobalKey<FormState>();
  String? _email;
  String? _password;
  String? _name;
  PlatformFile? _profileImage;

  // Create controllers for the input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    final cloudStorageService = GetIt.instance.get<CloudStorageService>();
    final mediaService = GetIt.instance.get<MediaService>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _registerFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  _profileImage = await mediaService.pickImageFromLibrary();
                  setState(() {});
                },
                child: _profileImage != null
                    ? Image.file(File(_profileImage!.path!), height: 100)
                    : Container(height: 100, color: Colors.grey),
              ),
              SizedBox(height: 16),
              CustomTextFormField(
                controller: _nameController, // Pass the name controller
                onSaved: (value) =>
                    _name = value.isNotEmpty == true ? value : null,
                regEx: r".{1,}",
                hintText: "Name",
                obscureText: false,
              ),
              SizedBox(height: 16),
              CustomTextFormField(
                controller: _emailController, // Pass the email controller
                onSaved: (value) =>
                    _email = value.isNotEmpty == true ? value : null,
                regEx:
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                hintText: "Email",
                obscureText: false,
              ),
              SizedBox(height: 16),
              CustomTextFormField(
                controller: _passwordController, // Pass the password controller
                onSaved: (value) =>
                    _password = value.isNotEmpty == true ? value : null,
                regEx: r".{8,}",
                hintText: "Password",
                obscureText: true,
              ),
              SizedBox(height: 16),
              RoundedButton(
                name: "Register",
                height: 50,
                width: 200,
                onPressed: () async {
                  if (_registerFormKey.currentState!.validate() &&
                      _profileImage != null) {
                    _registerFormKey.currentState!.save();

                    // Ensure that none of the variables are null before proceeding
                    if (_email != null && _password != null && _name != null) {
                      // Attempt to register the user
                      String? uid =
                          await authProvider.registerUserUsingEmailAndPassword(
                              _email!, _password!);

                      // Check if the uid is not null, meaning the registration was successful
                      if (uid != null) {
                        String? imageURL = await cloudStorageService
                            .saveUserImageToStorage(uid, _profileImage!);
                        await authProvider.createUser(
                            uid, _email!, _name!, imageURL!);
                        Navigator.pop(context);
                      } else {
                        // Handle the case where the uid is null (registration failed)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Registration failed. Please try again.')),
                        );
                      }
                    } else {
                      // Handle null cases appropriately
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Please fill in all fields correctly.')),
                      );
                    }
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
