# Command Helper Library

A Delphi library that makes it easier to work with command line applications

## Features

- Auto parse command line arguments
- Validation - Checks for duplicate commands and arguments and makes sure that required arguments have been provided
- Cli app included to auto generate commands
- Auto generate, format and display application help

![](/docs/images/screenshot1.png)

- Allows sub commands. The example below shows the "move" command and its two sub commands ("up" and "down")

![](/docs/images/screenshot2.png)

## Cli

You can build and use the cmdgen application to quickly generate commands

## Usage

See the included demo application or follow along with the steps below

### 1) Build the cmdgen app

- Open cmdgen.dproj and build the the cmdgen.exe app
- Place the cmdgen.exe app in a directory in the Environment Variables "path"
- Open a new terminal, run "cmdgen" and check the the app was found and execute

### 2) Create a new console application that uses uCommandHelper.pas

From within the Delphi IDE

- Create a new Delphi console applications (File > New > Console Applications)
- Right-click on the Project, click "Add", navigate to the "command_helper\src\" folder and add uCommandHelper.pas
- Create a TAppCommand and add code the execute it (see the "command_helper\demo\CommandHelperDemo.dpr" for an example)

### 3) Start adding commands to your application

- Use the cmdgen.exe app to generate boilerplate command code. See an example below:

```console
cd myapp\src
cmdgen g list
```

The sample code above will create a list_command.pas in the "myapp\src" directory

### 4) Link the newly generated command to your application

- See "command_helper\demo\CommandHelperDemo.dpr" for an example
- You could add the TListCommand with a line like below

```
  lAppCommand.commands.add(TListCommand.Create);
```

You can add an application description with the appDescription property. See example below:

```
  lAppCommand.description := 'Sample app description';
```

That's it. Build your console application and run it without parameters. The application will automatically display application help
