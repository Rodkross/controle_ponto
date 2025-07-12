import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para mostrar o diálogo de edição
  Future<void> _showEditDialog(DocumentSnapshot userDoc) async {
    final nameController = TextEditingController(text: userDoc['name']);

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Editar Usuário'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nome'),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text('Salvar'),
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                try {
                  await _firestore
                      .collection('users')
                      .doc(userDoc.id)
                      .update({'name': nameController.text.trim()});
                  Navigator.of(dialogContext).pop();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Usuário atualizado com sucesso!')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao atualizar usuário: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Função para mostrar a confirmação de exclusão
  Future<void> _confirmDelete(DocumentSnapshot userDoc) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text(
              'Tem certeza que deseja excluir o usuário ${userDoc['name']}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Excluir'),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Fecha o diálogo primeiro
                try {
                  // ATENÇÃO: Isso exclui apenas o registro do Firestore.
                  // A exclusão do usuário no FirebaseAuth requer um backend (Cloud Functions).
                  await _firestore.collection('users').doc(userDoc.id).delete();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Usuário excluído com sucesso!')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir usuário: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Usuários'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum usuário encontrado.'));
          }
          if (snapshot.hasError) {
            return const Center(
                child: Text('Ocorreu um erro ao carregar os usuários.'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userDoc = users[index];
              final userData = userDoc.data() as Map<String, dynamic>;
              final userName = userData['name'] ?? 'Nome não informado';
              final userEmail = userData['email'] ?? 'Email não informado';

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    child:
                        Text(userName.isNotEmpty ? userName[0].toUpperCase() : '?'),
                  ),
                  title: Text(userName),
                  subtitle: Text(userEmail),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditDialog(userDoc),
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(userDoc),
                        tooltip: 'Excluir',
                      ),
                    ],
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