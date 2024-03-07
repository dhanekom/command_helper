unit uCommandHelper;

interface

uses
  System.Generics.Collections, System.SysUtils, System.Variants, System.Generics.Defaults;

type
  TArgumentType = (atString, atBoolean, atInteger);

  TArgumentValue = record
  private
    FArgumentType : TArgumentType;
    FValue : Variant;
  public
    function AsInteger : Integer;
    function AsBoolean : Boolean;
    function AsString : string;
    function AsVariant : Variant;
    function Value : Variant;
    function ArgumentType : TArgumentType;
    procedure SetValue(aValue : Variant);
    procedure SetArgumentType(aValue : TArgumentType);
  end;

  TCommandArgument = class
  protected
    FCode : string;
    FAlias : string;
    FDescription : string;
    FRequired : Boolean;
    FValue : TArgumentValue;
  public
    property code : string read FCode;
    property alias : string read FAlias;
    property description : string read FDescription;
    property value : TArgumentValue read FValue write FValue;
    property required : boolean read FRequired;

    procedure SetValue(aValue : string);
    function hasValue : Boolean;
    function ValueAsInteger : Integer;
    function ValueAsBoolean : Boolean;
    function ValueAsString : string;
    function ValueAsVariant : Variant;

    constructor Create(aCode : string; aDesc : string; aArgumentType : TArgumentType; aRequired : boolean; aAlias : string = ''; aDefaultValue : string = '');
    destructor Destroy; override;
  end;

  TCommand = class
  protected
    FCode : string;
    FArguments : TObjectlist<TCommandArgument>;
    FDescription : string;
    FCommands : TObjectList<TCommand>;
    FAlias : string;
    function validateCommands : Boolean;
    procedure sort;
    procedure displayHelp;
    procedure parse(aParamPosition : Integer = 1);
  public
    property code : string read FCode;
    property alias : string read FAlias;
    property arguments : TObjectlist<TCommandArgument> read FArguments;
    property description : string read FDescription;
    property commands : TObjectList<TCommand> read FCommands;

    function commandByCode(aCommandCode : string) : TCommand;
    function validateValues : Boolean;
    function getArgumentByCode(aCode : string) : TCommandArgument;
    function values(aArgCode : string) : variant;

    procedure execute; virtual; abstract;
    constructor Create; virtual;
    destructor Destroy; override;
  end;

  TAppCommand = class(TCommand)
  public
    property description : string read FDescription write FDescription;

    procedure execute; override;
    constructor Create; override;
  end;

function ArgumentTypeToString(aArgumentType : TArgumentType) : string;

implementation

{ TCommand }

function ArgumentTypeToString(aArgumentType : TArgumentType) : string;
begin
  case aArgumentType of
    atString: result := 'string';
    atBoolean: result := 'boolean';
    atInteger: result := 'integer';
  end;
end;

destructor TCommand.Destroy;
begin
  FArguments.Free;
  FCommands.Free;
  inherited;
end;

function TCommand.getArgumentByCode(aCode: string): TCommandArgument;
var
  i : integer;
begin
  result := nil;

  if not aCode.StartsWith('-') then
    aCode := '-'+aCode;

  for i := 0 to FArguments.Count -1 do
  begin
    if FArguments[i].code = aCode then
    begin
      result := FArguments[i];
      Exit;
    end;
  end;
end;

procedure TCommand.parse(aParamPosition : Integer = 1);
var
  lCommand : TCommand;
  lArg : TCommandArgument;
  i : Integer;
  lParamKeyValueArr : TArray<System.string>;
