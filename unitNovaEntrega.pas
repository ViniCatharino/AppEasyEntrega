unit unitNovaEntrega;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.TabControl, core.Utils.Tipos, FMX.DialogService,FMX.Platform,
  FMX.Clipboard, System.Messaging;

type
  TfrmNovaEntrega = class(TForm)
    lblTitulo: TLabel;
    btnVoltar: TImage;
    TabControl1: TTabControl;
    tab1: TTabItem;
    tab2: TTabItem;
    tabEnviado: TTabItem;
    Layout1: TLayout;
    edtNome: TEdit;
    lblNome: TLabel;
    edtTelefone: TEdit;
    lblTelefone: TLabel;
    edtEndereco: TEdit;
    Label1: TLabel;
    edtBateria: TEdit;
    Label2: TLabel;
    Layout2: TLayout;
    Label3: TLabel;
    edtObservacao: TEdit;
    Label4: TLabel;
    edtPagamento: TEdit;
    Label6: TLabel;
    edtValor: TEdit;
    Label5: TLabel;
    edtVeiculo: TEdit;
    Label7: TLabel;
    GroupTipoServico: TGroupBox;
    btnEntrega: TRadioButton;
    btnAnotacao: TRadioButton;
    btnOutros: TRadioButton;
    btnGarantia: TRadioButton;
    LytBotoes: TLayout;
    rectVoltar: TRectangle;
    rectBtnProximo: TRectangle;
    btnBack: TSpeedButton;
    btnProximo: TSpeedButton;
    rectMensagem: TRectangle;
    Label8: TLabel;
    imgLogo: TImage;
    Timer1: TTimer;
    procedure btnVoltarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSalvarClick;
    procedure Timer1Timer(Sender: TObject);
    procedure btnProximoClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private

    procedure LimparCampos;
    procedure SelecionarTab(ATag: Integer);
    procedure RefreshInserirEntrega;
    procedure controlTab2;
    procedure TerminateEntrega(Sender: Tobject);
    procedure RefreshEditarEntrega;
    procedure RefreshListarEntrega;
    procedure TermianteListarEntregaPorId(Sender: Tobject);
    { Private declarations }
  public
    { Public declarations }
    FId_Entrega       : Integer;
    FTabAtual         : Integer;
    FTipoServico      : TTipoServico;
    FStatusEntrega    : TStatusEntrega;
    FTIpoAberturaTela : TTipoAberturaTela;
    FImpressao        : String;
  end;

var
  frmNovaEntrega: TfrmNovaEntrega;

implementation

{$R *.fmx}

uses uLoading,
     dataModule,
     uSession;

procedure TfrmNovaEntrega.btnVoltarClick(Sender: TObject);
begin
  Tsession.Fechamento := 'Voltar';
  Close;
end;

procedure TfrmNovaEntrega.controlTab2;
begin

end;

procedure TfrmNovaEntrega.FormClose(Sender: TObject; var Action: TCloseAction);
begin

  Action         := TCloseAction.caFree;
  frmNovaEntrega := nil;

end;

procedure TfrmNovaEntrega.FormShow(Sender: TObject);
begin
  FTabAtual  := 0;
  FImpressao := '';
  tabControl1.GotoVisibleTab(0);
  LytBotoes.Visible   := true;
  lblTitulo.Visible   := True;
  LimparCampos;

  if FTIpoAberturaTela = tatEditar then
    RefreshListarEntrega;




end;

procedure tfrmNovaEntrega.LimparCampos;
var
  I : Integer;
begin

   // Limpa campos de texto
  edtNome.Text       := '';
  edtTelefone.Text   := '';
  edtEndereco.Text   := '';
  edtBateria.Text    := '';
  edtObservacao.Text := '';
  edtPagamento.Text  := '';
  edtValor.Text      := '';
  edtVeiculo.Text    := '';

  // Desmarca todos os RadioButtons
  for i := 0 to GroupTipoServico.ChildrenCount - 1 do
    if GroupTipoServico.Children[i] is TRadioButton then
      TRadioButton(GroupTipoServico.Children[i]).IsChecked := False;

end;

procedure TfrmNovaEntrega.SelecionarTab(ATag : Integer);
begin

  if FtabAtual < 0 then
    FtabAtual := 0
  else
    FTabAtual := FTabAtual + Atag;

  case FtabAtual of
    0 : tabControl1.GotoVisibleTab(FtabAtual);
    1 : tabControl1.GotoVisibleTab(FtabAtual);
    2 : btnSalvarClick;
  end;



end;


procedure TfrmNovaEntrega.btnProximoClick(Sender: TObject);
var
  LTag : Integer;
begin
  LTag := TSpeedButton(Sender).tag;
  SelecionarTab(LTag);
end;

procedure TfrmNovaEntrega.btnSalvarClick;
var
  i       : Integer;
  Radio   : TRadioButton;
