import 'dart:ui';

import 'package:flutter/material.dart';

class VaultPreviewOverlay
    extends StatelessWidget {
  const VaultPreviewOverlay({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius:
              BorderRadius.circular(22),
          child: Image.network(
            "https://images.unsplash.com/photo-1581595219315-a187dd40c322",
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),

        Positioned.fill(
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 6,
                sigmaY: 6,
              ),
              child: Container(
                color:
                    Colors.black.withValues(
                  alpha: .06,
                ),
              ),
            ),
          ),
        ),

        Positioned.fill(
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color:
                    Colors.white.withValues(
                  alpha: .85,
                ),
                borderRadius:
                    BorderRadius.circular(
                  999,
                ),
              ),
              child: const Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(Icons.visibility),

                  SizedBox(width: 10),

                  Text(
                    "Tap to preview",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
