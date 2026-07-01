unit CmdHereWizard;

interface

uses
   System.SysUtils,
   System.Classes,
   System.Types,
   System.IOUtils,
   Winapi.Windows,
   Winapi.ShellAPI,
   ToolsAPI;

type
   TShellKind = (skCmd, skWindowsTerminal);

   TCmdHerePMCreator = class(TNotifierObject, IOTAProjectMenuItemCreatorNotifier)
   public
      procedure AddMenu(const Project: IOTAProject;
                        const IdentList: TStrings;
                        const ProjectManagerMenuList: IInterfaceList;
                        IsMultiSelect: Boolean);
   end;

   TCmdHereLocalMenu = class(TNotifierObject, IOTALocalMenu, IOTAProjectManagerMenu)
   private
      FCaption: string;
      FChecked: Boolean;
      FEnabled: Boolean;
      FHelpCtx: Integer;
      FName: string;
      FParent: string;
      FPosition: Integer;
      FVerb: string;
      FIsMulti: Boolean;
      FShell: TShellKind;
   public
      constructor Create(AShell: TShellKind); reintroduce;

      { IOTALocalMenu }
      function GetCaption: string;
      procedure SetCaption(const Value: string);
      function GetChecked: Boolean;
      procedure SetChecked(Value: Boolean);
      function GetEnabled: Boolean;
      procedure SetEnabled(Value: Boolean);
      function GetHelpContext: Integer;
      procedure SetHelpContext(Value: Integer);
      function GetName: string;
      procedure SetName(const Value: string);
      function GetParent: string;
      procedure SetParent(const Value: string);
      function GetPosition: Integer;
      procedure SetPosition(Value: Integer);
      function GetVerb: string;
      procedure SetVerb(const Value: string);

      { IOTAProjectManagerMenu }
      function GetIsMultiSelectable: Boolean;
      procedure SetIsMultiSelectable(Value: Boolean);
      function PreExecute(const MenuContextList: IInterfaceList): Boolean;
      procedure Execute(const MenuContextList: IInterfaceList);
      function PostExecute(const MenuContextList: IInterfaceList): Boolean;
   end;

procedure Register;

implementation

const
   sFileContainer         = 'FileContainer';
   sProjectContainer      = 'ProjectContainer';
   sProjectGroupContainer = 'ProjectGroupContainer';
   sDirectoryContainer    = 'DirectoryContainer';

var
   GNotifierIndex: Integer = -1;
   GHasWindowsTerminal: Boolean = False;

function Quote(const S: string): string;
begin
   Result := '"' + S + '"';
end;

function ShellAvailable(const ExeName: string): Boolean;
var
   Buf: array[0..MAX_PATH - 1] of Char;
   FilePart: PChar;
begin
   Result := SearchPath(nil, PChar(ExeName), nil, MAX_PATH, Buf, FilePart) > 0;
end;

procedure LaunchShell(AShell: TShellKind; const Folder: string);
var
   Exe, Params: string;
begin
   if (Folder = '') or not TDirectory.Exists(Folder) then Exit;

   case AShell of
      skCmd:
         begin
            Exe := 'cmd.exe';
            Params := '';
         end;
      skWindowsTerminal:
         begin
            Exe := 'wt.exe';
            Params := '-d ' + Quote(Folder);
         end;
   end;

   ShellExecute(0, 'open', PChar(Exe), PChar(Params), PChar(Folder), SW_SHOWNORMAL);
end;

function FolderOf(const FileName: string): string;
begin
   Result := IncludeTrailingPathDelimiter(ExtractFilePath(FileName));
end;

function LooksLikePath(const S: string): Boolean;
begin
   if S = '' then
      Exit(False);
   Result := (TPath.IsPathRooted(S) and TDirectory.Exists(S)) or TFile.Exists(S);
end;

function ProjectFolder(const Project: IOTAProject): string;
var
   Cur: IOTAProjectCurrentFolder;
begin
   Result := '';
   if Project = nil then Exit;

   if Supports(Project, IOTAProjectCurrentFolder, Cur) then
   begin
      Result := Cur.CurrentFolderPath;
      if (Result <> '') and TDirectory.Exists(Result) then
         Exit(IncludeTrailingPathDelimiter(Result));
      Result := '';
   end;

   if TFile.Exists(Project.FileName) then
      Result := FolderOf(Project.FileName);
end;

function ResolveClickedFolder(const MenuCtx: IOTAProjectMenuContext): string;
var
   ident, verb: string;
begin
   Result := '';
   if MenuCtx = nil then Exit;

   ident := MenuCtx.Ident;
   verb  := MenuCtx.Verb;

   if SameText(ident, sDirectoryContainer) then
   begin
      if LooksLikePath(verb) and TDirectory.Exists(verb) then
         Exit(IncludeTrailingPathDelimiter(verb));
   end;

   if SameText(ident, sFileContainer) then
   begin
      if TFile.Exists(verb) then
         Exit(FolderOf(verb));
   end;

   if SameText(ident, sProjectContainer) or SameText(ident, sProjectGroupContainer) then
   begin
      Result := ProjectFolder(MenuCtx.Project);
      if Result <> '' then Exit;
   end;

   if TDirectory.Exists(verb) then
      Exit(IncludeTrailingPathDelimiter(verb));
   if TFile.Exists(verb) then
      Exit(FolderOf(verb));

   Result := ProjectFolder(MenuCtx.Project);
