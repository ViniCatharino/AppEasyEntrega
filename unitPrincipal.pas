unit unitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ListBox, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, core.Utils.Tipos;

type
  TfrmPrincipal = class(TForm)
    lblTitulo: TLabel;
    lbEntregas: TListBox;
    btnRecarregar: TImage;
    btnConfig: TImage;
    rectBtnNovaEntraga: TRectangle;
    btnNovaEntrega: TImage;

    procedure FormShow(Sender: TObject);
    procedure btnRecarregarClick(Sender: TObject);
    procedure btnConfigClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnNovaEntregaClick(Sender: TObject);
  private
    procedure RefreshEntregas;
    procedure terminateEntregas(Sender: Tobject);
    procedure addEntregasListBox(AId_Entrega  : Integer;
                                 ANome        : String;
                                 ATelefone    : String;
                                 AEndereco    : String;
                                 AtipoServico : String;
                                 AHora        : String);
    procedure RefreshImprimir(Sender: Tobject);
    procedure TerminateImprimir(Sender: Tobject);
    procedure RefreshMarcarComoEntregue(Sender: Tobject);
    procedure AbrirTelaNovaEntrega(SEnder: Tobject);
    procedure RectFundoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure RectFundoMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure FormNovaEntregaClose(Sender: TObject; var Action: TCloseAction);
    { Private declarations }
  public
    FStartPoint     : TPointF;
    FClickValido    : Boolean;
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.fmx}

uses uLoading,
     dataModule,
     unitFrameEntregas,
     uSession,
     unitLogin,
     unitConfig,
     unitNovaEntrega;

procedure TfrmPrincipal.btnConfigClick(Sender: TObject);
begin

  if NOT Assigned(frmConfig) then
      Application.CreateForm(TFrmConfig, Frmconfig);

    Frmconfig.Show;
end;

procedure TfrmPrincipal.btnNovaEntregaClick(Sender: TObject);
begin
   if NOT Assigned(frmNovaEntrega) then
      Application.CreateForm(TfrmNovaEntrega, frmNovaEntrega);

  frmNovaENtrega.lblTitulo.Text    := 'Nova Entrega';
  frmNovaEntrega.FTIpoAberturaTela := tatInserir;
  frmNovaEntrega.FId_Entrega       := 0;
  frmNovaEntrega.Show;
end;

procedure TfrmPrincipal.btnRecarregarClick(Sender: TObject);
begin


  TLoading.Show(frmPrincipal);
  TLoading.ExecuteThread(procedure
  begin
      dm.ListarEntregasEmAberto;
  end,
  TerminateEntregas);
end;

procedure TfrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action       := TCloseAction.caFree;
  FrmPrincipal := nil;
end;

procedure TfrmPrincipal.FormNovaEntregaClose(Sender: TObject; var Action: TCloseAction);
begin

  if Tsession.Fechamento = 'Voltar' then
    RefreshEntregas
  else
    btnRecarregarClick(Sender);

end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  RefreshEntregas;
end;


procedure TfrmPrincipal.RefreshEntregas;
begin

  lbEntregas.items.Clear;

  TLoading.Show(frmPrincipal);
  TLoading.ExecuteThread(procedure
  begin
    dm.ListarEntregasLocal;
  end,
  TerminateEntregas);

end;

procedure TfrmPrincipal.terminateEntregas(Sender: Tobject);
var
  i: Integer;
begin
  TLoading.Hide;

    if Assigned(TThread(Sender).FatalException) then
    begin
        showmessage(Exception(TThread(sender).FatalException).Message);
        exit;
    end;

  try
      dm.QryEntregas.First;
      lbEntregas.items.Clear;

       if dm.QryEntregas.RecordCount <= 0 then
          raise Exception.Create('Não Tem Entregas');


      while not Dm.QryEntregas.Eof do
      begin
          AddEntregasListBox(Dm.QryEntregas.FieldByName('id').AsInteger,
                             Dm.QryEntregas.FieldByName('nome').AsString,
                             Dm.QryEntregas.FieldByName('telefone').AsString,
                             dm.QryEntregas.FieldByName('Endereco').asString,
                             Dm.QryEntregas.FieldByName('tiposervico').AsString,
                             DM.QryEntregas.FieldbyName('Hora').AsString);
      dm.QryEntregas.Next;
  end;
  except
    on E: Exception do
      ShowMessage(E.Message);

  end;

