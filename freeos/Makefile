
# Ĭ����Ϊ

default :
	../os_tools/make.exe img

# �ļ����ɹ���

ipl.bin : ipl.nas Makefile
	../os_tools/nask.exe ipl.nas ipl.bin ipl.lst

helloos.img : ipl.bin Makefile
	../os_tools/edimg.exe   imgin:../os_tools/fdimg0at.tek \
		wbinimg src:ipl.bin len:512 from:0 to:0   imgout:helloos.img

# ����

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
	-del ipl.bin
	-del ipl.lst

src_only :
	../os_tools/make.exe clean
	-del helloos.img