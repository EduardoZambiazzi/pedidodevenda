unit PedidoServiceTests;

interface

uses
  DUnitX.TestFramework,
  PedidoModel,
  PedidoServiceIntf,
  RepositoriosFalsos;

type
  [TestFixture]
  TPedidoServiceTests = class
  private
    FClienteRepo: TClienteRepositorioFalso;
    FProdutoRepo: TProdutoRepositorioFalso;
    FPedidoRepo: TPedidoRepositorioFalso;
    FSUT: IPedidoService;
  public
    [Setup]
    procedure Setup;

    [Test]
    procedure QuandoClienteExiste_BuscarClienteRetornarSeusDados;

    [Test]
    procedure QuandoClienteNaoExiste_BuscarClienteLevantarExcecao;

    [Test]
    procedure QuandoProdutoExiste_BuscarProdutoRetornarSeusDados;

    [Test]
    procedure QuandoProdutoNaoExiste_BuscarProdutoLevantarExcecao;

    [Test]
    procedure SeQuantidadeEValorUnitarioValidos_CalcularVlrTotalItemMultiplicarOsDois;

    [Test]
    procedure ComIndiceEdicaoMenosUm_AdicionarOuAtualizarItemIncluirNovoItem;

    [Test]
    procedure ComProdutoRepetido_AdicionarOuAtualizarItemCriarLinhasDistintas;

    [Test]
    procedure ComQuantidadeZeroOuNegativa_AdicionarOuAtualizarItemLevantarExcecao;

    [Test]
    procedure ComValorUnitarioNegativo_AdicionarOuAtualizarItemLevantarExcecao;

    [Test]
    procedure ComIndiceValido_AdicionarOuAtualizarItemSubstituirDadosDoItem;

    [Test]
    procedure ComIndiceInvalido_AdicionarOuAtualizarItemLevantarExcecao;

    [Test]
    procedure ComIndiceValido_RemoverItemExcluirItemDoPedido;

    [Test]
    procedure ComIndiceInvalido_RemoverItemLevantarExcecao;

    [Test]
    procedure SemItens_GravarPedidoLevantarExcecao;

    [Test]
    procedure SemClienteInformado_GravarPedidoLevantarExcecao;

    [Test]
    procedure ComPedidoValido_GravarPedidoDelegarParaRepositorioEDevolverNumero;

    [Test]
    procedure QuandoRepositorioFalhaAoGravar_GravarPedidoPropagarExcecao;
  end;

implementation

uses
  System.SysUtils,
  ClienteModel,
  ProdutoModel,
  PedidoItemModel,
  PedidoExcecoes,
  PedidoService;

procedure TPedidoServiceTests.Setup;
begin
  FClienteRepo := TClienteRepositorioFalso.Create;
  FProdutoRepo := TProdutoRepositorioFalso.Create;
  FPedidoRepo := TPedidoRepositorioFalso.Create;
  FSUT := TPedidoService.Create(FClienteRepo, FProdutoRepo, FPedidoRepo);

  FClienteRepo.Adicionar(TClienteModel.Create(1, 'Cliente Teste', 'Curitiba', 'PR'));
  FProdutoRepo.Adicionar(TProdutoModel.Create(10, 'Produto Teste', 25.5));
end;

procedure TPedidoServiceTests.QuandoClienteExiste_BuscarClienteRetornarSeusDados;
var
  Cliente: TClienteModel;
begin
  Cliente := FSUT.BuscarCliente(1);
  Assert.AreEqual('Cliente Teste', Cliente.Nome);
  Assert.AreEqual('Curitiba', Cliente.Cidade);
  Assert.AreEqual('PR', Cliente.UF);
end;

procedure TPedidoServiceTests.QuandoClienteNaoExiste_BuscarClienteLevantarExcecao;
begin
  Assert.WillRaise(
    procedure begin FSUT.BuscarCliente(999); end,
    EClienteNaoEncontrado);
end;

procedure TPedidoServiceTests.QuandoProdutoExiste_BuscarProdutoRetornarSeusDados;
var
  Produto: TProdutoModel;
