unit PedidoModelTests;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPedidoModelTests = class
  public
    [Test]
    procedure QuandoCalcularVlrTotalDoItem_MultiplicarQuantidadePeloValorUnitario;

    [Test]
    procedure ComQuantidadeFracionaria_VlrTotalDoItemArredondarParaCurrency;

    [Test]
    procedure SemItens_ValorTotalDoPedidoSerZero;

    [Test]
    procedure ComVariosItens_ValorTotalDoPedidoSerSomaDosTotais;
  end;

implementation

uses
  PedidoModel,
  PedidoItemModel;

procedure TPedidoModelTests.QuandoCalcularVlrTotalDoItem_MultiplicarQuantidadePeloValorUnitario;
var
  Item: TPedidoItemModel;
begin
  Item := TPedidoItemModel.Create(1, 'Produto Teste', 3, 10.5);
  try
    Assert.AreEqual(Currency(31.5), Item.VlrTotal);
  finally
    Item.Free;
  end;
end;

procedure TPedidoModelTests.ComQuantidadeFracionaria_VlrTotalDoItemArredondarParaCurrency;
var
  Item: TPedidoItemModel;
begin
  Item := TPedidoItemModel.Create(1, 'Produto Teste', 1.5, 10);
  try
    Assert.AreEqual(Currency(15), Item.VlrTotal);
  finally
    Item.Free;
  end;
end;

procedure TPedidoModelTests.SemItens_ValorTotalDoPedidoSerZero;
var
  Pedido: TPedidoModel;
begin
  Pedido := TPedidoModel.Create;
  try
    Assert.AreEqual(Currency(0), Pedido.ValorTotal);
  finally
    Pedido.Free;
  end;
end;

procedure TPedidoModelTests.ComVariosItens_ValorTotalDoPedidoSerSomaDosTotais;
var
  Pedido: TPedidoModel;
begin
  Pedido := TPedidoModel.Create;
  try
    Pedido.Itens.Add(TPedidoItemModel.Create(1, 'Produto 1', 2, 10));   // 20
    Pedido.Itens.Add(TPedidoItemModel.Create(2, 'Produto 2', 3, 5.5));  // 16.5
    Assert.AreEqual(Currency(36.5), Pedido.ValorTotal);
  finally
    Pedido.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TPedidoModelTests);

end.
