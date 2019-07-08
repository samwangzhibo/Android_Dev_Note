# if [ -n "$1" ]; then
#     echo "包含第一个参数"
# else
#     echo "没有包含第一参数"
# fi

if [ "$1" -eq 0 ]; then
    echo "第一个参数为0"
else
    echo "第一个参数不为0"
fi

# if [ -e "$1" ] || [ -d "$1" ]; then
#     echo "第一个参数为目录或者存在"
# else
#     echo "第一个参数不为目录或者不存在"
# fi

if test -e "$1"  || test -d "$1"; then
    echo "第一个参数为目录或者存在"
else
    echo "第一个参数不为目录或者不存在"
fi
