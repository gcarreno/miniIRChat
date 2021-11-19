  unit ChatRoomFrames;

{$mode objfpc}{$H+}
{$define use_webbrowser}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, ComCtrls, Menus, Graphics,
  LCLType,
  {$ifdef use_webbrowser}
  IpHtml,
  //HtmlView, HTMLSubs,
  {$endif}
  SynEdit, SynHighlighterMulti;

{
const
  sHTMLChat = {$i 'chat.html'}
}

type

  { TChatRoomFrame }

  TChatRoomFrame = class(TFrame)
    ChangeTopicBtn: TButton;
    MenuItem1: TMenuItem;
    SaveAsHtmlMnu: TMenuItem;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    TopicEdit: TEdit;
    WhoIsMnu: TMenuItem;
    OpMnu: TMenuItem;
    MenuItem2: TMenuItem;
    UsersPopupMenu: TPopupMenu;
    Splitter2: TSplitter;
    UserListBox: TListView;
    procedure ChangeTopicBtnClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure OpMnuClick(Sender: TObject);
    procedure SaveAsHtmlMnuClick(Sender: TObject);
    procedure WhoIsMnuClick(Sender: TObject);
  private
    function GetCurrentUser: string;
  protected
    {$ifdef use_webbrowser}
    //Viewer: THtmlViewer;
    Body: TIpHtmlNodeBODY;
    Viewer: TIpHtmlPanel;
    procedure HtmlEnumerator(Document: TIpHtml);
    {$else}
    MsgEdit: TSynEdit;
    {$endif}
  public
    RoomName: string;
    IsRoom: Boolean;
    constructor Create(TheOwner: TComponent); override;
    procedure AddMessage(aMsg: string; AClassName: string = ''; IsHeader: Boolean = False);
  end;

function CreateChatHTMLStream: TStream;

implementation

uses
  MainForm;

function CreateChatHTMLStream: TStream;
begin
  Result := TResourceStream.Create(hInstance, 'ChatHtml', RT_RCDATA);
end;

{$R *.lfm}

{ TChatRoomFrame }

procedure TChatRoomFrame.OpMnuClick(Sender: TObject);
var
  aUser: string;
begin
  aUser := GetCurrentUser;
  if aUser <> '' then
    IRC.OpUser(RoomName, aUser);
end;

procedure TChatRoomFrame.MenuItem1Click(Sender: TObject);
var
  aUser: string;
begin
  aUser := GetCurrentUser;
  if aUser <> '' then
    IRC.OpUser(RoomName, aUser);
end;

procedure TChatRoomFrame.SaveAsHtmlMnuClick(Sender: TObject);
begin

end;

procedure TChatRoomFrame.WhoIsMnuClick(Sender: TObject);
var
  aUser: string;
begin
  aUser := GetCurrentUser;
  if aUser <> '' then
    IRC.WhoIs(aUser);
end;

function TChatRoomFrame.GetCurrentUser: string;
begin
  Result := '';
  if UserListBox.Items.Count >0 then
  begin
    Result := UserListBox.Selected.Caption;
  end;
end;

{$ifdef use_webbrowser}
procedure TChatRoomFrame.HtmlEnumerator(Document: TIpHtml);
var
   n: TIpHtmlNode;
   nb: TIpHtmlNodeBODY;
   i: Integer;
begin
   if not Assigned(Document.HtmlNode) then begin
      Exit;
   end;
   if Document.HtmlNode.ChildCount < 1 then begin
      Exit;
   end;
   for i := 0 to Document.HtmlNode.ChildCount -1 do
   begin
     n := Document.HtmlNode.ChildNode[i];
     if (n is TIpHtmlNodeBODY) then
     begin
       Body := TIpHtmlNodeBODY(n);
       exit;
     end;
   end;
end;
{$endif}

procedure TChatRoomFrame.ChangeTopicBtnClick(Sender: TObject);
begin

end;

constructor TChatRoomFrame.Create(TheOwner: TComponent);
var
  i: Integer;
  aStream: TStream;
begin
  inherited Create(TheOwner);
  {$ifdef use_webbrowser}
  HandleAllocated;
  //Viewer := THtmlViewer.Create(Self);
  Viewer := TIpHtmlPanel.Create(Self);
  with Viewer do
  begin
    Parent := Self;
    Align := alClient;
    BorderStyle := bsNone;
    MarginHeight := 10;
    MarginWidth := 10;
    Visible := True;
    Font.Name := 'Courier New';
    Font.Size := 10;
    //ScrollBars := ssAutoVertical;
  end;
  //Viewer.LoadFromFile(Application.Location + 'chat.html');
  aStream:= CreateChatHTMLStream;
  try
    Viewer.SetHtmlFromStream(aStream);
    //Viewer.SetHtmlFromFile(Application.Location + 'chat.html');
  finally
    FreeAndNil(aStream);
  end;
  //Find Body
  //Viewer.EnumDocuments(@HtmlEnumerator);
  for i :=0 to Viewer.MasterFrame.Html.HtmlNode.ChildCount - 1 do
    if Viewer.MasterFrame.Html.HtmlNode.ChildNode[i] is TIpHtmlNodeBODY then
    begin
      Body := TIpHtmlNodeBODY(Viewer.MasterFrame.Html.HtmlNode.ChildNode[i]);
      break;
    end;
  {$else}
  MsgEdit := TSynEdit.Create(TheOwner);
  with MsgEdit do
  begin
    Parent := Self;
    //ParentWindow := Handle;
    Align := alClient;
    ScrollBars := ssAutoVertical;
    ReadOnly := True;
    Gutter.Visible := False;
    Options := Options + [eoHideRightMargin];
  end;
  {$endif}
end;

procedure TChatRoomFrame.AddMessage(aMsg: string; AClassName: string; IsHeader: Boolean);
{$ifdef use_webbrowser}
var
  TextNode: TIpHtmlNodeText;
  Node: TIpHtmlNodeInline;
{$endif}
begin
  {$ifdef use_webbrowser}
  if IsHeader then
  begin
    Node := TIpHtmlNodeHeader.Create(Body);
    (Node as TIpHtmlNodeHeader).Size := 4;
  end
  else
    Node := TIpHtmlNodeP.Create(Body);

  Node.ClassId := AClassName;

  TextNode := TIpHtmlNodeText.Create(Node);
  TextNode.AnsiText := aMsg;

  with TIpHtmlNodeBR.Create(Body) do
  begin
  end;

  Viewer.Update;
  Viewer.Scroll(hsaEnd);
  {$else}
  MsgEdit.Lines.Add(aMSG);
  MsgEdit.CaretY := MsgEdit.Lines.Count;
  //MsgEdit.ScrollBy(0, 1);
  {$endif}
end;

end.

