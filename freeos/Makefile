TOOLPATH = ../os_tools
SRCPATH = ./src
MAKE     = $(TOOLPATH)/make.exe -r
NASK     = $(TOOLPATH)/nask.exe
EDIMG    = $(TOOLPATH)/edimg.exe
IMGTOL   = $(TOOLPATH)/imgtol.com
COPY     = copy
DEL      = del


# 默认行为

default :
	$(MAKE) img

# 文件生成规则

ipl.bin : $(SRCPATH)/ipl.nas Makefile
	$(NASK) $(SRCPATH)/ipl.nas ipl.bin ipl.lst
	
haribote.sys : $(SRCPATH)/haribote.nas Makefile
	$(NASK) $(SRCPATH)/haribote.nas haribote.sys haribote.lst
	
haribote.img : ipl.bin haribote.sys Makefile
	$(EDIMG) imgin:../os_tools/fdimg0at.tek \
		wbinimg src:ipl.bin len:512 from:0 to:0 \
		copy from:haribote.sys to:@: \
		imgout:haribote.img

# 命令
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
	-$(DEL) *.bak
	-$(DEL) *.img
	-$(DEL) *.sys
	
src_only :
	$(MAKE) clean

