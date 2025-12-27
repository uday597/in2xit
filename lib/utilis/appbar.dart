import 'package:flutter/material.dart';

PreferredSizeWidget reuseAppBar({
  required String title,
  List<Widget>? actions,
  VoidCallback? ontap,
  bool showBack = true,
  bool centerTittle = false,
}) {
  return AppBar(
    centerTitle: centerTittle,
    automaticallyImplyLeading: showBack,
    leading: showBack ? null : const SizedBox.shrink(),
    elevation: 0,
    foregroundColor: Colors.white,

    title: Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),

    actions: [
      if (ontap != null)
        IconButton(onPressed: ontap, icon: const Icon(Icons.filter_list)),

      if (actions != null) ...actions,
    ],

    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF2196F3), const Color(0xFF1A237E)],

          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
    backgroundColor: Colors.transparent,
  );
}
