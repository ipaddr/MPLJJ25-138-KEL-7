import 'package:flutter/material.dart';
import 'package:lunchguard/features/school/presentation/screens/catering_list_screen.dart';
import 'package:lunchguard/features/school/presentation/screens/home_screen.dart';
import 'package:lunchguard/features/school/presentation/screens/order_history_screen.dart';
import 'package:lunchguard/features/school/presentation/screens/report_list_screen.dart';
import 'package:lunchguard/features/school/presentation/screens/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const CateringListScreen(),
    const OrderHistoryScreen(),
    const ReportListScreen(),
    const SettingsScreen(),
  ];

  final List<String> _titles = const [
    'Pesanan Aktif',
    'Pilih Katering',
    'Riwayat Pesanan',
    'Laporan Saya',
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
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Katering',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
