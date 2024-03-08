program CommandHelperDemo;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  uCommandHelper in '..\src\uCommandHelper.pas',
  sing_command in 'src\sing_command.pas',
  move_command in 'src\move_command.pas',
  move_down_command in 'src\move_down_command.pas',
  move_up_command in 'src\move_up_command.pas';

var
  lAppCommand : TAppCommand;
begin
  try
    lAppCommand := TAppCommand.Create;
    try
      lAppCommand.commands.Add(TSingCommand.create);
      lAppCommand.commands.Add(TMoveCommand.create);

      lAppCommand.description := 'This is a demo application that shows how to create an app using the uCommandHelpdesk library.'+#13#10+
                                 'The examples below show how you can run this application with a command and argument(s)'+#13#10+
                                 #13#10+
                                 'Examle 1: (Running the application without arguments will display help)'+#13#10+
                                 'CommandHelperDemo.exe'+#13#10+
                                 #13#10+
                                 'Examle 2: (If boolean arguments are omitted they default to false)'+#13#10+
                                 'CommandHelperDemo.exe sing -w="old mcdonald"'+#13#10+
                                 #13#10+
                                 'Examle 3: (Boolean arguments -u and -u=true have the same effect)'+#13#10+
                                 'CommandHelperDemo.exe sing -w="old mcdonald" -u'+#13#10+
                                 #13#10+
                                 'Examle 4: (move has sub commands. Note how help is now displayed for the move command)'+#13#10+
                                 'CommandHelperDemo.exe move'+#13+#10+
                                 #13#10+
                                 'Examle 5: (note that argument -w is defined for both the "sing" and "move up" commands. This is allowed)'+#13#10+
                                 'CommandHelperDemo.exe move up -s="Ahhh" -w';
                                 ;

      lAppCommand.execute;
    finally
      lAppCommand.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