begin
  if not validateCommands then
    Exit;

  if (ParamCount = aParamPosition -1 ) or
     ((ParamCount = aParamPosition) and
      ((AnsiCompareText('-h', ParamStr(aParamPosition)) = 0) or (AnsiCompareText('-help', ParamStr(aParamPosition)) = 0))) then
  begin
    DisplayHelp;
    Exit;
  end;

  sort;

  lCommand := commandByCode(ParamStr(aParamPosition));
  if (lCommand = nil) then
  begin
    DisplayHelp;
    Exit;
  end;

  if lCommand.commands.Count > 0 then
  begin
    lCommand.parse(aParamPosition + 1);
    Exit;
  end;

  i := aParamPosition + 1;
  while i <= ParamCount do
  begin
    lParamKeyValueArr := ParamStr(i).Split(['=']);
    if not (length(lParamKeyValueArr) in [1, 2]) then
    begin
      Writeln(Format('** argument "%s" is invalid **', [ParamStr(i)]));
      Exit;
    end;

    lArg := lCommand.getArgumentByCode(lParamKeyValueArr[0]);
    if lArg = nil then
    begin
      Writeln(Format('** argument "%s" not configured for command "%s" **', [lParamKeyValueArr[0], lCommand.code]));
      Exit;
    end;

    if length(lParamKeyValueArr) = 1 then
    begin
      if lArg.value.argumentType <> TArgumentType.atBoolean then
      begin
        Writeln(Format('** argument "%s" requires a value **', [lArg.code]));
        Exit;
      end;

      lArg.SetValue('true');
    end
    else
    begin
      lArg.SetValue(lParamKeyValueArr[1]);
    end;

    inc(i);
  end;

  if not lCommand.validateValues then
    Exit;

  lCommand.Execute;
end;

function TCommand.validateValues: Boolean;
var
  lArg : TCommandArgument;
  lValid : Boolean;
begin
  lValid := True;

  for lArg in FArguments do
  begin
    if lArg.required and
       VarIsEmpty(lArg.Value.AsVariant) then
    begin
      Writeln(Format('** argument %s (%s) requires a value **', [lArg.Code, lArg.description]));
      lValid := false;
    end;
  end;

  result := lValid;
end;

function TCommand.values(aArgCode: string): Variant;
var
  i : integer;
begin
  result := null;

  if not aArgCode.StartsWith('-') then
    aArgCode := '-'+aArgCode;

  for i := 0 to FArguments.Count -1 do
  begin
    if FArguments[i].code = aArgCode then
    begin
      result := FArguments[i].value.Value;
      Exit;
    end;
  end;
end;

constructor TCommand.Create;
begin
  inherited;
  FArguments := TObjectlist<TCommandArgument>.Create(True);
  FCommands := TObjectList<TCommand>.Create(True);
end;

{ TCommandArgument }

function TCommandArgument.ValueAsBoolean: Boolean;
begin
  result := value.AsBoolean;
end;

function TCommandArgument.ValueAsInteger: Integer;
begin
  result := value.AsInteger;
end;

function TCommandArgument.ValueAsString: string;
begin
  result := value.AsString;
end;

function TCommandArgument.ValueAsVariant: Variant;
begin
  result := value.AsVariant;
end;

constructor TCommandArgument.Create(aCode : string; aDesc : string; aArgumentType : TArgumentType;
  aRequired : boolean; aAlias : string = ''; aDefaultValue : string = '');
begin
  FValue.SetArgumentType(aArgumentType);

  aCode.TrimLeft(['-']);

  FCode := '-'+aCode;
  FDescription := aDesc;
  FRequired := aRequired;
  FAlias := aAlias;
  if aArgumentType = atBoolean then
  begin
    FValue.SetValue(StrToBoolDef(aDefaultValue, false));
  end
  else
  if aDefaultValue <> '' then
    FValue.SetValue(aDefaultValue);
end;

destructor TCommandArgument.Destroy;
begin
  inherited;
end;

function TCommandArgument.hasValue: Boolean;
begin
  result := VarIsEmpty(FValue.AsVariant);
end;

procedure TCommandArgument.SetValue(aValue: string);
begin
  FValue.SetValue(aValue);
end;

{ TCommands }

procedure TCommand.displayHelp;

  procedure addCommandHelp(aCommand : TCommand);
  var
    lArgLine : string;
    lArg : TCommandArgument;
    lAlias : string;
    lOptional : string;
  begin
    if aCommand.alias <> '' then
      lAlias := ' ('+aCommand.alias+')';

    WriteLn(('  ' + aCommand.code + lAlias + lArgLine+':').PadRight(35) + aCommand.description);
    if aCommand.FArguments.Count > 0 then
    for lArg in aCommand.FArguments do
    begin
      lOptional := '';
      if not lArg.required then
        lOptional := ' (optional)';

      Writeln(Format('    %s  %s'+lOptional+':', [lArg.code, ArgumentTypeToString(lArg.value.ArgumentType)]).PadRight(35) + lArg.description);
    end;
  end;

var
  lCommand : TCommand;
  lAlias : string;
