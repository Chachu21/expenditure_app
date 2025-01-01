import 'package:expenditure_app/model/expense.dart';
import 'package:expenditure_app/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Expense>> _expensesFuture;
  late Future<double> _totalExpenseFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final databaseService =
        Provider.of<DatabaseService>(context, listen: false);
    _expensesFuture = databaseService.getExpenses();
    _totalExpenseFuture = databaseService.getTotalExpenseForCurrentMonth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          FutureBuilder<double>(
            future: _totalExpenseFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              return Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Total Expense: \$${snapshot.data?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
          Expanded(
            child: FutureBuilder<List<Expense>>(
              future: _expensesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final expenses = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ListTile(
                      title: Text(expense.reason),
                      subtitle: Text(expense.date.toString().split(' ')[0]),
                      trailing: Text('\$${expense.amount.toStringAsFixed(2)}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _dateController = TextEditingController();
    final _amountController = TextEditingController();
    final _reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Expense'),
          content: SizedBox(
            width: double.infinity,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a date';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _reasonController,
                    decoration: InputDecoration(labelText: 'Reason'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a reason';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final databaseService =
                      Provider.of<DatabaseService>(context, listen: false);
                  await databaseService.insertExpense(
                    Expense(
                      date: DateTime.parse(_dateController.text),
                      amount: double.parse(_amountController.text),
                      reason: _reasonController.text,
                    ),
                  );
                  Navigator.pop(context);
                  setState(() {
                    _refreshData();
                  });
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
