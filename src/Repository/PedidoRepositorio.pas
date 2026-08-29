unit PedidoRepositorio;

interface

uses
  FireDAC.Comp.Client,
  PedidoModel,
  PedidoRepositorioIntf;

type
  TPedidoRepositorio = class(TInterfacedObject, IPedidoRepositorio)
  private
    FConnection: TFDConnection;
  public
    constructor Create(const AConnection: TFDConnection);
    // Grava cabeçalho + itens em uma única transação (commit se tudo der
    // certo, rollback completo se qualquer inserção falhar - ex.: FK de
    // produto/cliente inválida).
    function GravarPedido(APedido: TPedidoModel): Integer;
  end;

implementation

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Stan.Param,
  PedidoItemModel;

constructor TPedidoRepositorio.Create(const AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TPedidoRepositorio.GravarPedido(APedido: TPedidoModel): Integer;
var
  QryPedido, QryItem: TFDQuery;
  Item: TPedidoItemModel;
  NumeroPedido: Integer;
begin
  if not FConnection.Connected then
    FConnection.Connected := True;

  FConnection.StartTransaction;
  try
    QryPedido := TFDQuery.Create(nil);
    try
      QryPedido.Connection := FConnection;
      QryPedido.SQL.Text :=
        'INSERT INTO PEDIDO (DATA_EMISSAO, CODIGO_CLIENTE, VALOR_TOTAL) ' +
        'VALUES (:DATA_EMISSAO, :CODIGO_CLIENTE, :VALOR_TOTAL) ' +
        'RETURNING NUMERO_PEDIDO';
      QryPedido.ParamByName('DATA_EMISSAO').AsDateTime := APedido.DataEmissao;
      QryPedido.ParamByName('CODIGO_CLIENTE').AsInteger := APedido.CodigoCliente;
      QryPedido.ParamByName('VALOR_TOTAL').AsCurrency := APedido.ValorTotal;
      QryPedido.Open;
      NumeroPedido := QryPedido.FieldByName('NUMERO_PEDIDO').AsInteger;
      QryPedido.Close;
    finally
      QryPedido.Free;
    end;

    QryItem := TFDQuery.Create(nil);
    try
      QryItem.Connection := FConnection;
      QryItem.SQL.Text :=
        'INSERT INTO PEDIDO_ITEM (NUMERO_PEDIDO, CODIGO_PRODUTO, QUANTIDADE, VLR_UNITARIO, VLR_TOTAL) ' +
        'VALUES (:NUMERO_PEDIDO, :CODIGO_PRODUTO, :QUANTIDADE, :VLR_UNITARIO, :VLR_TOTAL)';
      for Item in APedido.Itens do
      begin
        QryItem.ParamByName('NUMERO_PEDIDO').AsInteger := NumeroPedido;
        QryItem.ParamByName('CODIGO_PRODUTO').AsInteger := Item.CodigoProduto;
        QryItem.ParamByName('QUANTIDADE').AsFloat := Item.Quantidade;
        QryItem.ParamByName('VLR_UNITARIO').AsCurrency := Item.VlrUnitario;
        QryItem.ParamByName('VLR_TOTAL').AsCurrency := Item.VlrTotal;
        QryItem.ExecSQL;
      end;
    finally
      QryItem.Free;
    end;

    FConnection.Commit;
    Result := NumeroPedido;
  except
    if FConnection.InTransaction then
      FConnection.Rollback;
    raise;
  end;
end;

end.
