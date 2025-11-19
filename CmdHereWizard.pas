unit CmdHereWizard;

interface

uses
   System.SysUtils,
   System.Classes,
   System.Types,
   Winapi.Windows,
   Winapi.ShellAPI,
   ToolsAPI;

type
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
   public
      constructor Create;

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
   sFileContainer        = 'FileContainer';
   sProjectContainer     = 'ProjectContainer';
   sProjectGroupContainer= 'ProjectGroupContainer';
   sDirectoryContainer   = 'DirectoryContainer';

function Quote(const S: string): string;
begin
   Result := '"' + S + '"';
end;

procedure OpenCmdHere(const Folder: string);
var
   Params: string;
begin
   if Folder = '' then Exit;
   Params := '/K cd /d ' + Quote(Folder);
   ShellExecute(0, 'open', 'cmd.exe', PChar(Params), nil, SW_SHOWNORMAL);
end;

function FolderOf(const FileName: string): string;
begin
   Result := IncludeTrailingPathDelimiter(ExtractFilePath(FileName));
end;

function LooksLikePath(const S: string): Boolean;
begin
   Result := (Length(S) > 1) and (S[2] = ':') and DirectoryExists(S) or FileExists(S);
end;

function FirstContext(const List: IInterfaceList): IOTAProjectMenuContext;
begin
   Result := nil;
   if (List <> nil) and (List.Count > 0) then
      Supports(List.Items[0], IOTAProjectMenuContext, Result);
end;

function ResolveClickedFolder(const MenuCtx: IOTAProjectMenuContext): string;
var
   ident, verb: string;
   prj: IOTAProject;
begin
   Result := '';
   if MenuCtx = nil then Exit;

   ident := MenuCtx.Ident;
   verb  := MenuCtx.Verb;

   if SameText(ident, sDirectoryContainer) then
   begin
      if LooksLikePath(verb) then
         Exit(IncludeTrailingPathDelimiter(verb));
   end;

   if SameText(ident, sFileContainer) then
   begin
      if FileExists(verb) then
         Exit(FolderOf(verb));
   end;

   if SameText(ident, sProjectContainer) or SameText(ident, sProjectGroupContainer) then
   begin
      prj := MenuCtx.Project;
      if (prj <> nil) and FileExists(prj.FileName) then
         Exit(FolderOf(prj.FileName));
   end;

   if DirectoryExists(verb) then
      Exit(IncludeTrailingPathDelimiter(verb));
   if FileExists(verb) then
      Exit(FolderOf(verb));

   prj := MenuCtx.Project;
   if (prj <> nil) and FileExists(prj.FileName) then
      Exit(FolderOf(prj.FileName));
end;

{=== TCmdHerePMCreator =======================================================}

procedure TCmdHerePMCreator.AddMenu(const Project: IOTAProject;
                                    const IdentList: TStrings;
                                    const ProjectManagerMenuList: IInterfaceList;
                                    IsMultiSelect: Boolean);
var
   Item: IOTAProjectManagerMenu;
begin
   Item := TCmdHereLocalMenu.Create;
   ProjectManagerMenuList.Add(Item);
end;

{=== TCmdHereLocalMenu =======================================================}

constructor TCmdHereLocalMenu.Create;
begin
   inherited Create;
   FCaption   := 'Open CMD here';
   FChecked   := False;
   FEnabled   := True;
   FHelpCtx   := 0;
   FName      := 'OpenCMDHere';
   FParent    := '';       { empty = no submenu }
   FPosition  := 0;        { 0 = IDE decides, change if you want custom positioning }
   FVerb      := '';       { not needed }
   FIsMulti   := True;     { open CMD for each selected node }
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
   Result := FHelpCtx; { 0 = no help }
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
            OpenCmdHere(Folder);
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
   if Supports(BorlandIDEServices, IOTAProjectManager, PM) then
      PM.AddMenuItemCreatorNotifier(TCmdHerePMCreator.Create);
end;

end.

