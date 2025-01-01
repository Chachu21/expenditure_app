// ignore_for_file: library_private_types_in_public_api

import 'package:expenditure_app/model/loan.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  _LoanScreenState createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _personController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Loans')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Loan>>(
              future: databaseService.getLoans(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No loans yet'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final loan = snapshot.data![index];
                    return Dismissible(
                      key: Key(loan.id.toString()),
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.check, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        databaseService.deleteLoan(loan.id!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Loan repaid')),
                        );
                      },
                      child: ListTile(
                        title: Text('${loan.person} owes you'),
                        subtitle:
                            Text(DateFormat('yyyy-MM-dd').format(loan.date)),
                        trailing: Text('\$${loan.amount.toStringAsFixed(2)}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Form(
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
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _personController,
                    decoration: InputDecoration(labelText: 'Person'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a person\'s name';
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
                          if (pickedDate != null &&
                              pickedDate != _selectedDate) {
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
                        final newLoan = Loan(
                          date: _selectedDate,
                          amount: double.parse(_amountController.text),
                          person: _personController.text,
                        );
                        databaseService.insertLoan(newLoan);
                        _amountController.clear();
                        _personController.clear();
                        setState(() {});
                      }
                    },
                    child: Text('Add Loan'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
