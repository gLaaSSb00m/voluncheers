import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'dart:ui';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFF01311F).withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: SalomonBottomBar(
                currentIndex: currentIndex,
                onTap: onTap,
                itemPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                items: [
                  SalomonBottomBarItem(
                    icon: const Icon(Icons.home_rounded, size: 22),
                    title: const Text('Home', style: TextStyle(fontSize: 12)),
                    selectedColor: const Color(0xFF01311F),
                    unselectedColor: Colors.grey,
                  ),
                  SalomonBottomBarItem(
                    icon: const Icon(Icons.favorite_rounded, size: 22),
                    title: const Text('Favs', style: TextStyle(fontSize: 12)),
                    selectedColor: const Color(0xFF01311F),
                    unselectedColor: Colors.grey,
                  ),
                  SalomonBottomBarItem(
                    icon: const Icon(Icons.chat_rounded, size: 22),
                    title: const Text('Chat', style: TextStyle(fontSize: 12)),
                    selectedColor: const Color(0xFF01311F),
                    unselectedColor: Colors.grey,
                  ),
                  SalomonBottomBarItem(
                    icon: const Icon(Icons.person_rounded, size: 22),
                    title: const Text('Profile', style: TextStyle(fontSize: 12)),
                    selectedColor: const Color(0xFF01311F),
                    unselectedColor: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}