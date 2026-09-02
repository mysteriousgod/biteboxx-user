import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressCardWidget extends StatelessWidget {
  final AddressModel? address;
  final bool fromAddress;
  final bool fromCheckout;
  final Function? onRemovePressed;
  final Function? onEditPressed;
  final Function? onTap;
  final bool isSelected;
  final bool fromDashBoard;
  const AddressCardWidget({
    super.key,
    required this.address,
    required this.fromAddress,
    this.onRemovePressed,
    this.onEditPressed,
    this.onTap,
    this.fromCheckout = false,
    this.isSelected = false,
    this.fromDashBoard = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: fromCheckout ? 0 : Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: onTap as void Function()?,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: Container(
          padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeSmall),
          decoration: fromDashBoard ? BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.transparent, width: isSelected ? 1 : 0),
          ) : fromCheckout ? const BoxDecoration() : BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : fromAddress
                      ? Theme.of(context).disabledColor.withValues(alpha: 0.2)
                      : Theme.of(context).cardColor,
              width: isSelected ? 1.5 : (fromAddress ? 1 : 0),
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.08)
                    : Colors.grey.withValues(alpha: 0.05),
                spreadRadius: isSelected ? 1.5 : 0.5,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: fromAddress ? _buildMyAddressContent(context) : _buildDefaultContent(context),
        ),
      ),
    );
  }

  Widget _buildMyAddressContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Radio button indicating active address
        Padding(
          padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
          child: Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
            size: 22,
          ),
        ),

        // Address type icon (home/office/other)
        Image.asset(
          address?.addressType == 'home'
              ? Images.houseIcon
              : address?.addressType == 'office'
                  ? Images.officeIcon
                  : Images.otherIcon,
          height: ResponsiveHelper.isDesktop(context) ? 25 : 22,
          width: ResponsiveHelper.isDesktop(context) ? 25 : 22,
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        // Address title, Active badge, and text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    address?.addressType?.tr ?? '',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 10),
                          const SizedBox(width: 3),
                          Text(
                            'Active',
                            style: robotoBold.copyWith(
                              fontSize: 10,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                address?.address ?? '',
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).disabledColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Edit button
        InkWell(
          onTap: onEditPressed as void Function()?,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              Icons.edit_outlined,
              color: Theme.of(context).disabledColor,
              size: ResponsiveHelper.isDesktop(context) ? 22 : 19,
            ),
          ),
        ),
        const SizedBox(width: 2),

        // Delete button
        InkWell(
          onTap: onRemovePressed as void Function()?,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              CupertinoIcons.delete,
              color: Theme.of(context).colorScheme.error,
              size: ResponsiveHelper.isDesktop(context) ? 22 : 19,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultContent(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Image.asset(
              address?.addressType == 'home'
                  ? Images.houseIcon
                  : address?.addressType == 'office'
                      ? Images.officeIcon
                      : Images.otherIcon,
              height: ResponsiveHelper.isDesktop(context) ? 25 : 20,
              width: ResponsiveHelper.isDesktop(context) ? 25 : 20,
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            Flexible(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(address?.addressType?.tr ?? '', style: robotoMedium),

                Text(
                  address?.address ?? '',
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
            ),
          ]),
        ]),
      ),

      fromAddress
          ? IconButton(
              icon: Icon(Icons.edit, color: Theme.of(context).disabledColor, size: ResponsiveHelper.isDesktop(context) ? 25 : 20),
              onPressed: onEditPressed as void Function()?,
            )
          : const SizedBox(),

      fromAddress
          ? IconButton(
              icon: Icon(CupertinoIcons.delete, color: Theme.of(context).colorScheme.error, size: ResponsiveHelper.isDesktop(context) ? 25 : 20),
              onPressed: onRemovePressed as void Function()?,
            )
          : const SizedBox(),
    ]);
  }
}