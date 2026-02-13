import 'package:flutter/material.dart';
import 'package:mealtrack/features/home/domain/home_tab.dart';
import 'package:mealtrack/features/home/presentation/widgets/home_fab.dart';
import 'package:mealtrack/features/home/presentation/widgets/home_navigation_bar.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';
import 'package:mealtrack/features/settings/presentation/settings_page.dart';
import 'package:mealtrack/features/sharing/presentation/sharing_page.dart';
import 'package:mealtrack/features/shoppinglist/presentation/shopping_list_page.dart';

Widget _buildSharingPage(BuildContext context) => const SharingPage();

Widget _buildSettingsPage(BuildContext context) => const SettingsPage();

class HomeMenu extends StatefulWidget {
  const HomeMenu({super.key});

  @override
  State<HomeMenu> createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  static const List<Widget> _pages = [
    InventoryPage(
      title: 'MealTrack',
      sharingPageBuilder: _buildSharingPage,
      settingsPageBuilder: _buildSettingsPage,
    ),
    ShoppingListPage(),
    SizedBox.shrink(), // Placeholder for Calories
    SizedBox.shrink(), // Placeholder for Statistics
  ];

  HomeTab _currentTab = HomeTab.inventory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: IndexedStack(index: _currentTab.index, children: _pages),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: 20.0 + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: HomeFab(currentTab: _currentTab),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: HomeNavigationBar(
        currentTab: _currentTab,
        onDestinationSelected: (tab) => setState(() => _currentTab = tab),
      ),
    );
  }
}
