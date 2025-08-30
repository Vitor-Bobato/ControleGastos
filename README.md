Estratégia para Resolução de Conflito de Dados (Offline-First)
Cenário: Um usuário edita uma despesa no dispositivo A (offline), alterando seu valor. Antes que o dispositivo A possa sincronizar, o mesmo usuário deleta essa mesma despesa no dispositivo B (online), e essa exclusão é sincronizada com o servidor na nuvem.

Estratégia Escolhida: "Last Write Wins" (Última Escrita Vence) com "Soft Delete" (Exclusão Lógica)

Nossa estratégia combina duas abordagens para garantir consistência e preservar a intenção do usuário da forma mais segura possível.

Soft Delete (Exclusão Lógica): Em vez de remover permanentemente um registro do banco de dados (DELETE FROM expenses...), nós adicionaríamos uma coluna is_deleted (ou deleted_at) à nossa tabela de despesas. Quando o usuário "deleta" uma despesa, nós apenas marcamos esse campo como true (ou preenchemos com a data/hora da exclusão). A aplicação então filtra e não exibe os itens marcados como deletados.

Last Write Wins (Última Escrita Vence): Cada registro de despesa também teria uma coluna last_updated (ou updated_at) com um timestamp preciso de quando foi a última modificação. Quando o dispositivo A (offline) finalmente se conecta à internet para sincronizar, ele envia sua alteração (a edição do valor da despesa) junto com o timestamp daquela alteração.

Processo de Resolução do Conflito:

Quando o servidor recebe a tentativa de atualização do dispositivo A, ele verifica o estado atual do registro no banco de dados central:

O servidor vê que o registro já está marcado como is_deleted = true.

Ele compara o timestamp da exclusão (que veio do dispositivo B) com o timestamp da edição (que veio do dispositivo A).

Seguindo a regra "Last Write Wins", a operação com o timestamp mais recente prevalece.

Neste cenário específico, a exclusão no dispositivo B provavelmente ocorreu depois da edição no dispositivo A (que estava offline). Portanto, a exclusão "vence". A edição do dispositivo A é descartada, e o servidor informa ao dispositivo A que o item foi, na verdade, excluído, para que a interface local seja atualizada e o item removido da lista.

Prós desta Estratégia:

Simplicidade de Implementação: É uma das estratégias mais diretas para resolver conflitos, evitando lógicas complexas de fusão de dados.

Consistência Garantida: Sempre haverá um estado final claro e consistente para os dados em todos os dispositivos.

Recuperação de Dados: O uso de "soft delete" permite que dados "excluídos" possam ser recuperados, se necessário, o que é uma grande vantagem em caso de exclusões acidentais.

Contras desta Estratégia:

Perda de Dados Potencial: A principal desvantagem é que a edição feita pelo usuário no dispositivo A (offline) é perdida. O usuário pode ficar frustrado ao ver que seu trabalho foi descartado sem aviso.

Não Considera a Intenção: A regra é baseada puramente em tempo, e não na "importância" da operação. Uma edição pode ter sido mais importante para o usuário do que a exclusão, mas o sistema não tem como saber.

Conclusão:

Apesar da potencial perda de dados, a combinação de "Last Write Wins" com "Soft Delete" é uma estratégia robusta e pragmática para uma aplicação como esta. Ela prioriza a consistência dos dados, que é crucial em um sistema financeiro, e oferece uma rede de segurança com a exclusão lógica. Para mitigar o contra, poderíamos implementar um sistema de notificação que informaria ao usuário: "A despesa 'Almoço' que você editou foi excluída em outro dispositivo e não pôde ser salva."
