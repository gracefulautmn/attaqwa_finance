import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:attaqwa_finance/theme/app_theme.dart';

class ConnectionCheckScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onError;

  const ConnectionCheckScreen({
    super.key,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<ConnectionCheckScreen> createState() => _ConnectionCheckScreenState();
}

class _ConnectionCheckScreenState extends State<ConnectionCheckScreen> {
  String _statusMessage = 'Memeriksa koneksi...';
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _checkSupabaseConnection();
  }

  Future<void> _checkSupabaseConnection() async {
    try {
      setState(() {
        _statusMessage = 'Memeriksa koneksi ke server...';
        _isRetrying = false;
      });

      final client = Supabase.instance.client;
      
      await client
          .from('categories')
          .select('count')
          .limit(1)
          .timeout(const Duration(seconds: 10));

      setState(() {
        _statusMessage = 'Koneksi berhasil!';
      });

      await Future.delayed(const Duration(milliseconds: 500));
      
      widget.onSuccess();
    } catch (e) {
      setState(() {
        _statusMessage = 'Gagal terhubung ke server';
      });
      
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        _retryConnection();
      }
    }
  }

  Future<void> _retryConnection() async {
    setState(() {
      _isRetrying = true;
      _statusMessage = 'Mencoba kembali...';
    });
    
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      _checkSupabaseConnection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primary,
                      AppTheme.primaryVariant,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.mosque,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 32),
              
              Text(
                'Attaqwa Finance',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sistem Keuangan DKM Masjid',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
              const SizedBox(height: 24),
              
              Text(
                _statusMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              if (_statusMessage.contains('Gagal') && !_isRetrying)
                ElevatedButton(
                  onPressed: _retryConnection,
                  child: const Text('Coba Lagi'),
                ),
              
              if (_statusMessage.contains('Gagal'))
                TextButton(
                  onPressed: widget.onError,
                  child: const Text('Lanjutkan Tanpa Koneksi'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
