import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/main_screen.dart';
import 'screens/auth/login_screen.dart';
import 'utils/app_config.dart';

import 'config/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize secure storage
    const secureStorage = FlutterSecureStorage();
    await secureStorage.deleteAll(); // Clear any existing data

    // Initialize Supabase
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      debug: true,
    );

    // Initialize shared preferences
    final prefs = await SharedPreferences.getInstance();

    // Run the app
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
          ChangeNotifierProvider(create: (_) => LanguageProvider(prefs)),
        ],
        child: const MyApp(),
      ),
    );
  } catch (error) {
    debugPrint('Error initializing app: $error');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Error initializing app: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Pet Care App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          locale: languageProvider.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('vi'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: StreamBuilder<AuthState>(
            stream: Supabase.instance.client.auth.onAuthStateChange,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final session = snapshot.data?.session;
                if (session != null) {
                  return const MainScreen();
                }
              }
              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}
