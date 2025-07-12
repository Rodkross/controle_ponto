import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para obter o UID do usuário logado

class ManageUsersScreen extends StatefulWidget {
  @override
  _ManageUsersScreenState createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isAdmin = false; // Estado para verificar se o usuário logado é admin

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  // Verifica se o usuário logado é administrador
  Future<void> _checkAdminStatus() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        setState(() {
          _isAdmin = userDoc.data()?['isAdmin'] ?? false;
        });
      }
    }
  }

  // Função para exibir o diálogo de edição
  Future<void> _showEditUserDialog(
      BuildContext context,
      String userId,
      String currentName,
      String currentEmail,
      bool currentIsAdmin) async {
    TextEditingController nameController = TextEditingController(text: currentName);
    bool isAdminValue = currentIsAdmin; // Valor inicial do checkbox

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Usuário deve tocar no botão
      builder: (BuildContext dialogContext) {
        return StatefulBuilder( // Use StatefulBuilder para atualizar o estado do diálogo
          builder: (context, setStateInsideDialog) {
            return AlertDialog(
              title: const Text('Editar Usuário'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                    ),
                    const SizedBox(height: 10),
                    // Email não é editável diretamente aqui, pois é a chave de login do Firebase Auth
                    Text('Email: $currentEmail', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: isAdminValue,
                          onChanged: (bool? newValue) {
                            setStateInsideDialog(() { // Atualiza o estado dentro do diálogo
                              isAdminValue = newValue ?? false;
                            });
                          },
                        ),
                        const Text('É Administrador'),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Salvar'),
                  onPressed: () async {
                    // Lógica para salvar as alterações no Firestore
                    try {
                      await _firestore.collection('users').doc(userId).update({
                        'name': nameController.text.trim(),
                        'isAdmin': isAdminValue, // Salva o novo status de admin
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Usuário atualizado com sucesso!')),
                        );
                        Navigator.of(dialogContext).pop(); // Fecha o diálogo
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao atualizar usuário: $e')),
                        );
                      }
                      print('Erro ao atualizar usuário: $e');
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Função para excluir usuário
  Future<void> _deleteUser(BuildContext context, String userId, String userName) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir o usuário "$userName"? Esta ação é irreversível.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red), // Botão de exclusão vermelho
              child: const Text('Excluir', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      // 1. Excluir o documento do usuário no Firestore
      await _firestore.collection('users').doc(userId).delete();

      // 2. Opcional: Excluir o usuário do Firebase Authentication.
      //    Isso é mais complexo e requer privilégios de administrador no backend (Cloud Functions)
      //    porque você não pode excluir outros usuários do Auth diretamente do cliente por segurança.
      //    Se você tentar, receberá um erro de permissão.
      //    Para uma aplicação real, você chamaria uma Cloud Function aqui.
      //    Ex: await FirebaseFunctions.instance.httpsCallable('deleteUserCallable').call({'uid': userId});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário "$userName" excluído com sucesso do Firestore!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir usuário: $e\n(Exclusão do Auth requer permissões de admin no backend)'),
          ),
        );
      }
      print('Erro ao excluir usuário: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Usuários'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(), // Escuta mudanças na coleção 'users'
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar usuários: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum usuário cadastrado.'));
          }

          // Exibe a lista de usuários
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot userDoc = snapshot.data!.docs[index];
              Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

              String userId = userDoc.id;
              String userName = userData['name'] ?? 'Nome não disponível';
              String userEmail = userData['email'] ?? 'Email não disponível';
              bool userIsAdmin = userData['isAdmin'] ?? false; // Obtém o status isAdmin

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0.0), // Margem vertical reduzida
                elevation: 2, // Elevação um pouco menor
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Raio da borda menor
                child: ListTile( // <-- NOVO: Usando ListTile para compactar a exibição
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Padding interno reduzido
                  title: Text(
                    userName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), // Tamanho de fonte ajustado
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userEmail,
                        style: Theme.of(context).textTheme.bodyMedium, // Tamanho de fonte ajustado
                      ),
                      Text(
                        'Status: ${userIsAdmin ? 'Administrador' : 'Usuário Comum'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith( // Tamanho de fonte ainda menor para o status
                          color: userIsAdmin ? Colors.blue.shade700 : Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: _isAdmin // Só exibe os botões se o usuário logado for admin
                      ? Row(
                          mainAxisSize: MainAxisSize.min, // Importante para que a Row não ocupe todo o espaço
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue, size: 20), // Ícone menor
                              tooltip: 'Editar Usuário',
                              onPressed: () {
                                _showEditUserDialog(context, userId, userName, userEmail, userIsAdmin);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20), // Ícone menor
                              tooltip: 'Excluir Usuário',
                              onPressed: () {
                                _deleteUser(context, userId, userName);
                              },
                            ),
                          ],
                        )
                      : null, // Sem trailing se não for admin
                  // Opcional: onTap no ListTile para abrir a edição, mas já temos botões explícitos
                  // onTap: _isAdmin ? () { _showEditUserDialog(context, userId, userName, userEmail, userIsAdmin); } : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}