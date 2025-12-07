# Especificação de Sincronização e Edição via Google Drive (Acesso Flexível)
## Projeto: mini (Minimalist, Intelligent, Nice Interface)
## Versão: 1.0 - 2025-11-15
## Autor: Equipe de IA (PO, Arquiteto/Supervisor, Dev Sênior)

---

## Objetivo

Oferecer ao usuário do **mini** liberdade total para escolher onde armazenar, sincronizar e editar arquivos via Google Drive: seja utilizando uma **pasta dedicada** para backups automáticos e configurações, seja navegando e editando **qualquer pasta/arquivo permitido pelo Drive**, incluindo `.txt`, `.md`, `.java`, `.py` etc.

---

## Modo de Operação

### 1. Pasta Dedicada (Padrão)
- O mini cria e sugere uso da pasta `/Apps/mini-backup` para backup, restore de sessão, configurações e arquivos em edição.
- Permissões pedidas ao Google: leitura/escrita apenas nesta pasta.
- Vantagens: segurança, isolamento, facilita restore e backup contínuo.

### 2. Acesso a Qualquer Pasta/Arquivo
- Usuário pode optar por acessar, abrir e editar arquivos fora da pasta padrão.
- Permissões adicionais requeridas: leitura e escrita em qualquer local do Drive.
- mini lista arquivos por filtros (ex.: `.txt`, `.md`, `.js`, `.java`, `.py`, `.json`).
- Usuário navega pelo Drive, abre, edita e salva arquivos diretamente, inclusive em subpastas.
- Edição respeita permissões e bloqueios do Google Drive (por ex.: colaboração, arquivos protegidos, etc).

---

## Fluxo de Autenticação e Seleção

1. Autenticação via OAuth2 padrão Google.
2. Ao conectar com o Drive, mini pergunta:
   - "Deseja usar uma pasta dedicada para backups/configurações ou selecionar manualmente os arquivos/pastas que deseja editar?"
3. Se pasta dedicada:
   - Apenas acesso à `/Apps/mini-backup`.
4. Se acesso total:
   - mini solicita permissão ampliada, com opção de escolher nova pasta inicial (root) ou navegar todo o Drive.

---

## Sincronização e Edição

- Ao salvar, arquivos são sincronizados em tempo real ou on-demand, conforme preferência.
- Sessão e configurações continuam salvas em arquivos JSON (`config.json`, `session.json`) na pasta dedicada (se for usada).
- Todas operações de edição, abertura, renomeio e exclusão respeitam as permissões ativas do usuário no Drive.

---

## Segurança e Privacidade

- Usuário pode limitar privilégios e revogar acesso pelo painel de configurações do mini ou na conta Google.
- mini sempre recomenda uso da pasta dedicada por segurança, mas permite acesso expandido sob consentimento.
- Logs de operações e notificações visíveis na interface.

---

## Considerações Técnicas

- Uso da Google Picker API e REST Drive API para navegação/edição fora da pasta padrão.
- Abordagem modular para fácil expansão futura a outros serviços (OneDrive, Dropbox, etc).
- Suporte a arquivos colaborativos e múltiplas sessões abertas.
- Diálogo claro em caso de conflitos de edição, permissões insuficientes ou arquivos grandes.

---

*Documento sujeito a revisões conforme feedback de usuários e avanços do projeto.*
