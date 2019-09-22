unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus, ExtCtrls, LazFileUtils, LResources, LazUnicode;

const
  SECTORSIZE: integer = 256;   {one sector in BAM in bytes}
  MAXROMSIZE: integer = 512;   {in kB}
  SAVEFILEID: String = 'TVC MultiCart ROM Image Save File';

type

  TMC21RecordType = (none, basic, cart, cas, bin);

  FileOfByte = File of Byte;

  TImageRec = class(TObject)
    fileName: string;
    displayName: string;
    bank: integer;
    block: integer;
    size : integer;
    blockNum : Integer;
    recType: TMC21RecordType;
  end;

  TImageBuffer = array of byte;

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ListBox1: TListBox;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    OpenDialog3: TOpenDialog;
    PaintBox1: TPaintBox;
    PopupMenu1: TPopupMenu;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    RadioButton6: TRadioButton;
    RadioButton7: TRadioButton;
    RadioButton8: TRadioButton;
    SaveDialog1: TSaveDialog;
    SaveDialog2: TSaveDialog;
    TaskDialog1: TTaskDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit1EditingDone(Sender: TObject);
    procedure Edit1Exit(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: char);
    procedure Edit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure GroupBox3Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure ListBox1KeyPress(Sender: TObject; var Key: char);
    procedure ListBox1KeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ListBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure PaintBox1Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure RadioButton3Change(Sender: TObject);
    procedure insertFS();
    procedure insertDirectory(bamStartPos: Integer);
    procedure insertBAM(bamStartPos: Integer);
    procedure saveTVCFile(fileName : String);
    procedure writeBAMs(fs: TFileStream);
    procedure writeROMs(fs: TFileStream);
    procedure writeDir(fs: TFileStream);
    procedure readBAMs(fs : TFileStream);
    procedure readROMs(fs : TFileStream);
    procedure readDirectory(fs : TFileStream);
    procedure readImageFileName(fs : TFileStream);
    function checkTVCFile(fs : TFileStream): boolean;
  private
    checkBoxes: array[1..8] of TRadioButton;
    buttonPressed: TMouseButton;
  public
    mcROMImageFile : String;
    tvcROMSaveFile : String;
  end;

var
  Form1: TForm1;
  BAM1: TBits;
  BAM2: TBits;
  ROM1: TImageBuffer;
  ROM2: TImageBuffer;
  romSize1, romSize2: integer;

procedure setFirmware;
procedure setROMSize(rs1: integer; rs2: integer);
function getFreeBlocks(): integer;
procedure createImageRec(fileName: string; var imageRec: TImageRec);
function addImageToROM(var imageRec: TImageRec): boolean;
function allocateCart(bankOffset, blockNum: integer; BAM: TBits;
  var imageRec: TImageRec): boolean;
function allocateCart(blockNum: integer; var imageRec: TImageRec): boolean;
procedure updateFreeSpace;

implementation

{$R *.lfm}


{ TForm1 }

procedure TForm1.GroupBox3Click(Sender: TObject);
var
  i, s1, s2: integer;
  rb: TRadioButton;
begin
  s1:=0;
  s2:=0;
  for i := 0 to GroupBox1.ControlCount - 1 do
  begin
    rb := TRadioButton(GroupBox1.Controls[i]);
    if (rb.Checked) then
    begin
      s1 := rb.Tag;
      break;
    end;
  end;
  for i := 0 to GroupBox2.ControlCount - 1 do
  begin
    rb := TRadioButton(GroupBox2.Controls[i]);
    if (rb.Checked) then
    begin
      s2 := rb.Tag;
      break;
    end;
  end;
  setROMSize(s1, s2);
  updateFreeSpace;
  PaintBox1.Refresh;
end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin

end;

procedure TForm1.ListBox1DblClick(Sender: TObject);
begin
  if ListBox1.ItemIndex <> -1 then
  begin
    MenuItem8Click(Sender);
  end;
end;

procedure TForm1.ListBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case key of
    38: {up}
    begin
      if ssShift in Shift then
      begin
        MenuItem9Click(sender);
        key:=0;
      end;
    end;
    40: {down}
    begin
      if ssShift in Shift then
      begin
        MenuItem10Click(sender);
        key:=0;
      end;
    end;
    46: {delete}
    begin
      if Shift = [] then
      begin
        MenuItem11Click(sender);
      end;
    end;
  end;

end;

procedure TForm1.ListBox1KeyPress(Sender: TObject; var Key: char);
begin
end;

procedure TForm1.ListBox1KeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  case key of
    13: {enter}
    begin
      if Shift = [] then
      begin
        MenuItem8Click(sender);
      end;
    end;
  end;
end;

procedure TForm1.ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var idx : Integer;
begin
  idx := ListBox1.GetIndexAtXY(x, y);
  if (idx>=0) and (Button = mbRight) Then
  begin
    listbox1.Selected[idx]:=true;
    buttonPressed:=button;
  end;
end;

