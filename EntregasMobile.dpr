program EntregasMobile;

uses
  System.StartUpCopy,
  FMX.Forms,
  unitLogin in 'unitLogin.pas' {frmLogin},
  dataModule in 'dataModule.pas' {dm: TDataModule},
  uActionSheet in 'Utils\uActionSheet.pas',
  uLoading in 'Utils\uLoading.pas',
  uSession in 'Utils\uSession.pas',
  core.Utils.Tipos in '..\Core\core.Utils.Tipos.pas',
  unitPrincipal in 'unitPrincipal.pas' {frmPrincipal},
  unitFrameEntregas in 'Frame\unitFrameEntregas.pas' {FrameEntregas: TFrame},
  unitConfig in 'unitConfig.pas' {frmConfig},
  unitNovaEntrega in 'unitNovaEntrega.pas' {frmNovaEntrega};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmLogin, frmLogin);
  Application.CreateForm(Tdm, dm);
  Application.Run;
end.
