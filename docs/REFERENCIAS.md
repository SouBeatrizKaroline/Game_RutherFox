# Referências e decisões

## Fontes fornecidas

- [Playlist Ruther Fox](https://youtube.com/playlist?list=PLJSttuLG4yjaUXYDnTLloLIeJYkyolbET): dois vídeos, trailer e pitch final, canal Arcade Age.
- [Pitch Final — Grupo 16 Arcade Age](https://www.youtube.com/watch?v=FE9BFbMSbms): transcrição automática consultada. Em 0:08–0:59 descreve a raposa sobrevivente, radiação, laboratório, furtividade, coleta de peças, cientistas/seguranças e perspectiva top-down. A grafia dos nomes não foi inferida da transcrição automática.
- [Trailer](https://www.youtube.com/watch?v=fPOfB8pwYgs): referência audiovisual do projeto. Não houve extração de sprites do vídeo.
- [Cutscene Final](https://www.youtube.com/watch?v=cOmJ579VRvQ): identificada como Ruther Fox; a transcrição automática só contém música e fragmentos, insuficientes para reconstruir o desfecho. Mantida como referência para a próxima etapa.
- [Página oficial no itch.io](https://arcade-age.itch.io/rutherfox): confirma o nome Gânia, a raposa azul/radioativa e a intenção de transformar os responsáveis em raposas. Lista setas para mover e clique para interagir. Esses controles foram mantidos e ampliados com WASD/E.

## Créditos da equipe original

Transcritos da página oficial do jogo:

- Ana Paula Marcello da Silva — gestão, programação e planejamento.
- Beatriz Karoline Cordeiro da Silva — roteiro e planejamento.
- Gabrielle Bocal Nalagaka — arte 2D e animação.
- Diana Imaizumi — artes 2D e game design.
- Matheus Erik Gonçalves — programação.

Não foram copiados músicas, executável antigo ou outros recursos da página.

## Triagem dos ZIPs

| Arquivo | Conteúdo | Uso |
|---|---|---|
| drive-download-20230531T003225Z-001.zip | 3 concept arts com prefixo RutherFox | referência visual |
| RutherFox_BackgroundSprites_Lab1.zip | 8 PNG: fundo, bancadas, armários e gaiola | laboratório de pesquisa |
| RutherFox_BackgroundSprites_Lab2.zip | 4 PNG: fundo nuclear, computador e cadeiras | laboratório nuclear |
| RutherFox_BackgroundSprites_Storage.zip | 18 PNG: fundo, caixas e barris | depósito |

Total: **33 PNGs**. Nomes e temática são consistentes com RutherFox; nenhum arquivo foi identificado claramente como pertencente a outro jogo. Isso não constitui prova de autoria. O pitch menciona um projeto anterior e uma ligação narrativa, mas isso não autoriza misturar seus recursos. Apenas os PNGs fornecidos foram incorporados.

As imagens foram preservadas byte a byte. As cópias em `assets/runtime` têm lado maior limitado a 1600 pixels para reduzir memória e importação. Cópias com nomes semelhantes foram mantidas para preservar a correspondência com os ZIPs; o inventário registra hashes para facilitar deduplicação futura.

## Decisão de engine

Godot 4 com GDScript mantém a origem do projeto, permite cenas 2D, colisão física e evolução para animações sem dependências externas. A base inicial usava 4.4.1 e foi atualizada para 4.7.2, versão estável mais recente confirmada no site oficial em 27/09/2026. Ver [visão geral oficial](https://docs.godotengine.org/en/stable/getting_started/introduction/introduction_to_godot.html).

Dados de sala foram separados da lógica. O jogador, os guardas e os interativos são componentes distintos. Para esta etapa, as salas são montadas a partir de JSON; migrar o layout para cenas `.tscn` é uma melhoria futura para edição visual por artistas.

## Limites conhecidos

- Arte dos personagens provisória, sem animações originais.
- Uma patrulha por sala, sem perseguição ou busca ativa.
- Cone visual indica alcance máximo; o raio de detecção é bloqueado pelos móveis, mas o desenho do cone ainda não é recortado por eles.
- Sem trilha sonora, diálogos, transformação ou reprodução da cutscene.
- Layout de computador, sem controles de toque.
- Persistência registra sala e peças, não uma captura exata do estado do mundo.
- Nenhum documento ou conteúdo da web foi tratado como instrução operacional.
