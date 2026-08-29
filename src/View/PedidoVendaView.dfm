object FormPedidoVenda: TFormPedidoVenda
  Left = 0
  Top = 0
  Caption = 'Pedido de Venda'
  ClientHeight = 625
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  Visible = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    900
    625)
  TextHeight = 15
  object lblValorTotalCaption: TLabel
    Left = 560
    Top = 555
    Width = 115
    Height = 15
    Anchors = [akRight, akBottom]
    Caption = 'Valor Total do Pedido:'
  end
  object lblValorTotal: TLabel
    Left = 740
    Top = 553
    Width = 31
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '0,00'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object grpCliente: TGroupBox
    Left = 8
    Top = 8
    Width = 884
    Height = 115
    Caption = ' Cliente '
    TabOrder = 0
    object lblClienteCodigo: TLabel
      Left = 16
      Top = 28
      Width = 42
      Height = 15
      Caption = 'C'#243'digo:'
    end
    object lblClienteNome: TLabel
      Left = 180
      Top = 28
      Width = 36
      Height = 15
      Caption = 'Nome:'
    end
    object lblClienteCidade: TLabel
      Left = 500
      Top = 28
      Width = 40
      Height = 15
      Caption = 'Cidade:'
    end
    object lblClienteUF: TLabel
      Left = 725
      Top = 28
      Width = 17
      Height = 15
      Caption = 'UF:'
    end
    object lblObservacao: TLabel
      Left = 16
      Top = 60
      Width = 65
      Height = 15
      Caption = 'Observa'#231#227'o:'
    end
    object edtClienteCodigo: TEdit
      Left = 80
      Top = 24
      Width = 80
      Height = 23
      TabOrder = 0
      OnExit = edtClienteCodigoExit
    end
    object edtClienteNome: TEdit
      Left = 230
      Top = 24
      Width = 260
      Height = 23
      TabStop = False
      ReadOnly = True
      TabOrder = 1
    end
    object edtClienteCidade: TEdit
      Left = 555
      Top = 24
      Width = 160
      Height = 23
      TabStop = False
      ReadOnly = True
      TabOrder = 2
    end
    object edtClienteUF: TEdit
      Left = 755
      Top = 24
      Width = 40
      Height = 23
      TabStop = False
      ReadOnly = True
      TabOrder = 3
    end
    object mmoObservacao: TMemo
      Left = 100
      Top = 56
      Width = 768
      Height = 48
      MaxLength = 200
      ScrollBars = ssVertical
      TabOrder = 4
    end
  end
  object grpItem: TGroupBox
    Left = 8
    Top = 131
    Width = 884
    Height = 90
    Caption = ' Item do Pedido '
    TabOrder = 1
    object lblProdutoCodigo: TLabel
      Left = 16
      Top = 28
      Width = 105
      Height = 15
      Caption = 'C'#243'digo do Produto:'
    end
    object lblProdutoDescricao: TLabel
      Left = 230
      Top = 28
      Width = 54
      Height = 15
      Caption = 'Descri'#231#227'o:'
    end
    object lblQuantidade: TLabel
      Left = 590
      Top = 28
      Width = 65
      Height = 15
      Caption = 'Quantidade:'
    end
    object lblValorUnitario: TLabel
      Left = 16
      Top = 60
      Width = 74
      Height = 15
      Caption = 'Valor Unit'#225'rio:'
    end
    object edtProdutoCodigo: TEdit
      Left = 140
      Top = 24
      Width = 80
      Height = 23
      TabOrder = 0
      OnExit = edtProdutoCodigoExit
    end
    object edtProdutoDescricao: TEdit
      Left = 300
      Top = 24
      Width = 280
      Height = 23
      TabStop = False
      ReadOnly = True
      TabOrder = 1
    end
    object edtQuantidade: TEdit
      Left = 660
      Top = 24
      Width = 70
      Height = 23
      TabOrder = 2
    end
    object edtValorUnitario: TEdit
      Left = 140
      Top = 56
      Width = 100
      Height = 23
      TabOrder = 3
    end
    object btnInserirAtualizarItem: TButton
      Left = 660
      Top = 54
      Width = 150
      Height = 27
      Caption = 'Inserir/Atualizar Item'
      TabOrder = 4
      OnClick = btnInserirAtualizarItemClick
    end
  end
  object sgItens: TStringGrid
    Left = 8
    Top = 229
    Width = 884
    Height = 318
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    OnKeyDown = sgItensKeyDown
  end
  object btnGravarPedido: TButton
    Left = 780
    Top = 585
    Width = 112
    Height = 32
    Anchors = [akRight, akBottom]
    Caption = 'Gravar Pedido'
    TabOrder = 3
    OnClick = btnGravarPedidoClick
  end
end
