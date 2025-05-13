import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supatha_shuttles/features/auth/data/firebase_auth_repo.dart';
import 'package:supatha_shuttles/features/auth/presentation/components/loading.dart';
import 'package:supatha_shuttles/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:supatha_shuttles/features/auth/presentation/cubits/auth_states.dart';
import 'package:supatha_shuttles/features/auth/presentation/pages/auth_page.dart';
import 'package:supatha_shuttles/features/home/presentation/pages/home_page.dart';
import 'package:supatha_shuttles/firebase_options.dart';
import 'package:supatha_shuttles/themes/dark_mode.dart';
import 'package:supatha_shuttles/themes/light_mode.dart';

void main() async {
//Firebase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({
    super.key,
  });

  final firebaseAuthRepo = FirebaseAuthRepo();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        darkTheme: darkMode,
        home: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, state) {
            // ignore: avoid_print
            print(state);

            //unauthenticated -> auth page (login/register)
            if (state is Unauthenticated) {
              return const AuthPage();
            }

            //authenticated -> home page
            if (state is Authenticated) {
              return const HomePage();
            }

            // loading
            else {
              return const LoadingScreen();
            }
          },
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
      ),
    );
  }
}
