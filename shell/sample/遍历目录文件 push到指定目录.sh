 #!/bin/bash
dir=`ls` #定义遍历的目录
for file in $dir
do
	if [ -d $file ]
	then
   	adb push $file 3d_test_raccoon /sdcard/3d
	fi
done 



