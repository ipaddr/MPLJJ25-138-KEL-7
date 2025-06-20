import 'package:flutter/material.dart';
import 'package:lunchguard/features/catering/presentation/screens/home_screen.dart';
import 'package:lunchguard/features/catering/presentation/screens/incoming_reports_screen.dart';
import 'package:lunchguard/features/catering/presentation/screens/menu_management_screen.dart';
import 'package:lunchguard/features/catering/presentation/screens/order_history_screen.dart';
import 'package:lunchguard/features/catering/presentation/screens/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const MenuManagementScreen(),
    const OrderHistoryScreen(),
    const IncomingReportsScreen(),
    const SettingsScreen(),
  ];

  final List<String> _titles = [
    'Pesanan Aktif',
    'Manajemen Menu',
    'Riwayat Pesanan',
    'Laporan Masuk',
    'Pengaturan'
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        // [HAPUS] Properti 'actions' dan IconButton untuk logout dihapus dari sini.
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Laporan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
