import 'package:ars/core/colors/app_colors.dart';
import 'package:ars/core/utils/constants.dart';
import 'package:ars/core/widgets/app_button.dart';
import 'package:ars/core/widgets/app_text.dart';
import 'package:ars/core/widgets/loading_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: kDebugMode ? 'frscadmin@frsc.com' : '');
  // final _emailController = TextEditingController(text: kDebugMode ? 'testofficer@gmail.com' : '');
  final _passwordController = TextEditingController(text: kDebugMode ? "P@ssw0rd" : '');
  // final _passwordController = TextEditingController(text: kDebugMode ? 'FRSC2025' : '');
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText("FRSC Accident Report System", fontWeight: FontWeight.bold,
              fontSize: 20, color: AppColors.primaryColor,),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 40),
              _loading
                  ? const LoadingAnimation()
                  : GradientButton(onTap: () async {
                setState(() => _loading = true);
                try {
                  await authProvider.login(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                  );
                  if (authProvider.userType == 'admin') {
                    final sharedPrefs = await SharedPreferences.getInstance();
                    sharedPrefs.setString(adminPasswrd, _passwordController.text);
                    context.go('/admin');
                  } else {
                    context.go('/officer');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login failed: $e')),
                  );
                }
                setState(() => _loading = false);
              }, label: "Login",),
            ],
          ),
        ),
      ),
    );
  }
}