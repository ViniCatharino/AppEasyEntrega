unit dataModule;

interface

uses
  System.SysUtils, System.Classes,
  DataSet.Serialize,
  DataSet.Serialize.Config,
  RESTRequest4D,
  DataSet.Serialize.Adapter.RESTRequest4D,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait, System.IOUtils,
  FireDAC.DApt,JSON,
  core.Utils.Tipos,FMX.Dialogs;

type
  Tdm = class(TDataModule)
    tabEntregas: TFDMemTable;
    Conn: TFDConnection;
    qryConfig: TFDQuery;
    QryEntregas: TFDQuery;
    tabEntregaId: TFDMemTable;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure ConnBeforeConnect(Sender: TObject);
    procedure ConnAfterConnect(Sender: TObject);
  private

    procedure AtualizarTabelaEntregas;

    { Private declarations }
  public
   procedure ListarPorIdLocal(AId_Entrega: String);
   procedure ListarEntregasLocal;
   procedure ValidarLogin;
   procedure InserirRegistroServidor(AServidor : String);
   procedure VerificarRegistroServidor;
   procedure ImprimirEntrega(AId_Entrega: String);
   Procedure InserirEntrega(ANome,ATelefone,AEndereco,
                             ABateria,AObservacao,APagamento,
                             AValor,AVeiculo       : String;
                             ATipoServico          : TTipoServico;
                             AStatus               : TStatusEntrega;
                             AImpressao            : String);
   procedure ListarEntregasEmAberto();
   procedure ListarEntregasPorTelefone(ATelefone: String);
   procedure EditarEntrega(AId_Entrega: Integer; ANome, ATelefone, AEndereco,
                           ABateria, AObservacao, APagamento, AValor, AVeiculo: String;
                           ATipoServico: TTipoServico; AStatus: TStatusEntrega);
   procedure ListarPorId(AId_Entrega : String);
   procedure MarcarComoEntregue(AId_Entrega: String);
   procedure ListarHistorico;
   procedure ListarAnotacao;

    { Public declarations }
  end;

var
  dm: Tdm;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses uSession;


{$R *.dfm}
procedure Tdm.VerificarRegistroServidor;
begin
    QryConfig.Active := false;
    QryConfig.SQL.Clear;
    QryConfig.SQL.Add('Select * from Servidor');
    QryConfig.Active := True;
end;

procedure Tdm.ListarEntregasLocal;
begin

    QryEntregas.Active := false;
    QryEntregas.SQL.Clear;
    QryEntregas.SQL.Add('Select * from entregas');
    QryEntregas.SQL.Add('Order By id Desc');
    QryEntregas.Active := True;

end;

procedure Tdm.InserirRegistroServidor(AServidor : String);
begin

  QryConfig.Active := False;
  QryConfig.SQL.Clear;
  QryConfig.SQL.Text := 'DELETE FROM Servidor';
  QryConfig.ExecSQL;

  QryConfig.SQL.Clear;
  QryConfig.SQL.Add('INSERT INTO Servidor (Servidor) VALUES (:Servidor)');
  QryConfig.ParamByName('Servidor').AsString := AServidor;
  QryConfig.ExecSQL;




end;

procedure Tdm.InserirEntrega(ANome,ATelefone,AEndereco,
                             ABateria,AObservacao,APagamento,
                             AValor,AVeiculo       : String;
                             ATipoServico          : TTipoServico;
                             AStatus               : TStatusEntrega;
                             AImpressao            : String);

var
    resp                 : IResponse;
    Json                 : TJsonObject;
    LtipoServico,LStatus : String;
