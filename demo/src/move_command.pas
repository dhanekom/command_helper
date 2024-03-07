unit move_command;

interface

uses
  uCommandHelper, System.SysUtils, move_up_command, move_down_command;

type

  TMoveCommand = class(TCommand)
  public
    procedure execute; override;
    constructor Create; override;
  end;

implementation

{ TMoveCommand }

constructor TMoveCommand.Create;
begin
  inherited;

  FCode := 'move';
  FAlias := 'm';
  FDescription := 'Sample description';

  FCommands.Add(TMoveUpCommand.Create);
  FCommands.Add(TMoveDownCommand.Create);
end;

procedure TMoveCommand.execute;
begin
  WriteLn(Format('command "%s" executed', [FCode]));
end;

end.
