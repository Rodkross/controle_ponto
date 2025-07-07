import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Pacote para formatação de data/hora
import 'package:flutter_localizations/flutter_localizations.dart'; // NECESSÁRIO para localização

// Importa o arquivo de opções do Firebase gerado automaticamente (se você já o gerou)
// Certifique-se de que este arquivo existe e está configurado corretamente.
import 'firebase_options.dart';

void main() async {
  // Garante que o Flutter Binding esteja inicializado antes de qualquer operação assíncrona do Firebase.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase para a plataforma atual.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicia o aplicativo Flutter.
  runApp(JornadaApp());
}

class JornadaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Jornada',
      // Define a página inicial como LoginPage.
      home: LoginPage(),

      // --- CONFIGURAÇÃO DE LOCALIZAÇÃO PARA RESOLVER LocaleDataException ---
      // Isso é importante para a formatação de datas em português (ex: "Julho")
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // Inglês americano (padrão)
        Locale('pt', 'BR'), // Português do Brasil
      ],
      // Define o locale padrão para Português do Brasil, se disponível.
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode &&
              supportedLocale.countryCode == locale?.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales
            .first; // Retorna a primeira localidade suportada como fallback
      },
      // -------------------------------------------------------------------

      // Define um tema básico para o aplicativo para um visual mais coeso
      theme: ThemeData(
        primarySwatch: Colors.blue, // Cor primária para AppBar, botões, etc.
        visualDensity:
            VisualDensity.adaptivePlatformDensity, // Densidade visual adaptável
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue, // Cor de fundo da AppBar
          foregroundColor: Colors.white, // Cor do texto e ícones na AppBar
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Colors.blue, // Cor de fundo padrão para ElevatedButtons
            foregroundColor:
                Colors.white, // Cor do texto padrão para ElevatedButtons
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                10,
              ), // Bordas arredondadas padrão
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor:
                Colors.blue, // Cor do texto padrão para TextButtons
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor:
                Colors.blue, // Cor do texto/ícone para OutlinedButtons
            side: const BorderSide(color: Colors.blue), // Cor da borda
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
  // Correção da nomenclatura: createState deve retornar uma instância de _LoginPageState
  _LoginPageState createState() => _LoginPageState();
}

