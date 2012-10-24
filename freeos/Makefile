
# 默认行为

default :
	../os_tools/make.exe img

# 文件生成规则

ipl.bin : ./src/ipl.nas Makefile
	../os_tools/nask.exe ./src/ipl.nas ipl.bin ipl.lst

helloos.img : ipl.bin Makefile
	../os_tools/edimg.exe   imgin:../os_tools/fdimg0at.tek \
		wbinimg src:ipl.bin len:512 from:0 to:0   imgout:helloos.img

# 命令

asm :
	../os_tools/make.exe -r ipl.bin

img :
	../os_tools/make.exe -r helloos.img

run :
	../os_tools/make.exe img
	copy helloos.img ..\os_tools\qemu\fdimage0.bin
	../os_tools/make.exe -C ../os_tools/qemu

install :
	../os_tools/make.exe img
	../os_tools/imgtol.com w a: helloos.img

clean :
	-del *.bin
	-del *.lst
	-del *.bak
	-del *.img

src_only :
	../os_tools/make.exe clean
	-del *.img