begin
  FTipoServico   := TTipoServico(-1);
  FStatusEntrega := tseEmAberto;

  for i := 0 to GroupTipoServico.ChildrenCount - 1 do
  begin
    if GroupTipoServico.Children[i] is TRadioButton then
    begin
      Radio := TRadioButton(GroupTipoServico.Children[i]);
      if Radio.IsChecked then
      begin
        FTipoServico := TTipoServico(Radio.Tag);
        Break;
      end;
    end;
  end;

  if edtNome.Text.Trim = '' then
  begin
    ShowMessage('Informe o nome do cliente.');
    exit;
  end
  else if not (FTipoServico in [Low(TTipoServico)..High(TTipoServico)]) then
  begin
    ShowMessage('Informe o Tipo de Serviço!');
    exit;
  end;



  if FTIpoAberturaTela = tatInserir then
    RefreshInserirEntrega
  else if FTIpoAberturaTela = tatEditar then
    RefreshEditarEntrega;
end;

procedure TfrmNovaEntrega.RefreshEditarEntrega;
begin

  TLoading.Show(frmNovaEntrega);
  TLoading.ExecuteThread(procedure
   begin
     dm.EditarEntrega(FId_Entrega,
                      edtNome.Text,
                      edtTelefone.Text,
                      edtEndereco.Text,
                      edtBateria.Text,
                      edtObservacao.Text,
                      edtPagamento.Text,
                      edtValor.Text,
                      edtVeiculo.Text,
                      FTipoServico,
                      FStatusEntrega);

    end,
    TerminateEntrega);

end;

procedure TfrmNovaEntrega.RefreshListarEntrega;
begin

    TLoading.Show(frmNovaEntrega);

    TLoading.ExecuteThread(procedure
    begin
      dm.ListarPorIdLocal(FId_Entrega.ToString)
    end,
    TermianteListarEntregaPorId);


end;

procedure TfrmNovaEntrega.TermianteListarEntregaPorId(Sender : Tobject);
var
  LTipoServico : String;
begin

  TLoading.Hide;
  if dm.QryEntregas.RecordCount <= 0 then
  begin
    showmessage('Cliente não encontrado!');
    exit;
  end;

  try
    edtNome.Text       := dm.QryEntregas.FieldByName('Nome').AsString;
    edtTelefone.Text   := dm.QryEntregas.FieldByName('Telefone').AsString;
    edtEndereco.Text   := dm.QryEntregas.FieldByName('Endereco').AsString;
    edtBateria.Text    := dm.QryEntregas.FieldByName('Bateria').AsString;
    edtObservacao.Text := dm.QryEntregas.FieldByName('Observacao').AsString;
    edtPagamento.Text  := dm.QryEntregas.FieldByName('Pagamento').AsString;
    edtValor.Text      := dm.QryEntregas.FieldByName('Valor').AsString;
    edtVeiculo.Text    := dm.QryEntregas.FieldByName('Veiculo').AsString;
    LTipoServico       := dm.QryEntregas.FieldByName('TipoServico').AsString;

      if LTipoServico      = 'E' then
        FTipoServico := ttsEntrega
      else if LTipoServico = 'G' then
        FTipoServico := ttsGarantia
      else if LTipoServico = 'O' then
        FTipoServico := ttsOutroServico
      else if LTipoServico = 'A' then
        FTipoServico := ttsAnotacao;


    case FTipoServico of
      ttsEntrega      : btnEntrega.IsChecked  := True;
      ttsGarantia     : btnGarantia.IsChecked := True;
      ttsOutroServico : btnOutros.IsChecked   := True;
      ttsAnotacao     : btnAnotacao.IsChecked := True;
    end;

  Except
    showmessage('Erro ao inserir dados nos campos!');
  end;



end;

procedure TfrmNovaEntrega.RefreshInserirEntrega;
begin


  TLoading.Show(frmNovaEntrega);
  TLoading.ExecuteThread(procedure
   begin
     dm.InserirEntrega(edtNome.Text,
                       edtTelefone.Text,
                       edtEndereco.Text,
                       edtBateria.Text,
                       edtObservacao.Text,
                       edtPagamento.Text,
                       edtValor.Text,
                       edtVeiculo.Text,
                       FTipoServico,
                       FStatusEntrega,
                       FImpressao);

    end,
    TerminateEntrega);

end;

procedure TfrmNovaEntrega.TerminateEntrega(Sender: Tobject);
begin

    TLoading.Hide;

    if Assigned(TThread(Sender).FatalException) then
    begin
        showmessage(Exception(TThread(sender).FatalException).Message);
        exit;
    end;

    tabControl1.GotoVisibleTab(FtabAtual);
    lblTitulo.Visible   := False;
    lytBotoes.Visible   := false;
    Tsession.Fechamento := 'Ir';

    Timer1.enabled := True;



end;

procedure TfrmNovaEntrega.Timer1Timer(Sender: TObject);
begin
  Timer1.enabled := false;
  self.close;

end;



end.
