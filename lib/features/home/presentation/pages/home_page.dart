import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supatha_shuttles/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:supatha_shuttles/features/home/presentation/nav_bar/nav_bar_sizes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int navBarIndex = 0;
  List<Widget> navBarList = const [
    Text("All rides"),
    Text("Add rides"),
    Text("Your Rides"),
    Text("Profile")
  ];

  @override
  Widget build(BuildContext context) {
    final sizes = getNavBarSizes(context);
    final TextStyle optionStyle = TextStyle(
        fontSize: sizes.fontSize,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.inversePrimary);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        actions: [
          IconButton(
            onPressed: () {
              final authCubit = context.read<AuthCubit>();
              authCubit.logout();
            },
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GNav(
          onTabChange: (index) {
            setState(() {
              navBarIndex = index;
            });
          },
          selectedIndex: navBarIndex,
          iconSize: sizes.iconSize,
          tabBackgroundColor: Theme.of(context).colorScheme.primary,
          tabs: [
            GButton(
              icon: Icons.search,
              text: "  Search",
              textStyle: optionStyle,
            ),
            GButton(
              icon: Icons.add_outlined,
              text: "  Add",
              textStyle: optionStyle,
            ),
            GButton(
              icon: Icons.airport_shuttle_outlined,
              text: "  Rides",
              textStyle: optionStyle,
            ),
            GButton(
              icon: Icons.account_circle_outlined,
              text: "  Account",
              textStyle: optionStyle,
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [navBarList[navBarIndex]],
            ),
          ),
        ),
      ),
    );
  }
}
