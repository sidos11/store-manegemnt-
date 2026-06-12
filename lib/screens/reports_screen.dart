import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../controllers/sale_controller.dart';
import 'package:store_management/l10n/app_localizations.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'Weekly';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<SaleController>().loadSales());
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SaleController>();
    final l10n = AppLocalizations.of(context)!;

    final double totalRevenue = controller.totalProfit;
    final double avgTicketSize = controller.sales.isEmpty
        ? 0.0
        : totalRevenue / controller.sales.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.reports,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191c1d),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sales overview and insights',
                      style: TextStyle(fontSize: 14, color: Color(0xFF444655)),
                    ),
                    const SizedBox(height: 24),

                    // Périodes Tabs
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf3f4f5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildTabButton('Daily', 'Daily'),
                          _buildTabButton('Weekly', 'Weekly'),
                          _buildTabButton('Monthly', 'Monthly'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bento Grid KPI
                    Row(
                      children: [
                        Expanded(
                          child: _buildGlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.payments,
                                  color: Color(0xFF006c4f),
                                  size: 24,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Total Revenue',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF444655),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${totalRevenue.toStringAsFixed(0)} MRU',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF191c1d),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.receipt_long,
                                  color: Color(0xFF4361ee),
                                  size: 24,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Avg Ticket Size',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF444655),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${avgTicketSize.toStringAsFixed(0)} MRU',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF191c1d),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Chart Card
                    _buildGlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sales Trends',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF191c1d),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 192,
                            child: Stack(
                              children: [
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    4,
                                    (index) => Container(
                                      width: double.infinity,
                                      height: 1,
                                      color: const Color(
                                        0xFF747686,
                                      ).withOpacity(0.2),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      _buildChartBar(
                                        0.40,
                                        '400 MRU',
                                        isHighlighted: false,
                                      ),
                                      _buildChartBar(
                                        0.60,
                                        '600 MRU',
                                        isHighlighted: false,
                                      ),
                                      _buildChartBar(
                                        0.85,
                                        '850 MRU',
                                        isHighlighted: true,
                                      ),
                                      _buildChartBar(
                                        0.50,
                                        '500 MRU',
                                        isHighlighted: false,
                                      ),
                                      _buildChartBar(
                                        0.70,
                                        '700 MRU',
                                        isHighlighted: false,
                                      ),
                                      _buildChartBar(
                                        0.90,
                                        '900 MRU',
                                        isHighlighted: false,
                                      ),
                                      _buildChartBar(
                                        0.30,
                                        '300 MRU',
                                        isHighlighted: false,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _XLabel('M'),
                              _XLabel('T'),
                              _XLabel('W'),
                              _XLabel('T'),
                              _XLabel('F'),
                              _XLabel('S'),
                              _XLabel('S'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Ventes Récentes Dynamiques
                    _buildGlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent Sales',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF191c1d),
                            ),
                          ),
                          const SizedBox(height: 12),
                          controller.sales.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: Text('No sales recorded yet.'),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: controller.sales.length > 5
                                      ? 5
                                      : controller.sales.length,
                                  itemBuilder: (context, index) {
                                    final sale =
                                        controller.sales[controller
                                                .sales
                                                .length -
                                            1 -
                                            index];
                                    final isLast =
                                        index ==
                                        (controller.sales.length > 5
                                            ? 4
                                            : controller.sales.length - 1);
                                    return _buildTransactionItem(
                                      sale.productName.isEmpty
                                          ? 'Product #${sale.productId}'
                                          : sale.productName,
                                      'Qty: ${sale.quantity}',
                                      '${sale.totalPrice.toStringAsFixed(0)} MRU',
                                      isLast: isLast,
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = value),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? const Color(0xFF2346d5)
                  : const Color(0xFF444655),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartBar(
    double fillFactor,
    String tooltipValue, {
    required bool isHighlighted,
  }) {
    final barColor = isHighlighted
        ? const Color(0xFF006c4f)
        : const Color(0xFF006c4f).withOpacity(0.2);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: FractionallySizedBox(
          heightFactor: fillFactor,
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String subtitle,
    String income, {
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFe1e3e4), width: 1),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF4361ee).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_bag,
                  color: Color(0xFF4361ee),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF191c1d),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF444655),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            income,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006c4f),
            ),
          ),
        ],
      ),
    );
  }
}

class _XLabel extends StatelessWidget {
  final String label;
  const _XLabel(this.label);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF444655),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