procedure TForm1.ListBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if ButtonPressed = mbRight Then
  begin
    listbox1.Selected[ListBox1.GetIndexAtXY(x, y)]:=true;
  end;
end;

procedure TForm1.ListBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var idx : integer;
  glopos : TPoint;
begin
  idx := ListBox1.GetIndexAtXY(x, y);
  if (idx>=0) and (Button = mbRight) Then
  begin
    buttonPressed:=TMouseButton.mbLeft;
    if idx<0 Then exit;
    listbox1.Selected[idx]:=true;
    MenuItem9.Enabled := idx <> 0;
    MenuItem10.Enabled:= idx <> ListBox1.Count-1;
    glopos:=ListBox1.ClientToScreen(Point (X,Y));
    PopupMenu1.PopUp(glopos.x, glopos.y);
  end;
end;

procedure TForm1.MenuItem10Click(Sender: TObject);
var item : TStringItem;
    idx : Integer;
begin
  idx := ListBox1.ItemIndex;
  if (idx = -1) or (idx = ListBox1.Count-1) then exit;
  item.FString := ListBox1.Items.Strings[idx];
  item.FObject := ListBox1.items.Objects[idx];
  ListBox1.Items.Strings[idx] := ListBox1.Items.Strings[idx+1];
  ListBox1.items.Objects[idx] := ListBox1.items.Objects[idx+1];
  ListBox1.Items.Strings[idx+1] := item.FString;
  ListBox1.items.Objects[idx+1] := item.FObject;
  ListBox1.ItemIndex:=idx + 1;
end;

procedure removeCas(bank, block: Integer);
var b1, b2: Integer;
        bam: TBits;
    rom: array of byte;
begin
  repeat
    if bank>31 then
    begin
      bam:=BAM2;
      rom:=ROM2;
      dec(bank, 32);
    end
    else
    begin
      bam:=BAM1;
      rom:=ROM1;
    end;
    bam.Clear(bank*64+block);
    b1:=ROM[bank*16384+block*256];
    b2:=ROM[bank*16384+block*256+1];
    if(b1=bank) and (b2=block) Then
      break;
    bank:=b1;
    block:=b2;
  until bank=255;
end;
procedure removeCart(bank, block, blockNum:Integer);
var     bam: TBits;
    i:integer;
begin
  if bank>31 then
    begin
      bam:=BAM2;
      dec(bank, 32);
    end
    else
    begin
      bam:=BAM1;
    end;
  for i:=0 to blockNum-1 Do
  begin
    bam.Clear(bank*64+block+i);
  end;
end;

procedure TForm1.MenuItem11Click(Sender: TObject);
var
    idx : Integer;
    imageRec : TImageRec;
    bank, block : integer;
begin
  idx := ListBox1.ItemIndex;
  if idx = -1 then exit;
  imageRec := TIMageRec(ListBox1.Items.Objects[idx]);
  bank := imageRec.bank;
  block:=imageRec.block;
  case imageRec.recType of
    cas:
      begin
        removeCas(bank, block);
      end;
    cart:
      begin
        removeCart(bank, block, imageRec.blockNum);
      end;
  end;
  imageRec.Free;
  ListBox1.DeleteSelected;
  PaintBox1.Refresh;
  updateFreeSpace;
  if ListBox1.Count=0 then
  begin
    GroupBox3.enabled:=true;
  end;
end;

procedure TForm1.writeBAMs(fs: TFileStream);
var i, j, val: Integer;
begin
  fs.WriteWord(romSize1);
  fs.WriteWord(romSize2);

  for i:=0 to ((BAM1.Size) div 8) - 1 Do
  begin
    val:=0;
    for j:=0 to 7 Do
    begin
      val := val shl 1;
      val := val or byte(BAM1.Bits[i*8+j]);
    end;
    fs.WriteByte(byte(val));
  end;
  for i:=0 to ((BAM2.Size) div 8) - 1 Do
  begin
    val:=0;
    for j:=0 to 7 Do
    begin
      val := val shl 1;
      val := val or byte(BAM2.Bits[i*8+j]);
    end;
    fs.WriteByte(byte(val));
  end;
end;

procedure TForm1.writeROMs(fs: TFileStream);
var i : integer;
begin
  for i:=0 to romSize1*1024-1 Do
    fs.writeByte(ROM1[i]);
  for i:=0 to romSize2*1024-1 Do
    fs.writeByte(ROM2[i]);
end;

procedure TForm1.writeDir(fs: TFileStream);
var i: Integer;
    imageRec : TImageRec;
begin
  fs.WriteWord(ListBox1.Count);
  for i:=0 to ListBox1.Count - 1 Do
    fs.WriteAnsiString(ListBox1.Items.Strings[i]);
  for i:=0 to ListBox1.Count - 1 Do
  Begin
    imageRec := TImageRec(ListBox1.Items.Objects[i]);
    fs.WriteAnsiString(imageRec.fileName);
    fs.WriteByte(byte(imageRec.size));
    fs.WriteByte(byte(imageRec.bank));
    fs.WriteByte(byte(imageRec.block));
    fs.WriteByte(byte(imageRec.blockNum));
    fs.WriteAnsiString(imageRec.displayName);
    case imageRec.recType of
      TMC21RecordType.basic:
        fs.WriteByte(1);
      TMC21RecordType.cart:
        fs.WriteByte(2);
      TMC21RecordType.cas:
        fs.WriteByte(3);
      TMC21RecordType.bin:
        fs.WriteByte(4);
    end;
  end;
