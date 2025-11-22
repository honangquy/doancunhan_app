import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? color; // Alias for backgroundColor
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.color,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final button = icon != null
        ? ElevatedButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: Icon(icon),
            label: _buildLabel(),
            style: _buildStyle(),
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: _buildStyle(),
            child: _buildLabel(),
          );

    return fullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }

  Widget _buildLabel() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
    return Text(text);
  }

  ButtonStyle _buildStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? color ?? AppColors.authorPrimary,
      foregroundColor: textColor ?? Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingL,
        vertical: AppSizes.paddingM,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppStyles.mediumRadius,
      ),
    );
  }
}

class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? textColor;
  final IconData? icon;

  const CustomOutlinedButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.borderColor,
    this.textColor,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final button = icon != null
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(text),
            style: _buildStyle(),
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: _buildStyle(),
            child: Text(text),
          );

    return SizedBox(width: double.infinity, child: button);
  }

  ButtonStyle _buildStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: textColor ?? AppColors.authorPrimary,
      side: BorderSide(color: borderColor ?? AppColors.authorPrimary),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingL,
        vertical: AppSizes.paddingM,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppStyles.mediumRadius,
      ),
    );
  }
}