begin

  case ATipoServico of
    ttsEntrega     :  LtipoServico := TipoServico[Integer(TTipoServico.ttsEntrega)];
    ttsGarantia    :  LtipoServico := TipoServico[Integer(TTipoServico.ttsGarantia)];
    ttsOutroServico:  LtipoServico := TipoServico[Integer(TTipoServico.ttsOutroServico)];
    ttsAnotacao    :  LtipoServico := TipoServico[Integer(TTipoServico.ttsAnotacao)];
  end;

  If ATipoServico = ttsAnotacao then
    LStatus := StatusEntrega[Integer(TStatusEntrega.tseEntregue)]
  else
    begin
      case AStatus of
        tseEmAberto : LStatus := StatusEntrega[Integer(TStatusEntrega.tseEmAberto)];
        tseEntregue : LStatus := StatusEntrega[Integer(TStatusEntrega.tseEntregue)];
      end;
    end;

  try
        json := TJSONObject.Create;
        json
          .AddPair('Nome',        ANome)
          .AddPair('Telefone',    ATelefone)
          .AddPair('Endereco',    AEndereco)
          .AddPair('Bateria',     ABateria)
          .AddPair('Observacao',  AObservacao)
          .AddPair('Pagamento',   APagamento)
          .AddPair('Valor',       AValor)
          .AddPair('Veiculo',     AVeiculo)
          .AddPair('TipoServico', LtipoServico)
          .AddPair('Status',      LStatus);

        resp := TRequest.New
                .BaseURL(TSession.servidor)
                .Resource('NovaEntrega')
                .AddBody(json.ToString)
                .Adapters(TDataSetSerializeAdapter.New(tabEntregaId))
                .Accept('application/json')
                .Post;


        if resp.StatusCode <> 201 then
            raise Exception.Create(resp.Content);

    finally
        json.Free;
    end;

end;

procedure TDm.ValidarLogin;
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(TSession.servidor)
                        .Resource('Teste')
                        .Accept('application/json')
                        .Post;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);

end;

procedure Tdm.ConnBeforeConnect(Sender: TObject);
begin
    Conn.DriverName := 'SQLite';

    {$IFDEF MSWINDOWS}
    Conn.Params.Values['Database'] := System.SysUtils.GetCurrentDir + '\entregas.db';
    {$ELSE}
    Conn.Params.Values['Database'] := TPath.Combine(TPath.GetDocumentsPath, 'entregas.db');
    {$ENDIF}
end;

procedure Tdm.DataModuleCreate(Sender: TObject);
begin
    TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower;
    TDataSetSerializeConfig.GetInstance.Import.DecimalSeparator := '.';

    Conn.Connected := True;
end;

procedure Tdm.DataModuleDestroy(Sender: TObject);
begin
   Conn.Connected := False;
end;

procedure TDm.ConnAfterConnect(Sender: TObject);
begin
    Conn.ExecSQL('create table if not exists Servidor (        ' +
                 'ID_Servidor    INTEGER NOT NULL PRIMARY KEY, ' +
                 'Servidor       VARCHAR (100))                ' );

    Conn.ExecSQL('CREATE TABLE if not exists ENTREGAS ( ' +
                 'ID           INTEGER NOT NULL,        ' +
                 'NOME         VARCHAR(100),            ' +
                 'TELEFONE     VARCHAR(50),             ' +
                 'ENDERECO     VARCHAR(200),            ' +
                 'BATERIA      VARCHAR(50),             ' +
                 'OBSERVACAO   VARCHAR(255),            ' +
                 'PAGAMENTO    VARCHAR(30),             ' +
                 'VEICULO      VARCHAR(100),            ' +
                 'TIPOSERVICO  VARCHAR(30),             ' +
                 'STATUS       VARCHAR(20),             ' +
                 'VALOR        VARCHAR(50),             ' +
                 'HORA         VARCHAR(50)           ); ');
end;

procedure Tdm.EditarEntrega(AId_Entrega            : Integer;
                             ANome,ATelefone,AEndereco,
                             ABateria,AObservacao,APagamento,
                             AValor,AVeiculo       : String;
                             ATipoServico          : TTipoServico;
                             AStatus               : TStatusEntrega);

