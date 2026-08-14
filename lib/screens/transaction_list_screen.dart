import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/glass_surface.dart';
import 'add_transaction_screen.dart';

/// Transaction history screen — Apple Liquid Glass design with filter chips.
class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String _selectedType = 'All';
  String _selectedCategory = 'All';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final isLight = context.watch<SettingsProvider>().isLight;
    final textColor = isLight ? const Color(0xFF1A1A2E) : Colors.white;
    final subtextColor = (isLight ? Colors.black : Colors.white).withValues(alpha: 0.5);

    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final filtered = provider.getFilteredTransactions(
          type: _selectedType,
          category: _selectedCategory,
          startDate: _startDate,
          endDate: _endDate,
        );

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transactions',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${filtered.length} transactions found',
                    style: TextStyle(color: subtextColor, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  _buildFilters(isLight),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: GlassSurface(
                          isLight: isLight,
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 56,
                                color: subtextColor.withValues(alpha: 0.35),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No transactions found',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Try clearing your filters or adding a new transaction',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: subtextColor, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: const Color(0xFF7C4DFF),
                      backgroundColor: isLight ? Colors.white : const Color(0xFF050505),
                      onRefresh: () async {
                        await provider.loadTransactions();
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final t = filtered[index];
                          return TransactionListItem(
                            transaction: t,
                            isLight: isLight,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddTransactionScreen(transaction: t),
                              ),
                            ),
                            onDelete: () => provider.deleteTransaction(t.id!),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilters(bool isLight) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip(_selectedType, Icons.swap_vert_rounded, () => _showTypeFilter(isLight), isLight: isLight),
          const SizedBox(width: 8),
          _chip(_selectedCategory, Icons.category_rounded, () => _showCategoryFilter(isLight), isLight: isLight),
          const SizedBox(width: 8),
          _chip(
            _startDate != null ? 'Date filtered' : 'Date range',
            Icons.date_range_rounded,
            _pickDateRange,
            isActive: _startDate != null,
            isLight: isLight,
          ),
          if (_selectedType != 'All' || _selectedCategory != 'All' || _startDate != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() {
                _selectedType = 'All';
                _selectedCategory = 'All';
                _startDate = null;
                _endDate = null;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 0.8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.clear_rounded, size: 16, color: Colors.redAccent),
                    SizedBox(width: 4),
                    Text(
                      'Clear',
                      style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, IconData icon, VoidCallback onTap, {bool isActive = false, bool isLight = false}) {
    final active = isActive || (label != 'All' && label != 'Date range');
    final baseColor = isLight ? Colors.black : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF7C4DFF).withValues(alpha: 0.2)
              : baseColor.withValues(alpha: isLight ? 0.04 : 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? const Color(0xFF7C4DFF).withValues(alpha: 0.5)
                : baseColor.withValues(alpha: isLight ? 0.08 : 0.12),
            width: 0.8,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
                    blurRadius: 10,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: active ? const Color(0xFF7C4DFF) : baseColor.withValues(alpha: 0.6)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: active ? const Color(0xFF7C4DFF) : baseColor.withValues(alpha: 0.75),
                fontWeight: active ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down_rounded, size: 18, color: active ? const Color(0xFF7C4DFF) : baseColor.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }

  void _showTypeFilter(bool isLight) {
    final sheetBg = isLight ? const Color(0xFFF5F5FF) : const Color(0xFF050505);
    final textColor = isLight ? const Color(0xFF1A1A2E) : Colors.white;

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filter by Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 20),
            ...['All', 'Income', 'Expense'].map(
              (type) => ListTile(
                title: Text(type, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                leading: Icon(
                  _selectedType == type ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                  color: _selectedType == type ? const Color(0xFF7C4DFF) : textColor.withValues(alpha: 0.4),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onTap: () {
                  setState(() => _selectedType = type);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilter(bool isLight) {
    final sheetBg = isLight ? const Color(0xFFF5F5FF) : const Color(0xFF050505);
    final textColor = isLight ? const Color(0xFF1A1A2E) : Colors.white;
    final allCats = ['All', ...expenseCategories.map((c) => c.name)];

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filter by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 16),
            SizedBox(
              height: 320,
              child: ListView(
                children: allCats
                    .map(
                      (cat) => ListTile(
                        title: Text(cat, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                        leading: cat == 'All'
                            ? Icon(Icons.all_inclusive_rounded, color: textColor.withValues(alpha: 0.4))
                            : Icon(getCategoryData(cat).icon, color: getCategoryData(cat).color),
                        selected: _selectedCategory == cat,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        onTap: () {
                          setState(() => _selectedCategory = cat);
                          Navigator.pop(context);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null ? DateTimeRange(start: _startDate!, end: _endDate!) : null,
    );
    if (range != null) setState(() { _startDate = range.start; _endDate = range.end; });
  }
}
