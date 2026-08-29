program PedidoVenda;

uses
  Vcl.Forms,
  PedidoVendaView in 'src\View\PedidoVendaView.pas' {FormPedidoVenda},
  ClienteModel in 'src\Model\ClienteModel.pas',
  ProdutoModel in 'src\Model\ProdutoModel.pas',
  PedidoModel in 'src\Model\PedidoModel.pas',
  PedidoItemModel in 'src\Model\PedidoItemModel.pas',
  PedidoExcecoes in 'src\Service\PedidoExcecoes.pas',
  PedidoServiceIntf in 'src\Service\PedidoServiceIntf.pas',
  PedidoService in 'src\Service\PedidoService.pas',
  ClienteRepositorioIntf in 'src\Repository\ClienteRepositorioIntf.pas',
  ProdutoRepositorioIntf in 'src\Repository\ProdutoRepositorioIntf.pas',
  PedidoRepositorioIntf in 'src\Repository\PedidoRepositorioIntf.pas',
  ClienteRepositorio in 'src\Repository\ClienteRepositorio.pas',
  ProdutoRepositorio in 'src\Repository\ProdutoRepositorio.pas',
  PedidoRepositorio in 'src\Repository\PedidoRepositorio.pas',
  ConfiguracaoAplicacao in 'src\Data\ConfiguracaoAplicacao.pas',
  FabricaConexaoFireDAC in 'src\Data\FabricaConexaoFireDAC.pas';

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormPedidoVenda, FormPedidoVenda);
  Application.Run;
end.
