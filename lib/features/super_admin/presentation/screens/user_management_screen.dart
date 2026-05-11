import 'package:ecom_app/app/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/admin_crud_controller.dart';
import '../widgets/admin_data_table.dart';

class UserManagementScreen extends GetView<AdminCrudController> {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Padding(
        padding: EdgeInsets.all(context.wp(2.5).clamp(16.0, 32.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User & Vendor Management',
              style: GoogleFonts.outfit(
                fontSize: context.sp(22).clamp(20.0, 28.0),
                fontWeight: FontWeight.w800,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage platform access, roles, and administrative support actions.',
              style: GoogleFonts.outfit(fontSize: 14, color: AppColors.grey),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: AdminDataTable<dynamic>(
                title: 'Platform Entities',
                columns: const [
                  'User/Vendor',
                  'Email',
                  'Role',
                  'Status',
                  'Joined',
                  'Actions',
                ],
                items: controller.allUsers,
                rowBuilder: (item) {
                  return Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.camelLight,
                              child: Text(
                                item.fullName[0],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.camel,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item.fullName,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item.email,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                      Expanded(child: _buildRoleBadge(item.role)),
                      Expanded(child: _buildStatusBadge(item.status)),
                      Expanded(
                        child: Text(
                          item.joinDate,
                          style: GoogleFonts.outfit(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Tooltip(
                              message: 'Impersonate',
                              child: IconButton(
                                onPressed: () =>
                                    controller.impersonateUser(item.id),
                                icon: const Icon(
                                  Icons.login_rounded,
                                  size: 18,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.shield_outlined,
                                size: 18,
                                color: AppColors.camel,
                              ),
                            ),
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

  Widget _buildRoleBadge(dynamic role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Text(
        role.toString().split('.').last.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.charcoal,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final bool isActive = status == 'Active';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.green : AppColors.error,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          status,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
      ],
    );
  }
}