end;

{=== TCmdHerePMCreator =======================================================}

procedure TCmdHerePMCreator.AddMenu(const Project: IOTAProject;
                                    const IdentList: TStrings;
                                    const ProjectManagerMenuList: IInterfaceList;
                                    IsMultiSelect: Boolean);
begin
   ProjectManagerMenuList.Add(IOTAProjectManagerMenu(TCmdHereLocalMenu.Create(skCmd)));
   if GHasWindowsTerminal then
      ProjectManagerMenuList.Add(IOTAProjectManagerMenu(TCmdHereLocalMenu.Create(skWindowsTerminal)));
end;

{=== TCmdHereLocalMenu =======================================================}

constructor TCmdHereLocalMenu.Create(AShell: TShellKind);
begin
   inherited Create;
   FShell    := AShell;
   FChecked  := False;
   FEnabled  := True;
   FHelpCtx  := 0;
   FIsMulti  := True;
   FVerb     := '';
   FParent   := '';

   case AShell of
      skCmd:
         begin
            FCaption  := 'Open CMD here';
            FName     := 'OpenCmdHereItem';
            FPosition := 1;
         end;
      skWindowsTerminal:
         begin
            FCaption  := 'Open Windows Terminal here';
            FName     := 'OpenWindowsTerminalHereItem';
            FPosition := 2;
         end;
   end;
end;

function TCmdHereLocalMenu.GetCaption: string;
begin
   Result := FCaption;
end;

procedure TCmdHereLocalMenu.SetCaption(const Value: string);
begin
   FCaption := Value;
end;

function TCmdHereLocalMenu.GetChecked: Boolean;
begin
   Result := FChecked;
end;

procedure TCmdHereLocalMenu.SetChecked(Value: Boolean);
begin
   FChecked := Value;
end;

function TCmdHereLocalMenu.GetEnabled: Boolean;
begin
   Result := FEnabled;
end;

procedure TCmdHereLocalMenu.SetEnabled(Value: Boolean);
begin
   FEnabled := Value;
end;

function TCmdHereLocalMenu.GetHelpContext: Integer;
begin
   Result := FHelpCtx;
end;

procedure TCmdHereLocalMenu.SetHelpContext(Value: Integer);
begin
   FHelpCtx := Value;
end;

function TCmdHereLocalMenu.GetName: string;
begin
   Result := FName;
end;

procedure TCmdHereLocalMenu.SetName(const Value: string);
begin
   FName := Value;
end;

function TCmdHereLocalMenu.GetParent: string;
begin
   Result := FParent;
end;

procedure TCmdHereLocalMenu.SetParent(const Value: string);
begin
   FParent := Value;
end;

function TCmdHereLocalMenu.GetPosition: Integer;
begin
   Result := FPosition;
end;

procedure TCmdHereLocalMenu.SetPosition(Value: Integer);
begin
   FPosition := Value;
end;

function TCmdHereLocalMenu.GetVerb: string;
begin
   Result := FVerb;
end;

procedure TCmdHereLocalMenu.SetVerb(const Value: string);
begin
   FVerb := Value;
end;

function TCmdHereLocalMenu.GetIsMultiSelectable: Boolean;
begin
   Result := FIsMulti;
end;

procedure TCmdHereLocalMenu.SetIsMultiSelectable(Value: Boolean);
begin
   FIsMulti := Value;
end;

function TCmdHereLocalMenu.PreExecute(const MenuContextList: IInterfaceList): Boolean;
begin
   Result := False;
end;

procedure TCmdHereLocalMenu.Execute(const MenuContextList: IInterfaceList);
var
   i: Integer;
   Ctx: IOTAProjectMenuContext;
   Folder: string;
begin
   if (MenuContextList = nil) or (MenuContextList.Count = 0) then Exit;

   for i := 0 to MenuContextList.Count - 1 do
   begin
      if Supports(MenuContextList.Items[i], IOTAProjectMenuContext, Ctx) then
      begin
         Folder := ResolveClickedFolder(Ctx);
         if Folder <> '' then
            LaunchShell(FShell, Folder);
      end;
   end;
end;

function TCmdHereLocalMenu.PostExecute(const MenuContextList: IInterfaceList): Boolean;
begin
   Result := False;
end;

{=== Registration ============================================================}

procedure Register;
var
   PM: IOTAProjectManager;
begin
   GHasWindowsTerminal := ShellAvailable('wt.exe');

   if Supports(BorlandIDEServices, IOTAProjectManager, PM) then
      GNotifierIndex := PM.AddMenuItemCreatorNotifier(TCmdHerePMCreator.Create);
end;

procedure UnregisterNotifier;
var
   PM: IOTAProjectManager;
begin
   if GNotifierIndex < 0 then Exit;
   if Supports(BorlandIDEServices, IOTAProjectManager, PM) then
      PM.RemoveMenuItemCreatorNotifier(GNotifierIndex);
   GNotifierIndex := -1;
end;

initialization

finalization
   UnregisterNotifier;

end.
