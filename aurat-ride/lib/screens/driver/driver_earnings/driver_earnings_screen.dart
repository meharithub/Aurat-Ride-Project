import 'package:aurat_ride/global_widgets/primary_back_button.dart';
import 'package:aurat_ride/global_widgets/primary_heading.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  String _selectedPeriod = 'Today';
  double _totalEarnings = 1250.0;
  int _totalRides = 15;
  double _averageEarnings = 83.33;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryWhite,
      appBar: AppBar(
        backgroundColor: kPrimaryGreen,
        title: Text(
          'Earnings',
          style: TextStyle(color: kPrimaryWhite),
        ),
        leading: PrimaryBackButton(),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: kPrimaryWhite),
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Today', child: Text('Today')),
              PopupMenuItem(value: 'This Week', child: Text('This Week')),
              PopupMenuItem(value: 'This Month', child: Text('This Month')),
              PopupMenuItem(value: 'Last Month', child: Text('Last Month')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            _buildPeriodSelector(),
            SizedBox(height: 20),
            
            // Earnings Summary
            _buildEarningsSummary(),
            SizedBox(height: 20),
            
            // Earnings Chart (Placeholder)
            _buildEarningsChart(),
            SizedBox(height: 20),
            
            // Recent Transactions
            PrimaryHeading(
              heading: "Recent Transactions",
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 10),
            _buildRecentTransactions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: kPrimaryGreen),
          SizedBox(width: 10),
          Text(
            'Showing earnings for: ',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            _selectedPeriod,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kPrimaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSummary() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryGreen, kPrimaryGreen.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Total Earnings',
            style: TextStyle(
              color: kPrimaryWhite,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Rs ${_totalEarnings.toStringAsFixed(0)}',
            style: TextStyle(
              color: kPrimaryWhite,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Rides', '$_totalRides', Icons.local_taxi),
              _buildSummaryItem('Avg/Ride', 'Rs ${_averageEarnings.toStringAsFixed(0)}', Icons.trending_up),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: kPrimaryWhite, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: kPrimaryWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: kPrimaryWhite.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsChart() {
    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimaryWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earnings Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 50,
                    color: kPrimaryGreen.withOpacity(0.3),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Chart Coming Soon',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Container(
      decoration: BoxDecoration(
        color: kPrimaryWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTransactionItem(
            'Ride #12345',
            'Clifton to DHA',
            'Rs 250',
            '2 hours ago',
            true,
          ),
          Divider(height: 1),
          _buildTransactionItem(
            'Ride #12344',
            'Gulshan to Saddar',
            'Rs 180',
            '5 hours ago',
            true,
          ),
          Divider(height: 1),
          _buildTransactionItem(
            'Ride #12343',
            'Korangi to North Nazimabad',
            'Rs 320',
            '1 day ago',
            true,
          ),
          Divider(height: 1),
          _buildTransactionItem(
            'Ride #12342',
            'Defence to Clifton',
            'Rs 150',
            '2 days ago',
            true,
          ),
          Divider(height: 1),
          _buildTransactionItem(
            'Ride #12341',
            'Airport to DHA',
            'Rs 400',
            '3 days ago',
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    String rideId,
    String route,
    String amount,
    String time,
    bool isCompleted,
  ) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.pending,
              color: isCompleted ? Colors.green : Colors.orange,
              size: 20,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rideId,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  route,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryGreen,
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isCompleted ? 'Completed' : 'Pending',
                  style: TextStyle(
                    fontSize: 10,
                    color: isCompleted ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
