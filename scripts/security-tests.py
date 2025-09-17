#!/usr/bin/env python3
"""
Script de Testes de Segurança Customizados para DAST
Testa vulnerabilidades específicas da aplicação XP
"""

import requests
import json
import sys
import time
from urllib.parse import urljoin
from datetime import datetime

class SecurityTester:
    def __init__(self, base_url):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.results = {
            'timestamp': datetime.now().isoformat(),
            'base_url': self.base_url,
            'tests': [],
            'summary': {
                'total_tests': 0,
                'passed': 0,
                'failed': 0,
                'vulnerabilities_found': 0
            }
        }
        
    def log_test(self, test_name, status, details, vulnerability_level=None):
        """Registra resultado de um teste"""
        test_result = {
            'test_name': test_name,
            'status': status,
            'details': details,
            'vulnerability_level': vulnerability_level,
            'timestamp': datetime.now().isoformat()
        }
        
        self.results['tests'].append(test_result)
        self.results['summary']['total_tests'] += 1
        
        if status == 'PASS':
            self.results['summary']['passed'] += 1
        else:
            self.results['summary']['failed'] += 1
            if vulnerability_level in ['HIGH', 'MEDIUM', 'LOW']:
                self.results['summary']['vulnerabilities_found'] += 1
        
        print(f"[{status}] {test_name}: {details}")
    
    def test_authentication_bypass(self):
        """Testa tentativas de bypass de autenticação"""
        print("\n🔐 Testando bypass de autenticação...")
        
        # Teste 1: Acesso direto a endpoints protegidos
        protected_endpoints = [
            '/api/customers',
            '/api/products',
            '/api/admin/users',
            '/actuator/env'
        ]
        
        for endpoint in protected_endpoints:
            try:
                response = self.session.get(urljoin(self.base_url, endpoint))
                if response.status_code == 200:
                    self.log_test(
                        f"Authentication Bypass - {endpoint}",
                        "FAIL",
                        f"Endpoint acessível sem autenticação (Status: {response.status_code})",
                        "HIGH"
                    )
                else:
                    self.log_test(
                        f"Authentication Bypass - {endpoint}",
                        "PASS",
                        f"Endpoint protegido corretamente (Status: {response.status_code})"
                    )
            except Exception as e:
                self.log_test(
                    f"Authentication Bypass - {endpoint}",
                    "ERROR",
                    f"Erro ao testar endpoint: {str(e)}"
                )
    
    def test_sql_injection(self):
        """Testa vulnerabilidades de SQL Injection"""
        print("\n💉 Testando SQL Injection...")
        
        # Payloads de SQL Injection
        sql_payloads = [
            "' OR '1'='1",
            "'; DROP TABLE users; --",
            "' UNION SELECT * FROM users --",
            "1' OR 1=1 --",
            "admin'--",
            "' OR 1=1 LIMIT 1 --"
        ]
        
        # Endpoints que podem ser vulneráveis
        test_endpoints = [
            '/api/auth/authenticate',
            '/api/customers/search',
            '/api/products/search'
        ]
        
        for endpoint in test_endpoints:
            for payload in sql_payloads:
                try:
                    # Teste via POST
                    data = {'username': payload, 'password': 'test'}
                    response = self.session.post(urljoin(self.base_url, endpoint), json=data)
                    
                    # Verifica indicadores de SQL Injection
                    if any(indicator in response.text.lower() for indicator in [
                        'sql', 'mysql', 'postgresql', 'oracle', 'syntax error',
                        'database error', 'query failed'
                    ]):
                        self.log_test(
                            f"SQL Injection - {endpoint}",
                            "FAIL",
                            f"Possível SQL Injection detectado com payload: {payload}",
                            "HIGH"
                        )
                        break
                except Exception as e:
                    continue
            
            # Se chegou aqui, não encontrou SQL Injection
            self.log_test(
                f"SQL Injection - {endpoint}",
                "PASS",
                "Nenhuma vulnerabilidade de SQL Injection detectada"
            )
    
    def test_xss_vulnerabilities(self):
        """Testa vulnerabilidades de Cross-Site Scripting (XSS)"""
        print("\n🎯 Testando XSS...")
        
        xss_payloads = [
            "<script>alert('XSS')</script>",
            "javascript:alert('XSS')",
            "<img src=x onerror=alert('XSS')>",
            "<svg onload=alert('XSS')>",
            "';alert('XSS');//"
        ]
        
        # Endpoints que podem refletir entrada do usuário
        test_endpoints = [
            '/api/customers',
            '/api/products',
            '/api/search'
        ]
        
        for endpoint in test_endpoints:
            for payload in xss_payloads:
                try:
                    data = {'name': payload, 'description': payload}
                    response = self.session.post(urljoin(self.base_url, endpoint), json=data)
                    
                    # Verifica se o payload foi refletido sem sanitização
                    if payload in response.text:
                        self.log_test(
                            f"XSS - {endpoint}",
                            "FAIL",
                            f"XSS detectado - payload refletido: {payload}",
                            "MEDIUM"
                        )
                        break
                except Exception as e:
                    continue
            
            # Se chegou aqui, não encontrou XSS
            self.log_test(
                f"XSS - {endpoint}",
                "PASS",
                "Nenhuma vulnerabilidade XSS detectada"
            )
    
    def test_security_headers(self):
        """Testa presença de headers de segurança"""
        print("\n🛡️ Testando headers de segurança...")
        
        required_headers = {
            'X-Frame-Options': 'DENY',
            'X-Content-Type-Options': 'nosniff',
            'X-XSS-Protection': '1; mode=block',
            'Strict-Transport-Security': None,  # Qualquer valor é aceito
            'Content-Security-Policy': None     # Qualquer valor é aceito
        }
        
        try:
            response = self.session.get(self.base_url)
            headers = response.headers
            
            for header, expected_value in required_headers.items():
                if header in headers:
                    if expected_value is None or expected_value in headers[header]:
                        self.log_test(
                            f"Security Header - {header}",
                            "PASS",
                            f"Header presente: {headers[header]}"
                        )
                    else:
                        self.log_test(
                            f"Security Header - {header}",
                            "FAIL",
                            f"Header com valor incorreto: {headers[header]} (esperado: {expected_value})",
                            "MEDIUM"
                        )
                else:
                    self.log_test(
                        f"Security Header - {header}",
                        "FAIL",
                        "Header de segurança ausente",
                        "MEDIUM"
                    )
        except Exception as e:
            self.log_test(
                "Security Headers",
                "ERROR",
                f"Erro ao verificar headers: {str(e)}"
            )
    
    def test_directory_traversal(self):
        """Testa vulnerabilidades de Directory Traversal"""
        print("\n📁 Testando Directory Traversal...")
        
        traversal_payloads = [
            '../../../etc/passwd',
            '..\\..\\..\\windows\\system32\\drivers\\etc\\hosts',
            '....//....//....//etc/passwd',
            '%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd'
        ]
        
        # Endpoints que podem ser vulneráveis
        test_endpoints = [
            '/api/files/',
            '/api/download/',
            '/api/export/'
        ]
        
        for endpoint in test_endpoints:
            for payload in traversal_payloads:
                try:
                    response = self.session.get(urljoin(self.base_url, f"{endpoint}{payload}"))
                    
                    # Verifica indicadores de Directory Traversal
                    if any(indicator in response.text.lower() for indicator in [
                        'root:', 'bin:', 'daemon:', 'system32', 'windows',
                        'passwd', 'hosts', 'boot.ini'
                    ]):
                        self.log_test(
                            f"Directory Traversal - {endpoint}",
                            "FAIL",
                            f"Directory Traversal detectado com payload: {payload}",
                            "HIGH"
                        )
                        break
                except Exception as e:
                    continue
            
            # Se chegou aqui, não encontrou Directory Traversal
            self.log_test(
                f"Directory Traversal - {endpoint}",
                "PASS",
                "Nenhuma vulnerabilidade de Directory Traversal detectada"
            )
    
    def test_rate_limiting(self):
        """Testa implementação de rate limiting"""
        print("\n⏱️ Testando Rate Limiting...")
        
        endpoint = '/api/auth/authenticate'
        max_requests = 100
        
        try:
            # Faz múltiplas requisições rapidamente
            for i in range(max_requests):
                response = self.session.post(urljoin(self.base_url, endpoint), 
                                           json={'username': 'test', 'password': 'test'})
                
                if response.status_code == 429:  # Too Many Requests
                    self.log_test(
                        "Rate Limiting",
                        "PASS",
                        f"Rate limiting funcionando - bloqueado após {i+1} requisições"
                    )
                    return
            
            # Se chegou aqui, rate limiting não está funcionando
            self.log_test(
                "Rate Limiting",
                "FAIL",
                f"Rate limiting não implementado - {max_requests} requisições permitidas",
                "MEDIUM"
            )
        except Exception as e:
            self.log_test(
                "Rate Limiting",
                "ERROR",
                f"Erro ao testar rate limiting: {str(e)}"
            )
    
    def test_sensitive_data_exposure(self):
        """Testa exposição de dados sensíveis"""
        print("\n🔍 Testando exposição de dados sensíveis...")
        
        # Endpoints que podem expor dados sensíveis
        sensitive_endpoints = [
            '/actuator/env',
            '/actuator/configprops',
            '/actuator/health',
            '/h2-console',
            '/api/admin/users',
            '/api/customers'
        ]
        
        for endpoint in sensitive_endpoints:
            try:
                response = self.session.get(urljoin(self.base_url, endpoint))
                
                if response.status_code == 200:
                    content = response.text.lower()
                    
                    # Verifica se há dados sensíveis expostos
                    sensitive_patterns = [
                        'password', 'secret', 'key', 'token', 'jwt',
                        'database', 'connection', 'url', 'jdbc'
                    ]
                    
                    found_sensitive = [pattern for pattern in sensitive_patterns if pattern in content]
                    
                    if found_sensitive:
                        self.log_test(
                            f"Sensitive Data Exposure - {endpoint}",
                            "FAIL",
                            f"Dados sensíveis expostos: {', '.join(found_sensitive)}",
                            "HIGH"
                        )
                    else:
                        self.log_test(
                            f"Sensitive Data Exposure - {endpoint}",
                            "PASS",
                            "Nenhum dado sensível exposto"
                        )
                else:
                    self.log_test(
                        f"Sensitive Data Exposure - {endpoint}",
                        "PASS",
                        f"Endpoint protegido (Status: {response.status_code})"
                    )
            except Exception as e:
                self.log_test(
                    f"Sensitive Data Exposure - {endpoint}",
                    "ERROR",
                    f"Erro ao testar endpoint: {str(e)}"
                )
    
    def run_all_tests(self):
        """Executa todos os testes de segurança"""
        print(f"🔍 Iniciando testes de segurança para: {self.base_url}")
        print("=" * 60)
        
        # Executa todos os testes
        self.test_authentication_bypass()
        self.test_sql_injection()
        self.test_xss_vulnerabilities()
        self.test_security_headers()
        self.test_directory_traversal()
        self.test_rate_limiting()
        self.test_sensitive_data_exposure()
        
        # Gera relatório final
        self.generate_report()
    
    def generate_report(self):
        """Gera relatório final dos testes"""
        print("\n" + "=" * 60)
        print("📊 RESUMO DOS TESTES DE SEGURANÇA")
        print("=" * 60)
        
        summary = self.results['summary']
        print(f"Total de testes: {summary['total_tests']}")
        print(f"✅ Aprovados: {summary['passed']}")
        print(f"❌ Falharam: {summary['failed']}")
        print(f"🚨 Vulnerabilidades encontradas: {summary['vulnerabilities_found']}")
        
        # Salva relatório em arquivo JSON
        with open('security-tests-report.json', 'w', encoding='utf-8') as f:
            json.dump(self.results, f, indent=2, ensure_ascii=False)
        
        print(f"\n📄 Relatório salvo em: security-tests-report.json")
        
        # Retorna código de saída baseado nas vulnerabilidades
        if summary['vulnerabilities_found'] > 0:
            print(f"\n⚠️ ATENÇÃO: {summary['vulnerabilities_found']} vulnerabilidades encontradas!")
            return 1
        else:
            print(f"\n✅ Nenhuma vulnerabilidade crítica encontrada!")
            return 0

def main():
    if len(sys.argv) != 2:
        print("Uso: python3 security-tests.py <base_url>")
        print("Exemplo: python3 security-tests.py http://localhost:8080")
        sys.exit(1)
    
    base_url = sys.argv[1]
    tester = SecurityTester(base_url)
    
    try:
        exit_code = tester.run_all_tests()
        sys.exit(exit_code)
    except KeyboardInterrupt:
        print("\n\n⚠️ Testes interrompidos pelo usuário")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n❌ Erro inesperado: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
