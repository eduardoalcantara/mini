# Requisitos do PO

## Requisitos Visuais

### Dimensionamento da Janela

- O MINI deve ser configurável para permitir redimensionamento ou bloquear o redimensionamento.
- As opções de dimensionamento da janela devem ser:
    - Bloqueado no ùltimo tamanho definido pelo usuário;
    - Redimecionamento Livre;
    - X e Y fornecidos pelo usuário em PX ou %;
    - Tamanhos recomendados pelo aplicativo, como:
      - Centralizado, ocupando 50% da largura e 50% da altura;
      - À esqueda ou direita, em modo retrato ocupando 50% da tela;
      - Em cima ou em baixo, direita ou esqueda, ocupando 25% da tela, sendo o padrão na direita na parte de baixo.
    - Em modo normal (nem minimizado nem maximizado) o MINI deve ficar sempre afastado das bordas do monitor por 10px em todas as direções, inclusive da barra de tarefas do SO.
    - O MINI sempre deve salvar o posicionamento da tela quando em modo normal, para que sempre que for inicializado, seja posicionado na posição anterior ao fechamento.
    - O MINI nunca deve salvar o posicionamento da tela quando maximizado, pois perderá o posicionamento do modo normal para 0x0, mas deve salvar a informação de que estava maximizado, para que volte a ser maximizado na próxima vez que for aberto.
    - O MINI também deve salvar a informação sobre em qual monitor estava aberto.

### Movimento da Janela

- As opções de movimento da janela devem ser:
  - Bloqueado pelo usuário para não movimentar livremente, mas pode escolher a posição no tray e tamanho nas configurações;
  - Movimentação livre;
  - Movimentação assistida pela tecla Ctrl para deslizar no eixo Y e Shift para deslizar no eixo X.
- Sempre que o MINI for minimizado ou reaparecer, a janela deve aparecer/desaparecer em fade-in/fade-out. 


### Itens Mostrados na Janela

- Por padrão, o MINI inicializa pela primeira vez mostrando a tela de boas vindas, que consome uma aba de edição de texto, onde tem as opções `Abrir Arquivo`, `Abrir Pasta` e `Abrir Painel de Tarefas`, além das opções de configuração e ajuda.
- Se o usuário optar por abrir uma pasta, um painel à esquerda mostrará os arquivos e sub-pastas, como se a pasta fosse um repositório, para que o usuário possa alternar entre os arquivos facilmente.
- Se o usuário optar por abrir um ou mais arquivos, o MINI deve parar de se comportar como se estivesse trabalhando num repositório e deve permitir que o usuário possa configurar como quer ver a listagem de arquivos nesse caso:
  - Os nomes dos arquivos aparecem como abas em cima do editor de texto, mostrando o caminho completo quando passar o mouse em cima e ficar por mais de 2 segundos;
  - Os nomes dos arquivos devem aparecer numa lista no painel à esqueda, como se fosse um repositório, mas mostrando os nomes dos arquivos em negrito e em baixo no nome o caminho completo;
  - BOTH: permite mostrar as duas formas de listagem dos arquivos abertos.
- Outro item mostrado na tela inicial é o menu padrão de qualquer sistema, com itens como `Arquivo`, `Editar`, `Ferramentas`, `Visual`, `Janelas`, `Sobre` etc.
- Outros itens são ferramentas que serão detalhas em outros tópicos específicos, como a ferramenta `Taregas`, `Sincronização` e `Assistente de IA`.

### Temas Embutidos

- O MINI deve ter alguns temas embutidos:
  - Tema Claro, inspirado no tema do Github Light Default;
  - Tema Escuro, inspirado no tema escuro do VSCode;
  - Tema Pastel, inspirado nos cadernos Moleskine;
  - Aproveitar os temos do Zed;
  - Permitir criação de Temas novos, já disponível no Zed.
- O MINI deve, por padrão (e alterável pelo usuário), ter um modelo próprio de fontes a serem usadas para tipos diferentes de arquivos. Isso significa que o usuário pode aceitar esse comportamento do MINI, ou escolher suas próprias fontes, ou permitir que o Tema escolhido defina a fonte. Os padrões de fonte do MINI são:
    - Para arquivos de texto (.txt): Bookman Old Style (deve instalar a fonte automaticamente se o SO não tiver) [ont-family: "Bookman Old Style", Literata, "EB Garamond", serif, "Times New Roman", Times, Consolas, "Courier New", monospace;] em 16px e altura de linha de 1.6;
    - Para arquivos de código fonte (.java, .js .md etc.): Jetbrains Mono (também instala automaticamente) [font-family: "JetBrains Mono", "Fira Code", "Cascadia Code", Consolas, monospace, Consolas, "Courier New", monospace;];
    - O usuário deve poder configurar outras fontes para outras extensões se assim quiser.
    - O tamanho da fonte e distância entre linhas também é configurável de forma independente, para melhor experiência do usuário e acessibilidade.

