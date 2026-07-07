import 'package:flutter/material.dart';

void main() {
  runApp(const TradingApp());
}

class TradingApp extends StatelessWidget {
  const TradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trade Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
      },
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Trade> activeTrades = [
    Trade(symbol: 'AAPL', entryPrice: 175.50, targetExit: 185.00, stopLoss: 170.00, purpose: 'Breakout from consolidation'),
    Trade(symbol: 'EUR/USD', entryPrice: 1.0850, targetExit: 1.0950, stopLoss: 1.0800, purpose: 'Support bounce'),
  ];

  void _addTrade() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddTradeForm(
          onAdd: (trade) {
            setState(() {
              activeTrades.add(trade);
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Tracker - Entry & Exit'),
        centerTitle: true,
      ),
      body: activeTrades.isEmpty
          ? const Center(child: Text('No active trades. Add one to start tracking.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activeTrades.length,
              itemBuilder: (context, index) {
                final trade = activeTrades[index];
                return TradeCard(trade: trade);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTrade,
        icon: const Icon(Icons.add),
        label: const Text('New Trade'),
      ),
    );
  }
}

class TradeCard extends StatelessWidget {
  final Trade trade;

  const TradeCard({super.key, required this.trade});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trade.symbol,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('ACTIVE', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Purpose: ${trade.purpose}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPriceMetric('ENTRY', trade.entryPrice, Colors.amber),
                _buildPriceMetric('TARGET EXIT', trade.targetExit, Colors.green),
                _buildPriceMetric('STOP LOSS', trade.stopLoss, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceMetric(String label, double price, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
        const SizedBox(height: 4),
        Text(
          price.toStringAsFixed(2),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

class AddTradeForm extends StatefulWidget {
  final Function(Trade) onAdd;

  const AddTradeForm({super.key, required this.onAdd});

  @override
  State<AddTradeForm> createState() => _AddTradeFormState();
}

class _AddTradeFormState extends State<AddTradeForm> {
  final _formKey = GlobalKey<FormState>();
  String symbol = '';
  double entryPrice = 0;
  double targetExit = 0;
  double stopLoss = 0;
  String purpose = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Record New Trade Entry', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Symbol (e.g. BTC/USD)'),
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              onSaved: (value) => symbol = value ?? '',
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Entry Price'),
              keyboardType: TextInputType.number,
              validator: (value) => value == null || double.tryParse(value) == null ? 'Invalid number' : null,
              onSaved: (value) => entryPrice = double.tryParse(value ?? '0') ?? 0,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Target Exit Price'),
              keyboardType: TextInputType.number,
              validator: (value) => value == null || double.tryParse(value) == null ? 'Invalid number' : null,
              onSaved: (value) => targetExit = double.tryParse(value ?? '0') ?? 0,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Stop Loss Exit Price'),
              keyboardType: TextInputType.number,
              validator: (value) => value == null || double.tryParse(value) == null ? 'Invalid number' : null,
              onSaved: (value) => stopLoss = double.tryParse(value ?? '0') ?? 0,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Trade Purpose / Thesis'),
              maxLines: 2,
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              onSaved: (value) => purpose = value ?? '',
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  widget.onAdd(Trade(
                    symbol: symbol,
                    entryPrice: entryPrice,
                    targetExit: targetExit,
                    stopLoss: stopLoss,
                    purpose: purpose,
                  ));
                }
              },
              child: const Text('Save Entry'),
            )
          ],
        ),
      ),
    );
  }
}

class Trade {
  final String symbol;
  final double entryPrice;
  final double targetExit;
  final double stopLoss;
  final String purpose;

  Trade({
    required this.symbol,
    required this.entryPrice,
    required this.targetExit,
    required this.stopLoss,
    required this.purpose,
  });
}
