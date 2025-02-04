import 'package:flutter/material.dart';
import '../../models/login/login_request.dart';
import '../../utils/api_service.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../home_page.dart';
import '../register/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final loginRequest = LoginRequest(
      email: _emailController.text,
      password: _passwordController.text,
    );

    final result = await _apiService.login(loginRequest);

    if (!mounted) return; // ✅ Check before calling setState

    setState(() => _isLoading = false);

    if (!mounted) return; // ✅ Check before using context

    if (result['success']) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', result['access_token']);
      await prefs.setString('refresh_token', result['refresh_token']);
      await prefs.setBool('is_logged_in', true);

      if (!mounted) return; // ✅ Check before navigating

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(
            accessToken: result['access_token'],
            refreshToken: result['refresh_token'],
          ),
        ),
      );
    } else {
      if (!mounted) return; // ✅ Check before showing SnackBar

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                obscureText: true,
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _navigateToRegister,
                child: const Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
