procedure TForm1.Button17Click(Sender: TObject);
const CART : integer = (1 shl 0);
      WR   : integer = (1 shl 11);
      RD   : integer = (1 shl 10);
      REL  : integer = (1 shl 12);
      RAM  : integer = (1 shl 13);
      A19  : integer = (1 shl 14);
      RES  : integer = (1 shl 15);
      RST  : integer = (1 shl 16);
      A13  : integer = (1 shl 9);

const ROMCE0 : byte = (1 shl 0);
      ROMCE1 : byte = (1 shl 1);
      RAMCE  : byte = (1 shl 2);
      MEMRD  : byte = (1 shl 3);
      MEMWR  : byte = (1 shl 4);
      REGWR  : byte = (1 shl 5);
      REGCLR : byte = (1 shl 6);
      RESENA : byte = (1 shl 7);

var b : array [0..$1ffff] of byte;
    i : integer;
    a : word;
    f : file;
    nrd, nwr : boolean;

  procedure clrb(i : integer; value : byte); begin b[i] := b[i] and (not value); end;
  procedure setb(i : integer; value : byte); begin b[i] := b[i] or value; end;
  function isset(i, value : integer) : boolean; begin Result := (i and value) <> 0; end;
  function isres(i, value : integer) : boolean; begin Result := (i and value) = 0; end;

begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;
  Memo3.Lines.Clear;

  FillChar(b, sizeof(b), ROMCE0 or ROMCE1 or RAMCE or MEMRD or MEMWR or REGCLR or RESENA or REGWR);

  for i := 0 to $1ffff do begin
      a := i and $01FE;
      if isset(i, A13) then a := a or (1 shl 13);
      if isset(i, REL) then a := a xor (1 shl 13);
      a := a or $C000;

      if isres(i, RST) then begin
         clrb(i, REGCLR);
         continue;
      end;

      if isres(i, RES) then clrb(i, RESENA);

      if isset(i, CART) then continue;

      // CART low

      nrd := isres(i, RD); nwr := false;      // nrd = RD
      if not nrd then nwr := isres(i, WR);    // nwr = (not RD) and WR

      if (a = $C000) then begin               // C000-C001
         if nrd then begin                    // RD -> CLR latch
            if isset(i, RESENA) then clrb(i, REGCLR);
         end;
         if nwr then begin                    // WR -> write latch
            clrb(i, REGWR);
            setb(i, RESENA);
            continue;
         end;
      end;

      if (a = $C002) then begin               // C002-C003
         if nwr then begin                    // WR -> write latch
            clrb(i, REGWR);
            clrb(i, RESENA);
            continue;
         end;
      end;

      if nrd then clrb(i, MEMRD);
      if nwr then clrb(i, MEMWR);

      if isset(i, RAM) then begin
         clrb(i, RAMCE);
         continue;
      end;

      if isset(i, A19) then clrb(i, ROMCE1) else clrb(i, ROMCE0);

  end;
  assignfile(f, 'd:\tvcpla.bin'); rewrite(f,1); blockwrite(f, b, sizeof(b)); closefile(f);


end;
