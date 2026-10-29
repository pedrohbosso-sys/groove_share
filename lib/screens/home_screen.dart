
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groove_share/screens/login_screen.dart';
import 'package:groove_share/screens/pesquisa_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Desconecta a conta e volta para a tela de login
  Future<void> sair(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.library_music,
              color: Color(0xFFB45CFF),
              size: 30,
            ),
            SizedBox(width: 10),
            Text(
              'GrooveShare',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => sair(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Sair da conta',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carrega os dados do usuário para exibir o nome na saudação
              FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: usuario == null
                    ? null
                    : FirebaseFirestore.instance
                        .collection('users')
                        .doc(usuario.uid)
                        .get(),
                builder: (context, snapshot) {
                  String nome = usuario?.displayName ?? 'Músico';

                  if (snapshot.hasData && snapshot.data!.exists) {
                    final dados = snapshot.data!.data();
                    if (dados != null && dados['nome'] != null) {
                      nome = dados['nome'].toString();
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, $nome!',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Que tal descobrir novas músicas hoje?',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF7B2CBF),
                      Color(0xFFB45CFF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.headphones,
                      size: 45,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Sua música,\ncompartilhada!',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Encontre suas músicas favoritas e prepare-se '
                      'para criar playlists com seus amigos.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PesquisaScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.search),
                        label: const Text('Pesquisar músicas'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF7B2CBF),
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Suas playlists',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF211B2B),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF3A2B4A),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.queue_music,
                      size: 55,
                      color: Colors.purple.shade200,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Suas playlists aparecerão aqui',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Em breve você poderá criar playlists, '
                      'adicionar músicas e compartilhar suas listas '
                      'com outros usuários.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF211B2B),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_circle,
                      size: 42,
                      color: Color(0xFFB45CFF),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sua conta',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            usuario?.email ?? 'Usuário não identificado',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
