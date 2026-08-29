unit PedidoVendaView;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.UITypes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids,
  FireDAC.Comp.Client,
  PedidoModel,
  PedidoServiceIntf;

type
  TFormPedidoVenda = class(TForm)
    grpCliente: TGroupBox;
    lblClienteCodigo: TLabel;
    edtClienteCodigo: TEdit;
    lblClienteNome: TLabel;
    edtClienteNome: TEdit;
    lblClienteCidade: TLabel;
    edtClienteCidade: TEdit;
    lblClienteUF: TLabel;
    edtClienteUF: TEdit;
    lblObservacao: TLabel;
    mmoObservacao: TMemo;
    grpItem: TGroupBox;
    lblProdutoCodigo: TLabel;
    edtProdutoCodigo: TEdit;
    lblProdutoDescricao: TLabel;
    edtProdutoDescricao: TEdit;
    lblQuantidade: TLabel;
    edtQuantidade: TEdit;
    lblValorUnitario: TLabel;
    edtValorUnitario: TEdit;
    btnInserirAtualizarItem: TButton;
    sgItens: TStringGrid;
    lblValorTotalCaption: TLabel;
    lblValorTotal: TLabel;
    btnGravarPedido: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edtClienteCodigoExit(Sender: TObject);
    procedure edtProdutoCodigoExit(Sender: TObject);
    procedure btnInserirAtualizarItemClick(Sender: TObject);
    procedure btnGravarPedidoClick(Sender: TObject);
    procedure sgItensKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FConnection: TFDConnection;
    FPedidoService: IPedidoService;
    FPedido: TPedidoModel;
    FIndiceEdicaoItem: Integer;
    procedure InicializarServicos;
    procedure ConfigurarGrid;
    procedure LimparCamposCliente;
    procedure LimparCamposItem;
    procedure AtualizarGrid;
    procedure AtualizarValorTotal;
    procedure CarregarItemParaEdicao(const ALinha: Integer);
    procedure ExcluirItem(const ALinha: Integer);
    procedure NovoPedido;
    procedure FocarCampoCliente;
  end;

var
  FormPedidoVenda: TFormPedidoVenda;

implementation

{$R *.dfm}

uses
  System.IOUtils,
  ConfiguracaoAplicacao,
  FabricaConexaoFireDAC,
  ClienteModel,
  ProdutoModel,
  PedidoItemModel,
  ClienteRepositorioIntf,
  ProdutoRepositorioIntf,
  PedidoRepositorioIntf,
  ClienteRepositorio,
  ProdutoRepositorio,
  PedidoRepositorio,
  PedidoExcecoes,
  PedidoService;

resourcestring
  StrFalhaAoInicializarConexao = 'Falha ao inicializar a conexão com o banco de dados:';
  StrCodigoDoClienteInvalido = 'Código do cliente inválido.';
  StrCodigoDoProdutoInvalido = 'Código do produto inválido.';
  StrInformeCodigoDeProdutoValido = 'Informe um código de produto válido.';
  StrQuantidadeInvalida = 'Quantidade inválida.';
  StrValorUnitarioInvalido = 'Valor unitário inválido.';
  StrConfirmaExclusaoDoItem = 'Confirma a exclusão do item selecionado?';
  StrInformeClienteValidoAntesDeGravar = 'Informe um cliente válido antes de gravar o pedido.';
  StrIncluaPeloMenosUmItemAntesDeGravar = 'Inclua pelo menos um item antes de gravar o pedido.';
  StrErroAoGravarPedido = 'Erro ao gravar o pedido:';
  StrFmtPedidoGravadoComSucesso = 'Pedido número %d gravado com sucesso.';

const
  COL_CODIGO = 0;
  COL_DESCRICAO = 1;
  COL_QUANTIDADE = 2;
  COL_VLR_UNITARIO = 3;
  COL_VLR_TOTAL = 4;

{ TFormPedidoVenda }

