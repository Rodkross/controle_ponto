import 'register_user_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:collection/collection.dart'; // Importação necessária para firstWhereOrNull

import 'firebase_options.dart'; // Certifique-se de que este arquivo existe e está configurado

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(JornadaApp());
}

class JornadaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Jornada',
      home: LoginPage(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('pt', 'BR')],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode &&
              supportedLocale.countryCode == locale?.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.blue),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
            side: const BorderSide(color: Colors.blue),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isPasswordVisible =
      false; // Variável de estado para visibilidade da senha

  void _login() async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );
      // Navega para a WelcomeScreen após o login bem-sucedido
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WelcomeScreen(user: userCredential.user!),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Erro desconhecido no login.';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Nenhum usuário encontrado para este e-mail.';
          break;
        case 'wrong-password':
          errorMessage = 'Senha incorreta. Por favor, tente novamente.';
          break;
        case 'invalid-email':
          errorMessage = 'O formato do e-mail é inválido.';
          break;
        case 'network-request-failed':
          errorMessage = 'Erro de conexão. Verifique sua internet.';
          break;
        case 'too-many-requests':
          errorMessage =
              'Muitas tentativas de login. Tente novamente mais tarde.';
          break;
        default:
          errorMessage = 'Erro no login: ${e.message ?? e.code}';
          break;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro inesperado: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/images/logo2.png',
                  height: 150, // Ajuste a altura conforme necessário
                  width: 150, // Ajuste a largura conforme necessário
                ),
                const SizedBox(height: 120), // Espaçamento após a logo
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: senhaController,
                  obscureText:
                      !_isPasswordVisible, // Controla a visibilidade da senha
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      // Botão para alternar visibilidade da senha
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Entrar', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Funcionalidade "Esqueceu a senha?" em desenvolvimento.',
                        ),
                      ),
                    );
                  },
                  child: const Text('Esqueceu a senha?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Tela de Boas-Vindas ---
class WelcomeScreen extends StatefulWidget {
  final User user;

  const WelcomeScreen({required this.user});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  void _navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(user: widget.user)),
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bem-vindo(a), ${widget.user.email?.split('@')[0].toUpperCase() ?? 'Usuário'.toUpperCase()}!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _navigateToHomePage,
              icon: const Icon(Icons.calendar_today),
              label: const Text('Registrar Ponto'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 25,
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Implementar navegação para tela de cadastro
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterUserScreen()),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Cadastrar Usuário'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 25,
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Sair'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 25,
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// --- Fim da Tela de Boas-Vindas ---

// --- Definição do enum PunchType e sua extensão ---
enum PunchType { entrada, saidaIntervalo, retornoIntervalo, saida }

extension PunchTypeExtension on PunchType {
  String toFirestoreString() {
    switch (this) {
      case PunchType.entrada:
        return 'entrada';
      case PunchType.saidaIntervalo:
        return 'saída intervalo';
      case PunchType.retornoIntervalo:
        return 'retorno intervalo';
      case PunchType.saida:
        return 'saída';
    }
  }

  String toDisplayString() {
    switch (this) {
      case PunchType.entrada:
        return 'Entrada';
      case PunchType.saidaIntervalo:
        return 'Saída Intervalo';
      case PunchType.retornoIntervalo:
        return 'Retorno Intervalo';
      case PunchType.saida:
        return 'Saída';
    }
  }
}
// --- Fim da definição do enum PunchType e sua extensão ---

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _status = "Fora de Jornada";
  bool _isAdmin = false;

  bool _canRegisterEntrada = true;
  bool _canRegisterSaidaIntervalo = false;
  bool _canRegisterRetornoIntervalo = false;
  bool _canRegisterSaida = false;

  @override
  void initState() {
    super.initState();
    _loadUserStatusAndPunchStates();
  }

  Future<void> _loadUserStatusAndPunchStates() async {
    setState(() {
      _isAdmin =
          true; // Definido como true para fins de demonstração. Em um app real, buscaria de algum lugar.
    });

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    try {
      final lastPunchSnapshot = await _db
          .collection('batidas')
          .where('uid', isEqualTo: widget.user.uid)
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThanOrEqualTo: endOfDay)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (lastPunchSnapshot.docs.isNotEmpty) {
        final lastPunch = lastPunchSnapshot.docs.first.data();
        final lastPunchTypeString = lastPunch['tipo'] as String;

        // Converte a string do Firestore de volta para o enum PunchType
        final PunchType? lastPunchType = PunchType.values.firstWhereOrNull(
          (type) => type.toFirestoreString() == lastPunchTypeString,
        );

        if (lastPunchType == PunchType.saida) {
          setState(() {
            _status = "Jornada Concluída";
            _canRegisterEntrada = false;
            _canRegisterSaidaIntervalo = false;
            _canRegisterRetornoIntervalo = false;
            _canRegisterSaida = false;
          });
        } else if (lastPunchType != null) {
          setState(() {
            _updateStatusAndButtonStates(lastPunchType);
          });
        }
      } else {
        setState(() {
          _status = "Fora de Jornada";
          _canRegisterEntrada = true;
          _canRegisterSaidaIntervalo = false;
          _canRegisterRetornoIntervalo = false;
          _canRegisterSaida = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar estado dos pontos: $e')),
        );
      }
      print('Erro ao carregar estado dos pontos: $e');
    }
  }

  void _updateStatusAndButtonStates(PunchType lastPunchType) {
    switch (lastPunchType) {
      case PunchType.entrada:
        _status = "Em Jornada";
        _canRegisterEntrada = false;
        _canRegisterSaidaIntervalo = true;
        _canRegisterRetornoIntervalo = false;
        _canRegisterSaida = true;
        break;
      case PunchType.saidaIntervalo:
        _status = "Em Intervalo";
        _canRegisterEntrada = false;
        _canRegisterSaidaIntervalo = false;
        _canRegisterRetornoIntervalo = true;
        _canRegisterSaida = false;
        break;
      case PunchType.retornoIntervalo:
        _status = "Em Jornada";
        _canRegisterEntrada = false;
        _canRegisterSaidaIntervalo = false;
        _canRegisterRetornoIntervalo = false;
        _canRegisterSaida = true;
        break;
      case PunchType.saida:
        _status = "Jornada Concluída";
        _canRegisterEntrada = false;
        _canRegisterSaidaIntervalo = false;
        _canRegisterRetornoIntervalo = false;
        _canRegisterSaida = false;
        break;
    }
  }

  void _registrarBatida(BuildContext context, PunchType tipo) async {
    if ((tipo == PunchType.entrada && !_canRegisterEntrada) ||
        (tipo == PunchType.saidaIntervalo && !_canRegisterSaidaIntervalo) ||
        (tipo == PunchType.retornoIntervalo && !_canRegisterRetornoIntervalo) ||
        (tipo == PunchType.saida && !_canRegisterSaida)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Esta batida não é permitida no momento.'),
          ),
        );
      }
      return;
    }

    try {
      await _db.collection('batidas').add({
        'uid': widget.user.uid,
        'tipo': tipo
            .toFirestoreString(), // Usa a extensão para gravar no Firestore
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _updateStatusAndButtonStates(tipo);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Batida "${tipo.toDisplayString()}" registrada com sucesso.',
            ),
          ), // Usa para exibição na UI
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao registrar batida: $e')));
      }
      print('Erro ao registrar batida: $e');
    }
  }

  Future<void> _mostrarRegistrosDoMes(BuildContext context) async {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    try {
      final querySnapshot = await _db
          .collection('batidas')
          .where('uid', isEqualTo: widget.user.uid)
          .where('timestamp', isGreaterThanOrEqualTo: firstDayOfMonth)
          .where('timestamp', isLessThanOrEqualTo: lastDayOfMonth)
          .orderBy('timestamp', descending: false)
          .get();

      Map<String, Map<String, String>> dailyRecords = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
        final tipo =
            data['tipo'] as String?; // Continua lendo como string do Firestore

        if (timestamp != null && tipo != null) {
          final dateKey = DateFormat('yyyy-MM-dd').format(timestamp);
          final timeValue = DateFormat('HH:mm').format(timestamp);

          dailyRecords.putIfAbsent(dateKey, () => {});
          dailyRecords[dateKey]![tipo] = timeValue;
        }
      }

      final sortedDates = dailyRecords.keys.toList()..sort();

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(
              'Registros do Mês (${DateFormat('MMMM y', 'pt_BR').format(now)})',
              style: const TextStyle(fontSize: 18),
            ),
            content: SizedBox(
              width: kIsWeb ? 800 : MediaQuery.of(context).size.width * 0.9,
              child: sortedDates.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum registro encontrado para este mês.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : kIsWeb
                  ? SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 20,
                        dataRowMinHeight: 40,
                        dataRowMaxHeight: 50,
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Data',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Entrada',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Saída Intervalo',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Retorno Intervalo',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Saída',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: sortedDates.map((dateKey) {
                          final records = dailyRecords[dateKey]!;
                          final displayDate = DateFormat(
                            'dd/MM',
                          ).format(DateTime.parse(dateKey));
                          // Mapeie as chaves usando as strings do Firestore que correspondem aos enums
                          return DataRow(
                            cells: <DataCell>[
                              DataCell(Text(displayDate)),
                              DataCell(
                                Text(
                                  records[PunchType.entrada
                                          .toFirestoreString()] ??
                                      '-',
                                ),
                              ),
                              DataCell(
                                Text(
                                  records[PunchType.saidaIntervalo
                                          .toFirestoreString()] ??
                                      '-',
                                ),
                              ),
                              DataCell(
                                Text(
                                  records[PunchType.retornoIntervalo
                                          .toFirestoreString()] ??
                                      '-',
                                ),
                              ),
                              DataCell(
                                Text(
                                  records[PunchType.saida
                                          .toFirestoreString()] ??
                                      '-',
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: sortedDates.length,
                      itemBuilder: (context, index) {
                        final dateKey = sortedDates[index];
                        final records = dailyRecords[dateKey]!;
                        final displayDate = DateFormat(
                          'dd/MM/yyyy',
                        ).format(DateTime.parse(dateKey));

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayDate,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Divider(),
                                // Use toDisplayString para o rótulo e toFirestoreString para buscar no mapa
                                _buildTimeRow(
                                  PunchType.entrada.toDisplayString(),
                                  records[PunchType.entrada
                                      .toFirestoreString()],
                                ),
                                _buildTimeRow(
                                  PunchType.saidaIntervalo.toDisplayString(),
                                  records[PunchType.saidaIntervalo
                                      .toFirestoreString()],
                                ),
                                _buildTimeRow(
                                  PunchType.retornoIntervalo.toDisplayString(),
                                  records[PunchType.retornoIntervalo
                                      .toFirestoreString()],
                                ),
                                _buildTimeRow(
                                  PunchType.saida.toDisplayString(),
                                  records[PunchType.saida.toFirestoreString()],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar registros do mês: $e')),
        );
      }
      print('Erro ao carregar registros do mês: $e');
    }
  }

  Widget _buildTimeRow(String label, String? time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(time ?? '-'),
        ],
      ),
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  // --- FUNÇÃO PARA VOLTAR PARA A TELA DE BOAS-VINDAS ---
  void _backToWelcomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen(user: widget.user)),
    );
  }
  // --- FIM DA FUNÇÃO ---

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.blue; // Cor padrão para "Fora de Jornada"

    if (_status == "Jornada Concluída") {
      statusColor = Colors.green; // Verde para "Jornada Concluída"
    } else if (_status == "Em Jornada") {
      statusColor = Colors.red; // Vermelho para "Em Jornada"
    } else if (_status == "Em Intervalo") {
      statusColor = Colors.orange; // Laranja para "Em Intervalo"
    }

    // O caso padrão (Fora de Jornada) já está definido como azul na inicialização.

    // O restante do código permanece o mesmo...

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Jornada'),
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
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, ${widget.user.email?.split('@')[0] ?? 'Usuário'}!',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Divider(color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text(
                          'Status Atual:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          _status,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio:
                      (MediaQuery.of(context).size.width / 2 - 35) / 100,
                  children: [
                    _buildPontoButton(
                      context,
                      'Registrar Entrada',
                      PunchType.entrada, // Usando o enum
                      _canRegisterEntrada,
                      Icons.login,
                    ),
                    _buildPontoButton(
                      context,
                      'Saída para Intervalo',
                      PunchType.saidaIntervalo, // Usando o enum
                      _canRegisterSaidaIntervalo,
                      Icons.lunch_dining,
                    ),
                    _buildPontoButton(
                      context,
                      'Retorno do Intervalo',
                      PunchType.retornoIntervalo, // Usando o enum
                      _canRegisterRetornoIntervalo,
                      Icons.restaurant_menu,
                    ),
                    _buildPontoButton(
                      context,
                      'Registrar Saída',
                      PunchType.saida, // Usando o enum
                      _canRegisterSaida,
                      Icons.logout,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                OutlinedButton.icon(
                  onPressed: () => _mostrarRegistrosDoMes(context),
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Ver Registros do Mês'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                if (_isAdmin) ...[
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Gestão de registros (Admin) em desenvolvimento.',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.red,
                    ),
                    label: const Text(
                      'Gerir Registros (Admin)',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      // --- FloatingActionButtons na parte inferior ---
      floatingActionButton: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Para espaçar os botões
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 30,
            ), // Adiciona um padding para a esquerda
            child: FloatingActionButton(
              onPressed: _backToWelcomeScreen,
              child: const Icon(Icons.arrow_back),
              tooltip: 'Voltar',
              heroTag: 'backButton', // Adicione um heroTag único
            ),
          ),
          FloatingActionButton.extended(
            onPressed: _backToWelcomeScreen,
            label: const Text('Voltar'),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Voltar',
            heroTag: 'backButton',
            backgroundColor: Theme.of(context).primaryColor,
          ),
          FloatingActionButton.extended(
            onPressed: _logout,
            label: const Text('Sair'),
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Sair',
            heroTag: 'logoutButton',
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat, // Centraliza a Row
    );
  }

  // --- Função _buildPontoButton COMPLETA ---
  Widget _buildPontoButton(
    BuildContext context,
    String text,
    PunchType type,
    bool isEnabled,
    IconData icon,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width:
              (constraints.maxWidth / 2) -
              7.5, // Define a largura igual para todos os botões
          child: ElevatedButton.icon(
            onPressed: isEnabled ? () => _registrarBatida(context, type) : null,
            icon: Icon(icon),
            label: Text(text, textAlign: TextAlign.center),
            style: ElevatedButton.styleFrom(
              foregroundColor: isEnabled ? Colors.white : Colors.grey[400],
              backgroundColor: isEnabled
                  ? Theme.of(context).primaryColor
                  : Colors.grey[200],
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              elevation: 5,
            ),
          ),
        );
      },
    );
  }
}
