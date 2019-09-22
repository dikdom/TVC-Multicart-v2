v2.12beta

doc:
  readme.txt: ez a file, amit most olvasol
  BOM : bill of material. Mik kellenek az �sszeszerel�shez
  FLASH : hogyan s mit kell ki�rni, hogy elinduljon a multicart

hardware:
  eagle:
    Eagle v8.3.1 file -ok a tervez�shez
  gerber6-7.zip
    gerber file -ok a rendel�shez. Az utols�, m�k�d� v�ltozat.

software:
  firmware:
    A multicart bet�lt� programja. Ezt a programot kell a 0. BANK elej�re �rni.
    A ROM maker program ezt a firmware-t haszn�lja.
    Meg lehet tenni azt is, hogy csak egy cart image ker�l az 1. ROM elej�re,
    nyilv�n akkor az fog elindulni �s nem lesz t�bb, v�laszthat� ROM a cart-on.
    �n az ASM80.com nev� online IDE -ben fejlesztettem, ott m�dos�t�s n�lk�l
    ford�that� a program (a main file: multicart_v2.1.z80), rem�lem m�shol is
    egyszer�en ford�that�.
    A haszn�lt nyelv egy kapcsol�val �ll�that� (�s belefordul a bin�risba, azaz fut�s
    k�zben nem lehet v�ltoztatni). Ezt a v�ltoz�t kell �ll�tani:
      LANG
    Jelenleg t�mogatott nyelvek: magyar (HU), angol (EN), spanyol (ES)
  tvcpla:
    tvcla.pas
    Azon bin�ris file gener�l� program forr�sa, melyet a PLA chip-be (logikai kapuk
    helyett) kell majd �getni.
    Abban az esetben, ha nem 128kB -os a ROM, akkor a legf�ls� 128kB -ba kell �rni
    a legener�lt bin�rist
    tvcpla.bin
    A m�r legener�lt bin�ris file
  rom-builder:
    Lazarus forr�s file-ok. A program (+az elk�sz�tett firmware bin�ris + CAS �s CART
    bin�risok) seg�ts�g�vel lehet olyan bin�ris file-okat k�sz�teni, amiket az 
    EEPROM-okba �rva fog a multicart elindulni �s file-ok list�j�t adni.
    Windows alatt fejlesztettem �s futtattam, ott mennie kell.

bom.txt