begin
  if (self is TAppCommand) and
     (TAppCommand(self).description.trim <> '') then
  begin
    WriteLn(TAppCommand(self).description.trim);
    WriteLn('');
  end;

  WriteLn(format('Usage: %s [COMMAND...] [arg...]', [ExtractFileName(ParamStr(0))]));

  WriteLn('');
  if FCommands.Count = 0 then
  begin
    WriteLn('** No commands configure yet **');
  end
  else
  begin
    if self is TAppCommand then
    begin
      WriteLn('Commands:');
    end
    else
    begin
      if alias <> '' then
        lAlias := ' ('+alias+')';
      WriteLn('Command: '+ FCode + lAlias);
      WriteLn('Subcommands:');
    end;
    for lCommand in FCommands do
    begin
      addCommandHelp(lCommand);
    end;
  end;
end;

function TCommand.commandByCode(aCommandCode: string): TCommand;
var
  i : integer;
begin
  result := nil;

  for i := 0 to FCommands.Count -1 do
  begin
    if (AnsiCompareText(FCommands[i].code, aCommandCode) = 0) or
       (AnsiCompareText(FCommands[i].alias, aCommandCode) = 0) then
    begin
      result := FCommands[i];
      Exit;
    end;
  end;
end;

procedure TCommand.sort;
begin
  commands.Sort(
    TComparer<TCommand>.Construct(
      function(const Left, Right: TCommand): integer
      begin
        if Left.code < Right.code then
          result := -1
        else
        if Left.code > Right.code then
          result := 1
        else
          result := 0;
      end
    )
  );
end;

function TCommand.validateCommands: Boolean;
var
  i, x, y : Integer;
begin
  result := false;

  for i := 0 to FCommands.Count -1 do
  begin
    if FCommands[i].commands.Count > 0 then
    begin
      for x := 0 to FCommands[i].commands.Count -1 do
      begin
        if not FCommands[i].commands[x].validateCommands then
          Exit;
      end;
    end;

    if (Trim(FCommands[i].code) = '') then
    begin
      Writeln(Format('** all commands require a code **', []));
      Exit;
    end;

    if (Trim(FCommands[i].description) = '') then
    begin
      Writeln(Format('** command "%s" requires a description **', [FCommands[i].code]));
      Exit;
    end;

    for x := 0 to FCommands.Count -1 do
    begin
      if i <> x then
      begin
        if (AnsiCompareText(FCommands[i].code, FCommands[x].code) = 0) then
        begin
          WriteLn(Format('** command "%s" has duplicate entries **', [FCommands[i].code]));
          Exit;
        end;
      end;
    end;

    for x := 0 to FCommands[i].arguments.Count -1 do
    begin
      for y := 0 to FCommands[i].arguments.Count -1 do
      begin
        if x <> y then
        begin
          if AnsiCompareText(FCommands[i].arguments[x].code, FCommands[i].arguments[y].code) = 0 then
          begin
            WriteLn(Format('** command "%s" has duplicate entries for argument %s **', [FCommands[i].code, FCommands[i].arguments[x].code]));
            Exit;
          end;
        end;
      end;
    end;

    if (FCommands[i].commands.Count > 0) and
       (FCommands[i].arguments.Count > 0) then
    begin
      WriteLn(Format('** command "%s" has sub commands and is not allowed to have any arguments **', [FCommands[i].code]));
      Exit;
    end;
  end;

  result := True;
end;

{ TArgumentValue }

function TArgumentValue.ArgumentType: TArgumentType;
begin
  Result := FArgumentType;
end;

function TArgumentValue.AsBoolean: Boolean;
begin
  result := StrToBool(FValue);
end;

function TArgumentValue.AsInteger: Integer;
begin
  result := StrToInt(FValue);
end;

function TArgumentValue.AsString: string;
begin
  result := VarToStr(FValue);
end;

function TArgumentValue.AsVariant: Variant;
begin
  result := FValue;
end;

procedure TArgumentValue.SetArgumentType(aValue: TArgumentType);
begin
  FArgumentType := aValue;
end;

procedure TArgumentValue.SetValue(aValue: Variant);
begin
  FValue := aValue;
end;

function TArgumentValue.Value: Variant;
begin
  case FArgumentType of
    atBoolean: result := AsBoolean;
    atInteger: result := AsInteger;
  else
    result := AsString;
  end;
end;

{ TAppCommand }

constructor TAppCommand.Create;
begin
  inherited;
end;

procedure TAppCommand.execute;
begin
  parse;
end;

end.
