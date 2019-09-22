v2.12beta

doc:
  readme.txt: ez a file, amit most olvasol
  BOM : bill of material. Mik kellenek az �sszeszerel�shez (angolul, magyarul)
  FLASH : hogyan s mit kell ki�rni, hogy elinduljon a multicart (angolul, magyarul)

hardware:
  eagle:
    Eagle v8.3.1 file -ok a tervez�shez, �jratervez�shez.
  gerber6-7.zip
    gerber file -ok a rendel�shez. Az utols�, m�k�d� v�ltozat.

software:
  firmware:
    multicart_v2.12.bin
      A multicart firmware bin�ris, m�r leford�tott �llom�nya. Ezt a programot kell a 0. BANK elej�re �rni.
      Ezt a bin�rist haszn�lja a RomMaker is. M�sold oda az exe mell�!
    *.z80 file-ok
      A multicart firmware forr�sa. Meg lehet tenni azt is, hogy csak egy cart image ker�l az 1. ROM elej�re,
      nyilv�n akkor az fog elindulni �s nem lesz t�bb, v�laszthat� ROM a cart-on.
      �n az ASM80.com nev� online IDE -ben fejlesztettem, ott m�dos�t�s n�lk�l
      ford�that� a program (a main file: multicart_v2.1.z80), rem�lem m�shol is
      egyszer�en ford�that�.
      A haszn�lt nyelv egy kapcsol�val �ll�that� (�s belefordul a bin�risba, azaz fut�s
      k�zben nem lehet v�ltoztatni). Ezt a v�ltoz�t kell �ll�tani:
        LANG
      Jelenleg t�mogatott nyelvek: magyar (HU), angol (EN), spanyol (ES)
  tvcpla:
    tvcpla.pas
      Azon bin�ris file gener�l� program forr�sa, melyet a PLA chip-be (logikai kapuk
      helyett) kell majd �getni.
      Abban az esetben, ha nem 128kB -os a ROM, akkor a legf�ls� 128kB -ba kell �rni
      a legener�lt bin�rist
    tvcpla.bin
      A m�r legener�lt bin�ris file
  rom-builder:
    Lazarus forr�s file-ok. A program (+az elk�sz�tett firmware bin�ris + CAS �s CART
    bin�risok) seg�ts�g�vel lehet olyan bin�ris ROM file-okat k�sz�teni, amiket az 
    EEPROM-okba �rva fog a multicart elindulni �s file-ok list�j�t adni.
    Windows alatt fejlesztettem �s futtattam, ott mennie kell.
    Futtat�s elott m�sold be az .exe mell� a fent eml�tett  multicart_v2.12.bin  file-t!