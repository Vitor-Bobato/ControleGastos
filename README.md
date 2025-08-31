# Estratégia para Resolução de Conflito de Dados (Offline vs. Online)
## 1. Cenário do Conflito
*O conflito a ser resolvido é o seguinte:*

`Estado Inicial: Uma despesa "Almoço, R$25" existe no dispositivo local e na nuvem.
Ação Offline: O usuário, sem conexão com a internet, edita a despesa no dispositivo local para "Almoço, R$50".
Ação Online: Simultaneamente (ou antes da sincronização), o usuário exclui essa mesma despesa a partir de outro dispositivo que está online.
Momento da Sincronização: O dispositivo offline finalmente se conecta à internet e tenta sincronizar a sua alteração (a edição para R$50).
O sistema precisa decidir o que fazer: a despesa deve ser restaurada com o novo valor ou deve permanecer excluída?`

## 2. Estratégia Escolhida: "A Exclusão Prevalece" (Server-side Wins on Deletion)
`A estratégia que eu adotaria como padrão para este cenário é dar prioridade à operação de exclusão. Quando o dispositivo offline tentar enviar a atualização, o servidor de sincronização detectará que o registro correspondente não existe mais (foi excluído) e instruirá o cliente a descartar a alteração local.
*Fluxo da Resolução:*
O cliente offline tenta enviar um UPDATE para a despesa com ID=XYZ, alterando seu valor para R$50.
O servidor recebe a requisição, mas ao procurar pelo registro com ID=XYZ, descobre que ele foi permanentemente excluído (ou marcado como "deletado").
O servidor retorna uma resposta ao cliente, informando que o registro não existe mais (ex: um código de status 404 Not Found ou uma resposta específica de "conflito de exclusão").
O aplicativo cliente, ao receber essa resposta, entende o conflito e remove a despesa de seu banco de dados local para espelhar o estado do servidor.`

## 3. Justificativa, Prós e Contras

`*Por que essa estratégia?*
A exclusão é, geralmente, uma ação com maior "intenção final" do que uma edição. Um usuário que deleta algo espera que aquilo desapareça permanentemente. Restaurar um item deletado sem a permissão explícita do usuário pode causar confusão e frustração, fazendo-o pensar que o aplicativo não é confiável. Essa abordagem preza pela consistência e previsibilidade, tratando o estado do servidor como a fonte da verdade em caso de conflitos destrutivos.`

### *Prós:*

`Consistência dos Dados: Garante que o estado final dos dados seja consistente em todos os dispositivos, evitando que itens "fantasmas" reapareçam.
Previsibilidade para o Usuário: A ação de deletar é honrada. Se o usuário deletou, o item permanece deletado. Isso é o comportamento esperado na maioria dos casos.
Simplicidade de Implementação: É uma lógica de resolução de conflitos relativamente simples de implementar no backend. Não requer a intervenção do usuário, tornando o processo de sincronização mais rápido e automático.`

### *Contras:*

`Perda Silenciosa de Dados (Principal Desvantagem): O usuário que fez a edição offline perderá seu trabalho (a alteração de R25paraR50) sem ser notificado. Ele pode abrir o app mais tarde e simplesmente não encontrar a despesa que editou, o que é uma péssima experiência do usuário.
Falta de Contexto: A estratégia não leva em conta quando as ações ocorreram. A edição pode ter sido mais recente e mais importante que a exclusão, mas mesmo assim é descartada.`

## 4. Melhoria (Abordagem Híbrida)

`*Para mitigar a principal desvantagem (perda silenciosa de dados), uma versão aprimorada desta estratégia seria:*
O servidor ainda rejeita a atualização, mas retorna uma mensagem de conflito mais detalhada.
O aplicativo cliente, em vez de apagar a despesa silenciosamente, armazena a alteração falha em uma área de "conflitos" ou "itens não sincronizados".
O aplicativo exibe uma notificação para o usuário, algo como: "Não foi possível salvar a edição em 'Almoço', pois esta despesa foi excluída em outro dispositivo. [Ver detalhes]".
O usuário pode então ver a alteração que foi perdida e decidir se quer recriar a despesa manualmente.
Esta abordagem híbrida combina a robustez da "exclusão prevalece" com uma experiência de usuário muito melhor, pois informa sobre a perda de dados e dá ao usuário o poder de agir.`
