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
