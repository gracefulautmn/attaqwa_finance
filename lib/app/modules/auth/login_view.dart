import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _supabase = Supabase.instance.client;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _isLoading = ValueNotifier<bool>(false);
  final _isSignUp = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _isLoading.dispose();
    _isSignUp.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    try {
      _isLoading.value = true;
      await _supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // Don't manually navigate - let the auth listener handle it
      if (mounted) {
        Get.snackbar(
          'Success',
          'Login berhasil!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        Get.snackbar(
          'Error',
          error.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (error) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Unexpected error occurred: $error',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        _isLoading.value = false;
      }
    }
  }

  Future<void> _signUp() async {
    try {
      _isLoading.value = true;
      await _supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (mounted) {
        Get.snackbar(
          'Success',
          'Check your email for verification link',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        _isSignUp.value = false;
      }
    } on AuthException catch (error) {
      if (mounted) {
        Get.snackbar(
          'Error',
          error.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (error) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Unexpected error occurred: $error',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        _isLoading.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Title
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Attaqwa Finance',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kelola keuangan dengan mudah',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Login Form
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ValueListenableBuilder<bool>(
                            valueListenable: _isSignUp,
                            builder: (context, isSignUp, child) {
                              return Text(
                                isSignUp ? 'Daftar Akun' : 'Masuk',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Submit Button
                          ValueListenableBuilder<bool>(
                            valueListenable: _isLoading,
                            builder: (context, isLoading, child) {
                              return ValueListenableBuilder<bool>(
                                valueListenable: _isSignUp,
                                builder: (context, isSignUp, child) {
                                  return ElevatedButton(
                                    onPressed: isLoading ? null : (isSignUp ? _signUp : _signIn),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(16),
                                      backgroundColor: Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: isLoading
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : Text(
                                            isSignUp ? 'Daftar' : 'Masuk',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Toggle Sign Up/Sign In
                          ValueListenableBuilder<bool>(
                            valueListenable: _isSignUp,
                            builder: (context, isSignUp, child) {
                              return TextButton(
                                onPressed: () {
                                  _isSignUp.value = !_isSignUp.value;
                                },
                                child: Text(
                                  isSignUp
                                      ? 'Sudah punya akun? Masuk'
                                      : 'Belum punya akun? Daftar',
                                ),
                              );
                            },
                          ),
                          
                          // Demo Login Button
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              _emailController.text = 'demo@attaqwa.com';
                              _passwordController.text = 'demo123456';
                              _signIn();
                            },
                            child: const Text(
                              'Demo Login (test)',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
