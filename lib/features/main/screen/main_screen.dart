import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:waste_classification_app/features/history/presentation/screen/history_screen.dart';
import 'package:waste_classification_app/features/home/screens/home_screen.dart';

import '../../map/map_screen.dart';
import '../../profile/presentation/screen/person_screen.dart';
import '../../scan/presentation/screens/scan_screen.dart';
import '../cubit/main_cubit.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  final List<Widget> _pages = const [
    HomeScreen(),
    MapScreen(),
    ScanScreen(),
    HistoryScreen(),
    PersonScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MainCubit(),
      child: Builder(
        builder: (context) {
          return BlocBuilder<MainCubit, int>(
            builder: (context, currentIndex) {
              return Scaffold(
                body: IndexedStack(index: currentIndex, children: _pages),
                bottomNavigationBar: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SalomonBottomBar(
                    currentIndex: currentIndex,
                    onTap: (index) => context.read<MainCubit>().chage(index),
                    selectedItemColor: const Color(0xFF2E7D32),
                    unselectedItemColor: Colors.grey,
                    items: [
                      SalomonBottomBarItem(
                        icon: const Icon(Icons.home),
                        title: const Text('Trang chủ'),
                      ),
                      SalomonBottomBarItem(
                        icon: const Icon(Icons.map_outlined),
                        title: const Text('Map'),
                      ),
                      SalomonBottomBarItem(
                        icon: const Icon(Icons.qr_code_scanner_rounded),
                        title: const Text('Quét Rác'),
                      ),
                      SalomonBottomBarItem(
                        icon: const Icon(Icons.history),
                        title: const Text('Lịch sử'),
                      ),
                      SalomonBottomBarItem(
                        icon: const Icon(Icons.person),
                        title: const Text('Cá nhân'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
