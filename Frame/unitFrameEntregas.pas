unit unitFrameEntregas;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, FMX.Effects,
  System.Math.Vectors, FMX.Controls3D, FMX.Layers3D;

type
  TFrameEntregas = class(TFrame)
    rectFundo: TRectangle;
    Layout1: TLayout;
    lblNome: TLabel;
    lblTelefone: TLabel;
    lblEndereco: TLabel;
    lblHora: TLabel;
    Layout3D1: TLayout3D;
    lytBotoes: TLayout;
    rectTipoServico: TRectangle;
    lblTipoServico: TLabel;
    BtnMarcarComoEntregue: TRectangle;
    btnImprimir: TLayout;
    ImgImprimir: TImage;
    lblImprimir: TLabel;
    imgCheckEntrega: TImage;
    lblCheck: TLabel;
    btnVisualizar: TLayout;
    imgVisualizar: TImage;
    lblVisualizar: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
