import 'package:flutter/material.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:google_fonts/google_fonts.dart';

class AISizePredictorCard extends StatelessWidget {
  final double sw;
  final bool isPredicting;
  final String recommendedSize;
  final String predictionDetails;
  final VoidCallback onPredict;

  const AISizePredictorCard({
    super.key,
    required this.sw,
    required this.isPredicting,
    required this.recommendedSize,
    required this.predictionDetails,
    required this.onPredict,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.035),
      decoration: BoxDecoration(
        color: AppColors.camelLight,
        borderRadius: BorderRadius.circular(sw * 0.04),
        border: Border.all(color: AppColors.camel.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(sw * 0.02),
                decoration: BoxDecoration(
                  color: AppColors.camel.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(sw * 0.02),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.camel,
                  size: sw * 0.045,
                ),
              ),
              SizedBox(width: sw * 0.025),
              Text(
                'AI Size Predictor',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: sw * 0.038,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.02),

          if (isPredicting) ...[
            Container(
              height: sw * 0.12,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(color: AppColors.camel),
            ),
          ] else if (recommendedSize.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(sw * 0.025),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(sw * 0.03),
                border: Border.all(
                  color: AppColors.camel.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.camel,
                    size: sw * 0.05,
                  ),
                  SizedBox(width: sw * 0.025),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recommended Size: $recommendedSize',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                            fontSize: sw * 0.034,
                          ),
                        ),
                        SizedBox(height: sw * 0.01),
                        Text(
                          predictionDetails,
                          style: GoogleFonts.outfit(
                            color: AppColors.grey,
                            fontSize: sw * 0.028,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: sw * 0.02),
            GestureDetector(
              onTap: onPredict,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: sw * 0.035,
                    color: AppColors.camel,
                  ),
                  SizedBox(width: sw * 0.01),
                  Text(
                    'Re-calculate size',
                    style: GoogleFonts.outfit(
                      fontSize: sw * 0.028,
                      fontWeight: FontWeight.w600,
                      color: AppColors.camel,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Text(
              'Get your perfect fit using our intelligent size recommendation engine.',
              style: GoogleFonts.outfit(
                color: AppColors.ink,
                fontSize: sw * 0.03,
                height: 1.5,
              ),
            ),
            SizedBox(height: sw * 0.025),
            if (predictionDetails.isNotEmpty) ...[
              Text(
                predictionDetails,
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.028,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
              SizedBox(height: sw * 0.025),
            ],
            CustomButton(
              text: 'Predict My Size',
              onPressed: onPredict,
              height: sw * 0.1,
              icon: Icons.auto_awesome_rounded,
            ),
          ],
        ],
      ),
    );
  }
}
