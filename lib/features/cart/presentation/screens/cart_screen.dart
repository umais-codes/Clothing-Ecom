import 'package:flutter/material.dart';
import '../controllers/b2c_cart_controller.dart';
import '../widgets/retail_cart_view.dart';
import 'b2c_cart_screen.dart';

class ReusableCartListView extends StatelessWidget {
  final B2CCartController controller;

  const ReusableCartListView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return RetailCartView(controller: controller);
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const B2CCartScreen();
  }
}
