import 'dart:convert';
import 'package:http/http.dart' as http;

class MusicService {
  // Faz a busca de músicas na API pública do Deezer
  Future<List<Map<String, dynamic>>> pesquisarMusicas(String texto) async {
    final busca = texto.trim();
    if (busca.isEmpty) return [];

    final url = Uri.parse(
      'https://api.deezer.com/search?q=${Uri.encodeComponent(busca)}&limit=20',
    );

    try {
      final resposta = await http.get(url);

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        final List resultados = dados['data'] ?? [];

        // Converte os dados da API para o formato da lista
        return resultados.map<Map<String, dynamic>>((item) {
          return {
            'id': item['id'].toString(),
            'titulo': item['title'] ?? 'Sem título',
            'artista': item['artist']?['name'] ?? 'Artista desconhecido',
            'album': item['album']?['title'] ?? 'Sem álbum',
            'capaUrl': item['album']?['cover_medium'] ?? '',
            'preview': item['preview'] ?? '',
          };
        }).toList();
      }
    } catch (_) {
    }

    return [];
  }
}