end;


procedure TForm1.saveTVCFile(fileName: String);
var fs : TFileStream;
begin
  try
    try
      fs := TFileStream.create(fileName, fmOpenWrite or fmCreate);
      fs.WriteAnsiString(SAVEFILEID);
      fs.WriteByte(2);
      fs.WriteByte(1);
      writeBAMs(fs);
      writeROMs(fs);
      writeDir(fs);
      fs.WriteAnsiString(mcROMImageFile);
      except
        on e:EFOpenError Do
        begin

        end;
        on EStreamError Do
        begin

        end;
    end;
    finally
      fs.Free;
  end;
end;

procedure TForm1.MenuItem12Click(Sender: TObject);
begin
  if SaveDialog2.Execute Then
    saveTVCFile(SaveDialog2.FileName);
end;

function TForm1.checkTVCFile(fs : TFileStream): boolean;
var id : String;
begin
  id := fs.ReadAnsiString;
  if id<>SAVEFILEID Then
  begin
    result:=false;
    exit;
  end;
  if (fs.readByte <> 2) or (fs.readByte < 1) then
  begin
    result:=false;
    exit;
  end;
  result:=True;
end;

procedure setCheckBoxes(rs1, rs2 : Integer);
begin
  case rs1 of
    128 : form1.RadioButton2.Checked:=true;
    256 : form1.RadioButton3.Checked:=true;
    512 : form1.RadioButton4.Checked:=true;
  end;
 case rs2 of
    0   : form1.RadioButton5.Checked:=true;
    128 : form1.RadioButton6.Checked:=true;
    256 : form1.RadioButton7.Checked:=true;
    512 : form1.RadioButton8.Checked:=true;
  end;
end;

procedure TForm1.readBAMs(fs : TFileStream);
var i,j, rs1, rs2: Integer;
    val : Byte;
begin
  rs1:=fs.ReadWord;
  rs2:=fs.ReadWord;
  setCheckBoxes(rs1, rs2);
{  Bam1.Free;                        // BAM and ROMs are created by setting the radiobuttons..
  Bam2.Free;
  bam1 := TBits.Create(romSize1*4); // romsize is in kB. BAM contains kB*4 entries
  bam2 := TBits.Create(romSize2*4); }
  for i:=0 to (romSize1 div 2) - 1 Do // each bytes contains 2 block's data
  begin
    val := fs.ReadByte;
    for j:=0 to 7 Do
    begin
      BAM1.Bits[i*8+j]:= (val and 128)<>0;
      val:=byte(val shl 1);
    end;
  end;
  for i:=0 to (romSize2 div 2) - 1 Do
  begin
    val := fs.ReadByte;
    for j:=0 to 7 Do
    begin
      BAM2.Bits[i*8+j]:= (val and 128)<>0;
      val:=byte(val shl 1);
    end;
  end;
  PaintBox1.Refresh;
end;

procedure TForm1.readROMs(fs : TFileStream);
var i:integer;
begin
{  setLength(ROM1, romSize1*1024);  // already set by checking the radiobuttons
  setLength(ROM2, romSize2*1024);}
  for i:=0 to romSize1*1024-1 Do
    ROM1[i]:=fs.readByte;
  for i:=0 to romSize2*1024-1 Do
    ROM2[i]:=fs.readByte;
end;

procedure TForm1.readDirectory(fs : TFileStream);
var size, t, i : Integer;
    imageRec : TImageRec;
begin
  size := fs.readWord;
  ListBox1.Clear;
  for i:=0 to size - 1 Do
    ListBox1.AddItem(fs.ReadAnsiString, nil);
  for i:=0 to size - 1 Do
  begin
    imageRec := TImageRec.Create;
    imageRec.fileName:=fs.ReadAnsiString;
    imageRec.size:=fs.ReadByte;
    imageRec.bank:=fs.ReadByte;
    imageRec.block:=fs.ReadByte;
    imageRec.blockNum:=fs.ReadByte;
    imageRec.displayName:=fs.ReadAnsiString;
    t := fs.ReadByte;
    case t of
       1: imageRec.recType:=basic;
       2: imageRec.recType:=cart;
       3: imageRec.recType:=cas;
       4: imageRec.recType:=bin;
    end;
    ListBox1.Items.Objects[i]:=imageRec;
  end;
  if i<>0 then
  begin
    GroupBox3.enabled:=false;
  end;
end;

procedure TForm1.readImageFileName(fs : TFileStream);
begin
   mcROMImageFile:=fs.ReadAnsiString;
   if mcROMImageFile<>'' then
     Label3.Caption:=mcROMImageFile;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
