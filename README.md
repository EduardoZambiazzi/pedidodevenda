# Pedido de Venda

Tela de Pedido de Venda em Delphi (VCL) + FireDAC + Firebird, desenvolvida
como teste técnico. Sem uso de componentes de terceiros.

> Escopo desta etapa: itens 1, 2, 3, 5 e 6 do edital (`TESTE TÉCNICO.docx`).
> A "Parte de Manutenção" (item 4 - campo Observação e recálculo do total ao
> excluir item) é tratada em commits/etapa separada.

## Arquitetura

Organizado em camadas, com o objetivo de manter a UI (VCL) o mais fina
possível e concentrar toda regra de negócio em código testável sem
depender de banco de dados:

```
src/
  Model/       TClienteModel, TProdutoModel, TPedidoModel, TPedidoItemModel
               (sem dependência de banco/UI)
  Repository/  Interfaces (IClienteRepositorio, IProdutoRepositorio, IPedidoRepositorio)
               + implementações FireDAC (acesso a dados, SQL parametrizado)
  Service/     IPedidoService / TPedidoService - regras de negócio (validações,
               cálculo de totais, orquestração de gravação) - depende apenas
               das interfaces de Repository, nunca de FireDAC diretamente
  Data/        TConfiguracaoAplicacao (leitura do config.ini) e a fábrica de
               conexão FireDAC
  View/        TFormPedidoVenda - só traduz eventos de UI em chamadas ao
               IPedidoService e exibe o resultado; não contém regra de negócio
db/
  db.sql       DDL + carga de dados de teste
tests/
  PedidoVendaTests.dpr - projeto de testes DUnitX
```

Como o Service depende apenas de interfaces de Repository (não de FireDAC),
os testes de regra de negócio usam repositórios falsos em memória
(`RepositoriosFalsos.pas`) e não precisam de banco de dados. Os testes de
Repository (FireDAC/SQL/transação) rodam à parte, como testes de integração,
contra um Firebird real. Dessa forma o sistema fica coberto de ponta a ponta:
regra de negócio (unitário, rápido, sem banco) + acesso a dados (integração,
contra Firebird de verdade).

## Pré-requisitos

- Delphi / RAD Studio com FireDAC e DUnitX (ambos já vêm inclusos na
  instalação padrão, inclusive na Community Edition).
- Firebird Server instalado e rodando (testado com Firebird 5.0).

## Como criar o banco de dados

O script `db/db.sql` contém toda a DDL (tabelas, generators, triggers,
índices e FKs) e a carga de clientes/produtos de teste.

1. Crie um banco vazio. Duas opções:

   - **Opção A** - deixe o próprio script criar o banco: abra `db/db.sql`,
     descomente as linhas do `CREATE DATABASE` no topo do arquivo e ajuste
     o caminho para onde você quer o `.fdb`. Depois rode (sem estar
     conectado a nenhum banco):

     ```bash
     isql -i db.sql
     ```

   - **Opção B** - crie o banco por outro meio (IBExpert, flamerobin, etc.)
     e depois rode o script conectado a ele:

     ```bash
     isql -user SYSDBA -password masterkey "C:\Bases\PEDIDOVENDA.FDB" -i db.sql
     ```

2. Confira que a carga funcionou (12 clientes e 12 produtos):

   ```sql
   SELECT COUNT(*) FROM CLIENTE;
   SELECT COUNT(*) FROM PRODUTO;
   ```

## Como configurar o config.ini

1. Copie `config.ini.example` para `config.ini` (raiz do projeto, ao lado
   do executável). O `config.ini` real **não** é versionado (contém
   credenciais) - veja `.gitignore`.
2. Preencha a seção `[Database]`:

   ```ini
   [Database]
   Path=C:\Bases\PEDIDOVENDA.FDB
   Username=SYSDBA
   Password=masterkey
   Server=localhost
   Port=3050
   ClientLibrary=fbclient.dll
   ```

   - `Path`: caminho completo do `.fdb` criado no passo anterior.
   - `ClientLibrary`: caminho do `fbclient.dll` que a aplicação deve
     carregar. O `fbclient.dll` do Firebird 5.0 já está incluído na pasta
     `bin/` deste repositório para distribuição junto com o executável -
     aponte para ele (ex.: `bin\fbclient.dll` relativo ao executável, ou um
     caminho absoluto).

