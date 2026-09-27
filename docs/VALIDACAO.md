# Validação da versão 0.1

Testado no Windows com Godot 4.4.1, renderizador Compatibility / Intel UHD Graphics.

16 verificações de integração passaram: menu, nova missão, restrição de proximidade, movimento com entrada real, colisão com mesa, coleta única, pausa de patrulha, cobertura, visão direta, captura por exposição, transição, terminal bloqueado sem peças, conclusão, persistência, rejeição de progresso inválido e reinício.

As quatro capturas nesta pasta foram geradas pelo próprio Godot e revisadas visualmente. O teste não substitui uma sessão de balanceamento com jogadores. A versão usa personagens provisórios e ainda não inclui áudio.

O ambiente restrito emitiu um aviso ao ler o repositório de certificados do Windows. O jogo é offline e os testes terminaram com zero falhas. Diretórios temporários de dados foram usados nos testes para não alterar o progresso do jogador.

Os 33 PNGs originais foram comparados byte a byte com os ZIPs e tiveram sua integridade confirmada. O inventário registra dimensões e SHA-256.

GitHub: publicado como público em https://github.com/SouBeatrizKaroline/Game_RutherFox, branch main, com autoria dos commits vinculada à conta SouBeatrizKaroline.