var fs : TFileStream;
begin
  if OpenDialog3.Execute Then
  begin
    try
      try
        fs := TFileStream.Create(OpenDialog3.FileName, fmOpenRead);
        if not checkTVCFile(fs) Then
        begin
          {show dialog, not valid file}
          exit;
        end;
        readBAMs(fs);
        readROMs(fs);
        readDirectory(fs);
        readImageFileName(fs);
      except
        on e: EReadError Do
        begin

        end;
      end;
    finally
      fs.Free;
    end;
  end;
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
  if SaveDialog2.FileName<>'' Then
  begin
    saveTVCFile(SaveDialog2.FileName)
  end
  else
  begin
    if SaveDialog2.Execute Then
    begin
      saveTVCFile(SaveDialog2.FileName);
    end;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i: integer;
  imageRec: TImageRec;
  itemAdded: boolean;
  listEntry: string;
begin
  if (OpenDialog1.Execute) then
  begin
    itemAdded := False;
    imageRec := TImageRec.Create;
    imageRec.recType := None;
    for i := 0 to OpenDialog1.Files.Count - 1 do
    begin
      createImageRec(OpenDialog1.Files[i], imageRec);
      if (imageRec.recType <> None) and addImageToROM(imageRec) then
      begin
        listEntry := '';
        if (imageRec.recType = cas) then
          listEntry := '[CAS] '
        else if (imageRec.recType = cart) Then
          listEntry := '[CRT] '
        else if (imageRec.recType = bin) Then
          listEntry := '[BIN] ';
        ListBox1.AddItem(listEntry + imageRec.displayName, imageRec);
        imageRec := TImageRec.Create;
        itemAdded := True;
      end;
    end;
    if itemAdded then
    begin
      GroupBox3.enabled:=false;
    end;
    PaintBox1.Refresh;
    updateFreeSpace;
    imageRec.Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  i: integer;
begin
  for i:=0 to ListBox1.Count-1 Do
    listBox1.Items.Objects[i].free;
  ListBox1.Clear;
  GroupBox3.enabled:=true;
  setROMSize(romSize1, romSize2);
  PaintBox1.Refresh;
  updateFreeSpace;
end;

procedure TForm1.Button3Click(Sender: TObject);
var f : File of Byte;
  fName: String;
  buf : array[0..16] of byte;
  addr : integer;
begin
  if(OpenDialog2.Execute) Then
  begin
    fName := OpenDialog2.FileName;
    assignFile(f, fName);
    reset(f);
    BlockRead(f, buf[0], 16);
    CloseFile(f);
    if (buf[0]<>ord('M')) or (buf[1]<>ord('O')) or
       (buf[2]<>ord('P')) or (buf[3]<>ord('S')) Then
    begin
      TaskDialog1.Text:=fName + ' is not a TVC CART image!';
      TaskDialog1.Execute;
      Exit;
    end;
    addr := buf[8] + 256*buf[9];
    if (buf[6]<33) or (addr<49152) Then
    begin
      TaskDialog1.Text:=fName + ' is not a TVC MultiCart v2.1+ image!';
      TaskDialog1.Execute;
      Exit;
    end;
    mcROMImageFile:=fName;
    setFirmware;
//    setROMSize(romSize1, romSize2);
  end;
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin

end;

procedure TForm1.Edit1EditingDone(Sender: TObject);
var idx:integer;
str : String;
imageRec : TImageRec;
begin
  edit1.Visible:=false;
  idx:=ListBox1.ItemIndex;
  str:=LeftStr(ListBox1.Items.Strings[idx], 6);
  str:=str + Edit1.Text;
  ListBox1.Items.Strings[idx]:=str;
  imageRec:=TImageRec(ListBox1.Items.Objects[idx]);
  imageRec.displayName:=Edit1.Text;
end;

procedure TForm1.Edit1Exit(Sender: TObject);
begin
  edit1.Visible:=false;
end;

procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: char);
begin

end;

procedure TForm1.Edit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
 if key = 27 Then
 begin
   Edit1.Visible:=false;
   SetFocusedControl(ListBox1);
 end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  checkBoxes[1] := RadioButton1;
  checkBoxes[2] := RadioButton2;
  checkBoxes[3] := RadioButton3;
  checkBoxes[4] := RadioButton4;
  checkBoxes[5] := RadioButton5;
  checkBoxes[6] := RadioButton6;
  checkBoxes[7] := RadioButton7;
  checkBoxes[8] := RadioButton8;

  BAM1 := TBits.Create(0);
  BAM2 := TBits.Create(0);
  mcROMImageFile:='';
  tvcROMSaveFile:='';

  GroupBox3Click(Sender);
end;

procedure TForm1.FormDestroy(Sender: TObject);
var i: integer;
begin
  for i:=0 to ListBox1.Count-1 Do
    ListBox1.Items.Objects[i].Free;
  BAM1.Free;
  BAM2.Free;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  caption:=IntToStr(width) + ' x ' + IntToStr(height);
end;


procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  form1.Close;
end;