var
    resp                 : IResponse;
    Json                 : TJsonObject;
    LtipoServico,LStatus : String;
begin

  case ATipoServico of
    ttsEntrega     :  LtipoServico := TipoServico[Integer(TTipoServico.ttsEntrega)];
    ttsGarantia    :  LtipoServico := TipoServico[Integer(TTipoServico.ttsGarantia)];
    ttsOutroServico:  LtipoServico := TipoServico[Integer(TTipoServico.ttsOutroServico)];
    ttsAnotacao    :  LtipoServico := TipoServico[Integer(TTipoServico.ttsAnotacao)];
  end;

  If ATipoServico = ttsAnotacao then
    LStatus := StatusEntrega[Integer(TStatusEntrega.tseEntregue)]
  else
    begin
      case AStatus of
        tseEmAberto : LStatus := StatusEntrega[Integer(TStatusEntrega.tseEmAberto)];
        tseEntregue : LStatus := StatusEntrega[Integer(TStatusEntrega.tseEntregue)];
      end;
    end;

  try
        json := TJSONObject.Create;
        json
          .AddPair('Nome'       , ANome)
          .AddPair('Telefone'   , ATelefone)
          .AddPair('Endereco'   , AEndereco)
          .AddPair('Bateria'    , ABateria)
          .AddPair('Observacao' , AObservacao)
          .AddPair('Pagamento'  , APagamento)
          .AddPair('Valor'      , AValor)
          .AddPair('Veiculo'    , AVeiculo)
          .AddPair('TipoServico', LtipoServico)
          .AddPair('Status'     , LStatus);

        resp := TRequest.New
                .BaseURL(TSession.servidor)
                .Resource('/EditarEntrega/' + Aid_Entrega.ToString)
                .AddBody(json.ToString)
                .Accept('application/json')
                .Post;

        if resp.StatusCode <> 200 then
            raise Exception.Create(resp.Content);

    finally
        json.Free;
    end;

end;

procedure Tdm.ListarEntregasEmAberto();
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(TSession.servidor)
                        .Resource('EntregasEmAbertas')
                        .Accept('application/json')
                        .Adapters(TDataSetSerializeAdapter.New(tabEntregas))
                        .Get;

    if resp.StatusCode <> 200 then
      raise Exception.Create(resp.Content);

    AtualizarTabelaEntregas;

end;

