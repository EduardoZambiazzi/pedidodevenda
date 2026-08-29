unit ClienteRepositorioIntf;

interface

uses
  ClienteModel;

type
  IClienteRepositorio = interface
    ['{B4F1D6A0-0001-4C1A-9C1A-1E2C3A4B5C01}']
    function BuscarPorCodigo(const ACodigo: Integer; out ACliente: TClienteModel): Boolean;
  end;

implementation

end.
