unit unitConfig;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Edit, FMX.Controls.Presentation, FMX.Layouts;

type
  TfrmConfig = class(TForm)
    Layout1: TLayout;
    lblNomeServido: TLabel;
    edtServidor: TEdit;
    rectBtnSalvar: TRectangle;
    btnSalvar: TSpeedButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSalvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmConfig: TfrmConfig;

implementation

{$R *.fmx}

uses uSession;

procedure TfrmConfig.btnSalvarClick(Sender: TObject);
begin
  TSession.servidor := EdtServidor.Text;
  Close;
end;

procedure TfrmConfig.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Action    := TCloseAction.caFree;
   FrmConfig := nil;
end;

end.