// Correção da nomenclatura: A classe de estado deve ter o sufixo 'State'
class _LoginPageState extends State<LoginPage> {
  // Controladores para os campos de texto de e-mail e senha.
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  // Instância do Firebase Authentication para operações de login.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Função assíncrona para realizar o login do usuário.
  void _login() async {
    try {
      // Tenta fazer login com e-mail e senha fornecidos.
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(), // Remove espaços em branco
        password: senhaController.text.trim(), // Remove espaços em branco
      );
      // Se o login for bem-sucedido, navega para a HomePage e substitui a LoginPage na pilha de navegação.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(user: userCredential.user!)),
      );
    } catch (e) {
      // Em caso de erro, exibe uma SnackBar com a mensagem de erro.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro no login: $e')));
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
            // Para evitar overflow quando o teclado aparece
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Estica os elementos na largura
              children: [
                Text(
                  'Bem-vindo ao Controle de Ponto',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
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
                  obscureText: true, // Esconde o texto para senhas.
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed:
                      _login, // Chama a função _login ao ser pressionado.
                  child: const Text('Entrar', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    // TODO: Implementar a funcionalidade de "Esqueceu a senha?".
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

class HomePage extends StatefulWidget {
  final User user; // O usuário logado é passado para a HomePage.
  const HomePage({required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Instância do Firestore para interagir com o banco de dados.
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Variáveis de estado para controlar a interface do usuário.
  String _status = "Fora de Jornada"; // Status atual da jornada.
  bool _isAdmin = false; // Flag para verificar se o usuário é admin.

  // Flags para controlar a habilitação dos botões de registro de ponto.
  bool _canRegisterEntrada = true;
  bool _canRegisterSaidaIntervalo = false;
  bool _canRegisterRetornoIntervalo = false;
  bool _canRegisterSaida = false;

  @override
  void initState() {
    super.initState();
    // Carrega o status do usuário e o estado dos botões ao iniciar a página.
    _loadUserStatusAndPunchStates();
  }

  // Carrega o status de admin do usuário (ex: de uma coleção 'users')
  // e o último ponto do dia para definir o status e a habilitação dos botões.
  Future<void> _loadUserStatusAndPunchStates() async {
    setState(() {
      // Exemplo: Definindo isAdmin como true fixo para fins de demonstração.
      // Em um app real, você buscaria isso de um perfil de usuário no Firestore
      // (ex: _db.collection('users').doc(widget.user.uid).get()).
      _isAdmin = true;
    });

    final today = DateTime.now();
    // Define o início e o fim do dia atual para a consulta.
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    try {
      // Consulta o último ponto registrado pelo usuário no dia atual.
      final lastPunchSnapshot = await _db
          .collection('batidas')
          .where('uid', isEqualTo: widget.user.uid)
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThanOrEqualTo: endOfDay)
          .orderBy('timestamp', descending: true) // Pega o mais recente.
          .limit(1) // Apenas um documento.
          .get();

      if (lastPunchSnapshot.docs.isNotEmpty) {
        final lastPunch = lastPunchSnapshot.docs.first.data();
        final lastPunchType = lastPunch['tipo'] as String;

        // **Lógica aprimorada para persistência do estado "Jornada Concluída":**
        // Se o último ponto do dia for uma 'saída', a jornada está completa.
        // Nesse caso, TODOS os botões devem ser desabilitados ao carregar a página.
        if (lastPunchType == 'saída') {
          setState(() {
            _status = "Jornada Concluída";
            _canRegisterEntrada = false;
            _canRegisterSaidaIntervalo = false;
            _canRegisterRetornoIntervalo = false;
            _canRegisterSaida = false;
          });
        } else {
          // Se o último ponto NÃO for uma 'saída' (ainda em jornada ou intervalo),
          // atualiza o estado dos botões de acordo com o fluxo normal da jornada.
          setState(() {
            _updateStatusAndButtonStates(lastPunchType);
          });
        }
      } else {
        // Se não houver pontos hoje (é um novo dia ou o primeiro acesso do dia),
        // define o estado inicial padrão para iniciar uma nova jornada.
        setState(() {
          _status = "Fora de Jornada";
          _canRegisterEntrada =
              true; // Habilita apenas a entrada para iniciar o dia
          _canRegisterSaidaIntervalo = false;
          _canRegisterRetornoIntervalo = false;
          _canRegisterSaida = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // Verifica se o widget ainda está montado antes de chamar setState
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar estado dos pontos: $e')),
        );
      }
      print('Erro ao carregar estado dos pontos: $e');
    }
  }

  // Lógica para atualizar o status da jornada e a habilitação dos botões
  // com base no último tipo de ponto registrado. Esta função é chamada
  // APÓS uma batida ser registrada com sucesso.
  void _updateStatusAndButtonStates(String lastPunchType) {
    switch (lastPunchType) {
      case 'entrada':
        _status = "Em Jornada";
        _canRegisterEntrada = false; // Não pode registrar entrada novamente.
        _canRegisterSaidaIntervalo = true; // Pode sair para intervalo.
        _canRegisterRetornoIntervalo = false; // Não pode retornar sem sair.
        _canRegisterSaida = true; // Pode registrar saída direta.
        break;
      case 'saída intervalo':
        _status = "Em Intervalo";
        _canRegisterEntrada = false;
        _canRegisterSaidaIntervalo =
            false; // DESABILITA: Não pode sair para intervalo novamente no mesmo dia.
        _canRegisterRetornoIntervalo = true; // Deve retornar do intervalo.
        _canRegisterSaida = false; // Não pode sair enquanto em intervalo.
        break;
      case 'retorno intervalo':
        _status = "Em Jornada";
        _canRegisterEntrada = false;
        _canRegisterSaidaIntervalo =
            false; // Mantém desabilitado após retorno do intervalo (uma única saída para intervalo por dia).
        _canRegisterRetornoIntervalo = false; // Não pode retornar novamente.
        _canRegisterSaida = true; // Pode registrar saída.
        break;
      case 'saída':
        _status = "Jornada Concluída";
        // Após a saída final, todos os botões são desabilitados para o dia.
        // Esta é a mesma lógica aplicada na _loadUserStatusAndPunchStates para consistência.
        _canRegisterEntrada = false;
        _canRegisterSaidaIntervalo = false;
        _canRegisterRetornoIntervalo = false;
        _canRegisterSaida = false;
        break;
      default:
        // Estado padrão, se houver um tipo de ponto desconhecido ou erro.
        _status = "Fora de Jornada";
        _canRegisterEntrada = true;
        _canRegisterSaidaIntervalo = false;
        _canRegisterRetornoIntervalo = false;
        _canRegisterSaida = false;
        break;
    }
  }

  // Registra um novo ponto no Firestore.
  void _registrarBatida(BuildContext context, String tipo) async {
    // --- IMPORTANTE: Verifica se o botão correspondente está habilitado antes de prosseguir. ---
    // Isso impede registros duplicados ou fora de sequência no mesmo dia.
    if ((tipo == 'entrada' && !_canRegisterEntrada) ||
        (tipo == 'saída intervalo' && !_canRegisterSaidaIntervalo) ||
        (tipo == 'retorno intervalo' && !_canRegisterRetornoIntervalo) ||
        (tipo == 'saída' && !_canRegisterSaida)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Este ponto já foi registrado para hoje ou não é permitido no momento.',
            ),
          ),
        );
      }
      return;
    }

    try {
      // Adiciona o novo registro de ponto à coleção 'batidas'.
      await _db.collection('batidas').add({
        'uid': widget.user.uid, // ID do usuário logado.
        'tipo': tipo, // Tipo de ponto (entrada, saída intervalo, etc.).
        'timestamp':
            FieldValue.serverTimestamp(), // Horário do servidor Firebase.
      });

      // Atualiza o estado da UI após o registro bem-sucedido.
      setState(() {
        _updateStatusAndButtonStates(tipo);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Batida "$tipo" registrada com sucesso.')),
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

  // Mostra um modal com todos os registros de ponto do mês atual.
  Future<void> _mostrarRegistrosDoMes(BuildContext context) async {
    final now = DateTime.now();
    // Calcula o primeiro e o último dia do mês atual.
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    try {
      // Consulta todos os registros de ponto do usuário para o mês atual.
      final querySnapshot = await _db
          .collection('batidas')
          .where('uid', isEqualTo: widget.user.uid)
          .where('timestamp', isGreaterThanOrEqualTo: firstDayOfMonth)
          .where('timestamp', isLessThanOrEqualTo: lastDayOfMonth)
          .orderBy(
            'timestamp',
            descending: false,
          ) // Ordena do mais antigo para o mais novo.
          .get();

      // Mapeia os registros por dia para a exibição em colunas.
      // Formato: { 'YYYY-MM-DD': { 'entrada': 'HH:mm', 'saída intervalo': 'HH:mm', ... } }
      Map<String, Map<String, String>> dailyRecords = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
        final tipo = data['tipo'] as String?;

        if (timestamp != null && tipo != null) {
          final dateKey = DateFormat(
            'yyyy-MM-dd',
          ).format(timestamp); // Chave para o dia.
          final timeValue = DateFormat(
            'HH:mm',
          ).format(timestamp); // Horário formatado.

          dailyRecords.putIfAbsent(
            dateKey,
            () => {},
          ); // Cria o mapa para o dia se não existir.
          dailyRecords[dateKey]![tipo] = timeValue; // Adiciona o ponto ao dia.
        }
      }

      // Ordena os dias para garantir a exibição cronológica.
      final sortedDates = dailyRecords.keys.toList().toList()..sort();

      // Exibe os registros em um AlertDialog com um DataTable.
      if (mounted) {
        // Verifica se o widget ainda está montado antes de chamar showDialog
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(
              'Registros do Mês (${DateFormat('MMMM y', 'pt_BR').format(now)})',
            ),
            content: SizedBox(
              width:
                  MediaQuery.of(context).size.width *
                  0.9, // Ocupa 90% da largura da tela.
              child: SingleChildScrollView(
                scrollDirection: Axis
                    .vertical, // Permite rolagem vertical se houver muitos registros.
                child: DataTable(
                  columnSpacing: 12, // Espaçamento entre as colunas.
                  dataRowMinHeight: 30,
                  dataRowMaxHeight: 40,
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
                    final displayDate = DateFormat('dd/MM').format(
                      DateTime.parse(dateKey),
                    ); // Formata a data para exibição (ex: 07/07).
                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(displayDate)),
                        DataCell(
                          Text(records['entrada'] ?? '-'),
                        ), // Exibe '-' se o ponto não existir.
                        DataCell(Text(records['saída intervalo'] ?? '-')),
                        DataCell(Text(records['retorno intervalo'] ?? '-')),
                        DataCell(Text(records['saída'] ?? '-')),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Fecha o modal.
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

  // Realiza o logout do usuário.
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    // Retorna para a LoginPage após o logout.
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define a cor da fonte do status com base no texto atual.
    Color statusColor;
    switch (_status) {
      case "Jornada Concluída":
        statusColor =
            Colors.green; // Verde para jornada finalizada com sucesso.
        break;
      default:
        statusColor = Colors
            .red; // Vermelho para outros status (Em Jornada, Em Intervalo, Fora de Jornada).
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Jornada'),
        centerTitle: true, // Centraliza o título
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          // Centraliza o conteúdo principal verticalmente
          child: SingleChildScrollView(
            // Para telas menores, permite rolar
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Centraliza conteúdo na coluna
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Estica elementos na largura
              children: [
                // --- Seção de Boas-Vindas e Status ---
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
                          'Olá, ${widget.user.email?.split('@')[0] ?? 'Usuário'}!', // Exibe só a parte antes do @
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

                // --- Botões de Registro de Ponto (Grid/Row para melhor organização) ---
                GridView.count(
                  shrinkWrap:
                      true, // Importante para GridView dentro de Column/SingleChildScrollView
                  physics:
                      const NeverScrollableScrollPhysics(), // Desabilita rolagem própria do GridView
                  crossAxisCount: 2, // 2 botões por linha
                  crossAxisSpacing: 15, // Espaçamento horizontal
                  mainAxisSpacing: 15, // Espaçamento vertical
                  childAspectRatio:
                      (MediaQuery.of(context).size.width / 2 - 35) /
                      100, // Ajusta proporção
                  children: [
                    _buildPontoButton(
                      context,
                      'Registrar Entrada',
                      'entrada',
                      _canRegisterEntrada,
                      Icons.login,
                    ),
                    _buildPontoButton(
                      context,
                      'Saída Intervalo',
                      'saída intervalo',
                      _canRegisterSaidaIntervalo,
                      Icons.lunch_dining,
                    ),
                    _buildPontoButton(
                      context,
                      'Retorno Intervalo',
                      'retorno intervalo',
                      _canRegisterRetornoIntervalo,
                      Icons.restaurant_menu,
                    ),
                    _buildPontoButton(
                      context,
                      'Registrar Saída',
                      'saída',
                      _canRegisterSaida,
                      Icons.logout,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // --- Botão Ver Registros e Admin ---
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
      // --- FloatingActionButton para o botão de Deslogar ---
      floatingActionButton: FloatingActionButton(
        onPressed: _logout, // Chama a função de logout
        child: const Icon(Icons.exit_to_app), // Ícone de porta saindo
        tooltip: 'Sair', // Texto que aparece ao segurar o botão
      ),
      // Posiciona o FloatingActionButton no canto inferior direito
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // ---------------------------------------------------
    );
  }

  // Widget auxiliar para construir os botões de ponto com um estilo consistente
  Widget _buildPontoButton(
    BuildContext context,
    String text,
    String type,
    bool isEnabled,
    IconData icon,
  ) {
    return ElevatedButton.icon(
      onPressed: isEnabled ? () => _registrarBatida(context, type) : null,
      icon: Icon(icon),
      label: Text(text, textAlign: TextAlign.center),
      style: ElevatedButton.styleFrom(
        foregroundColor: isEnabled
            ? Colors.white
            : Colors.grey[400], // Cor do texto/ícone
        backgroundColor: isEnabled
            ? Theme.of(context).primaryColor
            : Colors.grey[200], // Cor de fundo
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        elevation: 5,
      ),
    );
  }
}
