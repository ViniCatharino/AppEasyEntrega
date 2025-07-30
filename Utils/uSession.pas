unit uSession;

interface

type
  TSession = class
  private
    class var Ftoken          : string;
    class var Flogin          : string;
    class var Fnome           : string;
    class var Fid_usuario     : integer;
    class var Fservidor       : string;
    class var FStatusServidor : String;
    class var FTipoFechamento : String;
  public
    class property id_usuario: integer read Fid_usuario write Fid_usuario;
    class property nome: string read Fnome write Fnome;
    class property login: string read Flogin write Flogin;
    class property token: string read Ftoken write Ftoken;
    class property servidor: string read Fservidor write Fservidor;
    class property Fechamento: string read FTipoFechamento write FTipoFechamento;
    class property StatusServidor: string read FStatusServidor write FStatusServidor;
  end;

implementation



end.
