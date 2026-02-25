import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/address/controllers/address_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class LocationPickerBottomSheet extends StatelessWidget {
  const LocationPickerBottomSheet({super.key});

  /// Shows the bottom sheet and returns when closed.
  static void show(BuildContext context) {
    // Refresh saved addresses before opening (for logged-in users)
    if (AuthHelper.isLoggedIn()) {
      Get.find<AddressController>().getAddressList();
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LocationPickerBottomSheet(),
    );
  }

  IconData _iconFor(String? type) {
    switch (type) {
      case 'home':
        return Icons.home_rounded;
      case 'office':
        return Icons.work_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  String _labelFor(String? type) {
    switch (type) {
      case 'home':
        return 'home'.tr;
      case 'office':
        return 'office'.tr;
      default:
        return 'current_location'.tr;
    }
  }

  /// Returns true if [address] matches the currently active SharedPref address
  bool _matchesCurrent(AddressModel address, AddressModel? current) {
    if (current == null) return false;
    if (address.id != null && current.id != null) {
      return address.id == current.id;
    }
    return address.latitude == current.latitude &&
        address.longitude == current.longitude;
  }

  Future<void> _selectAddress(
      BuildContext context, AddressModel address) async {
    Get.back();
    Get.find<LocationController>().saveAddressAndNavigate(
      address,
      false,
      null,
      false,
      false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isLoggedIn = AuthHelper.isLoggedIn();

    // ── Active address (always from SharedPreferences) ────────────────────
    final AddressModel? activeAddress = AddressHelper.getAddressFromSharedPref();

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Dimensions.radiusExtraLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.paddingSizeLarge,
                12,
                Dimensions.paddingSizeLarge,
                0,
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_rounded, color: primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'choose_location'.tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: onSurface,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: Get.back,
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Divider(color: Colors.grey.withValues(alpha: 0.15), height: 1),

            // ── Address list ─────────────────────────────────────────────
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.52,
              ),
              child: GetBuilder<AddressController>(
                builder: (addressController) {
                  // Saved addresses from API (only when logged in)
                  final List<AddressModel> savedAddresses =
                      (isLoggedIn ? addressController.addressList : null) ?? [];

                  // Build the final display list:
                  // 1. Active address (from SharedPref) always first
                  // 2. Saved addresses that are NOT the active one
                  final List<_DisplayAddress> displayList = [];

                  if (activeAddress != null) {
                    displayList.add(_DisplayAddress(
                      address: activeAddress,
                      isCurrent: true,
                      isFromSharedPref: true,
                    ));
                  }

                  for (final saved in savedAddresses) {
                    // Skip the one already shown as active
                    if (!_matchesCurrent(saved, activeAddress)) {
                      displayList.add(_DisplayAddress(
                        address: saved,
                        isCurrent: false,
                        isFromSharedPref: false,
                      ));
                    }
                  }

                  // Show loading only if logged in and we haven't received
                  // addresses yet AND there's no active address to show
                  if (isLoggedIn &&
                      addressController.addressList == null &&
                      activeAddress == null) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (displayList.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_searching_rounded,
                              size: 52,
                              color: Colors.grey.withValues(alpha: 0.35)),
                          const SizedBox(height: 12),
                          Text(
                            'no_saved_address'.tr,
                            style: robotoMedium.copyWith(
                              color: Colors.grey.shade500,
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'use_current_location_hint'.tr.isEmpty
                                ? 'Tap "Use Current Location" below to get started'
                                : 'use_current_location_hint'.tr,
                            style: robotoRegular.copyWith(
                              color: Colors.grey.shade400,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    itemCount: displayList.length,
                    separatorBuilder: (_, __) => Divider(
                      color: Colors.grey.withValues(alpha: 0.12),
                      height: 1,
                      indent: 58,
                    ),
                    itemBuilder: (context, index) {
                      final item = displayList[index];
                      final addr = item.address;
                      return _AddressTile(
                        address: addr,
                        icon: _iconFor(addr.addressType),
                        label: item.isCurrent && item.isFromSharedPref &&
                                (addr.addressType == 'others' ||
                                    addr.addressType == null)
                            ? 'current_location'.tr
                            : _labelFor(addr.addressType),
                        isCurrent: item.isCurrent,
                        isActiveLocation:
                            item.isCurrent && item.isFromSharedPref,
                        primaryColor: primary,
                        onTap: () => _selectAddress(context, addr),
                      );
                    },
                  );
                },
              ),
            ),

            Divider(color: Colors.grey.withValues(alpha: 0.15), height: 1),

            // ── Bottom CTAs ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.paddingSizeLarge,
                12,
                Dimensions.paddingSizeLarge,
                16,
              ),
              child: _AddLocationButton(
                isLoggedIn: isLoggedIn,
                primaryColor: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal data class
// ─────────────────────────────────────────────────────────────────────────────
class _DisplayAddress {
  final AddressModel address;
  final bool isCurrent;
  final bool isFromSharedPref;

  const _DisplayAddress({
    required this.address,
    required this.isCurrent,
    required this.isFromSharedPref,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Address tile
// ─────────────────────────────────────────────────────────────────────────────
class _AddressTile extends StatelessWidget {
  final AddressModel address;
  final IconData icon;
  final String label;
  final bool isCurrent;
  final bool isActiveLocation;
  final Color primaryColor;
  final VoidCallback onTap;

  const _AddressTile({
    required this.address,
    required this.icon,
    required this.label,
    required this.isCurrent,
    required this.isActiveLocation,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: Dimensions.paddingSizeExtraSmall,
        ),
        child: Row(
          children: [
            // ── Icon ────────────────────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isActiveLocation
                    ? primaryColor.withValues(alpha: 0.12)
                    : Colors.grey.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActiveLocation ? Icons.my_location_rounded : icon,
                size: 20,
                color: isActiveLocation ? primaryColor : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            // ── Address details ─────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label row
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: isActiveLocation ? primaryColor : onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isActiveLocation) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            'current'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: 9,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Full Google-Maps-style address
                  Text(
                    address.address ?? '',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ── Right indicator ─────────────────────────────────────
            const SizedBox(width: 6),
            if (isActiveLocation)
              Icon(Icons.check_circle_rounded, size: 22, color: primaryColor)
            else
              Icon(Icons.chevron_right_rounded,
                  size: 22, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom CTA buttons: "Add a Location" + "Use Current Location"
// ─────────────────────────────────────────────────────────────────────────────
class _AddLocationButton extends StatelessWidget {
  final bool isLoggedIn;
  final Color primaryColor;

  const _AddLocationButton({
    required this.isLoggedIn,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Add a saved location (for logged-in users) ──────────────
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Get.back();
              if (isLoggedIn) {
                Get.toNamed(RouteHelper.getAddAddressRoute(false, 0));
              } else {
                Get.toNamed(RouteHelper.getAccessLocationRoute('home'));
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: BorderSide(color: primaryColor, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
            ),
            icon:
                Icon(Icons.add_location_alt_rounded, color: primaryColor, size: 20),
            label: Text(
              'add_a_location'.tr,
              style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault, color: primaryColor),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // ── Use current GPS location ────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () {
              Get.back();
              Get.toNamed(RouteHelper.getAccessLocationRoute('home'));
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            icon: Icon(Icons.my_location_rounded,
                color: Colors.grey.shade700, size: 18),
            label: Text(
              'use_current_location'.tr,
              style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Colors.grey.shade700),
            ),
          ),
        ),
      ],
    );
  }
}
