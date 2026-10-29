import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/home/themes/theme_tokens.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/widgets/order_view_widget.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class BiteboxxModernOrderView extends StatefulWidget {
  final TabController tabController;
  final VoidCallback onContinueShopping;

  const BiteboxxModernOrderView({
    super.key,
    required this.tabController,
    required this.onContinueShopping,
  });

  @override
  State<BiteboxxModernOrderView> createState() => _BiteboxxModernOrderViewState();
}

class _BiteboxxModernOrderViewState extends State<BiteboxxModernOrderView> {
  int _selectedPillIndex = 1; // 0: Grocery, 1: Food

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    final bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    return Container(
      color: isDark ? const Color(0xFF121214) : const Color(0xFFF7F8FA),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header with Peach Gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF221A14), Color(0xFF121214)],
                      )
                    : const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFEDE1), Color(0xFFF7F8FA)],
                      ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your orders',
                    style: robotoBold.copyWith(
                      fontSize: 24,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Past favorites and your current deliveries',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pill Switcher: [ Grocery ] [ Food ]
                  Row(
                    children: [
                      // Grocery Pill
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedPillIndex = 0),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedPillIndex == 0 ? const Color(0xFFFF6000) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedPillIndex == 0 ? const Color(0xFFFF6000) : const Color(0xFFD1D5DB),
                                width: 1,
                              ),
                              boxShadow: _selectedPillIndex == 0
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFFF6000).withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_basket_outlined,
                                  size: 18,
                                  color: _selectedPillIndex == 0 ? Colors.white : const Color(0xFF4B5563),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Grocery',
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: _selectedPillIndex == 0 ? Colors.white : const Color(0xFF4B5563),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Food Pill
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedPillIndex = 1),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedPillIndex == 1 ? const Color(0xFFFF6000) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedPillIndex == 1 ? const Color(0xFFFF6000) : const Color(0xFFD1D5DB),
                                width: 1,
                              ),
                              boxShadow: _selectedPillIndex == 1
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFFF6000).withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.restaurant_menu_rounded,
                                  size: 18,
                                  color: _selectedPillIndex == 1 ? Colors.white : const Color(0xFF4B5563),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Food',
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: _selectedPillIndex == 1 ? Colors.white : const Color(0xFF4B5563),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: GetBuilder<OrderController>(
                builder: (orderController) {
                  final bool hasRunning = orderController.runningOrderList != null && orderController.runningOrderList!.isNotEmpty;
                  final bool hasHistory = orderController.historyOrderList != null && orderController.historyOrderList!.isNotEmpty;
                  final bool hasOrders = isLoggedIn && (hasRunning || hasHistory);

                  if (!hasOrders || _selectedPillIndex == 0) {
                    // Empty State Card Matching Image 1
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                        decoration: ThemeTokens.modernCardBox(radius: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Peach Circle with Orange Receipt Icon
                            Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFFFF0E6),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.receipt_long_rounded,
                                  color: Color(0xFFFF6000),
                                  size: 30,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            Text(
                              'No orders yet',
                              style: robotoBold.copyWith(
                                fontSize: 18,
                                color: isDark ? Colors.white : const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              'Your orders will appear here after checkout.',
                              textAlign: TextAlign.center,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Orange Pill Button
                            InkWell(
                              onTap: widget.onContinueShopping,
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6000),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF6000).withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Continue shopping',
                                  style: robotoBold.copyWith(
                                    color: Colors.white,
                                    fontSize: Dimensions.fontSizeDefault,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // If user has orders, show tab view
                  return Column(
                    children: [
                      TabBar(
                        controller: widget.tabController,
                        indicatorColor: const Color(0xFFFF6000),
                        indicatorWeight: 3,
                        labelColor: const Color(0xFFFF6000),
                        unselectedLabelColor: Colors.grey,
                        labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                        tabs: [
                          Tab(text: 'running'.tr),
                          Tab(text: 'subscription'.tr),
                          Tab(text: 'history'.tr),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: widget.tabController,
                          children: const [
                            OrderViewWidget(isRunning: true),
                            OrderViewWidget(isRunning: false, isSubscription: true),
                            OrderViewWidget(isRunning: false),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
