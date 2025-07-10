import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Opcional: Se você já tiver a tela de registro e quiser acessá-la daqui
// import 'register_user_screen.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lista para armazenar os usuários. Você precisará popular isso.
  // Note: FirebaseAuth.instance.currentUser apenas retorna o usuário logado,
  // Para listar todos os usuários, você precisará de uma função de Admin SDK
  // ou uma coleção no Firestore que replique os usuários.
  // Por simplicidade inicial, vamos simular isso ou focar na leitura do Firestore.

  @override
  void initState() {
    super.initState();
    // Você pode chamar uma função aqui para carregar os usuários quando a tela for iniciada
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    // Esta é uma SIMULAÇÃO!
    // Para um ambiente de produção seguro, listar todos os usuários diretamente
    // do cliente (sem Cloud Functions/Admin SDK) não é recomendado por segurança e limitações.
    // Você normalmente teria uma coleção no Firestore, por exemplo, 'users',
    // onde você armazena dados públicos de cada usuário, e leria dali.

    try {
      // Exemplo de leitura de uma coleção 'users' no Firestore
      // Se você não tem uma coleção 'users' no Firestore, este código não vai funcionar como esperado.
      // Você precisará configurar seu backend/Cloud Functions para gerenciar usuários.
      final querySnapshot = await _firestore.collection('users').get();
      for (var doc in querySnapshot.docs) {
        print('Usuário do Firestore: ${doc.id} - ${doc.data()}');
      }
      // Aqui você atualizaria o estado com os usuários lidos.
      // Ex: List<UserModel> users = querySnapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
      // setState(() { this.users = users; });

      // Para uma solução mais robusta e segura para listar usuários do Firebase Authentication,
      // você precisaria de uma Cloud Function (Firebase Functions) que use o Admin SDK.
      // O Firebase Auth no lado do cliente NÃO PERMITE listar todos os usuários.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar usuários: $e')),
        );
      }
      print('Erro ao carregar usuários: $e');
    }
  }

  Future<void> _deleteUser(String userId, String email) async {
    // Isso é extremamente sensível! Deletar um usuário deve ser feito
    // com muito cuidado e, idealmente, através de uma Cloud Function segura
    // que verifica as permissões do usuário que está solicitando a exclusão.
    // Deletar diretamente do cliente não é seguro para usuários aleatórios.

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja deletar o usuário $email? Esta ação é irreversível.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Deletar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        // Exemplo: Deletar o documento do usuário no Firestore, se existir
        await _firestore.collection('users').doc(userId).delete();

        // Para realmente deletar a conta de autenticação (Firebase Auth),
        // você precisaria de uma Cloud Function.
        // O código abaixo é apenas ilustrativo e não funcionará para deletar
        // outros usuários diretamente do cliente, apenas o usuário logado se ele
        // tentar deletar a si mesmo (e mesmo assim, requer reautenticação recente).
        // await _auth.currentUser?.delete(); // Não é o que você quer para deletar outros.

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Usuário $email deletado (simulado, requer Cloud Function para Auth).')),
          );
        }
        // Recarregar a lista de usuários
        _loadUsers();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao deletar usuário: $e')),
          );
        }
        print('Erro ao deletar usuário: $e');
      }
    }
  }

  // Você precisará de uma maneira de exibir os usuários.
  // Para fins de demonstração, vamos apenas mostrar um texto.
  // Em uma aplicação real, você usaria um StreamBuilder ou FutureBuilder
  // com um ListView.builder para mostrar os usuários do Firestore.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Usuários'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Assumindo que você tem uma coleção 'users' no Firestore
        // com o UID do usuário como ID do documento e um campo 'email'.
        // Adapte esta consulta à sua estrutura de dados.
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum usuário encontrado no Firestore.'));
          }

          final usersDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: usersDocs.length,
            itemBuilder: (context, index) {
              final userData = usersDocs[index].data() as Map<String, dynamic>;
              final userId = usersDocs[index].id; // O UID do usuário (se for o ID do documento)
              final userEmail = userData['email'] ?? 'Email não informado';
              final userName = userData['name'] ?? userEmail.split('@')[0]; // Exemplo de nome

              // Exclua o próprio usuário logado da lista se ele for um admin
              // ou não liste o usuário "administrador" se você tiver um.
              // Para demonstração, estou listando todos.

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                elevation: 2,
                child: ListTile(
                  title: Text(userName),
                  subtitle: Text(userEmail),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // TODO: Implementar edição de usuário
                          // Você navegaria para uma tela de edição, passando o userId ou userData
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Editar usuário: $userEmail (ID: $userId)')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(userId, userEmail),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // Você pode adicionar um FloatingActionButton para adicionar novos usuários,
      // embora você já tenha o botão "Cadastrar Usuário" na WelcomeScreen.
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar para a tela de registro de usuário ou uma tela de adição.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterUserScreen()),
          );
        },
        child: const Icon(Icons.person_add),
        tooltip: 'Adicionar novo usuário',
      ),
      */
    );
  }
}