procedure TForm1.MenuItem6Click(Sender: TObject);
begin
  mcROMImageFile:='';
  tvcROMSaveFile:='';
  SaveDialog2.FileName:='';

  RadioButton2.Checked:=true;
  RadioButton5.Checked:=true;
  Button2Click(Sender);
end;

procedure TForm1.insertBAM(bamStartPos: Integer);
var i,j,v: integer;
begin
  for i:=0 to 511 Do
    ROM1[bamStartPos+i] := 255;
  for i:=0 to (BAM1.Size div 8)-1 Do
  begin
    v:=0;
    for j:=0 to 7 Do
    begin
      if(BAM1.Get(i*8 + j)) Then
      begin
        inc(v, 1 shl j);
      end;
    end;
    ROM1[bamStartPos+i] := v;
  end;
  for i:=0 to (BAM2.Size div 8)-1 Do
  begin
    v:=0;
    for j:=0 to 7 Do
    begin
      if(BAM2.Get(i*8 + j)) Then
      begin
        inc(v, 1 shl j);
      end;
    end;
    ROM1[bamStartPos+256+i] := v;
  end;
end;

function truncateSpecString(S: String; l:Integer) : String;
var
  CurP, EndP: PChar;
  Len: Integer;
  ACodePoint: String;
  res : String;
  i : integer;
begin
  if l >= Length(S) then
  begin
    result:=s;
    exit;
  end;

  CurP := PChar(S);        // if S='' then PChar(S) returns a pointer to #0
  EndP := CurP + length(S);
  res := '';
  i:=0;
  while CurP < EndP do
  begin
    Len := CodepointSize(CurP);
    SetLength(ACodePoint, Len);
    Move(CurP^, ACodePoint[1], Len);
    res:=res+aCodePoint;
    inc(i);
    if i=l then
    begin
      break
    end;
    inc(CurP, Len);
  end;
  result:=res;
end;


function ReplaceSpecToTVCChars(S: String) : String;
const
      SPEC_ARR: array[0..17] of String = ('Á','É','Í','Ó','Ö','Ő','Ú','Ü','Ű','á','é','í','ó','ö','ő','ú','ü','ű');
var
  CurP, EndP: PChar;
  Len: Integer;
  ACodePoint: String;
  res : String;
  i : integer;
  replaced : boolean;
begin
  CurP := PChar(S);        // if S='' then PChar(S) returns a pointer to #0
  EndP := CurP + length(S);
  res := '';
  while CurP < EndP do
  begin
    Len := CodepointSize(CurP);
    SetLength(ACodePoint, Len);
    Move(CurP^, ACodePoint[1], Len);
    replaced := false;
    for i:=0 to 17 Do
    begin
      if ACodePoint = SPEC_ARR[i] Then
      begin
        replaced:=true;
        if i<9 then
        begin
          res:=res + chr(128 + i);
        end
        else
        begin
          res:=res + chr(144 + (i - 9));
        end;
        break;
      end;
    end;
    if not replaced then
      res:=res + ACodePoint;
    inc(CurP, Len);
  end;
  result:=res;
end;

procedure TForm1.insertDirectory(bamStartPos: Integer);
// const BASIC_STR: String = '-  TVC  BASIC  -';
var i,j,p: integer;
    rec : TImageRec;
    tvcName : String;
begin
  for i:=bamStartPos + 512+20 to 16383 Do
  begin
    ROM1[i]:=0;
  end;
  p := bamStartPos + 512;
  ROM1[p]:=1;
//  for i:=1 to Length(BASIC_STR) Do
//  begin
//    ROM1[p+3+i]:=ord(BASIC_STR[i]);
//  end;
  Inc(p, 20);
  for i:=0 to ListBox1.Items.Count-1 do
  begin
    rec := TImageRec(ListBox1.Items.Objects[i]);
    case rec.recType of
      TMC21RecordType.basic : ROM1[p]:=1;
      TMC21RecordType.cart :
        begin
          ROM1[p]:=2;
          ROM1[p+1]:=rec.bank;
        end;
      TMC21RecordType.cas  :
        begin
          ROM1[p]:=3;
          ROM1[p+1]:=rec.bank;
          ROM1[p+2]:=rec.block;
        end;
      TMC21RecordType.bin  :
        begin
          ROM1[p]:=4;
          ROM1[p+1]:=rec.bank;
          ROM1[p+2]:=rec.block;
        end;
    end;
    ROM1[p+3]:=rec.blockNum;
    for j:=0 to 15 Do
      ROM1[p+4+j]:=32; {ord(' ')}
    tvcName:=ReplaceSpecToTVCChars(rec.displayName);
    for j:=1 to Length(tvcName) Do
    begin
      ROM1[p+3+j] := ord(tvcName[j]);
    end;
    Inc(p, 20);
    if p+20>16384 Then
      break;
  end;
end;

procedure TForm1.insertFS();
var bamStartPos: integer;
begin
  bamStartPos:=ROM1[9] * 256 + ROM1[8];
  bamStartPos:=bamStartPos - 49152;
  insertBAM(bamStartPos);
  insertDirectory(bamStartPos);
