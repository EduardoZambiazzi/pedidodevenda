unit ProdutoRepositorio;

interface

uses
  FireDAC.Comp.Client,
  ProdutoModel,
  ProdutoRepositorioIntf;

type
  TProdutoRepositorio = class(TInterfacedObject, IProdutoRepositorio)
  private
    FConnection: TFDConnection;
  public
    constructor Create(const AConnection: TFDConnection);
    function BuscarPorCodigo(const ACodigo: Integer; out AProduto: TProdutoModel): Boolean;
  end;

implementation

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Stan.Param;

constructor TProdutoRepositorio.Create(const AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TProdutoRepositorio.BuscarPorCodigo(const ACodigo: Integer; out AProduto: TProdutoModel): Boolean;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Text := 'SELECT CODIGO, DESCRICAO, PRECO_VENDA FROM PRODUTO WHERE CODIGO = :CODIGO';
    Qry.ParamByName('CODIGO').AsInteger := ACodigo;
    Qry.Open;
    try
      Result := not Qry.Eof;
      if Result then
        AProduto := TProdutoModel.Create(
          Qry.FieldByName('CODIGO').AsInteger,
          Trim(Qry.FieldByName('DESCRICAO').AsString),
          Qry.FieldByName('PRECO_VENDA').AsCurrency)
      else
        AProduto := TProdutoModel.Vazio;
    finally
      Qry.Close;
    end;
  finally
    Qry.Free;
  end;
end;

end.
