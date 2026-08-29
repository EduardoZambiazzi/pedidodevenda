unit PedidoRepositorioIntf;

interface

uses
  PedidoModel;

type
  IPedidoRepositorio = interface
    ['{B4F1D6A0-0003-4C1A-9C1A-1E2C3A4B5C03}']
    // Grava cabeçalho + itens em uma única transação (commit/rollback) e
    // devolve o NUMERO_PEDIDO gerado pelo banco.
    function GravarPedido(APedido: TPedidoModel): Integer;
  end;

implementation

end.
