import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waste_classification_app/features/history/screen/history_screen.dart';
import 'package:waste_classification_app/features/home/screens/home_screen.dart';

import '../../profile/screen/person_screen.dart';
import '../../scan_screen.dart';
import '../cubit/main_cubit.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _page = [
    HomeScreen(),
    ScanScreen(),
    HistoryScreen(),
    PersonScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainCubit(),
      child: BlocBuilder<MainCubit, int>(
        builder: (context, state) {
          return Scaffold(
            body: _page[state],
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF2E7D32),
              unselectedItemColor: Colors.grey.shade500,
              currentIndex: state,
              onTap: (value) => context.read<MainCubit>().chage(value),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Trang chủ',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code_scanner_rounded),
                  label: 'Quét rác',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'Lịch sử',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Cá nhân',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
