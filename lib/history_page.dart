import 'package:bolosewu/auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatelessWidget {

  const HistoryPage({super.key,
  });

  void _showDeleteDialog(BuildContext context, String collectionId, String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Hapus Data"),
          content: Text("Apakah Anda yakin ingin menghapus data ini?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Batal", style: Theme.of(context).textTheme.bodyMedium,),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance.collection(collectionId).doc(docId).delete()
                    .then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Data berhasil dihapus!")),
                  );
                  Navigator.pop(context);
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal menghapus data: $error")),
                  );
                  Navigator.pop(context);
                });
              },
              child: Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('History'),),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("${Auth().currentUser?.uid}").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan : ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Belum ada data."));
          }

          final transactionData = snapshot.data!.docs;

          return ListView.builder(
            itemCount: transactionData.length,
            itemBuilder: (context, index) {
              final QueryDocumentSnapshot doc = transactionData[index];
              final data = doc.data() as Map<String, dynamic>;
              final amount = data['amount'] ?? "-";
              final phone = data['phone'] ?? "-";
              final status = data['status'] ?? "-";

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    title: Text("Rp $amount",),
                    subtitle: Text("Nomor HP : $phone"),
                    trailing: Text(
                      status,
                    ),
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => EditData(
                      //       collectionId: collectionId,
                      //       docId: doc.id,
                      //       currentName: name,
                      //       currentNim: nim.toString(),
                      //     ),
                      //   ),
                      // );
                    },
                    onLongPress: () {
                      _showDeleteDialog(context, "${Auth().currentUser?.uid}", doc.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
