array_name=(
value0
value1
value2
value3
)
echo "数组第一个元素：${array_name[0]}"

length=${#array_name[*]}
echo "数组总元素个数： ${length}"

lengthn=${#array_name[0]}
echo "数组第一个元素长度： ${lengthn}"