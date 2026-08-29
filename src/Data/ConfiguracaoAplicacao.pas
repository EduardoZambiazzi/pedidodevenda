unit ConfiguracaoAplicacao;

interface

type
  // Configuração de acesso ao banco lida do config.ini (seção [Database]).
  TConfiguracaoAplicacao = record
    Database: string;      // caminho do .fdb
    Username: string;
    Password: string;
    Server: string;
    Port: Integer;
    ClientLibrary: string; // caminho do fbclient.dll
    class function CarregarDeArquivo(const ACaminhoIni: string): TConfiguracaoAplicacao; static;
  end;

implementation

uses
  System.SysUtils,
  System.IniFiles;

resourcestring
  StrFmtArquivoDeConfiguracaoNaoEncontrado = 'Arquivo de configuração não encontrado: %s';
  StrFmtConfiguracaoInvalida = 'Configuração inválida em %s: [Database] Path não informado.';

class function TConfiguracaoAplicacao.CarregarDeArquivo(const ACaminhoIni: string): TConfiguracaoAplicacao;
var
  Ini: TIniFile;
begin
  if not FileExists(ACaminhoIni) then
    raise Exception.CreateFmt(StrFmtArquivoDeConfiguracaoNaoEncontrado, [ACaminhoIni]);

  Ini := TIniFile.Create(ACaminhoIni);
  try
    Result.Database := Ini.ReadString('Database', 'Path', '');
    Result.Username := Ini.ReadString('Database', 'Username', '');
    Result.Password := Ini.ReadString('Database', 'Password', '');
    Result.Server := Ini.ReadString('Database', 'Server', 'localhost');
    Result.Port := Ini.ReadInteger('Database', 'Port', 3050);
    Result.ClientLibrary := Ini.ReadString('Database', 'ClientLibrary', '');
  finally
    Ini.Free;
  end;

  if Result.Database = '' then
    raise Exception.CreateFmt(StrFmtConfiguracaoInvalida, [ACaminhoIni]);
end;

end.
