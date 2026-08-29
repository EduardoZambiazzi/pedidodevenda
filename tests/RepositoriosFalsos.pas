unit RepositoriosFalsos;

{ Repositórios falsos (test doubles) usados pelos testes de unidade do
  Service, para não depender de banco de dados real. }

interface

uses
  System.Generics.Collections,
  ClienteModel,
  ProdutoModel,
  PedidoModel,
  ClienteRepositorioIntf,
  ProdutoRepositorioIntf,
  PedidoRepositorioIntf;

type
  TClienteRepositorioFalso = class(TInterfacedObject, IClienteRepositorio)
  private
    FClientes: TDictionary<Integer, TClienteModel>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Adicionar(const ACliente: TClienteModel);
    function BuscarPorCodigo(const ACodigo: Integer; out ACliente: TClienteModel): Boolean;
  end;

  TProdutoRepositorioFalso = class(TInterfacedObject, IProdutoRepositorio)
  private
    FProdutos: TDictionary<Integer, TProdutoModel>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Adicionar(const AProduto: TProdutoModel);
    function BuscarPorCodigo(const ACodigo: Integer; out AProduto: TProdutoModel): Boolean;
  end;

  TPedidoRepositorioFalso = class(TInterfacedObject, IPedidoRepositorio)
  private
    FProximoNumero: Integer;
  public
    UltimoPedidoGravado: TPedidoModel;
    QtdChamadasGravar: Integer;
    LancarExcecaoAoGravar: Boolean;
    constructor Create;
    function GravarPedido(APedido: TPedidoModel): Integer;
  end;

implementation

uses
  System.SysUtils;

{ TClienteRepositorioFalso }

constructor TClienteRepositorioFalso.Create;
begin
  inherited Create;
  FClientes := TDictionary<Integer, TClienteModel>.Create;
end;

destructor TClienteRepositorioFalso.Destroy;
begin
  FClientes.Free;
  inherited;
end;

procedure TClienteRepositorioFalso.Adicionar(const ACliente: TClienteModel);
begin
  FClientes.AddOrSetValue(ACliente.Codigo, ACliente);
end;

function TClienteRepositorioFalso.BuscarPorCodigo(const ACodigo: Integer; out ACliente: TClienteModel): Boolean;
begin
  Result := FClientes.TryGetValue(ACodigo, ACliente);
  if not Result then
    ACliente := TClienteModel.Vazio;
end;

{ TProdutoRepositorioFalso }

constructor TProdutoRepositorioFalso.Create;
begin
  inherited Create;
  FProdutos := TDictionary<Integer, TProdutoModel>.Create;
end;

destructor TProdutoRepositorioFalso.Destroy;
begin
  FProdutos.Free;
  inherited;
end;

procedure TProdutoRepositorioFalso.Adicionar(const AProduto: TProdutoModel);
begin
  FProdutos.AddOrSetValue(AProduto.Codigo, AProduto);
end;

function TProdutoRepositorioFalso.BuscarPorCodigo(const ACodigo: Integer; out AProduto: TProdutoModel): Boolean;
begin
  Result := FProdutos.TryGetValue(ACodigo, AProduto);
  if not Result then
    AProduto := TProdutoModel.Vazio;
end;

{ TPedidoRepositorioFalso }

constructor TPedidoRepositorioFalso.Create;
begin
  inherited Create;
  FProximoNumero := 1;
  QtdChamadasGravar := 0;
  LancarExcecaoAoGravar := False;
end;

function TPedidoRepositorioFalso.GravarPedido(APedido: TPedidoModel): Integer;
begin
  Inc(QtdChamadasGravar);
  if LancarExcecaoAoGravar then
    raise Exception.Create('Falha simulada ao gravar o pedido.');

  Result := FProximoNumero;
  Inc(FProximoNumero);
  APedido.NumeroPedido := Result;
  UltimoPedidoGravado := APedido;
end;

end.
