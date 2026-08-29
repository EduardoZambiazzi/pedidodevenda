unit PedidoService;

interface

uses
  PedidoServiceIntf,
  ClienteRepositorioIntf,
  ProdutoRepositorioIntf,
  PedidoRepositorioIntf,
  ClienteModel,
  ProdutoModel,
  PedidoModel,
  PedidoItemModel;

type
  TPedidoService = class(TInterfacedObject, IPedidoService)
  private
    FClienteRepositorio: IClienteRepositorio;
    FProdutoRepositorio: IProdutoRepositorio;
    FPedidoRepositorio: IPedidoRepositorio;
  public
    constructor Create(const AClienteRepositorio: IClienteRepositorio;
      const AProdutoRepositorio: IProdutoRepositorio; const APedidoRepositorio: IPedidoRepositorio);

    function BuscarCliente(const ACodigo: Integer): TClienteModel;
    function BuscarProduto(const ACodigo: Integer): TProdutoModel;
    function CalcularVlrTotalItem(const AQuantidade: Double; const AVlrUnitario: Currency): Currency;
    procedure AdicionarOuAtualizarItem(APedido: TPedidoModel; const AIndiceEdicao: Integer;
      const ACodigoProduto: Integer; const ADescricaoProduto: string;
      const AQuantidade: Double; const AVlrUnitario: Currency);
    procedure RemoverItem(APedido: TPedidoModel; const AIndice: Integer);
    function GravarPedido(APedido: TPedidoModel): Integer;
  end;

implementation

uses
  PedidoExcecoes;

resourcestring
  StrQuantidadeDeveSerMaiorQueZero = 'A quantidade deve ser maior que zero.';
  StrValorUnitarioNaoPodeSerNegativo = 'O valor unitário não pode ser negativo.';
  StrFmtIndiceDeItemInvalido = 'Índice de item inválido: %d.';
  StrPedidoDeveConterAoMenosUmItem = 'O pedido deve conter ao menos um item.';

{ TPedidoService }

constructor TPedidoService.Create(const AClienteRepositorio: IClienteRepositorio;
  const AProdutoRepositorio: IProdutoRepositorio; const APedidoRepositorio: IPedidoRepositorio);
begin
  inherited Create;
  FClienteRepositorio := AClienteRepositorio;
  FProdutoRepositorio := AProdutoRepositorio;
  FPedidoRepositorio := APedidoRepositorio;
end;

function TPedidoService.BuscarCliente(const ACodigo: Integer): TClienteModel;
begin
  if not FClienteRepositorio.BuscarPorCodigo(ACodigo, Result) then
    raise EClienteNaoEncontrado.CreateComCodigo(ACodigo);
end;

function TPedidoService.BuscarProduto(const ACodigo: Integer): TProdutoModel;
begin
  if not FProdutoRepositorio.BuscarPorCodigo(ACodigo, Result) then
    raise EProdutoNaoEncontrado.CreateComCodigo(ACodigo);
end;

function TPedidoService.CalcularVlrTotalItem(const AQuantidade: Double; const AVlrUnitario: Currency): Currency;
begin
  Result := AVlrUnitario * AQuantidade;
end;

procedure TPedidoService.AdicionarOuAtualizarItem(APedido: TPedidoModel; const AIndiceEdicao: Integer;
  const ACodigoProduto: Integer; const ADescricaoProduto: string;
  const AQuantidade: Double; const AVlrUnitario: Currency);
var
  Item: TPedidoItemModel;
begin
  if AQuantidade <= 0 then
    raise EItemQuantidadeInvalida.Create(StrQuantidadeDeveSerMaiorQueZero);
  if AVlrUnitario < 0 then
    raise EItemValorUnitarioInvalido.Create(StrValorUnitarioNaoPodeSerNegativo);

  if AIndiceEdicao >= 0 then
  begin
    if AIndiceEdicao >= APedido.Itens.Count then
      raise EItemIndiceInvalido.CreateFmt(StrFmtIndiceDeItemInvalido, [AIndiceEdicao]);

    Item := APedido.Itens[AIndiceEdicao];
    Item.CodigoProduto := ACodigoProduto;
    Item.DescricaoProduto := ADescricaoProduto;
    Item.Quantidade := AQuantidade;
    Item.VlrUnitario := AVlrUnitario;
  end
  else
    APedido.Itens.Add(TPedidoItemModel.Create(ACodigoProduto, ADescricaoProduto, AQuantidade, AVlrUnitario));
end;

procedure TPedidoService.RemoverItem(APedido: TPedidoModel; const AIndice: Integer);
begin
  if (AIndice < 0) or (AIndice >= APedido.Itens.Count) then
    raise EItemIndiceInvalido.CreateFmt(StrFmtIndiceDeItemInvalido, [AIndice]);

  APedido.Itens.Delete(AIndice);
end;

function TPedidoService.GravarPedido(APedido: TPedidoModel): Integer;
begin
  if APedido.CodigoCliente <= 0 then
    raise EClienteNaoEncontrado.CreateComCodigo(APedido.CodigoCliente);
  if APedido.Itens.Count = 0 then
    raise EPedidoSemItens.Create(StrPedidoDeveConterAoMenosUmItem);

  Result := FPedidoRepositorio.GravarPedido(APedido);
  APedido.NumeroPedido := Result;
end;

end.
