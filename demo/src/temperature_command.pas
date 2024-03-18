unit temperature_command;

interface

uses
  uCommandHelper, System.SysUtils;

type

  TTemperatureCommand = class(TCommand)
  public
    procedure execute; override;
    constructor Create; override;
  end;

implementation

{ TTemperatureCommand }

constructor TTemperatureCommand.Create;
begin
  inherited;

  FCode := 'temperature';
  FAlias := 't';
  FDescription := 'Displays a temperature';

  FArguments.Add(TCommandArgument.Create('c', 'Temperature in Celsius ', atFloat, false, ''));
  FArguments.Add(TCommandArgument.Create('f', 'Temperature in Fahrenheit', atFloat, false, ''));
end;

procedure TTemperatureCommand.execute;
var
  lCelsius,
  lFahrenheit : Extended;
begin
  lCelsius := values('c');
  lFahrenheit := values('f');

  if lCelsius > 0 then
    WriteLn(Format('Celsius temperature is %f', [lCelsius]));
  if lFahrenheit > 0 then
    WriteLn(Format('Fahrenheit temperature is %f', [lFahrenheit]));
end;

end.
