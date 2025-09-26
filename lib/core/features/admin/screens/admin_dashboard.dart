import 'dart:io';

import 'package:ars/core/utils/constants.dart';
import 'package:ars/core/utils/functions.dart';
import 'package:ars/core/widgets/custom_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pdf/pdf.dart';

import '../../auth/providers/auth_provider.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Future<void> _confirmLogout(BuildContext context, {required AppAuthProvider authProvider}) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await authProvider.logout();
      if (context.mounted) {
        context.go('/login');
      }
      customSnackBar(context, "Logout successfully",
      isError: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon:  Icon(Icons.logout, color: Colors.red,),
            onPressed: () async {
              _confirmLogout(context, authProvider: authProvider);
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
        onPressed: () => _showAddUserDialog(context, authProvider: authProvider),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  static void _showAddUserDialog(BuildContext context, {required AppAuthProvider authProvider}) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String? selectedRole;
    bool isLoading = false; // 👈 loading flag

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text("Add User"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(labelText: "Full Name"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(labelText: "Role"),
                    items: const [
                      DropdownMenuItem(
                        value: "admin",
                        child: Text("Admin"),
                      ),
                      DropdownMenuItem(
                        value: "officer",
                        child: Text("Officer"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                  final sharedPrefs = await SharedPreferences.getInstance();
                  String adminPassword = sharedPrefs.getString(adminPasswrd) ?? '';
                  final name = nameController.text.trim();
                  final email = emailController.text.trim();
                  final password = 'FRSC2025';
                  final role = selectedRole;

                  if (name.isEmpty || email.isEmpty || password.isEmpty || role == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all fields")),
                    );
                    return;
                  }

                  try {
                    setState(() => isLoading = true); // 👈 Start loading

                    // Save current admin credentials
                    final adminUser = FirebaseAuth.instance.currentUser;
                    final adminEmail = adminUser?.email;

                    // Create new user in Firebase Auth
                    final newUser = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );

                    // Store user role + extra data in Firestore
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(newUser.user!.uid)
                        .set({
                      'name': name,
                      'email': email,
                      'role': role,
                    });

                    // Re-login admin (if needed)
                    if (adminEmail != null) {
                      debugPrint("Started re-login");
                      await authProvider.login(
                        adminEmail,
                        adminPassword,
                      );
                      debugPrint("Completed re-login");

                      setState(() => isLoading = false);

                      if (context.mounted) Navigator.pop(ctx);

                    }
                    setState((){

                    });


                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  } finally {
                    setState(() => isLoading = false);
                  }
                },
                child: isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text("Add"),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UserManagementTab extends StatelessWidget {
  const _UserManagementTab();

  Future<void> _confirmDelete(BuildContext context, String userId, String userName) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete $userName?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$userName deleted successfully")),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return  Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No users found",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final users = snapshot.data!.docs;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return  Consumer<AppAuthProvider>(builder:
                (ctx, authProvider, child) {
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('${ user['name']} ${authProvider.adminEmail == user['email'] ? "(you)" : ''}'),
                  subtitle: Text("Role: ${user['role']}"),
                  trailing: user['email'] == FirebaseAuth.instance.currentUser?.email ? null : IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        _confirmDelete(context, user.id, user['name']),
                  ),
                );
              }
            );
          },
        );
      },
    );
  }
}

// class _ReportsTab extends StatelessWidget {
//   const _ReportsTab();
//
//   Future<void> _downloadReportAsPdf(Map<String, dynamic> report) async {
//     final pdf = pw.Document();
//
//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return pw.Padding(
//             padding: const pw.EdgeInsets.all(24),
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text(
//                   "Accident Report",
//                   style: pw.TextStyle(
//                     fontSize: 20,
//                     fontWeight: pw.FontWeight.bold,
//                   ),
//                 ),
//                 pw.SizedBox(height: 20),
//                 ...report.entries.map(
//                       (e) => pw.Text(
//                     "${e.key}: ${e.value ?? ''}",
//                     style: const pw.TextStyle(fontSize: 12),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//
//     // ✅ This opens the preview
//     await Printing.layoutPdf(
//       onLayout: (PdfPageFormat format) async => pdf.save(),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('accidents').snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.report_problem_outlined, size: 60, color: Colors.grey),
//                 SizedBox(height: 16),
//                 Text(
//                   "No accident reports yet",
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         final reports = snapshot.data!.docs;
//
//         return ListView.builder(
//           itemCount: reports.length,
//           itemBuilder: (context, index) {
//             final report = reports[index].data() as Map<String, dynamic>;
//             return Card(
//               margin: const EdgeInsets.all(8),
//               child: ListTile(
//                 title: Text("Accident at ${report['location'] ?? 'Unknown'}"),
//                 subtitle: Text("Date: ${formatDateTime(DateTime.parse(report['date'] ?? DateTime.now().toString()))}"),
//                 trailing: IconButton(
//                   icon: const Icon(Icons.picture_as_pdf),
//                   onPressed: () => _downloadReportAsPdf(report),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
class _ReportsTab extends StatelessWidget {
  const _ReportsTab();

  Future<pw.Document> _buildPdf(Map<String, dynamic> report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Accident Report",
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                ...report.entries.map(
                      (e) => pw.Text(
                    "${e.key}: ${e.value ?? ''}",
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  Future<void> _previewReport(Map<String, dynamic> report) async {
    final pdf = await _buildPdf(report);

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _downloadReport(Map<String, dynamic> report, {required BuildContext context}) async {
    final pdf = await _buildPdf(report);

    Directory? directory;

    if (Platform.isAndroid) {
      // Android: Save to public Downloads folder
      directory = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      // iOS: Save to app's documents directory (iOS restricts public Downloads access)
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final file = File(
      "${directory.path}/accident_report_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(await pdf.save());

    debugPrint("✅ File saved at: ${file.path}");

    // Show success message
    // ignore: use_build_context_synchronously
    customSnackBar(context, "Download Complete ${Platform.isAndroid ? 'Report saved in Downloads folder' : 'Report saved at ${file.path}'}",
    isError: false);

  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('accidents').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.report_problem_outlined, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No accident reports yet",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

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
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'preview') {
                      _previewReport(report);
                    } else if (value == 'download') {
                      _downloadReport(report, context: context);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'preview',
                      child: Row(
                        children: [
                          Icon(Icons.remove_red_eye, color: Colors.blue),
                          SizedBox(width: 8),
                          Text("Preview"),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'download',
                      child: Row(
                        children: [
                          Icon(Icons.download, color: Colors.green),
                          SizedBox(width: 8),
                          Text("Download"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}