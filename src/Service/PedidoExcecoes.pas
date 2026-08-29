unit PedidoExcecoes;

interface

uses
  System.SysUtils;

type
  EClienteNaoEncontrado = class(Exception)
  public
    constructor CreateComCodigo(const ACodigo: Integer);
  end;

  EProdutoNaoEncontrado = class(Exception)
  public
    constructor CreateComCodigo(const ACodigo: Integer);
  end;

  EPedidoSemItens = class(Exception);
  EItemQuantidadeInvalida = class(Exception);
  EItemValorUnitarioInvalido = class(Exception);
  EItemIndiceInvalido = class(Exception);

implementation

resourcestring
  StrFmtClienteNaoEncontrado = 'Cliente código %d não encontrado.';
  StrFmtProdutoNaoEncontrado = 'Produto código %d não encontrado.';

{ EClienteNaoEncontrado }

constructor EClienteNaoEncontrado.CreateComCodigo(const ACodigo: Integer);
begin
  inherited CreateFmt(StrFmtClienteNaoEncontrado, [ACodigo]);
end;

{ EProdutoNaoEncontrado }

constructor EProdutoNaoEncontrado.CreateComCodigo(const ACodigo: Integer);
begin
  inherited CreateFmt(StrFmtProdutoNaoEncontrado, [ACodigo]);
end;

end.