### Detalhes Diversos de UI

- Atualmente o Editor do Zed mostra a primeira linha do editor de texto imediatamente abaixo da barra de ferramentas. Deve haver um espaço (margem) de pelo menos a altura de uma linha de texto antes da linha 1 do editor.

## Requisitos Funcionais

### Ajuda Inteligente e Elegante

- O MINI deve ter várias formas de ajudar o usuário: atráves do menu Ajuda e via QA, além de ícones de (?) perto das funcionalidades.
- Quando o usuário passar o mouse em cima de (?) em alguma funcionalidade, uma caixa de resumo deve apararecer para ajudar e um link `Saiba mais...` deve aparecer, caso seja clicado o `Saiba Mais` ou o `(?)` o MINI deve abrir uma nova aba de edição de texto com a ajuda completa, como se fosse um arquivo que pudesse ser editado.

### Pesquisa de Arquivos nos discos da máquina numa barra de tarefas com `Ctrl+Shift+F`

- O Zed, que é a base do MINI já possui uma barra chamada `Project Search` que podemos usar como uma ferramenta não somente para encontrar arquivos no projeto (pasta aberta), mas também para encontrar qualquer arquivo no SO, quando o MINI não estiver em modo de pasta. Isso seria muito útil para o usuário, bem como uma opção para encontrar texto dentro dos arquivos.

### Sincronização via Github e Gitlab

- O MINI deve ser capaz de ser configurado para sincronizar os arquivos abertos localmente com um repositório remoto do Github ou Gitlab, ou ainda via arquivo `.mini` quando em modo de pasta, onde `.mini` deve indicar configurações da pasta para o MINI, como o endereço de um reposítório de sincronização específico para aquela pasta. Assim o usuário que usar o MINI em vários dispositivos poderá editar os mesmo arquivos, mas o MINI deve sempre entender onde o arquivo original se encontra (dispositivo, pasta e nome do arquivo) para atualizar o original com dados mofificados em outros dispositivos.
- O MINI deve utilizar uma versão interna do Git caso não detecte o git instalado no SO.
- O MINI deve ter ajuda completa para usuários leigos em Github, Gitlab e conceitos de Git.

### Sincronização via Google Drive

- O MINI deve ser capaz de fazer o mesmo tipo de sincronização que faz com o Github/Gitlab também com o Google Drive, com a diferença de que isso exige que o usuário faça login na sua conta do Google e autoriza o uso do seu Google Drive pelo MINI, e isso significa que preciso configurar uma conta de aplicativo no GCP para que nosso MINI possa acessar os Drives dos seus usuários.
- Os arquivos soltos (sem projeto e de várias origens diferentes no HDD) devem ser sincronizados numa pasta ou subpasta do Drive à escolha do usuário (padrão: mini).
- Quando o usuário estiver trabalhando em uma pasta, o arquivo `.mini` pode defirnir qual o nome da pasta ou subpasta dentro do seu Google Drive.

### Sincronização no Serviço MINI

- Futuramente vamos ter um serviço de núvem próprio para backup de arquivos dos usuários, que precisão criar suas contas e fazer login no serviço.
- Futuramente teremos uma versão web do MINI para que o usuário possa editar seus arquivos aberto localmente na web e sincronizar tudo.

### Agente de IA

- Hoje em dia não tem como não oferecer suporte à IA em novos sistemas, especialmente editores de texto. Por isso o MINI deve aproveitar o suporte a IAs através de API keys que o Zed já oferece, com uma configuração extra de simplicidade.
- A configuração minimalista de IA deve permitir que o usuário possa escolher entre usar a IA num painel exclusivo para isso, como já ocorre no Zed, ou de duas outras formas adicionais:
  - Uma barra de pesquisa igual a barra de pesquisa de arquivos, bem mais prático, só que a resposta aparecerá (será incluída) no arquivo aberto em foreground no MINI, a partir da linha/coluna em foco.
  - Digitando `///` e escrevendo seu prompt e pressionado ENTER, e a resposta deve ser colocada na linha seguinte no arquivo.
  - Inline Assitant, já disponível no Zed.
