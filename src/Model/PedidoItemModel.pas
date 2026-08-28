unit PedidoItemModel;

interface

type
  TPedidoItemModel = class
  private
    FId: Integer;
    FCodigoProduto: Integer;
    FDescricaoProduto: string;
    FQuantidade: Double;
    FVlrUnitario: Currency;
  public
    constructor Create(const ACodigoProduto: Integer; const ADescricaoProduto: string;
      const AQuantidade: Double; const AVlrUnitario: Currency; const AId: Integer = 0);
    property Id: Integer read FId write FId;
    property CodigoProduto: Integer read FCodigoProduto write FCodigoProduto;
    property DescricaoProduto: string read FDescricaoProduto write FDescricaoProduto;
    property Quantidade: Double read FQuantidade write FQuantidade;
    property VlrUnitario: Currency read FVlrUnitario write FVlrUnitario;
    function VlrTotal: Currency;
  end;

implementation

constructor TPedidoItemModel.Create(const ACodigoProduto: Integer; const ADescricaoProduto: string;
  const AQuantidade: Double; const AVlrUnitario: Currency; const AId: Integer);
begin
  inherited Create;
  FId := AId;
  FCodigoProduto := ACodigoProduto;
  FDescricaoProduto := ADescricaoProduto;
  FQuantidade := AQuantidade;
  FVlrUnitario := AVlrUnitario;
end;

function TPedidoItemModel.VlrTotal: Currency;
begin
  Result := FVlrUnitario * FQuantidade;
end;

end.
