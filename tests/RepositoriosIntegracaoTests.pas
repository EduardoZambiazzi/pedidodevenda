unit RepositoriosIntegracaoTests;

{ Testes de integração: rodam contra o Firebird de desenvolvimento real
  (data\PEDIDOVENDA.FDB, criado a partir de db\db.sql), usando o mesmo
  config.ini da aplicação. Exigem o serviço do Firebird 5.0 rodando na
  máquina. Cobrem o caminho FireDAC (parametrização, transação, FKs) que
  os testes de unidade do Service não alcançam (lá os repositórios são
  fakes). }

interface

uses
  DUnitX.TestFramework,
  FireDAC.Comp.Client,
  PedidoModel;

type
  [TestFixture]
  [Category('Integration')]
  TRepositoriosIntegracaoTests = class
  private
    FConnection: TFDConnection;
    FNumerosPedidoCriados: TArray<Integer>;
    procedure RegistrarParaLimpeza(const ANumeroPedido: Integer);
    procedure ExecutarSQL(const ASql: string);
    function ContarPedidos: Integer;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure QuandoClienteExiste_BuscarPorCodigoRetornarTrue;

    [Test]
    procedure QuandoClienteNaoExiste_BuscarPorCodigoRetornarFalse;

    [Test]
    procedure QuandoProdutoExiste_BuscarPorCodigoRetornarDescricaoEPreco;

    [Test]
    procedure QuandoProdutoNaoExiste_BuscarPorCodigoRetornarFalse;

    [Test]
    procedure ComPedidoValido_GravarPedidoGravarCabecalhoEItensNaMesmaTransacao;

    [Test]
    procedure ComProdutoInvalido_GravarPedidoFazerRollbackCompleto;
  end;

implementation

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Stan.Param,
  ConfiguracaoAplicacao,
  FabricaConexaoFireDAC,
  ClienteModel,
  ProdutoModel,
  PedidoItemModel,
  ClienteRepositorioIntf,
  ProdutoRepositorioIntf,
  PedidoRepositorioIntf,
  ClienteRepositorio,
  ProdutoRepositorio,
  PedidoRepositorio;

const
  CAMINHO_CONFIG_INI = 'D:\Desenvolvimento\delphi\pedidodevenda\config.ini';

procedure TRepositoriosIntegracaoTests.Setup;
var
  Config: TConfiguracaoAplicacao;
begin
  Config := TConfiguracaoAplicacao.CarregarDeArquivo(CAMINHO_CONFIG_INI);
  FConnection := TFabricaConexaoFireDAC.CriarConexao(Config);
  FConnection.Connected := True;
  SetLength(FNumerosPedidoCriados, 0);
end;

procedure TRepositoriosIntegracaoTests.TearDown;
var
  Numero: Integer;
begin
  for Numero in FNumerosPedidoCriados do
  begin
    ExecutarSQL(Format('DELETE FROM PEDIDO_ITEM WHERE NUMERO_PEDIDO = %d', [Numero]));
    ExecutarSQL(Format('DELETE FROM PEDIDO WHERE NUMERO_PEDIDO = %d', [Numero]));
  end;
  FConnection.Free;
end;

procedure TRepositoriosIntegracaoTests.RegistrarParaLimpeza(const ANumeroPedido: Integer);
begin
  SetLength(FNumerosPedidoCriados, Length(FNumerosPedidoCriados) + 1);
  FNumerosPedidoCriados[High(FNumerosPedidoCriados)] := ANumeroPedido;
end;

procedure TRepositoriosIntegracaoTests.ExecutarSQL(const ASql: string);
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Text := ASql;
    Qry.ExecSQL;
  finally
    Qry.Free;
  end;
end;

function TRepositoriosIntegracaoTests.ContarPedidos: Integer;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Text := 'SELECT COUNT(*) AS QTD FROM PEDIDO';
    Qry.Open;
    Result := Qry.FieldByName('QTD').AsInteger;
  finally
    Qry.Free;
  end;
end;

procedure TRepositoriosIntegracaoTests.QuandoClienteExiste_BuscarPorCodigoRetornarTrue;
var
  Repo: IClienteRepositorio;
  Cliente: TClienteModel;
begin
  Repo := TClienteRepositorio.Create(FConnection);
  Assert.IsTrue(Repo.BuscarPorCodigo(1, Cliente));
  Assert.AreEqual(1, Cliente.Codigo);
  Assert.IsTrue(Cliente.Nome <> '');
  Assert.IsTrue(Cliente.UF <> '');
end;

procedure TRepositoriosIntegracaoTests.QuandoClienteNaoExiste_BuscarPorCodigoRetornarFalse;
var
  Repo: IClienteRepositorio;
  Cliente: TClienteModel;
