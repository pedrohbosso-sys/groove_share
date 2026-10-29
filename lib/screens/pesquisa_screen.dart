import 'package:flutter/material.dart';
import '../services/music_service.dart';

class PesquisaScreen extends StatefulWidget {
  const PesquisaScreen({super.key});

  @override
  State<PesquisaScreen> createState() => _PesquisaScreenState();
}

class _PesquisaScreenState extends State<PesquisaScreen> {
  final MusicService musicService = MusicService();
  final TextEditingController pesquisaController =
      TextEditingController();

  List<Map<String, dynamic>> musicas = [];

  bool carregando = false;
  String? erro;
  String? ultimaPesquisa;

  // Busca as músicas na API pelo texto digitado
  Future<void> pesquisar() async {
    final texto = pesquisaController.text.trim();

    if (texto.isEmpty) {
      setState(() {
        musicas = [];
        erro = 'Digite o nome de uma música ou artista.';
        ultimaPesquisa = null;
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      carregando = true;
      erro = null;
      ultimaPesquisa = texto;
      musicas = [];
    });

    try {
      final resultados =
          await musicService.pesquisarMusicas(texto);

      if (!mounted) return;

      setState(() {
        musicas = resultados;
        if (resultados.isEmpty) {
          erro = 'Nenhuma música encontrada.';
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        erro =
            'Não foi possível buscar as músicas. Tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  // Exibe os detalhes da música em uma janela na parte inferior
  void mostrarDetalhes(Map<String, dynamic> musica) {
    final preview = musica['preview']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF211B2B),
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    musica['capaUrl'] ?? '',
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        width: 140,
                        height: 140,
                        child: Icon(
                          Icons.music_note,
                          size: 70,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  musica['titulo'] ?? 'Sem título',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(musica['artista'] ?? 'Artista desconhecido'),
                const SizedBox(height: 6),
                Text(
                  musica['album'] ?? 'Álbum desconhecido',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white60),
                ),
                const SizedBox(height: 20),
                if (preview.isNotEmpty)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.headphones),
                      SizedBox(width: 8),
                      Text('Prévia de áudio disponível'),
                    ],
                  )
                else
                  const Text(
                    'Prévia de áudio indisponível.',
                    style: TextStyle(color: Colors.white60),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Descobrir músicas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: TextField(
                controller: pesquisaController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => pesquisar(),
                decoration: InputDecoration(
                  hintText: 'Música, artista ou álbum...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: carregando
                        ? null
                        : () {
                            pesquisaController.clear();
                            setState(() {
                              musicas = [];
                              erro = null;
                              ultimaPesquisa = null;
                            });
                          },
                    icon: const Icon(Icons.close),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: carregando ? null : pesquisar,
                  icon: const Icon(Icons.search),
                  label: const Text('Pesquisar'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _construirResultados(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirResultados() {
    if (carregando) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Buscando músicas...'),
          ],
        ),
      );
    }

    if (erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.music_off,
                size: 56,
                color: Color(0xFFB45CFF),
              ),
              const SizedBox(height: 16),
              Text(
                erro!,
                textAlign: TextAlign.center,
              ),
              if (ultimaPesquisa != null) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: pesquisar,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (musicas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.library_music,
                size: 70,
                color: Color(0xFFB45CFF),
              ),
              SizedBox(height: 16),
              Text(
                'Encontre sua próxima música favorita!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Pesquise por título, artista ou álbum.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: musicas.length,
      itemBuilder: (context, index) {
        final musica = musicas[index];
        final capaUrl = musica['capaUrl']?.toString() ?? '';

        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          color: const Color(0xFF211B2B),
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: capaUrl.isNotEmpty
                  ? Image.network(
                      capaUrl,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _capaPadrao();
                      },
                    )
                  : _capaPadrao(),
            ),
            title: Text(
              musica['titulo'] ?? 'Sem título',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                '${musica['artista']}\n${musica['album']}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            isThreeLine: true,
            trailing: IconButton(
              onPressed: () => mostrarDetalhes(musica),
              icon: const Icon(
                Icons.info_outline,
                color: Color(0xFFB45CFF),
              ),
              tooltip: 'Detalhes da música',
            ),
          ),
        );
      },
    );
  }

  Widget _capaPadrao() {
    return Container(
      width: 58,
      height: 58,
      color: const Color(0xFF392B49),
      child: const Icon(
        Icons.music_note,
        color: Color(0xFFB45CFF),
      ),
    );
  }
}