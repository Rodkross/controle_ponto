import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterUserScreen extends StatefulWidget {
  @override
  _RegisterUserScreenState createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isAdminUser = false; // <-- NOVO: Variável para controlar se é admin

  void _registerUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Criar usuário no Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? newUser = userCredential.user;

      if (newUser != null) {
        // 2. Salvar informações adicionais no Firestore
        await _firestore.collection('users').doc(newUser.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'isAdmin': _isAdminUser, // <-- NOVO: Salva o status de admin
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Usuário ${_nameController.text.trim()} cadastrado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          // Opcional: Limpar campos ou voltar para a tela anterior
          _emailController.clear();
          _passwordController.clear();
          _nameController.clear();
          setState(() {
            _isAdminUser = false; // Resetar para o próximo cadastro
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Erro ao cadastrar usuário.';
      if (e.code == 'weak-password') {
        errorMessage = 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Já existe uma conta com este e-mail.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'O formato do e-mail é inválido.';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'Erro de conexão. Verifique sua internet.';
      } else {
        errorMessage = 'Erro: ${e.message ?? e.code}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro inesperado: $e'), backgroundColor: Colors.red),
        );
      }
      print('Erro inesperado ao cadastrar: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Novo Usuário'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Preencha os dados para cadastrar um novo usuário.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    prefixIcon: Icon(Icons.person),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // <-- NOVO: Checkbox para Administrador
                Row(
                  children: [
                    Checkbox(
                      value: _isAdminUser,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _isAdminUser = newValue ?? false;
                        });
                      },
                    ),
                    const Text('Definir como Administrador'),
                  ],
                ),
                const SizedBox(height: 25),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _registerUser,
                        child: const Text('Cadastrar', style: TextStyle(fontSize: 18)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}