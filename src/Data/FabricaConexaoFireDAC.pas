unit FabricaConexaoFireDAC;

interface

uses
  FireDAC.Comp.Client,
  ConfiguracaoAplicacao;

type
  // Monta uma TFDConnection configurada dinamicamente a partir do config.ini,
  // sem depender de nenhuma conexão pré-desenhada em tempo de design.
  TFabricaConexaoFireDAC = class
  public
    class function CriarConexao(const AConfig: TConfiguracaoAplicacao): TFDConnection; static;
  end;

implementation

uses
  System.SysUtils,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.Stan.Def,
  FireDAC.Stan.Param,
  FireDAC.Stan.Async,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  FireDAC.UI.Intf,
  FireDAC.Comp.UI,
  FireDAC.Comp.DataSet;

class function TFabricaConexaoFireDAC.CriarConexao(const AConfig: TConfiguracaoAplicacao): TFDConnection;
begin
  Result := TFDConnection.Create(nil);
  try
    Result.LoginPrompt := False;
    // Sem nenhum componente GUIx (TFDGUIxWaitCursor/ErrorDialog/LoginDialog)
    // "solto" em um form, o FireDAC exige um deles para qualquer interação
    // gráfica interna. SilentMode desliga essa interação por completo -
    // o app trata erros e feedback ao usuário por conta própria (MessageDlg).
    Result.ResourceOptions.SilentMode := True;
    Result.Params.Clear;
    Result.Params.Values['DriverID'] := 'FB';
    Result.Params.Values['Database'] := AConfig.Database;
    Result.Params.Values['User_Name'] := AConfig.Username;
    Result.Params.Values['Password'] := AConfig.Password;
    Result.Params.Values['Server'] := AConfig.Server;
    Result.Params.Values['Port'] := IntToStr(AConfig.Port);
    Result.Params.Values['Protocol'] := 'TCPIP';
    Result.Params.Values['CharacterSet'] := 'UTF8';

    if AConfig.ClientLibrary <> '' then
      Result.Params.Values['VendorLib'] := AConfig.ClientLibrary;
  except
    Result.Free;
    raise;
  end;
end;

var
  // Como nenhum componente FireDAC é "solto" em um form (tudo é montado por
  // código), essa instância registra o provider GUIx de cursor de espera que
  // o FireDAC exige internamente - reforço para o SilentMode acima.
  GWaitCursor: TFDGUIxWaitCursor;

initialization
  GWaitCursor := TFDGUIxWaitCursor.Create(nil);

finalization
  GWaitCursor.Free;

end.
