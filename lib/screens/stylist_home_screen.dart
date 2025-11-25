import 'package:flutter/material.dart';
import 'stylist_schedule_screen.dart';
import 'stylist_appointments_screen.dart';
import 'stylist_profile_screen.dart';

// Color scheme matching the design
const Color _darkGreen = Color(0xFF2D5016);
const Color _lightBeige = Color(0xFFF5E6D3);

class StylistHomeScreen extends StatefulWidget {
  const StylistHomeScreen({super.key});

  @override
  State<StylistHomeScreen> createState() => _StylistHomeScreenState();
}

class _StylistHomeScreenState extends State<StylistHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const StylistScheduleScreen(),
    const StylistAppointmentsScreen(),
    const StylistProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBeige,
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: _currentIndex,
        indicatorColor: _darkGreen.withOpacity(0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Lịch làm việc',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Lịch hẹn',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}

