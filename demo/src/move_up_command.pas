unit move_up_command;

interface

uses
  uCommandHelper, System.SysUtils;

type

  TMoveUpCommand = class(TCommand)
  public
    procedure execute; override;
    constructor Create; override;
  end;

implementation

{ TMoveUpCommand }

constructor TMoveUpCommand.Create;
begin
  inherited;

  FCode := 'up';
  FAlias := 'u';
  FDescription := 'Move up';

  FArguments.Add(TCommandArgument.Create('s', 'Scream sound', atString, true));
  FArguments.Add(TCommandArgument.Create('w', 'Must wave', atBoolean, true));
end;

procedure TMoveUpCommand.execute;
var
  lScreamSound : string;
  lMustWave : Boolean;
begin
  lScreamSound := getArgumentByCode('s').ValueAsString;
  lMustWave := getArgumentByCode('w').ValueAsBoolean;

  WriteLn('Scream sound: ' + lScreamSound);
  WriteLn('Must wave: ' + BoolToStr(lMustWave, true));
end;

end.
