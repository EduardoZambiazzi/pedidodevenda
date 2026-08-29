unit ConfiguracaoAplicacaoTests;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TConfiguracaoAplicacaoTests = class
  private
    FArquivoIni: string;
    procedure EscreverIni(const AConteudo: string);
  public
    [TearDown]
    procedure TearDown;

    [Test]
    procedure SeArquivoNaoExiste_CarregarDeArquivoLevantarExcecao;

    [Test]
    procedure ComTodasAsChavesPreenchidas_CarregarDeArquivoLerTodosOsValores;

    [Test]
    procedure SemPathDoBancoNoIni_CarregarDeArquivoLevantarExcecao;

    [Test]
    procedure SemServerNemPortNoIni_CarregarDeArquivoUsarValoresPadrao;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  ConfiguracaoAplicacao;

procedure TConfiguracaoAplicacaoTests.EscreverIni(const AConteudo: string);
begin
  FArquivoIni := TPath.Combine(TPath.GetTempPath, 'pedidovenda_test_' + TGuid.NewGuid.ToString + '.ini');
  TFile.WriteAllText(FArquivoIni, AConteudo);
end;

procedure TConfiguracaoAplicacaoTests.TearDown;
begin
  if (FArquivoIni <> '') and TFile.Exists(FArquivoIni) then
    TFile.Delete(FArquivoIni);
  FArquivoIni := '';
end;

procedure TConfiguracaoAplicacaoTests.SeArquivoNaoExiste_CarregarDeArquivoLevantarExcecao;
begin
  Assert.WillRaise(
    procedure begin TConfiguracaoAplicacao.CarregarDeArquivo('C:\arquivo\que\nao\existe.ini'); end,
    Exception);
end;

procedure TConfiguracaoAplicacaoTests.ComTodasAsChavesPreenchidas_CarregarDeArquivoLerTodosOsValores;
var
  Config: TConfiguracaoAplicacao;
begin
  EscreverIni(
    '[Database]' + sLineBreak +
    'Path=C:\Bases\PEDIDOVENDA.FDB' + sLineBreak +
    'Username=SYSDBA' + sLineBreak +
    'Password=masterkey' + sLineBreak +
    'Server=localhost' + sLineBreak +
    'Port=3053' + sLineBreak +
    'ClientLibrary=C:\Firebird\fbclient.dll');

  Config := TConfiguracaoAplicacao.CarregarDeArquivo(FArquivoIni);

  Assert.AreEqual('C:\Bases\PEDIDOVENDA.FDB', Config.Database);
  Assert.AreEqual('SYSDBA', Config.Username);
  Assert.AreEqual('masterkey', Config.Password);
  Assert.AreEqual('localhost', Config.Server);
  Assert.AreEqual(3053, Config.Port);
  Assert.AreEqual('C:\Firebird\fbclient.dll', Config.ClientLibrary);
end;

procedure TConfiguracaoAplicacaoTests.SemPathDoBancoNoIni_CarregarDeArquivoLevantarExcecao;
begin
  EscreverIni('[Database]' + sLineBreak + 'Username=SYSDBA');

  Assert.WillRaise(
    procedure begin TConfiguracaoAplicacao.CarregarDeArquivo(FArquivoIni); end,
    Exception);
end;

procedure TConfiguracaoAplicacaoTests.SemServerNemPortNoIni_CarregarDeArquivoUsarValoresPadrao;
var
  Config: TConfiguracaoAplicacao;
begin
  EscreverIni('[Database]' + sLineBreak + 'Path=C:\Bases\PEDIDOVENDA.FDB');

  Config := TConfiguracaoAplicacao.CarregarDeArquivo(FArquivoIni);

  Assert.AreEqual('localhost', Config.Server);
  Assert.AreEqual(3050, Config.Port);
end;

initialization
  TDUnitX.RegisterTestFixture(TConfiguracaoAplicacaoTests);

end.
