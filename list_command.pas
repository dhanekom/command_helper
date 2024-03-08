unit list_command;

interface

uses
  uCommandHelper, System.SysUtils;

type

  TListCommand = class(TCommand)
  public
    procedure execute; override;
    constructor Create; override;
  end;

implementation

{ TListCommand }

constructor TListCommand.Create;
begin
  inherited;

  FCode := 'list';
  FAlias := 'l';
  FDescription := 'Sample description';

  //FArguments.Add(TCommandArgument.Create('', '', atString, true, ''));
end;

procedure TListCommand.execute;
begin
  WriteLn(Format('command "%s" executed', [FCode]));
end;

end.