end;

procedure TForm1.MenuItem7Click(Sender: TObject);
var fileName, extension : String;
    f : File of Byte;
begin
  if SaveDialog1.Execute Then
  begin
    insertFS();
    fileName:=ExtractFileNameWithoutExt(SaveDialog1.FileName);
    extension:=ExtractFileExt(SaveDialog1.FileName);
    AssignFile(f, fileName + '-rom1' + extension);
    Rewrite(f);
    BlockWrite(f, ROM1[0], romSize1*1024);
    CloseFile(f);
    if romSize2 <> 0 Then
    begin
      AssignFile(f, fileName + '-rom2' + extension);
      Rewrite(f);
      BlockWrite(f, ROM2[0], romSize2*1024);
      CloseFile(f);
    end;
  end;
end;

procedure TForm1.MenuItem8Click(Sender: TObject);
var idx,h : integer;
    rect : TRect;
begin
  idx := ListBox1.ItemIndex;
  if idx = -1 then exit;
  Edit1.Text:=RightStr(ListBox1.GetSelectedText, Length(ListBox1.GetSelectedText)-6);
  rect:=ListBox1.ItemRect(idx);
  h:=rect.Height;
  rect.left:=rect.left + listBox1.Left;
  rect.top:=rect.top + listBox1.top;
  rect.width:=ListBox1.Width;
  rect.Height:=h;
  edit1.SetBounds(rect.left, rect.top, rect.Width, rect.Height);
  edit1.SelectAll;
  edit1.Visible:=true;
  edit1.SetFocus;
end;

procedure TForm1.MenuItem9Click(Sender: TObject);
var item : TStringItem;
    idx : Integer;
begin
  idx := ListBox1.ItemIndex;
  if (idx = -1) or (idx = 0) then exit;
  item.FString := ListBox1.Items.Strings[idx];
  item.FObject := ListBox1.items.Objects[idx];
  ListBox1.Items.Strings[idx] := ListBox1.Items.Strings[idx-1];
  ListBox1.items.Objects[idx] := ListBox1.items.Objects[idx-1];
  ListBox1.Items.Strings[idx-1] := item.FString;
  ListBox1.items.Objects[idx-1] := item.FObject;
  ListBox1.ItemIndex:=idx - 1;
end;

procedure TForm1.PaintBox1Click(Sender: TObject);
begin

end;

procedure drawBAM(canvas: TCanvas; rect: TRect; BAM: TBits);
var
  x, i: integer;
  w, h: real;
begin
  x := rect.left;
  w := rect.Width / 64;
  h := rect.Height / 32;
  for i := 0 to BAM.Size - 1 do
  begin
    rect.Left := x + round((i mod 64) * w) + 1;
    rect.top := round((i div 64) * h) + 1;
    rect.Width := round(w) - 2;
    rect.Height := round(h) - 2;
    if BAM.Get(i) then
      canvas.Brush.Color := clRed
    else
      canvas.Brush.Color := clGreen;
    canvas.FillRect(rect);
  end;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
  rect: TRect;
begin
  rect := PaintBox1.ClientRect;
  //  PaintBox1.Canvas.TryLock;
  PaintBox1.Canvas.Line(rect.Width div 2, 0, rect.Width div 2, rect.Height);
  rect.right := rect.Width div 2;
  drawBam(PaintBox1.Canvas, rect, BAM1);
  rect := PaintBox1.ClientRect;
  rect.Left := rect.Width div 2;
  drawBam(PaintBox1.Canvas, rect, BAM2);
  //  PaintBox1.Canvas.Unlock;
end;

procedure TForm1.RadioButton3Change(Sender: TObject);
begin

end;

function getLatestMCRomFile:String;
var mcROMList : TStringList;
  timeStamp,latestTimeStamp : LongInt;
  latestROMFileName: String;
  i : integer;
begin
  mcROMList:= TStringList.Create;
  FindAllFiles(mcROMList, '.', 'multicart_v2.1*.bin', false);
  if mcROMList.Count = 0 Then
  Begin
    result:='';
  end
  else
  begin
    latestTimeStamp:=0;
    for i:=0 to mcROMList.Count-1 Do
    Begin
      timeStamp:=FileAge(mcROMList.Strings[i]);
      if timeStamp>latestTimeStamp then
      begin
        latestTimeStamp:=timeStamp;
        latestROMFileName:=mcROMList.Strings[i];
      end;
    end;
    Result:=latestROMFileName;
  end;
  mcROMList.Free;
end;

procedure setFirmware;
var
  i: integer;
  res: TLResource;
  data: AnsiString;
  romFileInDisk : String;
  f : File of Byte;
  buf : array[0..16383] of byte;
  bufRead : boolean;
