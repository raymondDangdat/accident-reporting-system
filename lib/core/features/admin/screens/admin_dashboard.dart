import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                context.go('/login');
              }
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
                Tab(text: "Users"),
                Tab(text: "Reports"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _UserManagementTab(),
                  _ReportsTab(),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  static void _showAddUserDialog(BuildContext context) {
    final emailController = TextEditingController();
    final roleController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add User"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(labelText: "Role (admin/officer)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              final role = roleController.text.trim().toLowerCase();

              if (email.isEmpty || role.isEmpty) return;

              // Create a user in Firestore (Auth user created by super admin manually)
              await FirebaseFirestore.instance.collection('users').add({
                'email': email,
                'role': role,
                'createdAt': FieldValue.serverTimestamp(),
              });

              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }
}

class _UserManagementTab extends StatelessWidget {
  const _UserManagementTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final users = snapshot.data!.docs;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(user['email']),
              subtitle: Text("Role: ${user['role']}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.id)
                      .delete();
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab();

  Future<void> _downloadReportAsPdf(Map<String, dynamic> report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Padding(
          padding: const pw.EdgeInsets.all(16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: report.entries
                .map((e) => pw.Text("${e.key}: ${e.value}"))
                .toList(),
          ),
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('accidents').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final reports = snapshot.data!.docs;

        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text("Accident at ${report['location'] ?? 'Unknown'}"),
                subtitle: Text("Date: ${report['date'] ?? ''}"),
                trailing: IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: () => _downloadReportAsPdf(report),
                ),
              ),
            );
          },
        );
      },
    );
  }
}