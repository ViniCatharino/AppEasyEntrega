unit uListboxLayout;

interface

uses
  FMX.ListBox, UnitFrameComanda, System.UITypes, System.SysUtils;

procedure AddComandaListbox(listbox: TListbox;
                            id_comanda: integer;
                            comanda_cliente: string;
                            valor: double);

implementation

procedure AddComandaListbox(listbox: TListbox;
                            id_comanda: integer;
                            comanda_cliente: string;
                            valor: double);
var
  item: TListBoxItem;
  frame: TFrameComanda;
begin
    // Item da listbox
    item := TListBoxItem.Create(listbox);
    item.Text := '';
    item.Height := 60;
    item.Tag := id_comanda;
    item.TagString := comanda_cliente;
    item.TagFloat := valor;
    item.Selectable := false;
    item.Cursor := crHandPoint;

    // Frame
    frame := TFrameComanda.Create(item);
    frame.lblNome.Text := comanda_cliente;
    frame.lblValor.Text := FormatFloat('R$ #,##0.00', valor);

    item.AddObject(frame);

    listbox.AddObject(item);
end;

end.
