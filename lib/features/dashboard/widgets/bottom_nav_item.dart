import 'package:flutter/material.dart';

class BottomNavItem extends StatelessWidget {
  final IconData iconData;
  final Function? onTap;
  final bool isSelected;
  final int? badge;
  const BottomNavItem({super.key, required this.iconData, this.onTap, this.isSelected = false, this.badge});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: Icon(iconData, color: isSelected ? Theme.of(context).primaryColor : Colors.grey, size: 24),
            onPressed: onTap as void Function()?,
          ),
          if (badge != null && badge! > 0)
            Positioned(
              right: 18,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge!.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
