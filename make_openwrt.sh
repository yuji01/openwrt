RED='\e[1;31m'
YELLOW='\e[1;33m'
GREEN='\e[1;32m'
BLUE='\e[1;34m'
OTHER="\e[1;$[RANDOM%7+31]m"
END='\e[0m'
echo -e "$OTHER此脚本用于编译openwrt固件，不要使用CentOS系统$END"
pwd=`pwd`
read -e -p "`echo -e "$YELLOW请选择工作空间，默认为$pwd    $END"`" INPUT
DIR=${INPUT:-$pwd}
[ ! -d $DIR ] && mkdir -p $DIR
cd $DIR ||exit 1
echo -e "${YELLOW}请选择版本，默认为openwrt，选择lean源码请输入${RED}lede$END"
read -e -p "请输入：" INPUT_VERSION
if [[ $INPUT_VERSION = "lede" ]];then
  export VERSION="lede"
else
  export VERSION="openwrt"
fi
echo -e "最终使用的源码为$RED $VERSION $END，若想使用其他源码，请重新运行此脚本"
os_type(){
  grep centos /etc/os-release &> /dev/null && echo "centos"
}
apt1(){
  echo -e "${YELLOW}开始安装依赖$END"
  if [[ `os_type` =~ centos ]];then
    echo -e "${RED}该脚本不适用于centos$END"
    exit 1
  elif [ $VERSION = "openwrt" ];then
    sudo apt-get update &&
    sudo apt install -y build-essential ccache ecj fastjar file g++ gawk gettext git java-propose-classpath libelf-dev libncurses5-dev libncursesw5-dev libssl-dev python python2.7-dev python3 unzip wget python3-distutils python3-setuptools rsync subversion swig time xsltproc zlib1g-dev &&
	echo -e "${GREEN}安装依赖--成功$END"||echo -e "${RED}安装依赖--失败$END"
  else
    sudo apt update -y &&
    sudo apt full-upgrade -y &&
    sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
    bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext gcc-multilib g++-multilib \
    git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev libltdl-dev \
    libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libreadline-dev libssl-dev libtool lrzsz \
    mkisofs msmtp nano ninja-build p7zip p7zip-full patch pkgconf python2.7 python3 python3-pip qemu-utils \
    rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev &&
	echo -e "${GREEN}安装依赖--成功$END"||echo -e "${RED}安装依赖--失败$END"
  fi
}
git1(){
  if [ ! -d $DIR/$VERSION/ -a $VERSION = "openwrt" ];then
    echo -e "${YELLOW}开始拉取源码$END"
    git clone https://github.com/openwrt/openwrt.git &&
	echo -e "${GREEN}下载源码--成功$END"||echo -e "${RED}下载源码--失败$END"
  else
    echo -e "${RED}$DIR/$VERSION/ 文件已经存在$END"
  fi
  if [ ! -d $DIR/$VERSION/ -a $VERSION = "lede" ];then
    echo -e "${YELLOW}开始拉取源码$END"
    git clone https://github.com/coolsnowwolf/lede.git && 
	echo -e "${GREEN}下载源码--成功$END"||echo -e "${RED}下载源码--失败$END"
  else
    echo -e "${RED}文件存放在 $DIR/$VERSION/$END"
  fi
}
dir_exist(){
  if [ ! -d $DIR/$VERSION/ ];then
    echo -e "${RED}目录：$DIR/$VERSION 不存在，程序退出$END"
    quit
  fi
}
tag_1(){
  dir_exist &&
  echo -e "${YELLOW}此源码包含的tag如下：$END" &&
  cd $DIR/$VERSION/ && git tag
  read -e -p "请输入你要选择的tag：" input0
  git checkout $input0 && echo -e "${GREEN}你已经成功切换分支为$END${YELLOW} $input0$END"||echo -e "${RED}切换tag失败$END"
}
src2(){
  dir_exist &&
  echo -e "${YELLOW}开始编辑src-git$END"
  [ ! -e $DIR/$VERSION/feeds.conf.default.bak ] && cp $DIR/$VERSION/feeds.conf.default $DIR/$VERSION/feeds.conf.default.bak
  vi $DIR/$VERSION/feeds.conf.default &&
  echo -e "${GREEN}编辑src-git--成功$END"||echo -e "${RED}编辑src-git--失败$END"
}
feed(){
  dir_exist &&
  echo -e "${YELLOW}清理feed$END" &&
  /usr/bin/env  perl $DIR/$VERSION/scripts/feeds clean
  echo -e "${YELLOW}更新feed$END" &&
  /usr/bin/env  perl $DIR/$VERSION/scripts/feeds update -a
  echo -e "${YELLOW安装}feed$END"
  /usr/bin/env  perl $DIR/$VERSION/scripts/feeds install -a &&
  echo -e "${GREEN}feed更新及安装--成功$END"||echo -e "${RED}feed更新及安装--失败$END"
}
config(){
  dir_exist &&
  echo -e "${OTHER}开始配置菜单$END"
  cd $DIR/$VERSION/ && make menuconfig &&
  echo -e "${GREEN}配置菜单--成功$END"||echo -e "${RED}配置菜单--失败$END"
}
dl_1(){
  dir_exist &&
  echo -e "${YELLOW}下载DL库$END"
  cd $DIR/$VERSION/
  make download V=s &&
  echo -e "${GREEN}下载DL库--成功$END"||echo -e "${RED}下载DL库--失败$END"
}
dl_2(){
  dir_exist &&
  cd $DIR/$VERSION/
  read -n 1 -p "`echo -e "$YELLOW请输入下载DL库的次数：$END"`" input2
  [[ $input2 =~ [0-9] ]] || { echo -e "$RED请输入数字$END";exit 1; }
  for ((i=1;i<=$input2;i++));do
    echo -e "$OTHER开始第$i次下载DL库$END"
    make -j8 download V=s && echo -e "$OTHER第$i次下载DL库完成$END"
    [ $i -eq $input2 ] && 
	echo -e "${GREEN}下载DL库--成功$END"||echo -e "${YELLOW}下载DL库--失败$END"
  done
}
make1(){
  dir_exist &&
  cd $DIR/$VERSION/
  export FORCE_UNSAFE_CONFIGURE=1
  export FORCE=1
  echo -e "${OTHER}编译开始$END"
  make  V=s &&
  echo -e "${GREEN}编译--成功$END" || echo -e "${RED}编译--失败$END"
}
make2(){
  dir_exist &&
  cd $DIR/$VERSION/ && export FORCE_UNSAFE_CONFIGURE=1 && export FORCE=1
  read -n 1 -p "`echo -e "$YELLOW请输入编译线程数：$END"`" input3
  [[ $input3 =~ [0-9] ]] || { echo -e "$RED请输入数字$END";exit 1; }
  echo -e "$OTHER开始编译咯！$END"
  make -j$input3 V=s &&
  echo -e "${GREEN}编译--成功$END" || echo -e "${RED}编译--失败$END"
}
clean2(){
  dir_exist &&
  echo -e "${YELLOW}开始清理编译结果$END"
  cd $DIR/$VERSION/
  make clean &&
  echo -e "${GREEN}清理编译结果--成功$END"||echo -e "${RED}清理编译结果--失败$END"
}
dirclean2(){
  dir_exist &&
  echo -e "${YELLOW}开始清理所有编译文件$END"
  cd $DIR/$VERSION/
  make dirclean &&
  echo -e "${GREEN}清理所有编译文件--成功$END"||echo -e "${RED}清理所有编译文件--失败$END"
}
distclean2(){
  dir_exist &&
  echo -e "${YELLOW}开始清理所有编译文件以及相关依赖$END"
  cd $DIR/$VERSION/
  make distclean &&
  echo -e "${GREEN}清理所有编译文件以及相关依赖--成功$END"||echo -e "${RED}清理所有编译文件以及相关依赖--失败$END"
}
clean_xdf2(){
  dir_exist &&
  echo -e "${YELLOW}开始恢复初始状态$END"
  cd $DIR/$VERSION/
  git clean -xdf &&
  echo -e "${GREEN}恢复初始状态--成功$END"||echo -e "${RED}恢复初始状态--失败$END"
}
git2(){
  dir_exist &&
  echo -e "${YELLOW}开始git pull$END"
  cd $DIR/$VERSION/
  git pull &&
  echo -e "${GREEN}git pull--成功$END"||echo -e "${RED}git pull--失败$END"
}
defconfig2(){
  dir_exist &&
  echo -e "${YELLOW}开始make defconfig$END"
  cd $DIR/$VERSION/
  make defconfig &&
  echo -e "${GREEN}make defconfig--成功$END"||echo -e "${RED}make defconfig--失败$END"
}
delete_dir3(){
  dir_exist &&
  echo -e "${YELLOW}开始删除build_dir、staging_dir以及tmp$END"
  cd $DIR/$VERSION/
  rm -rf build_dir/ staging_dir/ tmp/ &&
  echo -e "${GREEN}删除build_dir、staging_dir以及tmp--成功$END"||echo -e "${RED}删除build_dir、staging_dir以及tmp--失败$END"
}
qt5_3(){
  dir_exist &&
  echo -e "${YELLOW}开始下载qt5包$END"
  wget -P $DIR/$VERSION/dl/ https://download.qt.io/archive/qt/5.9/5.9.8/single/qt-everywhere-opensource-src-5.9.8.tar.xz &&
  echo -e "${GREEN}下载qt5包--成功$END"||echo -e "${RED}下载qt5包--失败$END"
}
re_config3(){
  dir_exist &&
  echo -e "${YELLOW}开始重新配置$END"
  cd $DIR/$VERSION/ && rm -rf ./tmp && rm -rf .config &&
  echo -e "${GREEN}重新配置--成功$END"||echo -e "${RED}重新配置--失败$END"
}
single_4(){
  dir_exist &&
  echo -e "${YELLOW}开始编译单个插件$END"
  config && echo -e "${YELLOW}配置结束，开始下载DL库:  $END"
  dl_2 &&
  read -p "`echo -e "${YELLOW}请输入单独编译插件的名字:  $END"`" name
  echo -e "你输入的插件名字为 $RED${name}$END
  ${YELLOW}编译开始$END"
  make package/${name}/compile V=99 &&
  echo -e "${GREEN}编译插件${name}--成功$END" || echo -e "${RED}编译插件${name}--失败$END"
}
quit(){
  echo
  echo -e "${OTHER}感谢使用此脚本，欢迎下次使用！$END" && exit 1
}
while :;do
  echo -e "
