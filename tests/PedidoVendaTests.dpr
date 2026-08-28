program PedidoVendaTests;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
  DUnitX.Loggers.Console,
  DUnitX.TestFramework,
  PedidoModelTests in 'PedidoModelTests.pas',
  RepositoriosFalsos in 'RepositoriosFalsos.pas',
  PedidoServiceTests in 'PedidoServiceTests.pas',
  ConfiguracaoAplicacaoTests in 'ConfiguracaoAplicacaoTests.pas',
  RepositoriosIntegracaoTests in 'RepositoriosIntegracaoTests.pas',
  ClienteModel in '..\src\Model\ClienteModel.pas',
  ProdutoModel in '..\src\Model\ProdutoModel.pas',
  PedidoModel in '..\src\Model\PedidoModel.pas',
  PedidoItemModel in '..\src\Model\PedidoItemModel.pas',
  PedidoExcecoes in '..\src\Service\PedidoExcecoes.pas',
  PedidoServiceIntf in '..\src\Service\PedidoServiceIntf.pas',
  PedidoService in '..\src\Service\PedidoService.pas',
  ClienteRepositorioIntf in '..\src\Repository\ClienteRepositorioIntf.pas',
  ProdutoRepositorioIntf in '..\src\Repository\ProdutoRepositorioIntf.pas',
  PedidoRepositorioIntf in '..\src\Repository\PedidoRepositorioIntf.pas',
  ClienteRepositorio in '..\src\Repository\ClienteRepositorio.pas',
  ProdutoRepositorio in '..\src\Repository\ProdutoRepositorio.pas',
  PedidoRepositorio in '..\src\Repository\PedidoRepositorio.pas',
  ConfiguracaoAplicacao in '..\src\Data\ConfiguracaoAplicacao.pas',
  FabricaConexaoFireDAC in '..\src\Data\FabricaConexaoFireDAC.pas';

var
  Runner: ITestRunner;
  Results: IRunResults;
  Logger: ITestLogger;
begin
  try
    Runner := TDUnitX.CreateRunner;
    Runner.UseRTTI := True;
    Logger := TDUnitXConsoleLogger.Create(True);
    Runner.AddLogger(Logger);
    Runner.FailsOnNoAsserts := False;

    Results := Runner.Execute;

    if not Results.AllPassed then
      System.ExitCode := 1;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

  Write('Pressione ENTER para sair...');
  Readln;
end.
