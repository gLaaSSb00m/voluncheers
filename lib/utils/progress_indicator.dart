 import 'package:flutter/material.dart';
import 'constants.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  /// currentStep: 0 = Create Account, 1 = Personal Details, 2 = Confirmation.
  final int currentStep;

  const ProgressIndicatorWidget({
    Key? key,
    required this.currentStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Step labels.
    final List<String> labels = [
      "Create Account",
      "Personal Details",
      "Confirmation"
    ];
    const int totalSteps = 3;
    // Outer size for active/completed circles.
    const double outerCircleSize = 28.0;
    // Inner size used for the active inner circle and inactive steps.
    const double innerCircleSize = 18.0;
    const double lineThickness = 6.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Restrict overall width to 80% of screen.
        final double indicatorWidth = constraints.maxWidth * 0.8;
        final double horizontalPadding = (constraints.maxWidth - indicatorWidth) / 2;
        // Compute spacing between centers.
        final double spacing = (indicatorWidth - outerCircleSize) / (totalSteps - 1);
        // Total width of the connecting line equals the gap between the first and last circle centers.
        final double lineWidth = spacing * (totalSteps - 1);

        return SizedBox(
          height: 100,
          child: Stack(
            children: [
              // The connecting line is drawn relative to the restricted width.
              Positioned(
                top: outerCircleSize / 2 - lineThickness / 2,
                left: horizontalPadding + outerCircleSize / 2,
                child: Container(
                  width: lineWidth,
                  height: lineThickness,
                  color: AppColors.lightGray,
                ),
              ),
              // Dark green filled line indicating completed steps.
              if (currentStep > 0)
                Positioned(
                  top: outerCircleSize / 2 - lineThickness / 2,
                  left: horizontalPadding + outerCircleSize / 2,
                  child: Container(
                    width: spacing * currentStep,
                    height: lineThickness,
                    color: AppColors.darkGreen,
                  ),
                ),
              // Draw the circles (indicator icons) in a row.
              Positioned(
                top: 0,
                left: horizontalPadding,
                width: indicatorWidth,
                height: outerCircleSize,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(totalSteps, (index) {
                    return SizedBox(
                      width: outerCircleSize,
                      height: outerCircleSize,
                      child: _buildStepCircle(index, innerCircleSize, outerCircleSize),
                    );
                  }),
                ),
              ),
              // Draw text labels positioned beneath each circle.
              for (int i = 0; i < totalSteps; i++)
                Positioned(
                  top: outerCircleSize + 8,
                  left: horizontalPadding + outerCircleSize / 2 + i * spacing - 50,
                  width: 100, // You can adjust this fixed width if needed.
                  child: Center(
                    child: Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12, // Smaller font for breathing room.
                        fontWeight: FontWeight.w500,
                        color: i == currentStep ? AppColors.darkGreen : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the circle for each step.
  Widget _buildStepCircle(int index, double innerSize, double outerSize) {
    if (index < currentStep) {
      // Completed step: solid dark green circle with a white check.
      return Container(
        width: outerSize,
        height: outerSize,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.darkGreen,
        ),
        child: const Center(
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: 16,
          ),
        ),
      );
    } else if (index == currentStep) {
      // Active step: a three-layered circle with an outer translucent ring,
      // an inner dark green circle, and a small white center dot.
      return Container(
        width: outerSize,
        height: outerSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.darkGreen.withOpacity(0.2),
        ),
        child: Center(
          child: Container(
            width: innerSize,
            height: innerSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.darkGreen,
            ),
            child: const Center(
              child: CircleAvatar(
                radius: 3.5,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
      );
    } else {
      // Inactive step: same size as the active inner circle; display gray color.
      return Center(
        child: Container(
          width: innerSize,
          height: innerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey, // Inactive state uses gray.
          ),
          child: const Center(
            child: CircleAvatar(
              radius: 3.5,
              backgroundColor: Colors.white,
            ),
          ),
        ),
      );
    }
  }
}