${OTHER}主菜单：$END
    $BLUE[q] 退出脚本$END$OTHER
    [1] 首次编译
    [2] 二次编译
    [3] 其他
    [4] 编译插件
    $END"
read -n 1 -p "请输入: "
  case $REPLY in 
    q|Q)
      quit
      break
    ;;
    1)
      while :;do
        echo -e "
    ${GREEN}首次编译：$END
        $BLUE(q) 退出脚本$END$GREEN
        (0) 返回主菜单
        -----------------------------------
	(1) 安装相关依赖 
	(2) 下载源码 
	(3) 切换tag
	(4) feed更新及安装 
	(5) 配置菜单
	(6) 下载DL库
	(7) 编译
	(8) 全部执行
	$END" 
      read -n 1 -p "请输入: "
        case $REPLY in
          Q|q)
            quit
            break 2
          ;;
          0)
            break
          ;;
	  1)
	    apt1
	  ;;
          2)
	    git1
          ;;
          3)
	    tag_1
          ;;
          4)
	    feed
          ;;
          5)
	    config
          ;;
          6)
	    dl_1
          ;;
          7)
	    make1
          ;;
          8)
	    apt1 && git1 && tag_1 && feed && config && dl_1 && make1
          ;;
	  *)
            echo -e "$RED\t输入错误，请重新输入$END"
        esac
      done
    ;;
    2)
      while :;do
        echo -e "
    ${YELLOW}二次编译：$END
        $BLUE(q) 退出脚本$END$YELLOW
	(0) 返回主菜单
        -----------------------------------
	(1) 清理编译结果
	(2) 清理所有编译文件
	(3) 清理所有编译文件以及相关依赖
	(4) 恢复初始状态
        -----------------------------------
	(5) git pull
	(6) 编辑src-git
	(7) feed更新及安装
	(8) make defconfig
	(9) 配置菜单
       (10) 下载DL库
       (11) 编译
	$END"
      read -n 2 -p "请输入: "
        case $REPLY in
          Q|q)
            quit
            break 2
          ;;
          0)
            break
          ;;
          1)
	    clean2
          ;;
          2)
	    dirclean2
          ;;
          3)
	    distclean2
          ;;
          4)
	    clean_xdf2
          ;;
          5)
	    git2
          ;;
          6)
	    src2
          ;;
          7)
	    feed
          ;;
          8)
	    defconfig2
          ;;
          9)
	    config
          ;;
          10)
	    dl_2
          ;;
          11)
	    make2
          ;;
	  *)
            echo -e "$RED\t输入错误，请重新输入$END"
        esac
      done
    ;;
    3)
      while :;do
        echo -e "
    ${RED}其他：$END
        $BLUE(q) 退出脚本$END$RED
        (0) 返回主菜单
        -----------------------------------
	(1) 删除build_dir、staging_dir以及tmp
        (2) 下载qt5包
	(3) 重新配置
	 $END"
      read -n 1 -p "请输入: "
        case $REPLY in
          Q|q)
            quit
            break 2
          ;;
          0)
            break
          ;;
          1)
            delete_dir3
          ;;
          2)
            qt5_3
          ;;
          3)
            re_config3
          ;;
	  *)
            echo -e "$RED\t输入错误，请重新输入$END"
        esac
      done
    ;;
    4)
      single_4
	;;
    *)
      echo -e "$RED\t输入错误，请重新输入$END"
  esac
done