procedure TFormPedidoVenda.FormCreate(Sender: TObject);
begin
  try
    InicializarServicos;
  except
    on E: Exception do
    begin
      MessageDlg(StrFalhaAoInicializarConexao + sLineBreak + E.Message,
        mtError, [mbOK], 0);
      Application.Terminate;
      Exit;
    end;
  end;

  ConfigurarGrid;
  NovoPedido;
end;

procedure TFormPedidoVenda.FormShow(Sender: TObject);
begin
  FocarCampoCliente;
end;

procedure TFormPedidoVenda.FormDestroy(Sender: TObject);
begin
  FPedido.Free;
  FConnection.Free;
end;

procedure TFormPedidoVenda.InicializarServicos;
var
  CaminhoIni: string;
  Config: TConfiguracaoAplicacao;
  ClienteRepo: IClienteRepositorio;
  ProdutoRepo: IProdutoRepositorio;
  PedidoRepo: IPedidoRepositorio;
begin
  CaminhoIni := TPath.Combine(ExtractFilePath(ParamStr(0)), 'config.ini');
  Config := TConfiguracaoAplicacao.CarregarDeArquivo(CaminhoIni);

  FConnection := TFabricaConexaoFireDAC.CriarConexao(Config);
  FConnection.Connected := True;

  ClienteRepo := TClienteRepositorio.Create(FConnection);
  ProdutoRepo := TProdutoRepositorio.Create(FConnection);
  PedidoRepo := TPedidoRepositorio.Create(FConnection);

  FPedidoService := TPedidoService.Create(ClienteRepo, ProdutoRepo, PedidoRepo);
end;

procedure TFormPedidoVenda.ConfigurarGrid;
begin
  sgItens.ColCount := 5;
  sgItens.FixedCols := 0;
  sgItens.FixedRows := 1;
  sgItens.RowCount := 1;
  sgItens.Options := sgItens.Options + [goRowSelect];

  sgItens.ColWidths[COL_CODIGO] := 90;
  sgItens.ColWidths[COL_DESCRICAO] := 380;
  sgItens.ColWidths[COL_QUANTIDADE] := 90;
  sgItens.ColWidths[COL_VLR_UNITARIO] := 110;
  sgItens.ColWidths[COL_VLR_TOTAL] := 110;

  sgItens.Cells[COL_CODIGO, 0] := 'Cód. Produto';
  sgItens.Cells[COL_DESCRICAO, 0] := 'Descrição';
  sgItens.Cells[COL_QUANTIDADE, 0] := 'Quantidade';
  sgItens.Cells[COL_VLR_UNITARIO, 0] := 'Vlr. Unitário';
  sgItens.Cells[COL_VLR_TOTAL, 0] := 'Vlr. Total';
end;

procedure TFormPedidoVenda.NovoPedido;
begin
  FPedido.Free;
  FPedido := TPedidoModel.Create;
  FIndiceEdicaoItem := -1;

  edtClienteCodigo.Text := '';
  mmoObservacao.Text := '';
  LimparCamposCliente;
  LimparCamposItem;
  AtualizarGrid;
  AtualizarValorTotal;
end;

procedure TFormPedidoVenda.FocarCampoCliente;
begin
  if edtClienteCodigo.CanFocus then
    edtClienteCodigo.SetFocus;
end;

procedure TFormPedidoVenda.LimparCamposCliente;
begin
  edtClienteNome.Text := '';
  edtClienteCidade.Text := '';
  edtClienteUF.Text := '';
end;

procedure TFormPedidoVenda.LimparCamposItem;
begin
  edtProdutoCodigo.Text := '';
  edtProdutoDescricao.Text := '';
  edtQuantidade.Text := '';
  edtValorUnitario.Text := '';
  FIndiceEdicaoItem := -1;
end;

procedure TFormPedidoVenda.edtClienteCodigoExit(Sender: TObject);
var
  Codigo: Integer;
  Cliente: TClienteModel;
