// ignore_for_file: library_private_types_in_public_api

import 'package:expenditure_app/model/expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

// Constants for Text
const String appBarTitle = 'Expenditure Tracker';
const String noExpensesMessage = 'No expenses yet';
const String addExpenseButtonLabel = 'Add Expense';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(context);

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Expense>>(
              future: databaseService.getExpenses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(noExpensesMessage));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final expense = snapshot.data![index];
                    return Dismissible(
                      key: Key(expense.id.toString()),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        databaseService.deleteExpense(expense.id!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Expense deleted'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                databaseService.insertExpense(expense);
                              },
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(expense.reason),
                        subtitle:
                            Text(DateFormat('yyyy-MM-dd').format(expense.date)),
                        trailing:
                            Text('\$${expense.amount.toStringAsFixed(2)}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: ExpenseForm(
              onAddExpense: (expense) {
                databaseService.insertExpense(expense);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Expense added')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ExpenseForm Widget for Adding Expenses
class ExpenseForm extends StatefulWidget {
  final Function(Expense) onAddExpense;

  const ExpenseForm({super.key, required this.onAddExpense});

  @override
  _ExpenseFormState createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _amountController,
            decoration: InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
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
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                ),
              ),
              TextButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null && pickedDate != _selectedDate) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                child: Text('Select date'),
              ),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newExpense = Expense(
                  date: _selectedDate,
                  amount: double.parse(_amountController.text),
                  reason: _reasonController.text,
                );
                widget.onAddExpense(newExpense);
                _amountController.clear();
                _reasonController.clear();
              }
            },
            child: Text(addExpenseButtonLabel),
          ),
        ],
      ),
    );
  }
}
