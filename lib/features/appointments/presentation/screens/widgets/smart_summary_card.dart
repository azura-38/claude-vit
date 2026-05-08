import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/appointment_form_model.dart';

class SmartSummaryCard extends StatelessWidget {
  final AppointmentFormModel model;

  const SmartSummaryCard({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('MMM d • hh:mm a').format(model.date);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF005DA7),
            Color(0xFF2976C7),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 93, 167, 0.25),
            blurRadius: 24,
            offset: Offset(0, 12),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Appointment Summary',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            model.title.isEmpty
                ? 'Your appointment preview'
                : model.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.schedule, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                formatted,
                style: const TextStyle(color: Colors.white),
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined,
                  color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                model.reminder,
                style: const TextStyle(color: Colors.white),
              )
            ],
          )
        ],
      ),
    );
  }
}