begin
  if Trim(edtClienteCodigo.Text) = '' then
  begin
    LimparCamposCliente;
    FPedido.CodigoCliente := 0;
    Exit;
  end;

  if not TryStrToInt(Trim(edtClienteCodigo.Text), Codigo) then
  begin
    LimparCamposCliente;
    FPedido.CodigoCliente := 0;
    MessageDlg(StrCodigoDoClienteInvalido, mtWarning, [mbOK], 0);
    Exit;
  end;

  try
    Cliente := FPedidoService.BuscarCliente(Codigo);
    edtClienteNome.Text := Cliente.Nome;
    edtClienteCidade.Text := Cliente.Cidade;
    edtClienteUF.Text := Cliente.UF;
    FPedido.CodigoCliente := Cliente.Codigo;
    FPedido.NomeCliente := Cliente.Nome;
    FPedido.CidadeCliente := Cliente.Cidade;
    FPedido.UfCliente := Cliente.UF;
  except
    on E: EClienteNaoEncontrado do
    begin
      LimparCamposCliente;
      FPedido.CodigoCliente := 0;
      MessageDlg(E.Message, mtWarning, [mbOK], 0);
    end;
  end;
end;

procedure TFormPedidoVenda.edtProdutoCodigoExit(Sender: TObject);
var
  Codigo: Integer;
  Produto: TProdutoModel;
begin
  if Trim(edtProdutoCodigo.Text) = '' then
  begin
    edtProdutoDescricao.Text := '';
    edtValorUnitario.Text := '';
    Exit;
  end;

  if not TryStrToInt(Trim(edtProdutoCodigo.Text), Codigo) then
  begin
    edtProdutoDescricao.Text := '';
    edtValorUnitario.Text := '';
    MessageDlg(StrCodigoDoProdutoInvalido, mtWarning, [mbOK], 0);
    Exit;
  end;

  try
    Produto := FPedidoService.BuscarProduto(Codigo);
    edtProdutoDescricao.Text := Produto.Descricao;
    edtValorUnitario.Text := FormatFloat('0.00', Produto.PrecoVenda);
  except
    on E: EProdutoNaoEncontrado do
    begin
      edtProdutoDescricao.Text := '';
      edtValorUnitario.Text := '';
      MessageDlg(E.Message, mtWarning, [mbOK], 0);
    end;
  end;
end;

procedure TFormPedidoVenda.btnInserirAtualizarItemClick(Sender: TObject);
var
  CodigoProduto: Integer;
  Quantidade: Double;
  ValorUnitario: Currency;
begin
  if (not TryStrToInt(Trim(edtProdutoCodigo.Text), CodigoProduto)) or (Trim(edtProdutoDescricao.Text) = '') then
  begin
    MessageDlg(StrInformeCodigoDeProdutoValido, mtWarning, [mbOK], 0);
    Exit;
  end;

  if not TryStrToFloat(Trim(edtQuantidade.Text), Quantidade) then
  begin
    MessageDlg(StrQuantidadeInvalida, mtWarning, [mbOK], 0);
    Exit;
  end;

  if not TryStrToCurr(Trim(edtValorUnitario.Text), ValorUnitario) then
  begin
    MessageDlg(StrValorUnitarioInvalido, mtWarning, [mbOK], 0);
    Exit;
  end;

  try
    FPedidoService.AdicionarOuAtualizarItem(FPedido, FIndiceEdicaoItem, CodigoProduto,
      edtProdutoDescricao.Text, Quantidade, ValorUnitario);
  except
    on E: EItemQuantidadeInvalida do
    begin
      MessageDlg(E.Message, mtWarning, [mbOK], 0);
      Exit;
    end;
    on E: EItemValorUnitarioInvalido do
    begin
      MessageDlg(E.Message, mtWarning, [mbOK], 0);
      Exit;
    end;
    on E: EItemIndiceInvalido do
    begin
      MessageDlg(E.Message, mtWarning, [mbOK], 0);
      Exit;
    end;
  end;

  AtualizarGrid;
  AtualizarValorTotal;
  LimparCamposItem;
  if edtProdutoCodigo.CanFocus then
    edtProdutoCodigo.SetFocus;
