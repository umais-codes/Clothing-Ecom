import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinInputField extends StatefulWidget {
  final int length;
  final TextEditingController controller;
  final Function(String)? onCompleted;

  const PinInputField({
    super.key,
    this.length = 6,
    required this.controller,
    this.onCompleted,
  });

  @override
  State<PinInputField> createState() => _PinInputFieldState();
}

class _PinInputFieldState extends State<PinInputField> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    
    // Listen to changes in sub-controllers to update the main controller
    for (int i = 0; i < widget.length; i++) {
      _controllers[i].addListener(() {
        final pin = _controllers.map((c) => c.text).join();
        widget.controller.text = pin;
        if (pin.length == widget.length && widget.onCompleted != null) {
          widget.onCompleted!(pin);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < widget.length - 1) {
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
    final sw = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return Container(
          width: sw * 0.12,
          height: sw * 0.14,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(sw * 0.03),
            border: Border.all(
              color: _focusNodes[index].hasFocus 
                  ? AppColors.camel 
                  : AppColors.grey.withValues(alpha: 0.2),
              width: _focusNodes[index].hasFocus ? 2 : 1.2,
            ),
            boxShadow: _focusNodes[index].hasFocus 
              ? [BoxShadow(
                  color: AppColors.camel.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )]
              : [],
          ),
          child: Center(
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              onChanged: (v) => _onChanged(v, index),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
              decoration: const InputDecoration(
                counterText: "",
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        );
      }),
    );
  }
}
