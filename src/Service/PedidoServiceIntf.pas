unit PedidoServiceIntf;

interface

uses
  ClienteModel,
  ProdutoModel,
  PedidoModel;

type
  // Regras de negócio do Pedido de Venda. Não conhece FireDAC nem UI: recebe
  // e devolve apenas Model. Isso permite testar 100% das regras com
  // repositórios falsos (fakes), sem depender de banco de dados.
  IPedidoService = interface
    ['{C3D2E1F0-0001-4A1B-9C1A-2B3C4D5E6F01}']

    // Lança EClienteNaoEncontrado se o código não existir.
    function BuscarCliente(const ACodigo: Integer): TClienteModel;

    // Lança EProdutoNaoEncontrado se o código não existir.
    function BuscarProduto(const ACodigo: Integer): TProdutoModel;

    function CalcularVlrTotalItem(const AQuantidade: Double; const AVlrUnitario: Currency): Currency;

    // AIndiceEdicao = -1 insere um item novo no pedido.
    // AIndiceEdicao >= 0 atualiza o item nessa posição (fluxo do ENTER no grid).
    procedure AdicionarOuAtualizarItem(APedido: TPedidoModel; const AIndiceEdicao: Integer;
      const ACodigoProduto: Integer; const ADescricaoProduto: string;
      const AQuantidade: Double; const AVlrUnitario: Currency);

    // Lança EItemIndiceInvalido se o índice estiver fora dos limites.
    procedure RemoverItem(APedido: TPedidoModel; const AIndice: Integer);

    // Lança EClienteNaoEncontrado / EPedidoSemItens se o pedido for inválido.
    // Delega a persistência (transação/commit/rollback) ao IPedidoRepositorio.
    function GravarPedido(APedido: TPedidoModel): Integer;
  end;

implementation

end.
