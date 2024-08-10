import 'package:flutter/material.dart';
import 'package:rongo/screen/chatbot/chat.dart';
import 'package:rongo/screen/home/homepage.dart';
import 'package:rongo/screen/inventory/inventory_category.dart';
import 'package:rongo/screen/inventory/inventory_listview.dart';
import 'package:rongo/screen/inventory/inventory_tabs.dart';
import 'package:rongo/screen/onboarding/onboarding.dart';
import 'package:rongo/screen/recipe/recipe_homepage.dart';
import 'package:rongo/screen/scan_and_add/scanned_item_list.dart';
import 'package:rongo/screen/scan_and_add/scanner.dart';
import 'package:rongo/screen/notes/notespage.dart';
import 'package:rongo/utils/utils.dart';

class Routes {
  Routes._();

  static const String onboarding = '/onboarding';
  static const String scanner = '/scanner';
  static const String homepage = '/homepage';
  static const String recipeHomepage = '/recipe-homepage';
  static const String notespage = '/notespage';
  static const String scannedItemList = '/scanned-item-list';
  static const String inventoryCategory = '/inventory-category';
  static const String inventoryTabs = '/inventory-tabs';
  static const String inventoryListView = '/inventory-listview';
  static const String chat = '/chat';

  static final dynamic routes = <String, WidgetBuilder>{
    onboarding: (BuildContext context) => const OnboardingPage(),
    scanner: (BuildContext context) => const Scanner(),
    homepage: (BuildContext context) => const HomePage(),
    recipeHomepage: (BuildContext context) => const RecipeHomePage(),
    notespage: (BuildContext context) => const NotesPage(),
    scannedItemList: (BuildContext context) => const ScannedItemList(),
    inventoryCategory: (BuildContext context) => const InventoryCategory(),
    chat: (BuildContext context) => const ChatPage(),
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case inventoryListView:
        var args = settings.arguments as Map;
        List inventory = args['inventory'];
        String fridgeId = args['fridgeId'];
        InventoryFilter inventoryFilter = args['inventoryFilter'];
        String? currentCategory = args['currentCategory'];
        return MaterialPageRoute(builder: (_) => InventoryListview(
          inventory: inventory,
          fridgeId: fridgeId,
          inventoryFilter: inventoryFilter,
          currentCategory:currentCategory,
        ));
      case inventoryTabs:
        var args = settings.arguments as Map;
        InventoryFilter inventoryFilter = args['InventoryFilter'];
        String fridgeId = args['fridgeId'];
        return MaterialPageRoute(builder: (_) => InventoryTabs(inventoryFilter:inventoryFilter,fridgeId:fridgeId));
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                  child: Text('No route defined for ${settings.name}')),
            ));
    }
  }

}
