{*******************************************************}
{                                                       }
{       Open QBuilder Engine for ZEOS Sources           }
{                Lazarus / Free Pascal                  }
{                                                       }
{ Created by Christian Ulrich                           }
{ Data: 14/02/2013                                      }
{ E-mail: christian@ullihome.de                         }
{                                                       }
{*******************************************************}

unit qbepromet;

interface

uses
  types, SysUtils, Classes, DB, ZDataset, ZConnection, QBuilder;

type

  { TOQBEnginePromet }

  TOQBEnginePromet = class(TOQBEngine)
    procedure FResultQueryAfterOpen(DataSet: TDataSet);
    procedure GridFloatFieldGetText(Sender: TField; var aText: string;
      DisplayText: Boolean);
    procedure GridMemoFieldGetText(Sender: TField; var aText: string;
      DisplayText: Boolean);
  private
    FResultQuery: TZQuery;
    FZEOSConnection : TZConnection;
  public
    SchemaPostgreSQL : String;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ClearQuerySQL; override;
    procedure CloseResultQuery; override;
    procedure OpenResultQuery; override;
    procedure ReadFieldList(const ATableName: string); override;
    procedure ReadTableList; override;
    procedure SaveResultQueryData; override;
    procedure SetConnection(Value: TZConnection);
    procedure SetQuerySQL(const Value: string); override;
    function ResultQuery: TDataSet; override;
    function SelectDatabase: Boolean; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  published
  end;

implementation

uses uData,uZeosDBDM;

{ TOQBEngineZEOS }

procedure TOQBEnginePromet.FResultQueryAfterOpen(DataSet: TDataSet);
var
  i: Integer;
begin
  for i := 0 to DataSet.Fields.Count - 1 do
  begin
    if DataSet.Fields[i].DataType = ftMemo then
    begin
      DataSet.Fields[i].OnGetText := @GridMemoFieldGetText;
    end;
    // Work around Zeos 7.0.3 bug with DOUBLE PRECISION fields in Firebird
    if (DataSet.Fields[i].DataType = ftFloat) and
      (Pos('firebird',FZEOSConnection.Protocol) > 0) and
      (FZEOSConnection.Version = '7.0.3-stable') then
    begin
      DataSet.Fields[i].OnGetText := @GridFloatFieldGetText;
    end;
    // ------------------------------------------------------------------
  end;
end;

procedure TOQBEnginePromet.GridFloatFieldGetText(Sender: TField;
  var aText: string; DisplayText: Boolean);
begin
  // Work around Zeos 7.0.3 bug with DOUBLE PRECISION fields in Firebird
  aText := FloatToStr(TField(Sender).AsFloat);
end;

procedure TOQBEnginePromet.GridMemoFieldGetText(Sender: TField;
  var aText: string; DisplayText: Boolean);
begin
  // Show memo fields
  aText := TField(Sender).AsString;
end;

constructor TOQBEnginePromet.Create(AOwner: TComponent);
begin
  inherited;
  FResultQuery := TZQuery.Create(Self);
  FResultQuery.AfterOpen := @FResultQueryAfterOpen;
  if uData.Data is TZeosDBDM then
    begin
      FZEOSConnection := TZConnection(uData.Data.MainConnection);

    end;
  FResultQuery.Connection := FZEOSConnection;
end;

destructor TOQBEnginePromet.Destroy;
begin
  FResultQuery.Free;
  inherited;
end;

procedure TOQBEnginePromet.SetConnection(Value: TZConnection);
begin
end;

function TOQBEnginePromet.SelectDatabase: Boolean;
begin
  Result := True;
end;

procedure TOQBEnginePromet.ReadTableList;
var
  vTypesTables: TStringDynArray;
begin
  SetLength(vTypesTables,2);
  vTypesTables[0] := 'TABLE';
  vTypesTables[1] := 'VIEW';
  if ShowSystemTables then begin
    SetLength(vTypesTables,3);
    vTypesTables[0] := 'TABLE';
    vTypesTables[1] := 'VIEW';
    vTypesTables[2] := 'SYSTEM TABLE';
  end;
  TableList.Clear;
  FResultQuery.Connection.GetTableNames(SchemaPostgreSQL,'',vTypesTables,TableList);
end;

procedure TOQBEnginePromet.ReadFieldList(const ATableName: string);
begin
  FieldList.Clear;
  FResultQuery.Connection.GetColumnNames(ATableName, '', FieldList);
  FieldList.Insert(0, '*');
end;

procedure TOQBEnginePromet.ClearQuerySQL;
begin
  FResultQuery.SQL.Clear;
end;

procedure TOQBEnginePromet.SetQuerySQL(const Value: string);
begin
  FResultQuery.SQL.Text := Value;
end;

function TOQBEnginePromet.ResultQuery: TDataSet;
begin
  Result := FResultQuery;
end;

procedure TOQBEnginePromet.OpenResultQuery;
begin
  try
    FResultQuery.Open;
  finally
  end;
end;

procedure TOQBEnginePromet.CloseResultQuery;
begin
  FResultQuery.Close;
end;

{$WARNINGS OFF}
procedure TOQBEnginePromet.SaveResultQueryData;
begin
  //
end;
{$WARNINGS ON}

procedure TOQBEnginePromet.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (AComponent = FZEOSConnection) and (Operation = opRemove) then
  begin
    FZEOSCOnnection := nil;
    FResultQuery.Connection := nil;
  end;
end;

end.

