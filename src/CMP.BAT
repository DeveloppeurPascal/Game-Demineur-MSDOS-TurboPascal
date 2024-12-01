@echo off
set code=gamedemi
mkmsg demin
lha a c:\olf_soft\lzh\%code% demin.doc demin.exe demin.msg setup.cfg c:\prg\others\divers\setdflt.exe
set code=
echo on
