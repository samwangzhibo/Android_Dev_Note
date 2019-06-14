# Shell

## 1. 第一个shell脚本

``` shell
#!/bin/bash
echo "Hello World !"
```

> **#!** 是一个约定的标记，它告诉系统这个脚本需要什么解释器来执行，即使用哪一种 Shell。
>
> echo 命令用于向窗口输出文本。

### 运行 Shell 脚本有两种方法：

#### **1.1 作为可执行程序**

将上面的代码保存为 hello word.sh，并 cd 到相应目录：

``` she
wangzhibodeMacBook-Pro:chapter1 wzb$ chmod +x hello\ world.sh 
wangzhibodeMacBook-Pro:chapter1 wzb$ ./hello\ world.sh 
hello world
```

> 注意，一定要写成 **./test.sh**，而不是 **test.sh**，运行其它二进制的程序也一样，直接写 test.sh，linux 系统会去 PATH 里寻找有没有叫 test.sh 的，而只有 /bin, /sbin, /usr/bin，/usr/sbin 等在 PATH 里，你的当前目录通常不在 PATH 里，所以写成 test.sh 是会找不到命令的，要用 ./test.sh 告诉系统说，就在当前目录找。

#### **1.2、作为解释器参数**

这种运行方式是，直接运行解释器，其参数就是 shell 脚本的文件名，如：

```
wangzhibodeMacBook-Pro:chapter1 wzb$ /bin/sh hello\ world.sh 
hello world
```

这种方式运行的脚本，不需要在第一行指定解释器信息，写了也没用。

## 2. shell变量

### 2.1 定义变量

定义变量时，变量名不加美元符号（$，PHP语言中变量需要），如：

``` shell
your_name="runoob.com"
echo $your_name
```

注意，变量名和等号之间不能有空格，这可能和你熟悉的所有编程语言都不一样。同时，变量名的命名须遵循如下规则：

- 命名只能使用英文字母，数字和下划线，首个字符不能以数字开头。
- 中间不能有空格，可以使用下划线（_）。
- 不能使用标点符号。
- 不能使用bash里的关键字（可用help命令查看保留关键字）。

有效的 Shell 变量名示例如下：

```shell
RUNOOB
LD_LIBRARY_PATH
_var
var2
```

无效的变量命名：

```shell
?var=123
user*name=runoob
```

除了显式地直接赋值，还可以用语句给变量赋值，如：

```shell
for file in `ls /etc`
或
for file in $(ls /etc)
```

以上语句将 /etc 下目录的文件名循环出来。

### 2.2 使用变量

使用一个定义过的变量，只要在变量名前面加美元符号即可，如：

```shell
your_name="qinjx"
echo $your_name
echo ${your_name}
```

变量名外面的花括号是可选的，加不加都行，加花括号是为了帮助解释器识别变量的边界，比如下面这种情况：

```shell
for skill in Ada Coffe Action Java; do
    echo "I am good at ${skill} Script"
done
```

![image-20190529221124028](/Users/wzb/Documents/Android_Dev_Note/shell/assets/image-20190529221124028.png)

如果不给skill变量加花括号，写成echo `"I am good at $skillScript"`，解释器就会把$skillScript当成一个变量（其值为空），代码执行结果就不是我们期望的样子了。

``` shell
for skill in Ada Coffe Action Java; do
    echo "I am good at $skill Script"
done
```

![image-20190529221246962](/Users/wzb/Documents/Android_Dev_Note/shell/assets/image-20190529221246962.png)

推荐给所有变量加上花括号，这是个好的编程习惯。

已定义的变量，可以被重新定义，如：

```shell
your_name="tom"
echo $your_name
your_name="alibaba"
echo $your_name
```

这样写是合法的，但注意，第二次赋值的时候不能写 `$your_name="alibaba"`，使用变量的时候才加美元符（$）。

### 2.3 只读变量

使用 readonly 命令可以将变量定义为只读变量，只读变量的值不能被改变。

下面的例子尝试更改只读变量，结果报错：

```shell
#!/bin/bash
myUrl="http://www.google.com"
readonly myUrl
myUrl="http://www.runoob.com"
```

运行脚本，结果如下：

``` shell
line 13: myUrl: readonly variable
```

### 2.4 删除变量

使用 unset 命令可以删除变量。语法：

```
unset variable_name
```

变量被删除后不能再次使用。unset 命令不能删除**只读变量**。

**实例**

```
#!/bin/sh
myUrl="http://www.runoob.com"
unset myUrl
echo $myUrl
```

以上实例执行将没有任何输出。

![image-20190529222357353](/Users/wzb/Documents/Android_Dev_Note/shell/assets/image-20190529222357353.png)

### 变量类型

运行shell时，会同时存在三种变量：

- **1) 局部变量** 

  ​	局部变量在脚本或命令中定义，仅在当前shell实例中有效，其他shell启动的程序不能访问局部变量。

- **2) 环境变量** 

  ​	所有的程序，包括shell启动的程序，都能访问环境变量，有些程序需要环境变量来保证其正常运行。必要的时候shell脚本也可以定义环境变量。

- **3) shell变量** 

  ​	shell变量是由shell程序设置的特殊变量。shell变量中有一部分是环境变量，有一部分是局部变量，这些变量保证了shell的正常运行



















## 参考

[Shell 教程](https://www.runoob.com/linux/linux-shell.html)