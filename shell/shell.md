

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

#### **1.2 作为解释器参数**

这种运行方式是，直接运行解释器，其参数就是 shell 脚本的文件名，如：

```
wangzhibodeMacBook-Pro:chapter1 wzb$ /bin/sh hello\ world.sh 
hello world
```

这种方式运行的脚本，不需要在第一行指定解释器信息，写了也没用。

## 2. shell变量

### 2.1 变量

#### 2.1.1 定义变量

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

#### 2.1.2 使用变量

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

#### 2.1.3 只读变量

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

#### 2.1.4 删除变量

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

#### 2.1.5 变量类型

运行shell时，会同时存在三种变量：

- **1) 局部变量** 

  ​	局部变量在脚本或命令中定义，仅在当前shell实例中有效，其他shell启动的程序不能访问局部变量。

- **2) 环境变量** 

  ​	所有的程序，包括shell启动的程序，都能访问环境变量，有些程序需要环境变量来保证其正常运行。必要的时候shell脚本也可以定义环境变量。

- **3) shell变量** 

  ​	shell变量是由shell程序设置的特殊变量。shell变量中有一部分是环境变量，有一部分是局部变量，这些变量保证了shell的正常运行

### 2.2 Shell 字符串

​	字符串是shell编程中最常用最有用的数据类型（除了数字和字符串，也没啥其它类型好用了），字符串可以用单引号，也可以用双引号，也可以不用引号。单双引号的区别跟PHP类似。

#### 2.2.1 定义

1. 单引号

```
str='this is a string'
```

单引号字符串的限制：

- 单引号里的任何字符都会原样输出，单引号字符串中的变量是无效的；
- 单引号字串中不能出现单独一个的单引号（对单引号使用转义符后也不行），但可成对出现，作为字符串拼接使用。

2. 双引号

```
your_name='runoob'
str="Hello, I know you are \"$your_name\"! \n"
echo -e $str
```

输出结果为：

```
Hello, I know you are "runoob"! 
```

双引号的优点：

- 双引号里可以有变量
- 双引号里可以出现转义字符

#### 2.2.2 操作

1. 拼接字符串

   ``` shell
   your_name="runoob"
   # 使用双引号拼接
   greeting="hello, "$your_name" !"
   greeting_1="hello, ${your_name} !"
   echo $greeting  $greeting_1
   # 使用单引号拼接
   greeting_2='hello, '$your_name' !'
   greeting_3='hello, ${your_name} !'
   echo $greeting_2  $greeting_3
   ```

   ```shell
   wangzhibo03:chapter2 wzb$  /bin/sh test_2.2.sh 
   hello, runoob ! hello, runoob !
   hello, runoob ! hello, ${your_name} !
   ```

2. 获取字符串长度

   ``` shell
   string="abcd"
   echo ${#string} #输出 4
   ```

   输出

   ```shell
   wangzhibo03:chapter2 wzb$  /bin/sh test_2.2.sh 
   4
   ```

3. 提取子字符串

   以下实例从字符串第 **2** 个字符开始截取 **4** 个字符：

   ```shell
   string="runoob is a great site"
   echo ${string:1:4} # 输出 unoo
   ```

   ```shell
   wangzhibo03:chapter2 wzb$  /bin/sh test_2.2.sh 
   unoo
   ```

