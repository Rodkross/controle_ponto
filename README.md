# 📅 Controle de Jornada | Flutter + Firebase

Bem-vindo ao **Controle de Jornada**, um sistema moderno e intuitivo de marcação de ponto, desenvolvido em **Flutter Web** com integração ao **Firebase**. A aplicação permite aos usuários registrar suas jornadas de trabalho, incluindo entrada, saída para intervalo, retorno e saída, tudo com visualização organizada por dia e mês.

> Desenvolvido por **Rodkross** 💻

---

## 🧩 Funcionalidades

✅ Login com autenticação via Firebase  
✅ Registro de batidas de ponto:  
&nbsp;&nbsp;&nbsp;&nbsp;• Entrada  
&nbsp;&nbsp;&nbsp;&nbsp;• Saída para intervalo  
&nbsp;&nbsp;&nbsp;&nbsp;• Retorno do intervalo  
&nbsp;&nbsp;&nbsp;&nbsp;• Saída  
✅ Visualização dos registros do mês em modal (tabela ou cartões)  
✅ Interface adaptada para **Web e Mobile**  
✅ Suporte à localização em **Português (Brasil)** e **Inglês (EUA)**  
✅ Interface moderna, responsiva e intuitiva  
✅ Indicação de **status da jornada atual** com cores (vermelho/verde)  
✅ Lógica de habilitação de botões baseada no último ponto  
🚧 Funcionalidade Admin em desenvolvimento

---

## 🔧 Tecnologias Utilizadas

- [Flutter](https://flutter.dev/)  
- [Firebase Auth](https://firebase.google.com/products/auth)  
- [Cloud Firestore](https://firebase.google.com/products/firestore)  
- [Intl](https://pub.dev/packages/intl)  
- [Material Design](https://m3.material.io/)  
- Suporte a [Flutter Web](https://docs.flutter.dev/platform-integration/web)

---

## 🖼️ Layout e Design

- Interface responsiva com **Cards** e **GridView**
- Modal para exibição de registros usando `AlertDialog`
- **DataTable** para visualização no Web e `ListView` com `Cards` no mobile
- Feedbacks com `SnackBar` para ações de sucesso e erro
- Ícones temáticos com `Icons.*` para cada tipo de batida

---

## 🔐 Autenticação

A autenticação é feita com **FirebaseAuth**, com e-mail e senha. Em caso de erro, mensagens são exibidas para o usuário.  
*Funcionalidade de recuperação de senha ainda em desenvolvimento.*

Usuario de testes: teste@teste.com  senha:123123

---

## 📂 Organização do Projeto
lib/
├── main.dart # Arquivo principal com login e tela de jornada
├── firebase_options.dart # Gerado automaticamente pelo Firebase CLI


---



## 🚀 Como Rodar Localmente

1. **Clone o repositório**:

```
git clone https://github.com/rodkross/controle-jornada.git
cd controle-jornada
````

2. **Instale as dependências**:

```
flutter pub get
```

3. **Configure o Firebase**:
```
flutterfire configure
```

4. **Execute o projeto**:
```
flutter run -d chrome
```

🛡️ Requisitos
Flutter SDK (versão 3.10 ou superior)

Conta e projeto no Firebase

Navegador (recomendado: Chrome)


👨‍💻 Desenvolvedor
Feito com 💙 por Rodkross
Siga-me no GitHub para mais projetos como este!


📌 Status do Projeto
✅ MVP funcional
🚧 Admin/gestão de registros em desenvolvimento
🧪 Testes e melhorias na segurança em andamento

📃 Licença
Este projeto está sob a licença MIT.


|                       Tela de Login                      |                        Tela Principal                       |                         Registros Mensais                        |
| :------------------------------------------------------: | :---------------------------------------------------------: | :--------------------------------------------------------------: |
| ![WhatsApp Image 2025-07-08 at 08 44 22](https://github.com/user-attachments/assets/a1e22fe8-f0ec-4311-b7f4-9d032e573d93) | ![WhatsApp Image 2025-07-08 at 08 44 22 (1)](https://github.com/user-attachments/assets/b1cb0622-d458-495c-8c00-2b6a128dc97c) | ![WhatsApp Image 2025-07-08 at 08 44 22 (2)](https://github.com/user-attachments/assets/d1b0c1dc-a58d-4fa2-bb6c-cebe96ea8cbc) |



⭐ Dê uma estrela
Se você gostou do projeto, não esqueça de deixar uma ⭐ no repositório. Isso ajuda muito!