end;

procedure TfrmPrincipal.addEntregasListBox(AId_Entrega  : Integer;
                                           ANome        : String;
                                           ATelefone    : String;
                                           AEndereco    : String;
                                           AtipoServico : String;
                                           AHora        : String);
var
  LItem  : TListBoxItem;
  LFrame : TFrameEntregas;
  LCor   : TAlphaColor;
begin


      LItem            := TListBoxItem.Create(lbEntregas);
      Litem.Text       := '';
      Litem.Height     := 260;
      Litem.Tag        := Aid_Entrega;
      Litem.Selectable := False;
      LItem.TagObject  := LFrame;

      if AtipoServico = 'E' then
      begin
        AtipoServico := 'Entrega';
        LCor         := $FF4A70F7 ;
      end
      else if AtipoServico = 'G' then
      begin
        AtipoServico := 'Garantia';
        LCor         := TAlphaColors.Red;
      end
      else if AtipoServico = 'O' then
      begin
        AtipoServico := 'Outro';
        LCor         := TAlphaColors.Gray;
      end
      else if AtipoServico = 'A' then
      begin
        AtipoServico := 'Anotacão';
        LCor         := TAlphaColors.Gray;
      end;


      LFrame                               := TframeEntregas.create(LItem);
      LFrame.lblNome.Text                  := Anome;
      Lframe.lblTelefone.Text              := ATelefone;
      LFrame.lblEndereco.Text              := AEndereco;
      Lframe.lblHora.Text                  := AHora;
      Lframe.lblTipoServico.Text           := ATipoServico;
      Lframe.rectTipoServico.Fill.Color    := LCor;
      LFrame.btnImprimir.Tag               := AId_Entrega;
      Lframe.BtnMarcarComoEntregue.Tag     := AId_Entrega;
      LFrame.BtnVisualizar.Tag                 := AId_Entrega;
      LFrame.btnImprimir.OnClick           := RefreshImprimir;
      Lframe.BtnMarcarComoEntregue.OnClick := RefreshMarcarComoEntregue;
      Lframe.btnVisualizar.OnClick         := AbrirTelaNovaEntrega;


      Litem.AddObject(LFrame);
      lbEntregas.AddObject(Litem)

end;

procedure TfrmPrincipal.RectFundoMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  FStartPoint := PointF(X, Y);
  FClickValido := True;
end;

procedure TfrmPrincipal.RectFundoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  if Abs(X - FStartPoint.X) > 10 then
    FClickValido := False;
  if Abs(Y - FStartPoint.Y) > 10 then
    FClickValido := False;
end;

Procedure TfrmPrincipal.AbrirTelaNovaEntrega(SEnder: Tobject);
var
  Lid : Integer;
begin

  LId := TLayout(sender).Tag;

  if Not Assigned(frmNovaEntrega) then
    Application.CreateForm(TfrmNovaEntrega, frmNovaEntrega);

  frmNovaENtrega.lblTitulo.Text    := 'Editar Entrega';
  frmNovaEntrega.FTIpoAberturaTela := tatEditar;
  frmNovaEntrega.FId_Entrega       := LId;
  frmNovaEntrega.OnClose           := FormNovaEntregaClose;
  frmNovaEntrega.Show;

end;

procedure TfrmPrincipal.RefreshMarcarComoEntregue(Sender: Tobject);
var
  LId : Integer;
begin

  LId := TRectangle(Sender).Tag;


    TLoading.Show(FrmPrincipal);
    TLoading.ExecuteThread(procedure
    begin
      dm.MarcarComoEntregue(LId.ToString);
      dm.ListarEntregasEmAberto();
    end,
    TerminateEntregas);
end;

procedure TfrmPrincipal.RefreshImprimir(Sender : Tobject);
var
  LId : Integer;
begin

  LId := TLayout(Sender).Tag;
  TLoading.Show(frmPrincipal);
  TLoading.ExecuteThread(procedure
  begin
    dm.ImprimirEntrega(LId.ToString);
  end,
  TerminateImprimir);

end;

procedure TfrmPrincipal.TerminateImprimir(Sender: Tobject);
begin

   TLoading.Hide;
   if Assigned(TThread(Sender).FatalException) then
   begin
        showmessage(Exception(TThread(sender).FatalException).Message);
        exit;
   end;

    showmessage('Impresso com Sucesso!');

end;


end.
