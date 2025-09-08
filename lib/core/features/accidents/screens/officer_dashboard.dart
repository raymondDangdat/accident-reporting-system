import 'package:ars/core/features/accidents/screens/report_accident_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';

class OfficerDashboard extends StatelessWidget {
  const OfficerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Officer Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) context.go('/login');
            },
          )
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: const [
            TabBar(
              tabs: [
                Tab(text: "Report Accident"),
                Tab(text: "My Reports"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _ReportAccidentTab(),
                  _MyReportsTab(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ReportAccidentTab extends StatelessWidget {
  const _ReportAccidentTab();

  @override
  Widget build(BuildContext context) {
    return const ReportAccidentScreen(); // full form you already have
  }
}

class _MyReportsTab extends StatelessWidget {
  const _MyReportsTab();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('accidents')
          .where('officerId', isEqualTo: user?.uid)
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final reports = snapshot.data!.docs;

        if (reports.isEmpty) {
          return const Center(child: Text("No reports found."));
        }

        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: const Icon(Icons.report, color: Colors.red),
                title: Text("Accident at ${report['location'] ?? 'Unknown'}"),
                subtitle: Text("Date: ${report['date'] ?? ''}"),
              ),
            );
          },
        );
      },
    );
  }
}