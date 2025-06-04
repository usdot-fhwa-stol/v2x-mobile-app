import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:cv_mec/pages/dev_page.dart';
import 'package:cv_mec/pages/home_page.dart';
import 'package:cv_mec/pages/map_page.dart';
import 'package:cv_mec/pages/settings_page.dart';
import 'package:cv_mec/styles/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CVMecAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  CVMecAppBar({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: CVMECText.styleTwo(title != null ? title! : "CV-MEC"),
      actions: <Widget>[
        navigationMenu(context),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}

Widget navigationMenu(BuildContext context) {
  SettingsController settingsController = Get.find<SettingsController>();
  List<String> menuNoDev = ['Home', 'Map', 'Settings'];
  List<String> menuDev = ['Home', 'Map', 'Settings', 'Developer Page'];
  return PopupMenuButton<String>(
    icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.onPrimary),
    color: Theme.of(context).hoverColor,
    itemBuilder: (BuildContext context) {
      return settingsController.developerMode.value
          ? menuDev.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList()
          : menuNoDev.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
    },
    onSelected: (String choice) {
      if (choice == 'Settings') {
        Get.to(() => SettingsPage());
      } else if (choice == 'Home') {
        Get.off(() => const HomePage());
      } else if (choice == 'Map') {
        Get.to(() => const MapPage());
      } else if (choice == 'Developer Page') {
        Get.to(() => const DevPage());
      }
    },
  );
}
