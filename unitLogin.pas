unit unitLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Edit, FMX.Controls.Presentation, FMX.StdCtrls;

type
  TfrmLogin = class(TForm)
    Layout1: TLayout;
    imgLogo: TImage;
    lblNomeServido: TLabel;
    edtServidor: TEdit;
    rectBtnSalvar: TRectangle;
    btnSalvar: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure AbrirTelaPrincipal;
    procedure VerificarConexaoServidor;
    procedure TerminateVerificarConexaoServidor(Sender: Tobject);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLogin: TfrmLogin;

implementation

{$R *.fmx}
  uses
    uLoading,
    dataModule,
    uSession,
    unitPrincipal;

procedure TfrmLogin.btnSalvarClick(Sender: TObject);
begin

  if edtServidor.Text.Trim = '' then
  begin
    Showmessage('Preencha o campo do servidor');
    exit;
  end;

  dm.InserirRegistroServidor(EdtServidor.Text);
  dm.VerificarRegistroServidor;
  AbrirTelaPrincipal;

end;


procedure TfrmLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  FrmLogin := nil;
end;

procedure TfrmLogin.FormShow(Sender: TObject);
begin

  dm.VerificarRegistroServidor;

  if dm.qryConfig.RecordCount <= 0 then
    exit;

  AbrirTelaPrincipal;
end;

procedure TfrmLogin.AbrirTelaPrincipal;
begin

  TSession.servidor := dm.qryConfig.FieldByName('Servidor').Value;
  VerificarConexaoServidor;

end;

procedure TfrmLogin.VerificarConexaoServidor;
begin
    TLoading.Show(frmLogin);
    TLoading.ExecuteThread(procedure
    begin
    //  Dm.ValidarLogin;
    end,
    TerminateVerificarConexaoServidor);

end;

procedure TfrmLogin.TerminateVerificarConexaoServidor(Sender: Tobject);
begin

    TLoading.Hide;
    if Assigned(TThread(Sender).FatalException) then
    begin
        showmessage(Exception(TThread(sender).FatalException).Message);
        exit;
    end;

    if NOT Assigned(FrmPrincipal) then
      Application.CreateForm(TFrmPrincipal, FrmPrincipal);

    Application.MainForm := FrmPrincipal;
    FrmPrincipal.Show;
    FrmLogin.Close;


end;

end.
