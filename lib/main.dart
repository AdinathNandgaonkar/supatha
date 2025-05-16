import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supatha_shuttles/features/auth/data/firebase_auth_repo.dart';
import 'package:supatha_shuttles/features/auth/presentation/components/loading.dart';
import 'package:supatha_shuttles/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:supatha_shuttles/features/auth/presentation/cubits/auth_states.dart';
import 'package:supatha_shuttles/features/auth/presentation/cubits/theme_cubit.dart';
import 'package:supatha_shuttles/features/auth/presentation/pages/auth_page.dart';
import 'package:supatha_shuttles/features/home/presentation/pages/home_page.dart';
import 'package:supatha_shuttles/firebase_options.dart';
import 'package:supatha_shuttles/themes/dark_mode.dart';
import 'package:supatha_shuttles/themes/light_mode.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(MainApp(prefs: prefs));
}

class MainApp extends StatelessWidget {
  final SharedPreferences prefs;
  final FirebaseAuthRepo firebaseAuthRepo = FirebaseAuthRepo();

  MainApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(prefs),
        ),
      ],
      child: BlocBuilder<ThemeCubit, AppTheme>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: lightMode,
            darkTheme: darkMode,
            themeMode: themeState == AppTheme.system
                ? ThemeMode.system // Follow phone settings
                : (themeState == AppTheme.light
                    ? ThemeMode.light
                    : ThemeMode.dark),
            home: BlocConsumer<AuthCubit, AuthState>(
              builder: (context, state) {
                if (state is Unauthenticated) return const AuthPage();
                if (state is Authenticated) return const HomePage();
                return const LoadingScreen();
              },
              listener: (context, state) {
                if (state is AuthError) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
            ),
          );
        },
      ),
    );
  }
}
