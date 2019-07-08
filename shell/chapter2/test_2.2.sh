# 2.2.2 1
# your_name="runoob"
# # 使用双引号拼接
# greeting="hello, "$your_name" !"
# greeting_1="hello, ${your_name} !"
# echo $greeting  $greeting_1
# # 使用单引号拼接
# greeting_2='hello, '$your_name' !'
# greeting_3='hello, ${your_name} !'
# echo $greeting_2  $greeting_3

# 2.2.2 2
# string="abcd"
# echo ${#string} #输出 4

# 2.2.2 3
# string="runoob is a great site"
# echo ${string:1:4} # 输出 unoo

# 2.2.2 4
string="runoob is a great site"
echo `expr index "$string" io`  # 输出 4