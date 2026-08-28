unit ClienteModel;

interface

type
  TClienteModel = record
    Codigo: Integer;
    Nome: string;
    Cidade: string;
    UF: string;
    constructor Create(const ACodigo: Integer; const ANome, ACidade, AUF: string);
    class function Vazio: TClienteModel; static;
  end;

implementation

constructor TClienteModel.Create(const ACodigo: Integer; const ANome, ACidade, AUF: string);
begin
  Codigo := ACodigo;
  Nome := ANome;
  Cidade := ACidade;
  UF := AUF;
end;

class function TClienteModel.Vazio: TClienteModel;
begin
  Result.Codigo := 0;
  Result.Nome := '';
  Result.Cidade := '';
  Result.UF := '';
end;

end.
