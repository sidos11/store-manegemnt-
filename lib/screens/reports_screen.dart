import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/sale_controller.dart';
import '../../models/sale.dart';
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

  // دالة ذكية لحساب المبيعات اليومية وتوليد أطوال الأعمدة البيانية ديناميكياً
  List<Map<String, dynamic>> _calculateWeeklyTrends(List<Sale> sales) {
    // مصفوفة أيام الأسبوع السبعة تبدأ من الإثنين إلى الأحد
    List<String> weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    List<double> dayTotals = List.filled(7, 0.0);

    for (var sale in sales) {
      try {
        DateTime saleDate = DateTime.parse(sale.date);
        // weekday في دارت يعيد (1 للإثنين، 7 للأحد)
        int dayIndex = saleDate.weekday - 1;
        if (dayIndex >= 0 && dayIndex < 7) {
          dayTotals[dayIndex] += sale.totalPrice;
        }
      } catch (e) {
        // في حال كان تنسيق التاريخ غير القياسي ISO8601
        print("Error parsing sale date: $e");
      }
    }

    // إيجاد أعلى قيمة مبيعات في يوم واحد لتحديد النسبة الطولية القصوى (Max Height)
    double maxSale =
        dayTotals.reduce((curr, next) => curr > next ? curr : next);
    if (maxSale == 0) maxSale = 1.0; // تجنب القسمة على صفر

    List<Map<String, dynamic>> trends = [];
    for (int i = 0; i < 7; i++) {
      trends.add({
        'label': weekdays[i],
        'total': dayTotals[i],
        'factor': dayTotals[i] / maxSale, // نسبة الارتفاع بين 0.0 و 1.0
      });
    }
    return trends;
  }

  Widget _buildTabButton(String title, String value) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 4)
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFF4361ee) : Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100, width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: child,
    );
  }

  Widget _buildChartBar(double heightFactor, String value,
      {required bool isHighlighted}) {
    // جعل الطول الأدنى للعمود 0.05 حتى لا يختفي تماماً إذا كانت المبيعات 0
    final safeHeightFactor = heightFactor < 0.05 ? 0.05 : heightFactor;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            value,
            style: TextStyle(
                fontSize: 9,
                color: isHighlighted ? const Color(0xFF4361ee) : Colors.grey,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: FractionallySizedBox(
              alignment: Alignment.bottomCenter,
              heightFactor: safeHeightFactor,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? const Color(0xFF4361ee)
                      : const Color(0xFF4361ee).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SaleController>();
    final l10n = AppLocalizations.of(context)!;
    final double totalRevenue = controller.totalProfit;
    final double avgTicketSize =
        controller.sales.isEmpty ? 0.0 : totalRevenue / controller.sales.length;

    // توليد بيانات المبيعات الأسبوعية الحقيقية من الكنترولر والسيرفر
    final List<Map<String, dynamic>> weeklyTrends =
        _calculateWeeklyTrends(controller.sales);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: controller.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4361ee)))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.reports,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF191c1d))),
                    const SizedBox(height: 4),
                    const Text('Sales overview and insights',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF444655))),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: const Color(0xFFf3f4f5),
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          _buildTabButton('Daily', 'Daily'),
                          _buildTabButton('Weekly', 'Weekly'),
                          _buildTabButton('Monthly', 'Monthly'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildGlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.payments,
                                    color: Color(0xFF006c4f), size: 24),
                                const SizedBox(height: 8),
                                const Text('Total Revenue',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF444655))),
                                const SizedBox(height: 4),
                                Text('${totalRevenue.toStringAsFixed(0)} MRU',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF191c1d))),
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
                                const Icon(Icons.receipt_long,
                                    color: Color(0xFF4361ee), size: 24),
                                const SizedBox(height: 8),
                                const Text('Avg Ticket Size',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF444655))),
                                const SizedBox(height: 4),
                                Text('${avgTicketSize.toStringAsFixed(0)} MRU',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF191c1d))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildGlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Sales Trends',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF191c1d))),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 150,
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
                                          color: const Color(0xFF747686)
                                              .withOpacity(0.1))),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: weeklyTrends.map((trend) {
                                      // إبراز العمود بلون مميز إذا كان هو العمود الأعلى مبيعات اليوم
                                      bool isMax = trend['factor'] == 1.0 &&
                                          trend['total'] > 0;
                                      return _buildChartBar(
                                        trend['factor'],
                                        trend['total'] > 0
                                            ? trend['total'].toStringAsFixed(0)
                                            : '',
                                        isHighlighted: isMax,
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: weeklyTrends
                                .map((trend) => _XLabel(trend['label']))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildGlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Recent Sales',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF191c1d))),
                          const SizedBox(height: 12),
                          controller.sales.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                      child: Text('No sales recorded yet.')),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: controller.sales.length > 5
                                      ? 5
                                      : controller.sales.length,
                                  itemBuilder: (context, index) {
                                    // جلب المبيعات من الأحدث إلى الأقدم
                                    final sale = controller.sales[
                                        controller.sales.length - 1 - index];

                                    // استخراج الوقت أو صيغة العرض من حقل التاريخ المتاح
                                    String shortDate = sale.date.length > 10
                                        ? sale.date.substring(0, 10)
                                        : sale.date;

                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const CircleAvatar(
                                          backgroundColor: Color(0xFFEDEEEF),
                                          child: Icon(
                                              Icons.shopping_basket_outlined,
                                              color: Color(0xFF4361ee))),
                                      title: Text(
                                          sale
                                              .productName, // 🌟 عرض اسم المنتج الفعلي بدلاً من كلمة Facture
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Text(
                                          '${sale.quantity} units — $shortDate'), // 🌟 عرض عدد الوحدات وتاريخ الفاتورة
                                      trailing: Text(
                                          '${sale.totalPrice.toStringAsFixed(0)} MRU',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green)),
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
}

class _XLabel extends StatelessWidget {
  final String label;
  const _XLabel(this.label);
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Center(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold))));
  }
}
