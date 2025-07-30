unit unitListBoxLayout;

interface
uses
  FMX.ListBox,
  UnitFrameComanda,
  System.SysUtils;

procedure addComandaListBox(ListBox         : TListBox;
                            Id_Comanda      : Integer;
                            Comanda_Cliente : String;
                            Valor           : Double);

implementation



procedure addComandaListBox(ListBox         : TListbox;
                            Id_Comanda      : Integer;
                            Comanda_Cliente : String;
                            Valor           : Double);
var
  Item  : TlistboxItem;
  frame : TframeComanda;
begin

  Item            := TListBoxItem.Create(ListBox);
  item.Text       := '';
  item.Height     := 60;
  item.Tag        := id_Comanda;
  item.TagString  := Comanda_Cliente;
  item.Selectable := False;

  frame                := TframeComanda.Create(item);
  frame.lblNome.Text   := Comanda_Cliente;
  frame.lblValor.Text  := FormatFloat('#,##0.00',Valor);

  item.AddObject(frame);

  Listbox.AddObject(item);

end;

end.