begin
  Produto := FSUT.BuscarProduto(10);
  Assert.AreEqual('Produto Teste', Produto.Descricao);
  Assert.AreEqual(Currency(25.5), Produto.PrecoVenda);
end;

procedure TPedidoServiceTests.QuandoProdutoNaoExiste_BuscarProdutoLevantarExcecao;
begin
  Assert.WillRaise(
    procedure begin FSUT.BuscarProduto(999); end,
    EProdutoNaoEncontrado);
end;

procedure TPedidoServiceTests.SeQuantidadeEValorUnitarioValidos_CalcularVlrTotalItemMultiplicarOsDois;
begin
  Assert.AreEqual(Currency(51), FSUT.CalcularVlrTotalItem(2, 25.5));
end;

procedure TPedidoServiceTests.ComIndiceEdicaoMenosUm_AdicionarOuAtualizarItemIncluirNovoItem;
var
  Pedido: TPedidoModel;
begin
  Pedido := TPedidoModel.Create;
  try
    FSUT.AdicionarOuAtualizarItem(Pedido, -1, 10, 'Produto Teste', 2, 25.5);
    Assert.AreEqual(NativeInt(1), Pedido.Itens.Count);
    Assert.AreEqual(10, Pedido.Itens[0].CodigoProduto);
    Assert.AreEqual(2.0, Pedido.Itens[0].Quantidade);
    Assert.AreEqual(Currency(25.5), Pedido.Itens[0].VlrUnitario);
  finally
    Pedido.Free;
  end;
end;

procedure TPedidoServiceTests.ComProdutoRepetido_AdicionarOuAtualizarItemCriarLinhasDistintas;
var
  Pedido: TPedidoModel;
begin
  Pedido := TPedidoModel.Create;
  try
    FSUT.AdicionarOuAtualizarItem(Pedido, -1, 10, 'Produto Teste', 1, 25.5);
    FSUT.AdicionarOuAtualizarItem(Pedido, -1, 10, 'Produto Teste', 3, 25.5);
    Assert.AreEqual(NativeInt(2), Pedido.Itens.Count);
    Assert.AreEqual(Currency(4 * 25.5), Pedido.ValorTotal);
  finally
    Pedido.Free;
  end;
end;

procedure TPedidoServiceTests.ComQuantidadeZeroOuNegativa_AdicionarOuAtualizarItemLevantarExcecao;
var
  Pedido: TPedidoModel;
begin
  Pedido := TPedidoModel.Create;
  try
    Assert.WillRaise(
      procedure begin FSUT.AdicionarOuAtualizarItem(Pedido, -1, 10, 'Produto Teste', 0, 25.5); end,
      EItemQuantidadeInvalida);
    Assert.WillRaise(
      procedure begin FSUT.AdicionarOuAtualizarItem(Pedido, -1, 10, 'Produto Teste', -1, 25.5); end,
      EItemQuantidadeInvalida);
  finally
    Pedido.Free;
  end;
end;

procedure TPedidoServiceTests.ComValorUnitarioNegativo_AdicionarOuAtualizarItemLevantarExcecao;
var
  Pedido: TPedidoModel;
begin
  Pedido := TPedidoModel.Create;
  try
    Assert.WillRaise(
      procedure begin FSUT.AdicionarOuAtualizarItem(Pedido, -1, 10, 'Produto Teste', 1, -0.01); end,
      EItemValorUnitarioInvalido);
  finally
    Pedido.Free;
  end;
end;

procedure TPedidoServiceTests.ComIndiceValido_AdicionarOuAtualizarItemSubstituirDadosDoItem;
var
  Pedido: TPedidoModel;
begin
  Pedido := TPedidoModel.Create;
  try
    FSUT.AdicionarOuAtualizarItem(Pedido, -1, 10, 'Produto Teste', 1, 25.5);
    FSUT.AdicionarOuAtualizarItem(Pedido, 0, 10, 'Produto Teste', 5, 30);
    Assert.AreEqual(NativeInt(1), Pedido.Itens.Count);
    Assert.AreEqual(5.0, Pedido.Itens[0].Quantidade);
    Assert.AreEqual(Currency(30), Pedido.Itens[0].VlrUnitario);
  finally
    Pedido.Free;
  end;
