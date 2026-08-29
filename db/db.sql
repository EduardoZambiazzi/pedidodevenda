/* ============================================================================
   PEDIDO DE VENDA - Script de banco (Firebird)
   ============================================================================
   Como usar (veja também o README.md na raiz do projeto):

   1) Para criar um banco NOVO do zero, descomente a linha CREATE DATABASE
      abaixo, ajuste o caminho, e rode (sem estar conectado a nenhum banco):
         isql -i db.sql

   2) Se você já criou o banco (.fdb) por outro meio, apenas conecte antes
      de rodar este script:
         isql -user SYSDBA -password masterkey "C:\Bases\PEDIDOVENDA.FDB" -i db.sql

   Este script é idempotente apenas em bases novas/vazias (não usa
   IF NOT EXISTS - rodar duas vezes em cima da mesma base vai falhar).
   ============================================================================ */

-- CREATE DATABASE 'C:\Bases\PEDIDOVENDA.FDB'
--     USER 'SYSDBA' PASSWORD 'masterkey'
--     PAGE_SIZE 8192
--     DEFAULT CHARACTER SET UTF8;

SET SQL DIALECT 3;
SET NAMES UTF8;
SET TERM ^ ;

/* ============================================================================
   1) TABELAS
   ============================================================================ */

CREATE TABLE CLIENTE (
    CODIGO   INTEGER        NOT NULL,
    NOME     VARCHAR(100)   NOT NULL,
    CIDADE   VARCHAR(60)    NOT NULL,
    UF       CHAR(2)        NOT NULL,
    CONSTRAINT PK_CLIENTE PRIMARY KEY (CODIGO)
)^

CREATE TABLE PRODUTO (
    CODIGO        INTEGER        NOT NULL,
    DESCRICAO     VARCHAR(120)   NOT NULL,
    PRECO_VENDA   NUMERIC(15,2)  NOT NULL,
    CONSTRAINT PK_PRODUTO PRIMARY KEY (CODIGO)
)^

CREATE TABLE PEDIDO (
    NUMERO_PEDIDO    INTEGER        NOT NULL,
    DATA_EMISSAO     TIMESTAMP      NOT NULL,
    CODIGO_CLIENTE   INTEGER        NOT NULL,
    VALOR_TOTAL      NUMERIC(15,2)  DEFAULT 0 NOT NULL,
    OBSERVACAO       VARCHAR(200),
    CONSTRAINT PK_PEDIDO PRIMARY KEY (NUMERO_PEDIDO),
    CONSTRAINT FK_PEDIDO_CLIENTE FOREIGN KEY (CODIGO_CLIENTE)
        REFERENCES CLIENTE (CODIGO)
)^

CREATE TABLE PEDIDO_ITEM (
    ID                INTEGER        NOT NULL,
    NUMERO_PEDIDO     INTEGER        NOT NULL,
    CODIGO_PRODUTO    INTEGER        NOT NULL,
    QUANTIDADE        NUMERIC(15,3)  NOT NULL,
    VLR_UNITARIO      NUMERIC(15,2)  NOT NULL,
    VLR_TOTAL         NUMERIC(15,2)  NOT NULL,
    CONSTRAINT PK_PEDIDO_ITEM PRIMARY KEY (ID),
    CONSTRAINT FK_PEDIDO_ITEM_PEDIDO FOREIGN KEY (NUMERO_PEDIDO)
        REFERENCES PEDIDO (NUMERO_PEDIDO),
    CONSTRAINT FK_PEDIDO_ITEM_PRODUTO FOREIGN KEY (CODIGO_PRODUTO)
        REFERENCES PRODUTO (CODIGO)
)^

/* ============================================================================
   2) ÍNDICES MÍNIMOS (além dos índices de PK/FK criados automaticamente)
   ============================================================================ */

CREATE INDEX IDX_PEDIDO_CLIENTE ON PEDIDO (CODIGO_CLIENTE)^
CREATE INDEX IDX_PEDIDO_ITEM_PEDIDO ON PEDIDO_ITEM (NUMERO_PEDIDO)^
CREATE INDEX IDX_PEDIDO_ITEM_PRODUTO ON PEDIDO_ITEM (CODIGO_PRODUTO)^

/* ============================================================================
   3) GENERATORS (sequences) + TRIGGERS para chave sequencial/auto incremento
   ============================================================================ */

CREATE GENERATOR GEN_PEDIDO_NUMERO^
CREATE GENERATOR GEN_PEDIDO_ITEM_ID^

SET GENERATOR GEN_PEDIDO_NUMERO TO 0^
SET GENERATOR GEN_PEDIDO_ITEM_ID TO 0^

CREATE TRIGGER PEDIDO_BI0 FOR PEDIDO
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
    IF (NEW.NUMERO_PEDIDO IS NULL) THEN
        NEW.NUMERO_PEDIDO = NEXT VALUE FOR GEN_PEDIDO_NUMERO;
END^

CREATE TRIGGER PEDIDO_ITEM_BI0 FOR PEDIDO_ITEM
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
    IF (NEW.ID IS NULL) THEN
        NEW.ID = NEXT VALUE FOR GEN_PEDIDO_ITEM_ID;
END^

SET TERM ; ^

/* ============================================================================
   4) CARGA DE DADOS DE TESTE
   ============================================================================ */

INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (1,  'Comercial Alvorada Ltda',        'Curitiba',         'PR');
INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (2,  'Distribuidora Bom Preço ME',     'São Paulo',        'SP');
INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (3,  'Mercearia Santa Fé',             'Porto Alegre',     'RS');
INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (4,  'Atacado Nova Era Ltda',          'Belo Horizonte',   'MG');
INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (5,  'Casa das Ferragens',             'Joinville',        'SC');
INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (6,  'Padaria Pão Quente',             'Florianópolis',    'SC');
INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (7,  'Auto Peças Rodavel',             'Londrina',         'PR');
INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (8,  'Farmácia Vida Plena',            'Campinas',         'SP');
INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (9,  'Papelaria Escreva Bem',          'Maringá',          'PR');
INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (10, 'Supermercado Preço Justo',       'Ribeirão Preto',   'SP');
INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (11, 'Materiais de Construção Forte',  'Cascavel',         'PR');
INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (12, 'Loja Modas Elegance',            'Uberlândia',       'MG');

INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (1,  'Arroz Branco Tipo 1 5kg',            28.90);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (2,  'Feijão Carioca 1kg',                 8.50);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (3,  'Óleo de Soja 900ml',                 7.20);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (4,  'Açúcar Refinado 1kg',                5.30);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (5,  'Café Torrado e Moído 500g',          14.90);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (6,  'Sabão em Pó 1kg',                    16.40);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (7,  'Detergente Neutro 500ml',            2.80);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (8,  'Papel Higiênico 12 rolos',           22.90);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (9,  'Refrigerante Cola 2L',               9.90);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (10, 'Macarrão Espaguete 500g',            4.60);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (11, 'Leite Integral 1L',                  6.10);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (12, 'Biscoito Recheado 140g',             3.75);

COMMIT;
