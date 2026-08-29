unit ProdutoRepositorioIntf;

interface

uses
  ProdutoModel;

type
  IProdutoRepositorio = interface
    ['{B4F1D6A0-0002-4C1A-9C1A-1E2C3A4B5C02}']
    function BuscarPorCodigo(const ACodigo: Integer; out AProduto: TProdutoModel): Boolean;
  end;

implementation

end.
