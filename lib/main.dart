import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:budget_tracker/budget_repo.dart';
import 'package:budget_tracker/failure.dart';
import 'package:budget_tracker/item.dart';
import 'package:budget_tracker/spending_chart.dart';
import 'package:intl/intl.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 155, 217, 248),
      ),
      home: BudgetScreen(),
    );
  }
}

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late Future<List<Item>> _futureItems;

  @override
  void initState() {
    super.initState();
    _futureItems = BudgetRepository().getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracker'),
        backgroundColor: Color.fromARGB(255, 11, 15, 17),
        foregroundColor:Color.fromARGB(255, 217, 224, 228),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _futureItems = BudgetRepository().getItems();
          setState(() {});
        },
        child: FutureBuilder<List<Item>>(
          future: _futureItems,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // Show pie chart and list view of items.
              final items = snapshot.data!;
              return ListView.builder(
                itemCount: items.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) return SpendingChart(items: items);

                  final item = items[index - 1];
                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: getCategoryColor(item.category),
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                        width: 1.0,
                        color: getCategoryColor(item.category),
                        style: BorderStyle.none,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(item.name,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic)),
                      subtitle: Text(
                        '${item.category} • ${DateFormat.yMd().format(item.date)}',
                      ),
                      trailing: Text(
                        '₹${item.price.toStringAsFixed(2)}',
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              // Show failure error message.
              final failure = snapshot.error as Failure;
              return Center(child: Text(failure.message));
            }
            // Show a loading spinner.
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

Color getCategoryColor(String category) {
  switch (category) {
    case 'Education':
      return Color.fromARGB(255, 9, 188, 198);
    case 'Food':
      return Color.fromARGB(255, 230, 177, 20);
    case 'Personal':
      return Color.fromARGB(255, 150, 252, 60);
    case 'Transportation':
      return Color.fromARGB(255, 100, 110, 109);
    case 'Income':
      return Color.fromARGB(255, 252, 36, 36);
    case 'Medical':
      return Color.fromARGB(255, 180, 43, 239);
    case 'Utilities':
      return Color.fromARGB(255, 236, 225, 234);
    default:
      return Color.fromARGB(255, 44, 25, 131)!;
  }
}
