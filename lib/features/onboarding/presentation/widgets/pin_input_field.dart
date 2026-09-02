import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/utils/responsive.dart';

class PinInputField extends StatelessWidget {
  final int length;
  final TextEditingController controller;
  final Function(String)? onCompleted;

  PinInputField({
    super.key,
    this.length = 6,
    required this.controller,
    this.onCompleted,
  }) {
    _focusNodes = List.generate(length, (_) => FocusNode());
    _controllers = List.generate(length, (_) => TextEditingController());
    _focusedStates = List.generate(length, (_) => false.obs);

    for (int i = 0; i < length; i++) {
      final index = i;
      _focusNodes[index].addListener(() {
        _focusedStates[index].value = _focusNodes[index].hasFocus;
      });

      _controllers[index].addListener(() {
        final pin = _controllers.map((c) => c.text).join();
        controller.text = pin;
        if (pin.length == length && onCompleted != null) {
          onCompleted!(pin);
        }
      });
    }
  }

  late final List<FocusNode> _focusNodes;
  late final List<TextEditingController> _controllers;
  late final List<RxBool> _focusedStates;

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(length, (index) {
        return SizedBox(
          width: sw * 0.12,
          height: sw * 0.12,
          child: Obx(
            () => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(sw * 0.02),
                border: _focusedStates[index].value
                    ? Border.all(color: AppColors.camel, width: 1.5)
                    : null,
              ),
              child: CustomTextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                onChanged: (v) => _onChanged(v, index),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                margin: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                fillColor: AppColors.white,
                borderRadius: sw * 0.02,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                  fontSize: sw * 0.035,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
