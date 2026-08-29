unit ClienteRepositorio;

interface

uses
  FireDAC.Comp.Client,
  ClienteModel,
  ClienteRepositorioIntf;

type
  TClienteRepositorio = class(TInterfacedObject, IClienteRepositorio)
  private
    FConnection: TFDConnection;
  public
    constructor Create(const AConnection: TFDConnection);
    function BuscarPorCodigo(const ACodigo: Integer; out ACliente: TClienteModel): Boolean;
  end;

implementation

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Stan.Param;

constructor TClienteRepositorio.Create(const AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TClienteRepositorio.BuscarPorCodigo(const ACodigo: Integer; out ACliente: TClienteModel): Boolean;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Text := 'SELECT CODIGO, NOME, CIDADE, UF FROM CLIENTE WHERE CODIGO = :CODIGO';
    Qry.ParamByName('CODIGO').AsInteger := ACodigo;
    Qry.Open;
    try
      Result := not Qry.Eof;
      if Result then
        ACliente := TClienteModel.Create(
          Qry.FieldByName('CODIGO').AsInteger,
          Trim(Qry.FieldByName('NOME').AsString),
          Trim(Qry.FieldByName('CIDADE').AsString),
          Trim(Qry.FieldByName('UF').AsString))
      else
        ACliente := TClienteModel.Vazio;
    finally
      Qry.Close;
    end;
  finally
    Qry.Free;
  end;
end;

end.
