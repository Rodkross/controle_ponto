# Controle de Ponto - App em Flutter

Um aplicativo multiplataforma (Android, iOS, Web) desenvolvido em Flutter para registro e controle de jornada de trabalho de funcionários. O projeto utiliza Firebase para autenticação e armazenamento de dados em tempo real.

> Desenvolvido por **Rodkross** 💻

## ✨ Funcionalidades

O aplicativo foi projetado com dois tipos de perfis de usuário: **Administrador** e **Usuário Comum**.

### Para Usuários Comuns:
- **Login Seguro**: Autenticação por e-mail e senha.
- **Registro de Ponto**: Registre facilmente os 4 principais eventos da jornada:
  - Entrada
  - Saída para Intervalo
  - Retorno do Intervalo
  - Saída
- **Lógica de Batida**: O sistema habilita/desabilita os botões de registro de forma inteligente para evitar registros incorretos (ex: não é possível registrar "Saída" sem ter registrado "Entrada").
- **Status da Jornada**: Visualize seu status atual em tempo real (Ex: "Em Jornada", "Em Intervalo", "Jornada Concluída").
- **Visualização de Histórico**: Acesse um relatório com todos os seus registros de ponto do mês atual, formatado em tabela para web e em cartões para mobile.
- **Logout**: Saia da sua conta com segurança.

### Para Administradores:
- ✅ **Dashboard Admin**: Uma tela de boas-vindas com acesso rápido às funções administrativas.
- ✅ **Todas as funcionalidades de Usuário Comum**.
- ✅ **Cadastro de Novos Usuários**: Crie contas para novos funcionários diretamente pelo app.
- ✅ **Gerenciamento de Usuários**: Visualize, edite e remova usuários existentes.
- 🚧 **(Em desenvolvimento)** Gestão completa dos registros de todos os usuários. 

## 🛠️ Tecnologias Utilizadas

- **[Flutter](https://flutter.dev/)**: Framework para desenvolvimento de interfaces de usuário multiplataforma.
- **[Dart](https://dart.dev/)**: Linguagem de programação utilizada pelo Flutter.
- **[Firebase](https://firebase.google.com/)**: Plataforma de desenvolvimento de aplicativos do Google.
  - 🔐 **Firebase Authentication**: Para gerenciamento de login e autenticação de usuários.
  - **Cloud Firestore**: Banco de dados NoSQL para armazenar os registros de ponto e informações dos usuários.
- **[Provider](https://pub.dev/packages/provider)** (ou similar): Para gerenciamento de estado.
- **[intl](https://pub.dev/packages/intl)**: Para formatação de datas e internacionalização.

## 🚀 Como Executar o Projeto

Siga os passos abaixo para configurar e rodar o projeto em sua máquina local.

### Pré-requisitos

- Ter o **[Flutter SDK](https://docs.flutter.dev/get-started/install)** instalado.
- Ter uma conta no **[Firebase](https://firebase.google.com/)**.

### Passos de Configuração

1.  **Clone o repositório:**
    ```sh
    git clone https://github.com/seu-usuario/seu-repositorio.git
    cd seu-repositorio
    ```

2.  **Crie um projeto no Firebase:**
    - Acesse o [console do Firebase](https://console.firebase.google.com/).
    - Crie um novo projeto.
    - Adicione os aplicativos para as plataformas que deseja suportar (Android, iOS, Web).

3.  **Configure o Firebase no Flutter:**
    - Instale a CLI do Firebase: `npm install -g firebase-tools`.
    - Faça login: `firebase login`.
    - Instale a CLI do FlutterFire: `dart pub global activate flutterfire_cli`.
    - Configure o projeto:
      ```sh
      flutterfire configure
      ```
    - Este comando irá gerar o arquivo `lib/firebase_options.dart`, que é essencial para a conexão com o Firebase.

4.  **Habilite os serviços do Firebase:**
    - No console do Firebase, vá para a seção **Authentication**.
    - Na aba "Sign-in method", habilite o provedor **E-mail/senha**.
    - Vá para a seção **Firestore Database**.
    - Crie um novo banco de dados no **modo de produção** e escolha a localização mais próxima.

5.  **Configure as Regras do Firestore:**
    - Na aba "Regras" do Firestore, cole as seguintes regras para garantir que os usuários só possam acessar seus próprios dados.
    ```js
    rules_version = '2';
    service cloud.firestore {
      match /databases/{database}/documents {
        // Permite que usuários autenticados leiam e escrevam em seus próprios documentos
        match /users/{userId} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
        // Permite que usuários autenticados criem e leiam seus próprios registros de ponto
        match /batidas/{batidaId} {
          allow read, create: if request.auth != null && request.resource.data.uid == request.auth.uid;
        }
      }
    }
    ```

6.  **Instale as dependências do projeto:**
    ```sh
    flutter pub get
    ```

7.  **Execute o aplicativo:**
    ```sh
    flutter run
    ```

## 📝 Estrutura do Projeto

```
/lib
├── main.dart                 # Ponto de entrada principal, rotas e tema
├── register_user_screen.dart # Tela para administradores cadastrarem novos usuários
├── manage_users_screen.dart  # Tela para administradores gerenciarem usuários
└── firebase_options.dart     # Configurações de conexão com o Firebase
```

---



Feito com ❤️ por Rodkross.

📌 Status do Projeto
✅ MVP funcional
🚧 Admin/gestão de registros em desenvolvimento
🧪 Testes e melhorias na segurança em andamento

📃 Licença
Este projeto está sob a licença MIT.


|                       Tela de Login                      |                        Tela Principal                       |                         Registros Mensais                        |
| :------------------------------------------------------: | :---------------------------------------------------------: | :--------------------------------------------------------------: |
| ![WhatsApp Image 2025-07-08 at 08 44 22](https://github.com/user-attachments/assets/a1e22fe8-f0ec-4311-b7f4-9d032e573d93) | ![WhatsApp Image 2025-07-08 at 08 44 22 (1)](https://github.com/user-attachments/assets/b1cb0622-d458-495c-8c00-2b6a128dc97c) | ![WhatsApp Image 2025-07-08 at 08 44 22 (2)](https://github.com/user-attachments/assets/d1b0c1dc-a58d-4fa2-bb6c-cebe96ea8cbc) |



Se você gostou do projeto, não esqueça de deixar uma ⭐ no repositório. Isso ajuda muito!