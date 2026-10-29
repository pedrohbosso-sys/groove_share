import 'package:flutter_test/flutter_test.dart';
import 'package:groove_share/services/music_service.dart';

void main() {
  test('MusicService retorna lista vazia quando a busca for vazia', () async {
    final service = MusicService();
    final resultado = await service.pesquisarMusicas('');
    expect(resultado, isEmpty);
  });

  test('MusicService pesquisa músicas na API do Deezer', () async {
    final service = MusicService();
    final resultado = await service.pesquisarMusicas('Queen');

    expect(resultado, isNotEmpty);
    expect(resultado.first.containsKey('titulo'), true);
    expect(resultado.first.containsKey('artista'), true);
    expect(resultado.first.containsKey('album'), true);
  });
}
