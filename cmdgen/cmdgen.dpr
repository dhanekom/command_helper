program cmdgen;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  create_command_command in 'src\create_command_command.pas',
  uCommandHelper in '..\src\uCommandHelper.pas';

var
  lAppCommand : TAppCommand;
begin
  try
    lAppCommand := TAppCommand.Create;
    try
      lAppCommand.commands.add(TCreateCommandCommand.Create);

      lAppCommand.description := 'dcmd generates commands for applications that uses the uCommandHelper library.';

      lAppCommand.execute;
    finally
      lAppCommand.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
