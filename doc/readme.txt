v2.12beta

doc:
  readme.txt: ez a file, amit most olvasol
  BOM : bill of material. Mik kellenek az összeszereléshez
  FLASH : hogyan s mit kell kiírni, hogy elinduljon a multicart

hardware:
  eagle:
    Eagle v8.3.1 file -ok a tervezéshez
  gerber6-7.zip
    gerber file -ok a rendeléshez. Az utolsó, mûködõ változat.

software:
  firmware:
    A multicart betöltõ programja. Ezt a programot kell a 0. BANK elejére írni.
    A ROM maker program ezt a firmware-t használja.
    Meg lehet tenni azt is, hogy csak egy cart image kerül az 1. ROM elejére,
    nyilván akkor az fog elindulni és nem lesz több, választható ROM a cart-on.
    Én az ASM80.com nevû online IDE -ben fejlesztettem, ott módosítás nélkül
    fordítható a program (a main file: multicart_v2.1.z80), remélem máshol is
    egyszerûen fordítható.
    A használt nyelv egy kapcsolóval állítható (és belefordul a binárisba, azaz futás
    közben nem lehet változtatni). Ezt a változót kell állítani:
      LANG
    Jelenleg támogatott nyelvek: magyar (HU), angol (EN), spanyol (ES)
  tvcpla:
    tvcla.pas
    Azon bináris file generáló program forrása, melyet a PLA chip-be (logikai kapuk
    helyett) kell majd égetni.
    Abban az esetben, ha nem 128kB -os a ROM, akkor a legfölsõ 128kB -ba kell írni
    a legenerált binárist
    tvcpla.bin
    A már legenerált bináris file
  rom-builder:
    Lazarus forrás file-ok. A program (+az elkészített firmware bináris + CAS és CART
    binárisok) segítségével lehet olyan bináris file-okat készíteni, amiket az 
    EEPROM-okba írva fog a multicart elindulni és file-ok listáját adni.
    Windows alatt fejlesztettem és futtattam, ott mennie kell.

bom.txt
