import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:attaqwa_finance/screens/auth/login_screen.dart';
import 'package:attaqwa_finance/screens/main/main_screen.dart';
import 'package:attaqwa_finance/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('id_ID', null);
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const AttaqwaFinanceApp());
}

class AttaqwaFinanceApp extends StatelessWidget {
  const AttaqwaFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attaqwa Finance',
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _getInitialSession();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      setState(() {
        _user = data.session?.user;
      });
    });
  }

  Future<void> _getInitialSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    setState(() {
      _user = session?.user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _user == null ? const LoginScreen() : const MainScreen();
  }
}