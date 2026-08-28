unit ProdutoModel;

interface

type
  TProdutoModel = record
    Codigo: Integer;
    Descricao: string;
    PrecoVenda: Currency;
    constructor Create(const ACodigo: Integer; const ADescricao: string; const APrecoVenda: Currency);
    class function Vazio: TProdutoModel; static;
  end;

implementation

constructor TProdutoModel.Create(const ACodigo: Integer; const ADescricao: string; const APrecoVenda: Currency);
begin
  Codigo := ACodigo;
  Descricao := ADescricao;
  PrecoVenda := APrecoVenda;
end;

class function TProdutoModel.Vazio: TProdutoModel;
begin
  Result.Codigo := 0;
  Result.Descricao := '';
  Result.PrecoVenda := 0;
end;

end.
