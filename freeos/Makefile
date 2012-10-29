TOOLPATH = ../os_tools
SRCPATH = ./src
INCPATH  = ../os_tools/haribote/

MAKE     = $(TOOLPATH)/make.exe -r
NASK     = $(TOOLPATH)/nask.exe
CC1      = $(TOOLPATH)/cc1.exe -I$(INCPATH) -Os -Wall -quiet
GAS2NASK = $(TOOLPATH)/gas2nask.exe -a
OBJ2BIM  = $(TOOLPATH)/obj2bim.exe
BIM2HRB  = $(TOOLPATH)/bim2hrb.exe
RULEFILE = $(TOOLPATH)/haribote/haribote.rul
EDIMG    = $(TOOLPATH)/edimg.exe
IMGTOL   = $(TOOLPATH)/imgtol.com
COPY     = copy
DEL      = del



default :
	$(MAKE) img

ipl.bin : $(SRCPATH)/ipl.nas Makefile
	$(NASK) $(SRCPATH)/ipl.nas ipl.bin ipl.lst
	
asmhead.bin : $(SRCPATH)/asmhead.nas Makefile
	$(NASK) $(SRCPATH)/asmhead.nas asmhead.bin asmhead.lst

bootpack.gas : $(SRCPATH)/bootpack.c Makefile
	$(CC1) -o  bootpack.gas  $(SRCPATH)/bootpack.c

bootpack.nas : bootpack.gas Makefile
	$(GAS2NASK) bootpack.gas bootpack.nas 

bootpack.obj : bootpack.nas Makefile
	$(NASK) bootpack.nas bootpack.obj bootpack.lst

bootpack.bim : bootpack.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:bootpack.bim stack:3136k map:bootpack.map \
		bootpack.obj
# 3MB+64KB=3136KB

bootpack.hrb : bootpack.bim Makefile
	$(BIM2HRB) bootpack.bim bootpack.hrb 0

haribote.sys : asmhead.bin bootpack.hrb Makefile
	copy /B asmhead.bin+bootpack.hrb haribote.sys

haribote.img : ipl.bin haribote.sys Makefile
	$(EDIMG)   imgin:../os_tools/fdimg0at.tek \
		wbinimg src:ipl.bin len:512 from:0 to:0 \
		copy from:haribote.sys to:@: \
		imgout:haribote.img

img :
	$(MAKE) haribote.img

run :
	$(MAKE) img
	$(COPY) haribote.img ..\os_tools\qemu\fdimage0.bin
	$(MAKE) -C ../os_tools/qemu

install :
	$(MAKE) img
	$(IMGTOL) w a: haribote.img

clean :
	-$(DEL) *.bin
	-$(DEL) *.lst
	-$(DEL) *.gas
	-$(DEL) *.obj
	-$(DEL) bootpack.nas
	-$(DEL) bootpack.map
	-$(DEL) bootpack.bim
	-$(DEL) bootpack.hrb
	-$(DEL) haribote.sys

src_only :
	$(MAKE) clean
	-$(DEL) haribote.img
