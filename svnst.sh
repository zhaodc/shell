#优化svn st 输出
function svnst() {
        #计数器
        count=1;
        lp=0;
        tmpstr="";
        s=0;
        tmpstr2="";
        for str in $(/usr/bin/svn st)
        do
                if [ "$str" == "?" ];then
                        s=1
                        if [ "$tmpstr2" == "" ];then
                                tmpstr2="$str";
                        else
                                tmpstr2="$tmpstr2\t$str";
                        fi
                        continue;
                fi
                if [ "$s" == 1 ];then
                        s=0
                        if [ "$1" == "" ];then
                                echo -e "\t$tmpstr2\t$str";
                        fi
                        tmpstr2="";
                        continue;
                fi

                if [ "$tmpstr" == "" ];then
                        tmpstr="$str";
                else
                        tmpstr="$tmpstr\t$str";
                fi
                lp=$(($lp+1));

                if [ $(($lp%2)) == 0 ];then
                        if [ "$1" == "" ];then
                                echo -e "$count\t$tmpstr";
                        else 
                                if [ "$1" == $count ];then
                                        vim $str;
                                fi
                        fi
                        tmpstr="";
                        count=$(($count+1));
                fi
        done
}
function svndi() {
        s=0;
        i=0;
        for var in $(/usr/bin/svn st)
        do 
                if [ "$var" == "M" ] ||   #修改
                   [ "$var" == "A" ] ||   #增加
                   [ "$var" == "C" ] ||   #冲突
                   [ "$var" == "I" ] ||   #忽略
                   [ "$var" == "R" ] ||   #替换
                   [ "$var" == "X" ] ||   #未纳入版本控制的目录，被外部引用的目录所创建
                   [ "$var" == "!" ] ||   #该项目已遗失(被非 svn 命令删除)或不完整
                   [ "$var" == "~" ] ||   #版本控制下的项目与其它类型的项目重名
                   [ "$var" == "D" ] ||   #删除
                   [ "$var" == "U" ];then 
                        continue;
                fi
                if [ "$var" == "?" ];then
                        s=1
                        continue;
                fi
                if [ "$s" == 1 ];then
                        s=0
                        continue;
                fi

                i=$(($i+1))
                if [ "$i" == "$1" ];then
                        /usr/bin/php -l  $var
                        /usr/bin/svn di $var
                fi
        done
}

svnst;
read -p "input file index:" input
loop=$input
while [ 1 ] 
do
        if [ "$loop" == "q" ];then
                break;
        fi
        if [ "$loop" == "a" ];then # || [ "$loop" == "" ];then
                svnst
        fi
        if [ "${loop:0:3}" == "vim" ];then
                len=$((${#loop}-4));
                svnst ${loop:4:$len};
        else
                svndi $loop
        fi
        read -p "input file index:" input
        loop=$input
done
