# Relatório de Testes Dinâmicos de Segurança (DAST) 
Data: 19/09/2025  9:51:40,20 
 
## Resumo dos Testes DAST 
 
✅ OWASP ZAP Baseline Scan: SUCESSO 
- Relatório HTML: zap-baseline-report.html 
- Relatório JSON: zap-baseline-report.json 
- Relatório XML: zap-baseline-report.xml 
 
## Configuração da Aplicação 
 
- **Porta**: 8080 (ambiente de teste) 
- **Perfil**: test 
- **Banco**: H2 em memória 
- **SSL**: Desabilitado para testes 
 
## Vulnerabilidades Identificadas 
 
### OWASP ZAP - Vulnerabilidades por Severidade: 
- **Alta**: Verificar relatório JSON para detalhes 
- **Média**: Verificar relatório JSON para detalhes 
- **Baixa**: Verificar relatório JSON para detalhes 
- **Informativa**: Verificar relatório JSON para detalhes 
 
## Recomendações de Mitigação 
 
1. **Prioridade Alta**: Corrigir vulnerabilidades de alta severidade identificadas pelo ZAP 
2. **Prioridade Média**: Revisar e corrigir vulnerabilidades de média severidade 
3. **Configuração**: Implementar headers de segurança adicionais 
4. **Monitoramento**: Configurar alertas para tentativas de ataque 
5. **Testes Regulares**: Executar testes DAST em cada deploy 