begin
  Repo := TClienteRepositorio.Create(FConnection);
  Assert.IsFalse(Repo.BuscarPorCodigo(999999, Cliente));
end;

procedure TRepositoriosIntegracaoTests.QuandoProdutoExiste_BuscarPorCodigoRetornarDescricaoEPreco;
var
  Repo: IProdutoRepositorio;
  Produto: TProdutoModel;
begin
  Repo := TProdutoRepositorio.Create(FConnection);
  Assert.IsTrue(Repo.BuscarPorCodigo(1, Produto));
  Assert.AreEqual(1, Produto.Codigo);
  Assert.IsTrue(Produto.Descricao <> '');
  Assert.IsTrue(Produto.PrecoVenda > 0);
end;

procedure TRepositoriosIntegracaoTests.QuandoProdutoNaoExiste_BuscarPorCodigoRetornarFalse;
var
  Repo: IProdutoRepositorio;
  Produto: TProdutoModel;
begin
  Repo := TProdutoRepositorio.Create(FConnection);
  Assert.IsFalse(Repo.BuscarPorCodigo(999999, Produto));
end;

procedure TRepositoriosIntegracaoTests.ComPedidoValido_GravarPedidoGravarCabecalhoEItensNaMesmaTransacao;
var
  Repo: IPedidoRepositorio;
  Pedido: TPedidoModel;
  NumeroGerado: Integer;
  Qry: TFDQuery;
begin
  Repo := TPedidoRepositorio.Create(FConnection);
  Pedido := TPedidoModel.Create;
  try
    Pedido.CodigoCliente := 1;
    Pedido.Itens.Add(TPedidoItemModel.Create(1, 'Arroz', 2, 28.90));
    Pedido.Itens.Add(TPedidoItemModel.Create(2, 'Feijão', 1, 8.50));

    NumeroGerado := Repo.GravarPedido(Pedido);
    RegistrarParaLimpeza(NumeroGerado);

    Assert.IsTrue(NumeroGerado > 0);

    Qry := TFDQuery.Create(nil);
    try
      Qry.Connection := FConnection;
      Qry.SQL.Text := 'SELECT CODIGO_CLIENTE, VALOR_TOTAL FROM PEDIDO WHERE NUMERO_PEDIDO = :N';
      Qry.ParamByName('N').AsInteger := NumeroGerado;
      Qry.Open;
      Assert.IsFalse(Qry.Eof, 'Cabeçalho do pedido não foi gravado.');
      Assert.AreEqual(1, Qry.FieldByName('CODIGO_CLIENTE').AsInteger);
      Assert.AreEqual(Currency(66.30), Qry.FieldByName('VALOR_TOTAL').AsCurrency);
      Qry.Close;

      Qry.SQL.Text := 'SELECT COUNT(*) AS QTD FROM PEDIDO_ITEM WHERE NUMERO_PEDIDO = :N';
      Qry.ParamByName('N').AsInteger := NumeroGerado;
      Qry.Open;
      Assert.AreEqual(2, Qry.FieldByName('QTD').AsInteger);
    finally
      Qry.Free;
    end;
  finally
    Pedido.Free;
  end;
end;

procedure TRepositoriosIntegracaoTests.ComProdutoInvalido_GravarPedidoFazerRollbackCompleto;
var
  Repo: IPedidoRepositorio;
  Pedido: TPedidoModel;
  QtdPedidosAntes: Integer;
  FalhouComoEsperado: Boolean;
begin
  // Não usei Assert.WillRaise aqui de propósito: o que importa é que ALGUMA
  // falha aconteça e o rollback funcione, não a classe exata da exceção que o
  // driver do Firebird decide lançar para violação de FK (isso é detalhe de
  // implementação do FireDAC, não do nosso código).
  Repo := TPedidoRepositorio.Create(FConnection);
  QtdPedidosAntes := ContarPedidos;

  Pedido := TPedidoModel.Create;
  try
    Pedido.CodigoCliente := 1;
    Pedido.Itens.Add(TPedidoItemModel.Create(999999, 'Produto inexistente', 1, 10));

    FalhouComoEsperado := False;
    try
      Repo.GravarPedido(Pedido);
    except
      FalhouComoEsperado := True;
    end;

    Assert.IsTrue(FalhouComoEsperado, 'GravarPedido deveria ter lançado uma exceção para produto inexistente.');
    Assert.AreEqual(QtdPedidosAntes, ContarPedidos, 'Nenhum PEDIDO deveria ter sido gravado após falha no item (rollback).');
  finally
    Pedido.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TRepositoriosIntegracaoTests);

end.