begin
  bufRead := True;
  if form1.mcROMImageFile= '' Then
  begin
    romFileInDisk := getLatestMCRomFile;
    if(romFileInDisk = '') Then
    begin
      res:=LazarusResources.Find('MULTICART_V2.1.Z80');
      if res <> nil then
      begin
        data := res.Value;
        for i:=0 to data.Length Do
        begin
          buf[i]:=byte(data.Chars[i]);
        end;
        Form1.Label3.Caption:='Internal';
      end
      else
      begin
        Form1.Label3.Caption:='none!';
        bufRead:=False;
      end;
    end
    else
    begin
      AssignFile(f, romFileInDisk);
      Reset(f, 1);
      BlockRead(f, buf, FileSize(romFileInDisk));
      CloseFile(f);
      Form1.Label3.Caption:=ExtractFileNameOnly(romFileInDisk)
    end;
  end
  else
  begin
    AssignFile(f, form1.mcROMImageFile);
    Reset(f, 1);
    BlockRead(f, buf, FileSize(form1.mcROMImageFile));
    CloseFile(f);
    Form1.Label3.Caption:=ExtractFileNameOnly(form1.mcROMImageFile);
  end;

  if bufRead Then
  Begin
    Move(buf[0], ROM1[0], 3*4096);
    Move(buf[3*4096+512], ROM1[3*4096+512], 20);
  end;

end;

procedure setROMSize(rs1: integer; rs2: integer);
var
  i: integer;
  res: TLResource;
  data: AnsiString;
  romFileInDisk : String;
  f : File of Byte;
begin
  romSize1 := rs1;
  romSize2 := rs2;
  BAM1.Free;
  BAM2.Free;
  BAM1 := TBits.Create(rs1 * 1024 div SECTORSIZE);
  BAM2 := TBits.Create(rs2 * 1024 div SECTORSIZE);
  for i := 0 to 63 do
  begin
    BAM1.SetOn(i);
  end;
  SetLength(ROM1, romSize1 * 1024);
  for i := 0 to romSize1 * 1024 - 1 do
    ROM1[i] := 0;
  SetLength(ROM2, romSize2 * 1024);
  for i := 0 to romSize2 * 1024 - 1 do
    ROM2[i] := 0;
  if form1.mcROMImageFile= '' Then
  begin
    romFileInDisk := getLatestMCRomFile;
    if(romFileInDisk = '') Then
    begin
      res:=LazarusResources.Find('MULTICART_V2.1.Z80');
      if res <> nil then
      begin
        data := res.Value;
        for i:=0 to data.Length Do
        begin
          ROM1[i]:=byte(data.Chars[i]);
        end;
        Form1.Label3.Caption:='Internal';
      end
      else
      begin
        Form1.Label3.Caption:='none!';
      end;
    end
    else
    begin
      AssignFile(f, romFileInDisk);
      Reset(f, 1);
      BlockRead(f, ROM1[0], FileSize(romFileInDisk));
      CloseFile(f);
      Form1.Label3.Caption:=ExtractFileNameOnly(romFileInDisk)
    end;
  end
  else
  begin
    AssignFile(f, form1.mcROMImageFile);
    Reset(f, 1);
    BlockRead(f, ROM1[0], FileSize(form1.mcROMImageFile));
    CloseFile(f);
    Form1.Label3.Caption:=ExtractFileNameOnly(form1.mcROMImageFile);
  end;
end;

function getFreeBlocks(): integer;
var
  fb, i: integer;
begin
  fb := 0;
  i := 0;
  while i < BAM1.Size do
  begin
    if not BAM1.Get(i) then
      Inc(fb);
    Inc(i);
  end;
  i := 0;
  while i < BAM2.Size do
  begin
    if not BAM2.get(i) then
      Inc(fb);
    Inc(i);
  end;
  Result := fb;
end;

procedure createImageRec(fileName: string; var imageRec: TImageRec);
type
  TID = array[1..4] of char;
var
  f: file of TID;
  id: TID;

begin
  AssignFile(f, fileName);
  Reset(f);
  Read(f, id);
  CloseFile(f);
  if id = 'MOPS' then
  begin
    // cart
    imageRec.fileName := fileName;
    imageRec.displayName := ExtractFileNameOnly(fileName);
    imageRec.recType := cart;
    imageRec.displayName:=truncateSpecString(imageRec.displayName, 16);
  end
  else if fileName.EndsWith('.cas') or fileName.EndsWith('.CAS') then
  begin
    imageRec.fileName := fileName;
    imageRec.displayName := ExtractFileNameOnly(fileName);
    imageRec.recType := cas;
    if Length(imageRec.displayName) > 16 then
      imageRec.displayName:=LeftStr(imageRec.displayName, 16);
  end;
end;

procedure copyCart(bank: integer; fileName: string);
var
  bytesToRead, bytesRead, i: integer;
  buf: array[0..16383] of byte;
  f: file of byte;
  ROM: TImageBuffer;
begin
  AssignFile(f, fileName);
  ReSet(f);
  bytesToRead := fileSize(f);
  if bytesToRead > 16384 then
    bytesToRead := 16384;
  bytesRead:=0;
  BlockRead(f, buf, bytesToRead, bytesRead);
  CloseFile(f);
  if (bank < 32) then
  begin
    ROM := ROM1;
  end
  else
  begin
    ROM := ROM2;
    Dec(bank, 32);
  end;
  for i := 0 to bytesRead - 1 do
    ROM[i + bank * 16384] := buf[i];
