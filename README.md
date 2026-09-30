# Game_RutherFox

Uma nova base em **Godot 4.7.2 / GDScript** para o RutherFox, da Arcade Age. Protótipo de aventura e furtividade 2D com visão de cima, para computador.

Gânia é uma raposa azul e radioativa. Nesta primeira missão, explore três setores, encontre as peças de um dispositivo e monte-o sem ser capturada.

## Baixar e jogar

**[Baixar RutherFox para Windows 64 bits]( https://github.com/SouBeatrizKaroline/Game_RutherFox/releases/download/v0.2.1/RutherFox-Windows.zip )**

Extraia todo o ZIP e abra **RutherFox.exe**. Não precisa instalar Godot; o jogo funciona sem internet.

[Ver versão v0.2.1 e arquivos publicados](https://github.com/SouBeatrizKaroline/Game_RutherFox/releases/tag/v0.2.1).

## Imagens do jogo

Capturas do protótipo rodando no Godot 4.7.2. Os cenários usam as artes originais fornecidas; Gânia, guardas e cientistas usam arte vetorial animada criada para esta reconstrução.

### Menu inicial

![Menu inicial do RutherFox: Protocolo Azul, com botão para iniciar a missão](docs/menu.png)

### Laboratório de pesquisa

Gânia explora o primeiro setor enquanto evita o campo de visão do guarda.

![Gânia no laboratório de pesquisa, com bancadas, gaiola, peça coletável e guarda patrulhando](docs/gameplay.png)

### Depósito de materiais

Caixas e barris formam obstáculos para a exploração e a furtividade.

![Depósito com caixas, barris, uma peça coletável e o cone de visão do guarda](docs/storage.png)

### Laboratório nuclear

O setor final abriga o terminal de montagem do dispositivo.

![Laboratório nuclear com câmara de contenção, computadores e terminal de montagem](docs/lab2.png)

## Abrir e jogar

**Para jogar:** [baixe o pacote para Windows](https://github.com/SouBeatrizKaroline/Game_RutherFox/releases/download/v0.2.1/RutherFox-Windows.zip), extraia todo o ZIP e dê dois cliques em `RutherFox.exe`. O executável contém os dados do jogo e não precisa instalar Godot nem acessar a internet.

**Código-fonte deste repositório:** `Jogar.cmd` abre primeiro um executável exportado, se existir ao lado dele ou em `builds/`. Caso contrário, `tools/launch.ps1` prepara o projeto usando Godot local ou baixa automaticamente a versão oficial 4.7.2 na primeira abertura, verificando SHA-256. Importa os recursos antes de iniciar, guarda logs em `.runtime/logs` e mantém o aviso na tela quando ocorre um erro. Essa opção é para executar o projeto-fonte, diferente do pacote independente.

**Para editar:** importe `project.godot` no Godot 4.7.2 e pressione F5. Para gerar o executável, instale os templates oficiais dessa versão e exporte com o preset **Windows Desktop** de `export_presets.cfg`. O preset usa Windows x86_64 com o pacote de dados embutido, sem o editor; usa `data/*.json` e exclui documentação, testes e ferramentas do jogo exportado.

| Ação | Controle |
|---|---|
| Mover | WASD ou setas |
| Andar devagar / reduzir distância de detecção | Shift |
| Interagir | E, ou clique no objeto quando estiver perto |
| Distrair patrulha com ruído na direção do mouse | F (recarga de 5 s; alcance de 180 px) |
| Pausar / continuar | Esc |
| Reposicionar na entrada da sala | R |

**Objetivo:** recuperar a bobina na pesquisa, a célula no depósito e o módulo no laboratório nuclear; depois ativar o terminal nuclear. Os cones indicam o campo de visão. Móveis bloqueiam a visão e o movimento. A barra de alerta sobe enquanto Gânia é vista e diminui quando ela sai de vista. Ao ser capturada, as peças recuperadas são mantidas.

O progresso é salvo localmente ao coletar peças e trocar de sala. **Continuar progresso** retoma a sala e as peças; **Iniciar missão** começa um novo progresso. Posição e estado da patrulha não são salvos.

## O que já funciona

- Menu, pausa, captura, tentativa novamente e conclusão.
- Três salas conectadas usando as artes fornecidas.
- Movimento diagonal normalizado, colisões e caminhada lenta.
- Patrulha, cone de visão, obstrução por móveis e medidor de detecção.
- Interação por proximidade, inventário de três peças e terminal condicionado à coleta.
- Progresso local versionado e validado antes de carregar.
- Personagens animados, cientista no setor nuclear e transformação após ativação.
- Distração por ruído com recarga, busca ativa e cones recortados pelos móveis.
- Efeitos sonoros de coleta, distração e pulso sintetizados localmente.
- Testes de integração das regras da missão e das novas mecânicas.

## Organização

```text
assets/
  concepts/             desenhos de referência originais
  lab1/, lab2/, storage/ PNG originais intactos; ignorados pelo importador
  runtime/              cópias leves utilizadas pelo jogo
data/rooms.json         cenários, objetos, colisões, patrulhas e interações
scenes/main.tscn        cena de entrada
scripts/main.gd         sessão, progressão e interface
scripts/player.gd       movimento, furtividade e recarga
scripts/guard.gd        patrulha, perseguição, investigação e busca
scripts/interactable.gd indicadores de interação
tools/prepare_assets.gd preparação reproduzível das imagens
tests/                  validação e captura de prévias
docs/                   referências, decisões e inventário
```

## Desenvolvimento

Compatibilidade validada no Godot **4.7.2**, renderizador Compatibility. Não usa pacotes externos nem serviços online.

```powershell
godot --headless --path . --editor --import
godot --headless --path . --script tests/smoke.gd
godot --headless --path . --script tests/characters_ai.gd
```

Para regenerar as imagens leves, mantendo os originais:

```powershell
godot --headless --path . --script tools/prepare_assets.gd
godot --headless --path . --editor --import
```

Configure a variável `APPDATA` para uma pasta temporária ao testar se quiser isolar os dados do jogador. O teste de integração desativa a gravação de progresso.

## Escopo e próximos passos

Esta é uma reconstrução inicial baseada nas referências, não uma recuperação do código antigo. **Protocolo Azul** é um subtítulo provisório desta implementação. As posições, patrulhas e regras de detecção são novas decisões de prototipagem.

Os pacotes fornecidos contêm cenários e objetos, mas não sprites de personagens, áudio nem projeto Godot. Gânia, guardas e cientistas usam desenhos vetoriais originais animados em código, com repouso, caminhada e orientação; Gânia também possui postura furtiva. Ao montar o dispositivo, um pulso transforma o cientista do setor em raposa e apresenta um desfecho. Essa sequência é uma interpretação nova da sinopse, não uma reprodução da cutscene do YouTube. Os efeitos de coleta, ruído e ativação são sintetizados no jogo.

Os guardas investigam ruídos, perseguem Gânia, buscam a última posição vista e retornam à patrulha. Colisões impedem atravessar móveis; após bloquear-se, a patrulha troca o destino. Isso ainda não equivale a navegação por caminho ótimo. O cone é recortado pelos obstáculos. Próximos passos: revisar a fidelidade visual com os arquivos originais de personagens, adicionar diálogos e trilha, editar salas em cenas e calibrar dificuldade.

Referências, créditos e classificação dos materiais: [docs/REFERENCIAS.md](docs/REFERENCIAS.md). Consulte [docs/ASSETS.csv](docs/ASSETS.csv) para origem e integridade de cada PNG.

## Direitos e créditos

RutherFox e artes originais: Arcade Age e respectivos autores. Créditos confirmados na página do projeto estão nas referências. Não foi encontrada uma licença de redistribuição nos ZIPs: nenhuma licença aberta foi atribuída às artes. Antes de publicar os materiais, confirme as permissões com seus autores. Repositório público: https://github.com/SouBeatrizKaroline/Game_RutherFox.

