unit create_command_command;

interface

uses
  uCommandHelper, System.SysUtils, System.Classes, System.Variants;

type

  TCreateCommandCommand = class(TCommand)
  public
    procedure execute; override;
    constructor Create; override;
  end;

implementation

{ TCreateCommandCommand }

constructor TCreateCommandCommand.Create;
begin
  inherited;

  FCode := 'generate';
  FAlias := 'g';
  FDescription := 'Generate a new command';

  FArguments.Add(TCommandArgument.Create('c', 'Command name to generate', atString, true));
end;

procedure TCreateCommandCommand.execute;
var
  lCommandName : string;
  lClassName : string;
  lFile : TStringlist;
  lArr : TArray<string>;
  i, x : integer;
  lFilePath : string;
begin
  lCommandName := VarToStr(values('c')).ToLower;
  lArr := lCommandName.Split(['_']);
  lClassName := '';
  for i := Low(lArr) to High(lArr) do
  begin
    for x := 1 to Length(lArr[i]) do
    begin
      if x = 1 then
        lClassName := lClassName + Copy(lArr[i], x, 1).ToUpper
      else
        lClassName := lClassName + Copy(lArr[i], x, 1);
    end;
  end;

  lCommandName := lCommandName + '_command';
  lClassName := 'T'+lClassName+'Command';
  lFilePath := GetCurrentDir + '\' +lCommandName+'.pas';

  if FileExists(lFilePath) then
  begin
    Writeln(Format('file %s for command %s already exists', [lFilePath, lClassName]));
    Exit;
  end;

  lFile := TStringlist.Create;
  Try
    lFile.Add('unit '+ lCommandName+';');
    lFile.Add('');
    lFile.Add('interface');
    lFile.Add('');
    lFile.Add('uses');
    lFile.Add('  uCommandHelper, System.SysUtils;');
    lFile.Add('');
    lFile.Add('type');
    lFile.Add('');
    lFile.Add('  '+lClassName+' = class(TCommand)');
    lFile.Add('  public');
    lFile.Add('    procedure execute; override;');
    lFile.Add('    constructor Create; override;');
    lFile.Add('  end;');
    lFile.Add('');
    lFile.Add('implementation');
    lFile.Add('');
    lFile.Add('{ '+lClassName+' }');
    lFile.Add('');
    lFile.Add('constructor '+lClassName+'.Create;');
    lFile.Add('begin');
    lFile.Add('  inherited;');
    lFile.Add('');
    lFile.Add('  FCode := '''+lArr[0].ToLower+''';');
    lFile.Add('  FAlias := '''+Copy(lArr[0].ToLower, 1, 1)+''';');
    lFile.Add('  FDescription := ''Sample description'';');
    lFile.Add('');
    lFile.Add('  //FArguments.Add(TCommandArgument.Create('''', '''', atString, true, ''''));');
    lFile.Add('end;');
    lFile.Add('');
    lFile.Add('procedure '+lClassName+'.execute;');
    lFile.Add('begin');
    lFile.Add('  WriteLn(Format(''command "%s" executed'', [FCode]));');
    lFile.Add('end;');
    lFile.Add('');
   	lFile.Add('end.');

    lFile.SaveToFile(lFilePath);
    Writeln('successfully created command '+lClassName+' in ' +lFilePath);
  Finally
    lFile.free;
  End;
end;

end.