end;

procedure TPedidoServiceTests.ComIndiceInvalido_AdicionarOuAtualizarItemLevantarExcecao;
var
  Pedido: TPedidoModel;
begin
  Pedido := TPedidoModel.Create;
  try
    Assert.WillRaise(
      procedure begin FSUT.AdicionarOuAtualizarItem(Pedido, 0, 10, 'Produto Teste', 1, 25.5); end,
      EItemIndiceInvalido);
  finally
    Pedido.Free;
  end;
end;

procedure TPedidoServiceTests.ComIndiceValido_RemoverItemExcluirItemDoPedido;
var
  Pedido: TPedidoModel;
begin
  Pedido := TPedidoModel.Create;
  try
    FSUT.AdicionarOuAtualizarItem(Pedido, -1, 10, 'Produto Teste', 1, 25.5);
    FSUT.RemoverItem(Pedido, 0);
    Assert.AreEqual(NativeInt(0), Pedido.Itens.Count);
  finally
    Pedido.Free;
  end;
end;

procedure TPedidoServiceTests.ComIndiceInvalido_RemoverItemLevantarExcecao;
var
  Pedido: TPedidoModel;
begin
  Pedido := TPedidoModel.Create;
  try
    Assert.WillRaise(
      procedure begin FSUT.RemoverItem(Pedido, 0); end,
      EItemIndiceInvalido);
  finally
    Pedido.Free;
  end;
end;

procedure TPedidoServiceTests.SemItens_GravarPedidoLevantarExcecao;
var
  Pedido: TPedidoModel;
begin
  Pedido := TPedidoModel.Create;
  try
    Pedido.CodigoCliente := 1;
    Assert.WillRaise(
      procedure begin FSUT.GravarPedido(Pedido); end,
      EPedidoSemItens);
  finally
    Pedido.Free;
  end;
end;

procedure TPedidoServiceTests.SemClienteInformado_GravarPedidoLevantarExcecao;
var
  Pedido: TPedidoModel;
begin
  Pedido := TPedidoModel.Create;
  try
    Pedido.Itens.Add(TPedidoItemModel.Create(10, 'Produto Teste', 1, 25.5));
    Assert.WillRaise(
      procedure begin FSUT.GravarPedido(Pedido); end,
      EClienteNaoEncontrado);
  finally
    Pedido.Free;
  end;
end;

procedure TPedidoServiceTests.ComPedidoValido_GravarPedidoDelegarParaRepositorioEDevolverNumero;
var
  Pedido: TPedidoModel;
  NumeroGerado: Integer;
begin
  Pedido := TPedidoModel.Create;
  try
    Pedido.CodigoCliente := 1;
    Pedido.Itens.Add(TPedidoItemModel.Create(10, 'Produto Teste', 2, 25.5));

    NumeroGerado := FSUT.GravarPedido(Pedido);

    Assert.AreEqual(1, FPedidoRepo.QtdChamadasGravar);
    Assert.AreEqual(NumeroGerado, Pedido.NumeroPedido);
    Assert.IsTrue(NumeroGerado > 0);
  finally
    Pedido.Free;
  end;
end;

procedure TPedidoServiceTests.QuandoRepositorioFalhaAoGravar_GravarPedidoPropagarExcecao;
var
  Pedido: TPedidoModel;
begin
  Pedido := TPedidoModel.Create;
  try
    Pedido.CodigoCliente := 1;
    Pedido.Itens.Add(TPedidoItemModel.Create(10, 'Produto Teste', 2, 25.5));
    FPedidoRepo.LancarExcecaoAoGravar := True;

    Assert.WillRaise(
      procedure begin FSUT.GravarPedido(Pedido); end,
      Exception);
  finally
    Pedido.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TPedidoServiceTests);

end.
