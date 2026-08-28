unit PedidoModel;

interface

uses
  System.Generics.Collections,
  System.SysUtils,
  PedidoItemModel;

type
  TPedidoModel = class
  private
    FNumeroPedido: Integer;
    FDataEmissao: TDateTime;
    FCodigoCliente: Integer;
    FNomeCliente: string;
    FCidadeCliente: string;
    FUfCliente: string;
    FItens: TObjectList<TPedidoItemModel>;
  public
    constructor Create;
    destructor Destroy; override;
    property NumeroPedido: Integer read FNumeroPedido write FNumeroPedido;
    property DataEmissao: TDateTime read FDataEmissao write FDataEmissao;
    property CodigoCliente: Integer read FCodigoCliente write FCodigoCliente;
    property NomeCliente: string read FNomeCliente write FNomeCliente;
    property CidadeCliente: string read FCidadeCliente write FCidadeCliente;
    property UfCliente: string read FUfCliente write FUfCliente;
    property Itens: TObjectList<TPedidoItemModel> read FItens;
    function ValorTotal: Currency;
  end;

implementation

{ TPedidoModel }

constructor TPedidoModel.Create;
begin
  inherited Create;
  FItens := TObjectList<TPedidoItemModel>.Create(True);
  FDataEmissao := Now;
end;

destructor TPedidoModel.Destroy;
begin
  FItens.Free;
  inherited;
end;

function TPedidoModel.ValorTotal: Currency;
var
  Item: TPedidoItemModel;
begin
  Result := 0;
  for Item in FItens do
    Result := Result + Item.VlrTotal;
end;

end.