- O usuário deve poder ativar o modo autocompletar nas configurações, selecionado entre 3 modos:
  - Oferecer sugestões usando o agente de IA;
  - Oferecer sugestões usando palavras já contidas no arquivo;
  - Oferecer sugestões do dicionário da língua selecionada pelo usuário;
- O MINI só deve oferecer sugestão se o usuário usar o atalho `Ctrl+Espaço`.

### Gerenciador de Tarefas

- O MINI deverá ter um painel de Gerenciador de Tarefas, que pode ser configurado para ficar na esquerda no ludar da lista de arquivos, ou coexistir com ele, ficando na direita do editor de textos.
- A lista de tarefas fica no painel. O usuário pode clicar em (+) para adicionar uma tarefa simples, agendada, recorrente, item de compras ou tarefa complexa.
- Deverá haver um botão de limpeza de tarefas concluídas e um histórico de tarefas concluídas e exluídas.
- O usuário poderá configurar em quantos dias ou horas as tarefas concluídas sairão da lista de tarefas concluídas.
- As tarefas simples entram com a descrição e um simples ENTER.
- As tarefas simples podem ter status de antiga caso fique muitos dias sem serem realizadas.
- AS tarefas agendadas entram depois de uma descrição, ENTER, depois informa a data e/ou a hora(ou escreve HOJE ou AMANHÃ) e ENTER.
- As tarefas atrasadas podem ter status de iminente, atradada e realizada
- As tarefas complexas quando criadas, abrem uma aba de arquivo de texto para o usuário descrever a tarefas, colocar subtarefas etc. As tarefas complexas podem ter status de não iniciada, iniciada, realizada.
- As tarefas de listas de compras... PENDENTE DE FINALIZAÇÃO 
- As tarefas recorrentes são criadas indicando o tipo de recorrência, como diária, semanal, quinzenal, mensal, e é possível especificar o dia da inserção como número ou dia da semana, como por exemplo se o usuário quiser colocar tarefas de pagamentos de contas. 
- O MINI deve oferecer configuração de SMTP para envio de notificação de tarefas, diariamente e tarefas agendadas.
- O usuário pode inserir tags em tarefas. 
- O usuário pode filtrar tarefas por texto, por tag e por tipo. 

### Modo Pasta/Projeto/Repositório e Modo Solto

- No modo Pasta, o MINI mostra o painel com os arquivos e subpastas da pasta aberta, como já mencionado.
- No modo Solto, o MINI mostra arquivos abertos de vários locais e discos
- Se o usuário fechar a pasta, o MINI deve voltar ao modo Solto, reabrindo as abas de arquivos que estavam abertos antes de se abrir o MINI no modo pasta, para que o usuário não tenha que procurar todos os arquivos anteriormente abertos.

## Requisitos Não Funcionais

### Atualizações

- O MINI deve permitir uma atualização transparente, sem a necessidade de usar um instalador a cada nova atualização.

### Ambiente do SO

- O MINI deve se registrar para ser incluído no menu de contexto do GUI do SO, como por exemplo, no Windows Explorer, tanto para arquivos, como para pastas, para permitir abrir um arquivo ou modo pasta.

### Idiomas

- O MINI já deve vir compatível com Português do Brasil, Inglês e Chinês.
- O MINI deve permitir a inclusão de arquivos de tradução para adição de outros idiomas.

### Trayicon/Bandeja

- O MINI deve inicializar com o SO e abrir sua janela mostrando a aba de tarefas.
- O MINI deve ser configurável para minimizar para o trayicon ou para a barra de tarefas, sendo o padrão o trayicon, informando o usuário que o MINI foi para a bandeja de sistemas do SO, permitindo o usuário que opte por não ver mais essa mensagem.
- O aplicativo deve aparecer ou sumir sempre que o usuário clicar no seu ícone da bandeja com o botão direito, e sempre deve reaparecer na mesma posição que estava anteriormente.
- O botão esquerdo do mouse aciona o menu de contexto do MINI na bandeja, com opções de abrir, mudar posicionamento da janela com várias opções de posição tamanho e monitor, sincronizar e fechar.
- O trayicon deve ter a inteligência de saber em qual monitor ele foi acionado para que abra o MINI nesse monitor.