end;

procedure TFormPedidoVenda.sgItensKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if sgItens.Row < 1 then
    Exit;

  case Key of
    VK_RETURN:
      begin
        CarregarItemParaEdicao(sgItens.Row);
        Key := 0;
      end;
    VK_DELETE:
      begin
        ExcluirItem(sgItens.Row);
        Key := 0;
      end;
  end;
end;

procedure TFormPedidoVenda.CarregarItemParaEdicao(const ALinha: Integer);
var
  Item: TPedidoItemModel;
begin
  if (ALinha < 1) or (ALinha > FPedido.Itens.Count) then
    Exit;

  Item := FPedido.Itens[ALinha - 1];
  FIndiceEdicaoItem := ALinha - 1;

  edtProdutoCodigo.Text := IntToStr(Item.CodigoProduto);
  edtProdutoDescricao.Text := Item.DescricaoProduto;
  edtQuantidade.Text := FormatFloat('0.00', Item.Quantidade);
  edtValorUnitario.Text := FormatFloat('0.00', Item.VlrUnitario);

  if edtQuantidade.CanFocus then
    edtQuantidade.SetFocus;
end;

procedure TFormPedidoVenda.ExcluirItem(const ALinha: Integer);
begin
  if (ALinha < 1) or (ALinha > FPedido.Itens.Count) then
    Exit;

  if MessageDlg(StrConfirmaExclusaoDoItem, mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  FPedidoService.RemoverItem(FPedido, ALinha - 1);

  if FIndiceEdicaoItem = ALinha - 1 then
    LimparCamposItem;

  AtualizarGrid;
  AtualizarValorTotal;
end;

procedure TFormPedidoVenda.AtualizarGrid;
var
  Item: TPedidoItemModel;
begin
  sgItens.RowCount := FPedido.Itens.Count + 1;

  for var I := 0 to FPedido.Itens.Count - 1 do
  begin
    Item := FPedido.Itens[I];
    sgItens.Cells[COL_CODIGO, I + 1] := IntToStr(Item.CodigoProduto);
    sgItens.Cells[COL_DESCRICAO, I + 1] := Item.DescricaoProduto;
    sgItens.Cells[COL_QUANTIDADE, I + 1] := FormatFloat('0.00', Item.Quantidade);
    sgItens.Cells[COL_VLR_UNITARIO, I + 1] := FormatFloat('0.00', Item.VlrUnitario);
    sgItens.Cells[COL_VLR_TOTAL, I + 1] := FormatFloat('0.00', Item.VlrTotal);
  end;

  if FPedido.Itens.Count > 0 then
    sgItens.FixedRows := 1;
end;

procedure TFormPedidoVenda.AtualizarValorTotal;
begin
  lblValorTotal.Caption := FormatCurr('#,##0.00', FPedido.ValorTotal);
end;

procedure TFormPedidoVenda.btnGravarPedidoClick(Sender: TObject);
var
  NumeroPedido: Integer;
begin
  FPedido.Observacao := Trim(mmoObservacao.Text);
  try
    NumeroPedido := FPedidoService.GravarPedido(FPedido);
  except
    on E: EClienteNaoEncontrado do
    begin
      MessageDlg(StrInformeClienteValidoAntesDeGravar, mtWarning, [mbOK], 0);
      Exit;
    end;
    on E: EPedidoSemItens do
    begin
      MessageDlg(StrIncluaPeloMenosUmItemAntesDeGravar, mtWarning, [mbOK], 0);
      Exit;
    end;
    on E: Exception do
    begin
      MessageDlg(StrErroAoGravarPedido + sLineBreak + E.Message, mtError, [mbOK], 0);
      Exit;
    end;
  end;

  MessageDlg(Format(StrFmtPedidoGravadoComSucesso, [NumeroPedido]), mtInformation, [mbOK], 0);
  NovoPedido;
  FocarCampoCliente;
end;

end.
