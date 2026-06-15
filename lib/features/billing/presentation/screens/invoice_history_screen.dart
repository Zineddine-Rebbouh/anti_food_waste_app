import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:anti_food_waste_app/features/billing/domain/models/billing_models.dart';

class InvoiceHistoryScreen extends StatelessWidget {
  final List<SubscriptionPayment> payments;

  const InvoiceHistoryScreen({super.key, required this.payments});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Invoice History',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2D8659),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: payments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_rounded, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No invoice history available.',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final payment = payments[idx];
                Color statusColor = Colors.orange;
                if (payment.status == 'paid') statusColor = Colors.green;
                if (payment.status == 'refunded') statusColor = Colors.blue;
                if (payment.status == 'waived') statusColor = Colors.grey;

                final startStr = DateFormat('MMMM d, yyyy').format(payment.periodStart);
                final endStr = DateFormat('MMMM d, yyyy').format(payment.periodEnd);
                final createdStr = DateFormat('MMMM d, yyyy h:mm a').format(payment.createdAt);

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            payment.plan.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${payment.amountDzd.toStringAsFixed(0)} DZD',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D8659),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0xFFF1F1F1)),
                      const SizedBox(height: 12),
                      _buildDetailRow('Coverage Period', '$startStr to $endStr'),
                      _buildDetailRow('Payment Status', payment.status.toUpperCase(),
                          valueColor: statusColor, isBold: true),
                      _buildDetailRow(
                        'Payment Method',
                        payment.paymentMethod == 'bank_transfer'
                            ? 'Bank / CCP Transfer'
                            : (payment.paymentMethod == 'cash'
                                ? 'Cash'
                                : payment.paymentMethod.toUpperCase()),
                      ),
                      if (payment.referenceNumber.isNotEmpty)
                        _buildDetailRow('Reference Number', payment.referenceNumber),
                      if (payment.paidAt != null)
                        _buildDetailRow(
                            'Date Paid', DateFormat('MMMM d, yyyy h:mm a').format(payment.paidAt!)),
                      _buildDetailRow('Date Issued', createdStr),
                      if (payment.notes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Notes:',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          payment.notes,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.grey.shade800,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