procedure Tdm.AtualizarTabelaEntregas;
begin

  QryEntregas.Active := false;
  qryEntregas.SQL.Clear;
  qryEntregas.SQL.Add('Delete from Entregas');
  qryEntregas.ExecSQL;

  if (not tabEntregas.Active) or (tabEntregas.IsEmpty) then
  begin
      QryEntregas.Active := false;
      QryEntregas.SQL.Clear;
      QryEntregas.SQL.Add('Select * from Entregas');
      QryEntregas.SQL.Add('Order By id Desc      ');
      QryEntregas.Active := True;
      exit;
  end;


  qryEntregas.SQL.Clear;
  QryEntregas.SQL.Add('INSERT INTO ENTREGAS (                                         ');
  QryEntregas.SQL.Add('   ID, NOME, TELEFONE, ENDERECO, BATERIA, OBSERVACAO,          ');
  QryEntregas.SQL.Add('    PAGAMENTO, VALOR, VEICULO, TIPOSERVICO, STATUS, Hora)      ');
  QryEntregas.SQL.Add('VALUES (                                                       ');
  QryEntregas.SQL.Add('    :Id, :NOME, :TELEFONE, :ENDERECO, :BATERIA, :OBSERVACAO,   ');
  QryEntregas.SQL.Add('    :PAGAMENTO, :VALOR, :VEICULO, :TIPOSERVICO, :STATUS, :hora)');


  tabEntregas.First;
  while not tabEntregas.Eof do
  begin

        qryEntregas.ParamByName('Id').ASInteger         := tabEntregas.FieldByName('Id').AsInteger;
        QryEntregas.ParamByName('Nome').asString        := tabEntregas.FieldByName('Nome').AsString;
        QryEntregas.ParamByName('TELEFONE').Value       := tabEntregas.FieldByName('Telefone').asString;
        QryEntregas.ParamByName('Endereco').AsString    := tabEntregas.FieldByName('Endereco').AsString;
        QryEntregas.ParamByName('Bateria').AsString     := tabEntregas.FieldByName('Bateria').AsString;
        QryEntregas.ParamByName('Observacao').AsString  := tabEntregas.FieldByName('Observacao').AsString;
        QryEntregas.ParamByName('Pagamento').AsString   := tabEntregas.FieldByName('Pagamento').AsString;
        QryEntregas.ParamByName('Valor').AsString       := tabEntregas.FieldByName('Valor').AsString;
        QryEntregas.ParamByName('Veiculo').AsString     := tabEntregas.FieldByName('Veiculo').AsString;
        QryEntregas.ParamByName('TipoServico').AsString := tabEntregas.FieldByName('TipoServico').AsString;
        QryEntregas.ParamByName('Status').AsString      := tabEntregas.FieldByName('Status').AsString;
        QryEntregas.ParamByName('Hora').AsString        := tabEntregas.FieldByName('Hora').AsString;

    try
      QryEntregas.ExecSQL;
    except
      on e:exception do
      begin
        raise Exception.Create('Error Message: ' + e.ToString);
      end;
    end;
    Dm.tabEntregas.Next;
  end;

  QryEntregas.Active := false;
  qryEntregas.SQL.Clear;
  qryEntregas.SQL.Add('Select * from Entregas');
  QryEntregas.SQL.Add('Order By id Desc      ');
  QryEntregas.Active := True;

end;


procedure Tdm.ListarEntregasPorTelefone(ATelefone: String);
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(TSession.servidor)
                        .Resource('ListarPorTelefone/' + ATelefone)
                        .Accept('application/json')
                        .Adapters(TDataSetSerializeAdapter.New(tabEntregas))
                        .Get;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);

end;

procedure Tdm.ListarPorId(AId_Entrega: String);
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(TSession.servidor)
                        .Resource('/ListarEntregaPorId/' + AId_Entrega)
                        .Accept('application/json')
                        .Adapters(TDataSetSerializeAdapter.New(tabEntregas))
                        .Get;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);

end;

procedure Tdm.ListarPorIdLocal(AId_Entrega: String);
begin

  QryEntregas.Active   := False;
  QryEntregas.SQL.clear;
  QryEntregas.SQL.Add('Select * from Entregas');
  QryEntregas.SQL.Add('Where Id = :Id');
  QryEntregas.ParamByName('Id').Value := AId_Entrega;
  QryEntregas.Active := True;

end;

procedure Tdm.ImprimirEntrega(AId_Entrega: String);
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(TSession.servidor)
                        .Resource('/ImprimirEntrega/' + AID_entrega)
                        .Accept('application/json')
                        .Post;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);
end;

procedure Tdm.MarcarComoEntregue(AId_Entrega: String);
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(TSession.servidor)
                        .Resource('/MarcarComoEntregue/' + AId_Entrega)
                        .Accept('application/json')
                        .Post;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);

end;

procedure Tdm.ListarHistorico;
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(TSession.servidor)
                        .Resource('/ListarHistorico')
                        .Accept('application/json')
                        .Adapters(TDataSetSerializeAdapter.New(tabEntregas))
                        .Get;

    if resp.StatusCode <> 201 then
        raise Exception.Create(resp.Content);

end;

procedure Tdm.ListarAnotacao;
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(TSession.servidor)
                        .Resource('/ListarAnotacao')
                        .Accept('application/json')
                        .Adapters(TDataSetSerializeAdapter.New(tabEntregas))
                        .Get;

    if resp.StatusCode <> 201 then
        raise Exception.Create(resp.Content);

end;





end.
