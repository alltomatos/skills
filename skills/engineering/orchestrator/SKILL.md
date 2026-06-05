## Protocolo Call & Return (Ciclo de Vida)

Para garantir que o fluxo não se perca após a delegação:
1. **Chamada Determinística**: Invoque a skill apenas após formalizar o "Termo de Delegação" (Objetivo, Restrições, Output).
2. **Monitoramento de Conclusão**: O Orchestrator deve aguardar a sinalização de término da skill delegada.
3. **Ponto de Retorno**: Assim que a skill delegada encerrar, o fluxo **deve** retornar ao Orchestrator. 
4. **Re-avaliação pós-retorno**: O Orchestrator deve confrontar o *output* da skill delegada com a auditoria original. 
   - Se o gargalo persiste -> Nova delegação ou nova skill.
   - Se o gargalo foi resolvido -> Avançar para o próximo item da checklist.
