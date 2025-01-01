import 'package:expenditure_app/model/borrow.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class BorrowScreen extends StatefulWidget {
  const BorrowScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BorrowScreenState createState() => _BorrowScreenState();
}

class _BorrowScreenState extends State<BorrowScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _personController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Borrowings')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Borrow>>(
              future: databaseService.getBorrowings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No borrowings yet'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final borrow = snapshot.data![index];
                    return Dismissible(
                      key: Key(borrow.id.toString()),
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.check, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        databaseService.deleteBorrowing(borrow.id!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Borrowing repaid')),
                        );
                      },
                      child: ListTile(
                        title: Text('You owe ${borrow.person}'),
                        subtitle:
                            Text(DateFormat('yyyy-MM-dd').format(borrow.date)),
                        trailing: Text('\$${borrow.amount.toStringAsFixed(2)}'),
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
                        final newBorrow = Borrow(
                          date: _selectedDate,
                          amount: double.parse(_amountController.text),
                          person: _personController.text,
                        );
                        databaseService.insertBorrowing(newBorrow);
                        _amountController.clear();
                        _personController.clear();
                        setState(() {});
                      }
                    },
                    child: Text('Add Borrowing'),
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
