unit sing_command;

interface

uses
  uCommandHelper, System.SysUtils;

type

  TSingCommand = class(TCommand)
  public
    procedure execute; override;
    constructor Create; override;
  end;

implementation

{ TSingCommand }

constructor TSingCommand.Create;
begin
  inherited;

  FCode := 'sing';
  FAlias := 's';
  FDescription := 'Sing a song';

  FArguments.Add(TCommandArgument.Create('w', 'Words of the song', atString, true));
  FArguments.Add(TCommandArgument.Create('u', 'Uppercase the words', atBoolean, true));
end;

procedure TSingCommand.execute;
var
  lWords : string;
  lUppercase : Boolean;
begin
  lWords := values('w');
  lUppercase := values('u');

  if lUppercase then
    lWords := lWords.ToUpper;
  Writeln('Must uppercase words: '+BoolToStr(lUppercase, true));
  WriteLn('Song words: '+ lWords);
end;

end.
