
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groove_share/screens/home_screen.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool carregando = false;

  // Cria a conta do usuário no Firebase e salva no Firestore
  Future<void> cadastrar() async {
    final nome = nomeController.text.trim();
    final email = emailController.text.trim();
    final senha = senhaController.text;

    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      mensagem('Preencha todos os campos.');
      return;
    }

    if (senha.length < 6) {
      mensagem('A senha precisa ter pelo menos 6 caracteres.');
      return;
    }

    setState(() => carregando = true);

    try {
      final resultado = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final usuario = resultado.user!;

      await usuario.updateDisplayName(nome);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(usuario.uid)
          .set({
        'nome': nome,
        'email': email,
      });

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String erro = 'Não foi possível criar a conta.';

      if (e.code == 'email-already-in-use') {
        erro = 'Este e-mail já está cadastrado.';
      } else if (e.code == 'invalid-email') {
        erro = 'Digite um e-mail válido.';
      } else if (e.code == 'weak-password') {
        erro = 'A senha precisa ter pelo menos 6 caracteres.';
      }

      mensagem(erro);
    } catch (_) {
      mensagem('Erro ao cadastrar. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() => carregando = false);
      }
    }
  }

  void mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                const Icon(
                  Icons.person_add_alt_1,
                  size: 64,
                  color: Color(0xFFB45CFF),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: senhaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: carregando ? null : cadastrar,
                    child: carregando
                        ? const CircularProgressIndicator()
                        : const Text('Cadastrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
