import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_surface.dart';
import '../widgets/glass_input_field.dart';
import '../widgets/glass_button.dart';

/// Screen for adding or editing a transaction — Apple Liquid Glass design.
class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;
  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _type = 'Expense';
  String _category = 'Food';
  DateTime _selectedDate = DateTime.now();
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _isEditing = true;
      final t = widget.transaction!;
      _titleController.text = t.title;
      _amountController.text = t.amount.toString();
      _type = t.type;
      _category = t.category;
      _selectedDate = t.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  List<String> get _availableCategories =>
      _type == 'Income' ? incomeCategories : expenseCategoriesList;

  @override
  Widget build(BuildContext context) {
    final isLight = context.watch<SettingsProvider>().isLight;
    final textColor = isLight ? const Color(0xFF1A1A2E) : Colors.white;
    final dimColor = (isLight ? Colors.black : Colors.white).withValues(alpha: 0.45);

    if (!_availableCategories.contains(_category)) {
      _category = _availableCategories.first;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Transaction' : 'Add Transaction',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: GlassBackground(
        isLight: isLight,
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              children: [
                _buildTypeToggle(isLight),
                const SizedBox(height: 24),
                GlassInputField(
                  controller: _titleController,
                  label: 'Title',
                  hint: 'e.g., Grocery shopping',
                  icon: Icons.edit_rounded,
                  isLight: isLight,
                  textColor: textColor,
                  dimColor: dimColor,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 16),
                GlassInputField(
                  controller: _amountController,
                  label: 'Amount (₹)',
                  hint: 'e.g., 500',
                  icon: Icons.currency_rupee_rounded,
                  keyboardType: TextInputType.number,
                  isLight: isLight,
                  textColor: textColor,
                  dimColor: dimColor,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter amount';
                    final a = double.tryParse(v);
                    if (a == null || a <= 0) return 'Enter a valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Category',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCategoryGrid(isLight, textColor),
                const SizedBox(height: 24),
                _buildDatePicker(isLight, textColor, dimColor),
                const SizedBox(height: 36),
                GlassButton(
                  label: _isEditing ? 'Update Transaction' : 'Save Transaction',
                  icon: Icons.check_circle_rounded,
                  isLoading: _isLoading,
                  accentColor: const Color(0xFF7C4DFF),
                  isLight: isLight,
                  onPressed: _isLoading ? null : _saveTransaction,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle(bool isLight) {
    return GlassSurface(
      padding: const EdgeInsets.all(4),
      borderRadius: 20,
      blur: 10,
      fillOpacity: 0.05,
      isLight: isLight,
      child: Row(
        children: [
          _typeBtn('Income', const Color(0xFF00C9A7), isLight),
          _typeBtn('Expense', const Color(0xFFFF6B6B), isLight),
        ],
      ),
    );
  }

  Widget _typeBtn(String type, Color color, bool isLight) {
    final selected = _type == type;
    final inactiveColor = isLight
        ? Colors.black.withValues(alpha: 0.45)
        : Colors.white.withValues(alpha: 0.45);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _type = type;
          _category = (_type == 'Income' ? incomeCategories : expenseCategoriesList).first;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 14,
                      spreadRadius: -2,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              type,
              style: TextStyle(
                color: selected ? Colors.white : inactiveColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(bool isLight, Color textColor) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _availableCategories.map((cat) {
        final catData = getCategoryData(cat);
        final selected = _category == cat;
        final inactiveText = isLight
            ? Colors.black.withValues(alpha: 0.7)
            : Colors.white.withValues(alpha: 0.75);

        return GestureDetector(
          onTap: () => setState(() => _category = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? catData.color.withValues(alpha: 0.18)
                  : (isLight ? Colors.black : Colors.white).withValues(alpha: isLight ? 0.04 : 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? catData.color
                    : (isLight ? Colors.black : Colors.white).withValues(alpha: isLight ? 0.08 : 0.1),
                width: selected ? 1.5 : 0.8,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: catData.color.withValues(alpha: 0.25),
                        blurRadius: 10,
                        spreadRadius: -2,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(catData.icon, size: 18, color: catData.color),
                const SizedBox(width: 7),
                Text(
                  cat,
                  style: TextStyle(
                    color: selected ? catData.color : inactiveText,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker(bool isLight, Color textColor, Color dimColor) {
    return GlassSurface(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      isLight: isLight,
      onTap: _pickDate,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF7C4DFF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calendar_today_rounded, color: Color(0xFF7C4DFF), size: 18),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date', style: TextStyle(color: dimColor, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.arrow_drop_down_rounded, color: dimColor),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveTransaction() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final transaction = TransactionModel(
        id: _isEditing ? widget.transaction!.id : null,
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        type: _type,
        category: _category,
        date: _selectedDate,
        firestoreId: _isEditing ? widget.transaction!.firestoreId : null,
      );

      final provider = Provider.of<TransactionProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;

      if (_isEditing) {
        await provider.updateTransaction(transaction, userId: userId);
      } else {
        await provider.addTransaction(transaction, userId: userId);
      }

      if (mounted) {
        if (_type == 'Expense' && provider.isBudgetExceeded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Monthly budget exceeded!'),
                ],
              ),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          );
        }
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error saving transaction: $e');
    } finally {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
