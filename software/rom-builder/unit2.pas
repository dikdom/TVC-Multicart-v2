unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls;

const
    SECTORSIZE : Integer = 256;   {one sector in BAM}
    MAXROMSIZE : Integer = 512; {in kB}

type
  TMC20RecordType = (cart, cas);

  NameRec = Record
    name:String;
    bank: integer;
    block: integer;
    recType : TMC20RecordType;
  end;

  TBAM = class(TPaintBox)
  public
    procedure setROMSize(romSize1:integer; romSize2:Integer);
    procedure addCartImage(imageName: String; size: Integer);
    procedure addCASImage(imageName: String; size: Integer);
    procedure myPaint(sender: TObject);

  private
    romSize1, romSize2: Integer;
    BAM1 : TBits;
    BAM2 : TBits;
  End;

implementation
  procedure TBAM.setROMSize(romSize1:integer; romSize2:Integer);
  Var i:Integer;
  Begin
    self.romSize1:=romSize1;
    self.romSize2:=romSize2;
    BAM1 := TBits(self.romSize1 / SECTORSIZE);
    BAM2 := TBits(self.romSize2 / SECTORSIZE);
    for i:=0 to 15 Do
    Begin
      BAM1.SetIndex(i);
    end;
  End;

  procedure TBAM.addCartImage(imageName: String; size: Integer);
  Begin

  end;

  procedure TBAM.addCASImage(imageName: String; size: Integer);
  begin

  end;

  procedure TBAM.myPaint(Sender: TObject);
  begin

  end;


end.