A aplicação lê o `config.ini` e monta a conexão FireDAC dinamicamente em
tempo de execução (`src/Data/ConfiguracaoAplicacao.pas` +
`src/Data/FabricaConexaoFireDAC.pas`) - não há nenhuma conexão
pré-configurada em tempo de design.

## Como executar o projeto

1. Abra `PedidoVenda.dpr` no Delphi (na primeira vez que você compilar/salvar
   o projeto, a IDE cria o `.dproj` automaticamente).
2. Garanta que o `config.ini` fique na mesma pasta do executável gerado.
   O jeito mais simples: em *Project > Options > Building > Delphi Compiler
   > Output directory*, aponte para a raiz do projeto (`.\`), ou apenas
   copie o `config.ini` para a pasta de saída (`Win32\Debug`, por padrão)
   após compilar.
3. Compile e rode (F9). A tela de Pedido de Venda abre diretamente.

## Como rodar os testes automatizados (DUnitX)

1. Abra `tests\PedidoVendaTests.dpr` no Delphi.
2. Compile e rode (F9 ou Ctrl+F9). É um app console: o resultado de cada
   teste aparece no console.
3. Os testes de `PedidoModelTests.pas`, `PedidoServiceTests.pas` e
   `ConfiguracaoAplicacaoTests.pas` são unitários (não precisam de banco).
   `RepositoriosIntegracaoTests.pas` são testes de integração: precisam
   do Firebird rodando e do `config.ini` da raiz do projeto apontando para
   o banco criado a partir de `db/db.sql` (eles usam esse mesmo
   `config.ini`, então rode primeiro os passos de "Como criar o banco" e
   "Como configurar o config.ini" acima). Esses testes limpam os próprios
   registros de teste que inserem (não deixam lixo na base).

## Roteiro rápido de testes manuais

1. Abra a aplicação. A tela de Pedido de Venda deve abrir sem erros
   (se o `config.ini`/banco estiverem certos).
2. **Cliente válido**: digite `1` no campo Código do Cliente e saia do
   campo (Tab). Nome, Cidade e UF devem ser preenchidos automaticamente
   e ficarem somente leitura.
3. **Cliente inválido**: apague o código e digite `999999`, saia do campo.
   Deve aparecer um aviso de cliente não encontrado e os campos devem
   ficar em branco.
4. **Produto válido**: no campo Código do Produto digite `1`, saia do
   campo. A Descrição deve ser preenchida (somente leitura) e o Valor
   Unitário deve vir preenchido com o preço de venda do produto (e continua
   editável).
5. **Inserir item**: informe Quantidade `2`, ajuste ou mantenha o Valor
   Unitário, clique em "Inserir/Atualizar Item". O item deve aparecer no
   grid, com o Valor Total do item calculado (Quantidade x Valor Unitário).
6. **Produto repetido**: repita o passo 4-5 com o mesmo código de produto
   (ex.: `1` novamente, quantidade diferente). O item deve aparecer em uma
   nova linha do grid (não deve substituir o anterior).
7. **Editar item (ENTER)**: clique em uma linha do grid e pressione ENTER.
   Os campos de produto/quantidade/valor devem ser preenchidos com os
   dados daquela linha. Altere a quantidade e clique em
   "Inserir/Atualizar Item" novamente: a mesma linha deve ser atualizada
   (não deve criar uma linha nova).
8. **Excluir item (DEL)**: clique em uma linha do grid e pressione DEL.
   Confirme a exclusão na caixa de diálogo. A linha deve sumir do grid.
9. **Valor Total do Pedido**: confira, após os passos acima, que o rodapé
   mostra a soma dos valores totais dos itens ainda presentes no grid.
10. **Gravar pedido sem cliente/sem itens**: tente gravar sem informar
    cliente, ou sem nenhum item no grid - a aplicação deve avisar e não
    deve gravar nada no banco.
11. **Gravar pedido válido**: com cliente e ao menos um item informados,
    clique em "Gravar Pedido". Deve aparecer uma mensagem de sucesso com o
    número do pedido gerado, e a tela deve limpar para um novo pedido.
12. **Conferir no banco**: rode no `isql`:

    ```sql
    SELECT * FROM PEDIDO ORDER BY NUMERO_PEDIDO DESC;
    SELECT * FROM PEDIDO_ITEM WHERE NUMERO_PEDIDO = <número gerado no passo 11>;
    ```

    O cabeçalho e os itens gravados devem bater com o que foi lançado na
    tela, e o `VALOR_TOTAL` do cabeçalho deve ser a soma dos itens.