4. 查找子字符串

   查找字符 **i** 或 **o** 的位置(哪个字母先出现就计算哪个)：

   ```shell
   string="runoob is a great site"
   echo `expr index "$string" io`  # 输出 4
   ```

   **注意：** 以上脚本中 **`** 是反引号，而不是单引号 **'**，不要看错了哦。

### 2.3 Shell 数组

bash支持一维数组（不支持多维数组），并且没有限定数组的大小。

类似于 C 语言，数组元素的下标由 0 开始编号。获取数组中的元素要利用下标，下标可以是整数或算术表达式，其值应大于或等于 0。

#### 定义数组

​	在 Shell 中，用括号来表示数组，数组元素用"空格"符号分割开。定义数组的一般形式为：

```shell
数组名=(值1 值2 ... 值n)
```

```
array_name=(value0 value1 value2 value3)
```

或者

```shell
array_name=(
value0
value1
value2
value3
)
```

还可以单独定义数组的各个分量：

```shell
array_name[0]=value0
array_name[1]=value1
array_name[n]=valuen
```

可以不使用连续的下标，而且下标的范围没有限制。

#### 读取数组

读取数组元素值的一般格式是：

```
${数组名[下标]}
```

例如：

```
valuen=${array_name[n]}
```

使用 **@** 符号可以获取数组中的所有元素，例如：

```
echo ${array_name[@]}
```

#### 获取数组的长度

获取数组长度的方法与获取字符串长度的方法相同，例如：

```
# 取得数组元素的个数
length=${#array_name[@]}
# 或者
length=${#array_name[*]}
# 取得数组单个元素的长度
lengthn=${#array_name[n]}
```



### 2.4 注释

以 **#** 开头的行就是注释，会被解释器忽略。

通过每一行加一个 **#** 号设置多行注释，像这样：

```
#--------------------------------------------
# 这是一个注释
# author：菜鸟教程
# site：www.runoob.com
# slogan：学的不仅是技术，更是梦想！
#--------------------------------------------
##### 用户配置区 开始 #####
#
#
# 这里可以添加脚本描述信息
# 
#
##### 用户配置区 结束  #####
```

如果在开发过程中，遇到大段的代码需要临时注释起来，过一会儿又取消注释，怎么办呢？

每一行加个#符号太费力了，可以把这一段要注释的代码用一对花括号括起来，定义成一个函数，没有地方调用这个函数，这块代码就不会执行，达到了和注释一样的效果。

### 多行注释

多行注释还可以使用以下格式：

```shell
:<<EOF
注释内容...
注释内容...
注释内容...
EOF
```

EOF 也可以使用其他符号:

```shell
:<<'
注释内容...
注释内容...
注释内容...
'

:<<!
注释内容...
注释内容...
注释内容...
!
```



## 3. Shell 传递参数

> ​	我们可以在执行 Shell 脚本时，向脚本传递参数，脚本内获取参数的格式为：**$n**。**n** 代表一个数字，1 为执行脚本的第一个参数，2 为执行脚本的第二个参数，以此类推……

### 3.1 实例

以下实例我们向脚本传递三个参数，并分别输出，其中 **$0** 为执行的文件名：

```
#!/bin/bash
# author:菜鸟教程
# url:www.runoob.com

echo "Shell 传递参数实例！";
echo "执行的文件名：$0";
echo "第一个参数为：$1";
echo "第二个参数为：$2";
echo "第三个参数为：$3";
```

为脚本设置可执行权限，并执行脚本，输出结果如下所示：

```shell
wangzhibo03:chapter3 wzb$ chmod +x test_3.sh 
wangzhibo03:chapter3 wzb$ ./test_3.sh 1 2 3
Shell 传递参数实例！
执行的文件名：./test_3.sh
第一个参数为：1
第二个参数为：2
第三个参数为：3
```

### 3.2 特殊字符

另外，还有几个特殊字符用来处理参数：

| 参数处理 | 说明                                                         |
| :------- | :----------------------------------------------------------- |
| $#       | 传递到脚本的参数个数                                         |
| $*       | 以一个单字符串显示所有向脚本传递的参数。 如"$*"用「"」括起来的情况、以"$1 $2 … $n"的形式输出所有参数。 |
| $$       | 脚本运行的当前进程ID号                                       |
| $!       | 后台运行的最后一个进程的ID号                                 |
| $@       | 与$*相同，但是使用时加引号，并在引号中返回每个参数。 如"$@"用「"」括起来的情况、以"$1" "$2" … "$n" 的形式输出所有参数。 |
| $-       | 显示Shell使用的当前选项，与[set命令](https://www.runoob.com/linux/linux-comm-set.html)功能相同。 |
| $?       | 显示最后命令的退出状态。0表示没有错误，其他任何值表明有错误。 |

```shell
#!/bin/bash
# author:菜鸟教程
# url:www.runoob.com

echo "Shell 传递参数实例！";
echo "第一个参数为：$1";

echo "参数个数为：$#";
echo "传递的参数作为一个字符串显示：$*";
```

执行脚本，输出结果如下所示：

```shell
$ chmod +x test.sh 
$ ./test.sh 1 2 3
Shell 传递参数实例！
第一个参数为：1
参数个数为：3
传递的参数作为一个字符串显示：1 2 3
```

$* 与 $@ 区别：

- 相同点：都是引用所有参数。
- 不同点：只有在双引号中体现出来。假设在脚本运行时写了三个参数 1、2、3，，则 " * " 等价于 "1 2 3"（传递了一个参数），而 "@" 等价于 "1" "2" "3"（传递了三个参数）。

```shell
#!/bin/bash
# author:菜鸟教程
# url:www.runoob.com

echo "-- \$* 演示 ---"
for i in "$*"; do
    echo $i
done

echo "-- \$@ 演示 ---"
for i in "$@"; do
    echo $i
done
```

执行脚本，输出结果如下所示：

```shell
$ chmod +x test.sh 
$ ./test.sh 1 2 3
-- $* 演示 ---
1 2 3
-- $@ 演示 ---
1
2
3
```

### 3.3 中括号参数过滤

在为shell脚本传递的参数中**如果包含空格，应该使用单引号或者双引号将该参数括起来，以便于脚本将这个参数作为整体来接收**。

在有参数时，可以使用对参数进行校验的方式处理以减少错误发生：

```shell
if [ -n "$1" ]; then
    echo "包含第一个参数"
else
    echo "没有包含第一参数"
fi
```

效果：

```shell
wangzhibo03:chapter3 wzb$ ./test_3.3.sh 
没有包含第一参数
wangzhibo03:chapter3 wzb$ ./test_3.3.sh sad sad sdasd
包含第一个参数
```

**注意**：中括号 **[]** 与其中间的代码应该有空格隔开



Shell 里面的中括号（包括单中括号与双中括号）可用于一些条件的测试：

- 算术比较, 比如一个变量是否为0, `[ $var -eq 0 ]`。
- 文件属性测试，比如一个文件是否存在，`[ -e $var ]`, 是否是目录，`[ -d $var ]`。
- 字符串比较, 比如两个字符串是否相同， `[[ $var1 = $var2 ]]`。

## 4. Shell 数组

## 5. Shell 基本运算符

### 5.1 算数运算符

### 5.2 关系运算符

### 5.3 布尔运算符

### 5.4 字符串运算符

### 5.5 文件测试运算符



## 6. Shell 流程控制

## 7. Shell 输入/输出重定向





## 参考

[Shell 教程](https://www.runoob.com/linux/linux-shell.html)

[shell在线测试地址](https://www.runoob.com/try/runcode.php?filename=add2data&type=bash)