# TVC-Multicart-v2
Copyright (C) 2017-2019 by Sandor Vass <vass.sanyi@gmail.com>  
All rights reserved.

# About #
The multicart is a flash storage device for the Videoton TV Computer, 
inserted to the left side expansion slot (program-module).
This repository contains all the related source files to build one 
from scratch.

# Structure #

*  doc
   Contains descriptions and help how to solder and program a module.
   Also a short explanation the structure of the repo, Hungarian.

*  hardware
   Eagle source files and gerber files of the PCB.

*  software
   *  firmware
      The multicart firmware source and binary, that drives the whole stuff. The
      binary is needed to build a complete multicart.
   *  rom-builder
      The source of the Lazarus program (Multiplatform, free pascal IDE), that 
      aids the building of the ROM images to be written to the onboaed EEPROM chips.
   *  tvcpla
      The source of the pla binary generator, and the generated binary also.

# License #

The firmware itself is distributed under the following conditions:

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:
    1. Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
    2. Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
    ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
    FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
    DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
    OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
    HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
    OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
    SUCH DAMAGE.


