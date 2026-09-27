import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

enum AppTextStyleVariant {
  displayLogo,
  screenTitle,
  sectionHeading,
  cardTitle,
  priceText,
  totalPriceText,
  bodyText,
  caption,
  linkText,
  buttonText,
  chipLabel,
  navLabelActive,
  navLabelInactive,
}

class AppText extends StatelessWidget {
  final String text;
  final AppTextStyleVariant variant;
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool softWrap;

  const AppText(
    this.text, {
    super.key,
    this.variant = AppTextStyleVariant.bodyText,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  });

  // Named constructors for convenience
  const AppText.displayLogo(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : variant = AppTextStyleVariant.displayLogo;

  const AppText.screenTitle(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : variant = AppTextStyleVariant.screenTitle;

  const AppText.sectionHeading(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : variant = AppTextStyleVariant.sectionHeading;

  const AppText.cardTitle(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : variant = AppTextStyleVariant.cardTitle;

  const AppText.price(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : variant = AppTextStyleVariant.priceText;

  const AppText.totalPrice(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : variant = AppTextStyleVariant.totalPriceText;

  const AppText.body(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : variant = AppTextStyleVariant.bodyText;

  const AppText.caption(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : variant = AppTextStyleVariant.caption;

  const AppText.link(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : variant = AppTextStyleVariant.linkText;

  const AppText.button(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : variant = AppTextStyleVariant.buttonText;

  const AppText.chip(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : variant = AppTextStyleVariant.chipLabel;

  TextStyle _resolveStyle() {
    TextStyle base;
    switch (variant) {
      case AppTextStyleVariant.displayLogo:
        base = AppTextStyles.displayLogo;
        break;
      case AppTextStyleVariant.screenTitle:
        base = AppTextStyles.screenTitle;
        break;
      case AppTextStyleVariant.sectionHeading:
        base = AppTextStyles.sectionHeading;
        break;
      case AppTextStyleVariant.cardTitle:
        base = AppTextStyles.cardTitle;
        break;
      case AppTextStyleVariant.priceText:
        base = AppTextStyles.priceText;
        break;
      case AppTextStyleVariant.totalPriceText:
        base = AppTextStyles.totalPriceText;
        break;
      case AppTextStyleVariant.bodyText:
        base = AppTextStyles.bodyText;
        break;
      case AppTextStyleVariant.caption:
        base = AppTextStyles.caption;
        break;
      case AppTextStyleVariant.linkText:
        base = AppTextStyles.linkText;
        break;
      case AppTextStyleVariant.buttonText:
        base = AppTextStyles.buttonText;
        break;
      case AppTextStyleVariant.chipLabel:
        base = AppTextStyles.chipLabel;
        break;
      case AppTextStyleVariant.navLabelActive:
        base = AppTextStyles.navLabelActive;
        break;
      case AppTextStyleVariant.navLabelInactive:
        base = AppTextStyles.navLabelInactive;
        break;
    }

    if (color != null || fontWeight != null || fontSize != null) {
      return base.copyWith(
        color: color,
        fontWeight: fontWeight,
        fontSize: fontSize,
      );
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _resolveStyle(),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}
