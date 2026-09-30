# Validação da versão 0.1

## Atualização da engine — 27/09/2026

- Engine oficial: `4.7.2.stable.official.ed1daf0bf`; ZIP validado contra o SHA-512 publicado na release oficial.
- Versão estável confirmada em https://godotengine.org/download/windows/.
- Importação no editor concluída; 16 verificações de integração aprovadas novamente.
- Teste adicional: progresso criado pelo Godot 4.4.1, com duas peças e sala lab2, restaurado corretamente pelo Godot 4.7.2. Executado em diretório temporário sem tocar nos saves reais.
- Menu e três salas renderizados pela nova engine e revisados visualmente.
- Atalho `Jogar.cmd`, versão do projeto e documentação atualizados. Regras do jogo e formato do save preservados.
- Ponto de recuperação: tag `before-godot-4.7.2`. A engine portátil antiga permanece na pasta de trabalho; use uma cópia do projeto nessa tag para testar uma reversão, sem sobrescrever trabalho novo.

Para repetir a compatibilidade entre engines: execute `tests/save_compatibility.gd -- --write` na 4.4.1 antes de atualizar e `tests/save_compatibility.gd` na 4.7.2, usando o mesmo diretório de dados isolado. O teste usa um arquivo próprio e não grava o progresso normal.

Testado no Windows com Godot 4.7.2, renderizador Compatibility / Intel UHD Graphics.

16 verificações de integração passaram: menu, nova missão, restrição de proximidade, movimento com entrada real, colisão com mesa, coleta única, pausa de patrulha, cobertura, visão direta, captura por exposição, transição, terminal bloqueado sem peças, conclusão, persistência, rejeição de progresso inválido e reinício.

As quatro capturas nesta pasta foram geradas pelo próprio Godot e revisadas visualmente. O teste não substitui uma sessão de balanceamento com jogadores. A versão usa personagens provisórios e ainda não inclui áudio.

O ambiente restrito emitiu um aviso ao ler o repositório de certificados do Windows. O jogo é offline e os testes terminaram com zero falhas. Diretórios temporários de dados foram usados nos testes para não alterar o progresso do jogador.

Os 33 PNGs originais foram comparados byte a byte com os ZIPs e tiveram sua integridade confirmada. O inventário registra dimensões e SHA-256.

GitHub: publicado como público em https://github.com/SouBeatrizKaroline/Game_RutherFox, branch main, com autoria dos commits vinculada à conta SouBeatrizKaroline.

## Personagens e mecânicas — versão 0.2, 30/09/2026

- Godot 4.7.2: 16 verificações da missão e 9 verificações de personagens/IA aprovadas, zero falhas nos dois testes.
- Testes novos: chegada ao ruído, busca e retorno, recarga, bloqueio de repetição, pausa de animação/recarga, colisão do guarda, cientista, transformação sem detecção e tela de desfecho.
- Menu e três salas renderizados e inspecionados; capturas atualizadas.
- Dados temporários isolados do progresso real. O ambiente emite erro de leitura dos certificados do Windows, sem falhas no jogo offline.
- A migração de 4.4.1 não foi repetida nesta etapa. O teste específico de migração depende de fixture criada pela engine anterior; a persistência da versão atual passou no teste da missão.
- Novas artes e efeitos sintetizados em código. Ainda é necessária validação artística da equipe e uma sessão de balanceamento com jogadores.

## Correção de abertura e distribuição — 30/09/2026

O atalho anterior dependia de um Godot fora da pasta distribuída. Na ausência dele, só exibia instruções e fechava após pressionar uma tecla. A distribuição foi corrigida com exportação nativa Windows x86_64 e PCK embutido em RutherFox.exe. Não requer o editor instalado. O preset exclui testes/documentação/ferramentas e inclui explicitamente os dados JSON de salas.

O atalho do código-fonte procura o executável exportado antes de preparar o projeto. O inicializador do fonte pode obter Godot oficial 4.7.2 com SHA-256 fixado, importa recursos e preserva erros em logs. Validado em cópia sem cache e em caminho contendo espaços.

Executável release testado em pasta contendo apenas o jogo e os avisos de licença, sem project.godot nem editor. Abertura headless concluída e três quadros do menu renderizados pelo executável em OpenGL/Compatibility e revisados visualmente. Não houve erro de script. O template release não executa o modo de testes externos --script do editor; as 25 verificações são do projeto-fonte, não uma repetição dentro da release. O ambiente restrito emitiu erros de cache de shaders/certificados, mas o menu foi renderizado corretamente.
