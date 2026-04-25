import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

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

    for (int i = 0; i < widget.length; i++) {
      // Rebuild when focus changes to update border color
      _focusNodes[i].addListener(() => setState(() {}));

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
      mainAxisAlignment: .spaceBetween,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: sw * 0.12,
          height: sw * 0.12,
          child: CustomTextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            onChanged: (v) => _onChanged(v, index),
            keyboardType: .number,
            textAlign: .center,
            maxLength: 1,
            margin: .zero,
            contentPadding: .zero,
            fillColor: AppColors.white,
            borderRadius: sw * 0.02,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: .w700,
              color: AppColors.charcoal,
              fontSize: sw * 0.035,
            ),
          ),
        );
      }),
    );
  }
}
