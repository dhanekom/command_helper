unit move_down_command;

interface

uses
  uCommandHelper, System.SysUtils;

type

  TMoveDownCommand = class(TCommand)
  public
    procedure execute; override;
    constructor Create; override;
  end;

implementation

{ TMoveDownCommand }

constructor TMoveDownCommand.Create;
begin
  inherited;

  FCode := 'down';
  FAlias := 'd';
  FDescription := 'Move down';
end;

procedure TMoveDownCommand.execute;
begin
  WriteLn('We are moving down');
end;

end.