end;

function allocateAndCopyCAS(fSize: integer; var imageRec: TImageRec): boolean;
var
  f: file of byte;
  buf: array[0..65535] of byte;
  bufIndex, pos, readBytes: integer;
  ROM: TImageBuffer;
  BAM: TBits;
  firstAlloc: boolean;
  bankOffset, i: integer;
  prevBank, prevBlock: integer;
  prevROM: TImageBuffer;
begin
  allocateAndCopyCAS := getFreeBlocks() >= (((fSize - 1) div 254) + 1);
  if allocateAndCopyCAS then
  begin
    AssignFile(f, imageRec.fileName);
    Reset(f);
    Seek(f, 9 * 16);
    readBytes:=0;
    BlockRead(f, buf, fSize, readBytes);
    CloseFile(f);
    ROM := ROM1;
    BAM := BAM1;
    firstAlloc := True;
    bankOffset := 0;
    bufIndex := 0;
    prevBank := 0;
    prevBlock := 0;
    while bufIndex < readBytes do
    begin
      pos := BAM.FindFirstBit(False);
      if pos = -1 then
      begin
        ROM := ROM2;
        BAM := BAM2;
        bankOffset := 32;
        continue;
      end;
      if firstAlloc then
      begin
        imageRec.bank := bankOffset + (pos div 64);
        imageRec.block := pos mod 64;
        firstAlloc := False;
      end
      else
      begin
        prevROM[prevBank * 16384 + prevBlock * 256] := bankOffset + (pos div 64);
        prevROM[prevBank * 16384 + prevBlock * 256 + 1] := pos mod 64;
      end;
      BAM.SetOn(pos);
      i := 0;
      while (i < 254) and (bufIndex < readBytes) do
      begin
        ROM[pos * 256 + 2 + i] := buf[bufIndex];
        Inc(i);
        Inc(bufIndex);
      end;
      prevROM := ROM;
      prevBank := pos div 64;
      prevBlock := pos mod 64;
    end;
    prevROM[prevBank * 16384 + prevBlock * 256] := 255;
    prevROM[prevBank * 16384 + prevBlock * 256 + 1] := ((readBytes - 1) mod 254) + 1;
  end;
end;

function addImageToROM(var imageRec: TImageRec): boolean;
var
  f: file of byte;
  fSize: longint;
  a, b: byte;
  blockNum: integer;
begin
  addImageToROM := False;
  AssignFile(f, imageRec.fileName);
  Reset(f);
  fSize := FileSize(f);
  CloseFile(f);
  if (imageRec.recType = cart) then
  begin
    blockNum := 64;
    if blockNum > (((fSize - 1) div 256) + 1) then
    begin
      blockNum := (((fSize - 1) div 256) + 1);
    end;
    if allocateCart(blockNum, imageRec) then
    begin
      copyCart(imageRec.bank, imageRec.fileName);
      imageRec.size:=(blockNum + 1) div 4;
      imageRec.blockNum:=blockNum;
      Result := True;
    end;
  end
  else if imageRec.recType = cas then
  begin
    Reset(f);
    Seek(f, 8 * 16 + 2);
    Read(f, a);
    Read(f, b);
    CloseFile(f);
    if (fSize<(b * 256 + a)) or ((b * 256 + a) = 0) Then
    begin
      // do nothing
      imageRec.recType:=bin;
    end
    else
    begin
      fSize := b * 256 + a;
    end;
    imageRec.size:=(fSize + 512) div 1024;
    imageRec.blockNum:=((fSize-1) div 254) + 1;

    Result := allocateAndCopyCAS(fSize, imageRec)
  end;
end;

function allocateCart(blockNum: integer; var imageRec: TImageRec): boolean;
begin
  if not allocateCart(0, blockNum, BAM1, imageRec) then
  begin
    Result := allocateCart(32, blockNum, BAM2, imageRec);
  end
  else
    Result := True;

end;

function allocateCart(bankOffset, blockNum: integer; BAM: TBits;
  var imageRec: TImageRec): boolean;
var
  i, j: integer;
begin
  i := 0;
  allocateCart := False;
  while i < BAM.Size do
  begin
    for j := 0 to blockNum - 1 do
    begin
      if BAM.Get(i + j) then
        break;
    end;
    if j = blockNum - 1 then
    begin
      for j := 0 to blockNum - 1 do
        BAM.SetOn(i + j);
      imageRec.bank := bankOffset + i div 64;
      imageRec.block := 0;
      allocateCart := True;
      break;
    end
    else
      Inc(i, 64);
  end;
end;

procedure updateFreeSpace;
begin
  form1.label2.Caption := IntToStr(getFreeBlocks() div 4) + 'kB';
end;

initialization
{$I TV21CARTROM.lrs}

end.
