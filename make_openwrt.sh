RED='\e[1;31m'
YELLOW='\e[1;33m'
GREEN='\e[1;32m'
OTHER="\e[1;$[RANDOM%7+31]m"
END='\e[0m'
trap '' int quit
echo "此脚本用于编译openwrt固件，不要使用CentOS系统"
pwd=`pwd`
read -e -p "`echo -e "$YELLOW请选择工作空间，默认为$pwd    $END"`" INPUT
DIR=${INPUT:-$pwd}
[ ! -d $DIR ] && mkdir -p $DIR
cd $DIR ||exit 1
os_type(){
  grep centos /etc/os-release &> /dev/null && echo "centos"
}
apt1(){
  if [[ `os_type` =~ centos ]];then
    echo -e "$RED该脚本不适用于centos$END"
    exit 1
  else
    sudo apt-get update
    sudo apt install build-essential ccache ecj fastjar file g++ gawk gettext git java-propose-classpath libelf-dev libncurses5-dev libncursesw5-dev libssl-dev python python2.7-dev python3 unzip wget python3-distutils python3-setuptools rsync subversion swig time xsltproc zlib1g-dev
  fi
}
git1(){
  if [ ! -d $DIR/openwrt/ ];then
    echo -e "${YELLOW}开始拉取源码$END"
    git clone https://github.com/openwrt/openwrt.git $DIR/openwrt/
  else
    echo -e "${RED}$DIR/openwrt/ 文件已经存在$END"
  fi
}
tag_1(){
  echo -e "$YELLOW此源码包含的tag如下：$END" &&
  cd $DIR/openwrt/ && git tag
  read -e -p "请输入你要选择的tag：" input0
  git checkout $input0 && echo -e "${GREEN}你已经成功切换分支为$END${YELLOW}$input0$END"||echo -e "${RED}切换tag失败$END"
}
src2(){
  echo -e "${YELLOW}开始编辑src-git$END"
  [ ! -e $DIR/openwrt/feeds.conf.default.bak ] && cp $DIR/openwrt/feeds.conf.default $DIR/openwrt/feeds.conf.default.bak
  vi $DIR/openwrt/feeds.conf.default
}
feed(){
  echo -e "$YELLOW更新feed$END" &&
  /usr/bin/env  perl $DIR/openwrt/scripts/feeds update -a &&
  echo -e "$YELLOW安装feed$END" &&
  /usr/bin/env  perl $DIR/openwrt/scripts/feeds install -a
}
config(){
  echo -e "$OTHER开始配置文件吧$END"
  cd $DIR/openwrt/ && make menuconfig
}
dl_1(){
  echo -e "${YELLOW}下载DL库$END"
  cd $DIR/openwrt/
  make download V=s
}
dl_2(){
  cd $DIR/openwrt/
  read -n 1 -p "`echo -e "$YELLOW请输入下载DL库的线程数：$END"`" input1
  read -n 1 -p "`echo -e "$YELLOW请输入下载DL库的次数：$END"`" input2
  [[ $input1 =~ [0-9] ]] || { echo -e "$RED请输入数字$END";exit 1; }
  [[ $input2 =~ [0-9] ]] || { echo -e "$RED请输入数字$END";exit 1; }
  for ((i=1;i<=$input2;i++));do
    echo -e "$OTHER开始第$i次下载DL库$END"
    make -j$input1 download V=s && echo -e "$OTHER第$i次下载DL库完成$END"
  done
}
make1(){
  cd $DIR/openwrt/
  export FORCE_UNSAFE_CONFIGURE=1
  export FORCE=1
  echo -e "$OTHER开始编译咯！$END"
  make  V=s
}
make2(){
  cd $DIR/openwrt/ && export FORCE_UNSAFE_CONFIGURE=1 && export FORCE=1
  read -n 1 -p "`echo -e "$YELLOW请输入编译线程数：$END"`" input3
  [[ $input3 =~ [0-9] ]] || { echo -e "$RED请输入数字$END";exit 1; }
  echo -e "$OTHER开始编译咯！$END"
  make -j$input3 V=s
}
dirclean2(){
  cd $DIR/openwrt/ && make dirclean
}
git2(){
  cd $DIR/openwrt/ && git pull
}
defconfig2(){
  make defconfig
}
delete_dir3(){
  cd $DIR/openwrt/ && rm -rf build_dir/ staging_dir/ tmp/
}
qt5_3(){
  wget -P $DIR/openwrt/dl/ https://download.qt.io/archive/qt/5.9/5.9.8/single/qt-everywhere-opensource-src-5.9.8.tar.xz
}
re_config3(){
  cd $DIR/openwrt/ && rm -rf ./tmp && rm -rf .config
}
single_4(){
  config && echo -e "${YELLOW}配置结束，开始下载DL库:  $END"
  dl_2 && echo -e "${GREEN}下载DL库--成功$END"||echo -e "${RED}下载DL库--失败$END"
  echo
  read -p "`echo -e "${YELLOW}请输入单独编译插件的名字:  $END"`" name
  echo -e "你输入的插件名字为 $RED${name}$END
  ${YELLOW}编译开始$END"
  make package/${name}/compile V=99
}
while :;do
  echo -e "
此脚本功能如下：$OTHER
  (0) 退出脚本
  (1) 首次编译
  (2) 二次编译
  (3) 其他
  (4) 编译插件
  $END"
read -n 1 -p "请输入: "
  case $REPLY in 
    0)
      echo -e "$OTHER感谢使用此脚本，欢迎下次使用！$END"
      break
    ;;
    1)
      while :;do
      echo -e "$GREEN
	    (0) 返回上一级 
	    (1) 切换tag
	    (2) 安装相关依赖 
	    (3) 下载源码 
	    (4) feed更新及安装 
	    (5) 配置菜单
	    (6) 下载DL库
	    (7) 编译
	    (8) 全部执行
	    $END" 
      read -n 1 -p "请输入: "
        case $REPLY in
          0)
            break
          ;;
		  1)
		    tag_1 && echo -e "${GREEN}切换tag--成功$END"||echo -e "${RED}切换tag--失败$END"
		  ;;
          2)
	        apt1 && echo -e "${GREEN}安装依赖--成功$END"||echo -e "${RED}安装依赖--失败$END"
          ;;
          3)
	        git1 && echo -e "${GREEN}下载源码--成功$END"||echo -e "${RED}下载源码--失败$END"
          ;;
          4)
	        feed && echo -e "${GREEN}feed更新及安装--成功$END"||echo -e "${RED}feed更新及安装--失败$END"
          ;;
          5)
	        config && echo -e "${GREEN}配置菜单--成功$END"||echo -e "${RED}配置菜单--失败$END"
          ;;
          6)
	        dl_1 && echo -e "${GREEN}下载DL库--成功$END"||echo -e "${RED}下载DL库--失败$END"
          ;;
          7)
	        make1 && echo -e "${GREEN}编译--成功$END" || echo -e "${RED}编译--失败$END"
          ;;
          8)
	        apt1 && git1 && feed && config && dl_1 && make1
		    [ $? = 0 ] && echo -e "${GREEN}编译--成功$END" || echo -e "${RED}编译--失败$END"
          ;;
	      *)
            echo -e "$RED\t输入错误，请重新输入$END"
        esac
      done
    ;;
    2)
      while :;do
	    echo -e "$YELLOW
	    (0) 返回上一级
	    (1) 清理所有编译文件
	    (2) git pull
	    (3) 编辑src-git
	    (4) feed更新及安装
	    (5) make defconfig
	    (6) 配置菜单
	    (7) 下载DL库
	    (8) 编译
		(9) 全部执行
	    $END"
      read -n 1 -p "请输入: "
        case $REPLY in
          0)
            break
          ;;
          1)
	        dirclean2 && echo -e "${GREEN}清理所有编译文件--成功$END"||echo -e "${RED}清理所有编译文件--失败$END"
          ;;
          2)
	        git2 && echo -e "${GREEN}git pull--成功$END"||echo -e "${RED}git pull--失败$END"
          ;;
          3)
	        src2 && echo -e "${GREEN}编译src-git--成功$END"||echo -e "${RED}编译src-git--失败$END"
          ;;
          4)
	        feed && echo -e "${GREEN}feed更新及安装--成功$END"||echo -e "${RED}feed更新及安装--失败$END"
          ;;
          5)
	        defconfig2 && echo -e "${GREEN}make defconfig--成功$END"||echo -e "${RED}make defconfig--失败$END"
          ;;
          6)
	        config && echo -e "${GREEN}配置菜单--成功$END"||echo -e "${RED}配置菜单--失败$END"
          ;;
          7)
	        dl_2 && echo -e "${GREEN}下载DL库--成功$END"||echo -e "${RED}下载DL库--失败$END"
          ;;
          8)
	        make2 && echo -e "${GREEN}编译--成功$END"||echo -e "${RED}编译--失败$END"
          ;;
		  9)
	        dirclean2 && git2 && src2 && feed && defconfig2 && config && dl_2 && make2
		    [ $? = 0 ] && echo -e "${GREEN}编译--成功$END"||echo -e "${RED}编译--失败$END"
          ;;
	     *)
            echo -e "$RED\t输入错误，请重新输入$END"
        esac
      done
    ;;
    3)
      while :;do
	    echo -e "$RED
	    (0) 返回上一级
		(1) 删除build_dir、staging_dir以及tmp
		(2) 下载qt5包
		(3) 重新配置
	    $END"
      read -n 1 -p "请输入: "
        case $REPLY in
          0)
            break
          ;;
          1)
            delete_dir3 && echo -e "${GREEN}删除build_dir、staging_dir以及tmp--成功$END"||echo -e "${RED}删除build_dir、staging_dir以及tmp--失败$END"
          ;;
          2)
            qt5_3 && echo -e "${GREEN}下载qt5包--成功$END"||echo -e "${RED}下载qt5包--失败$END"
          ;;
          3)
            re_config && echo -e "${GREEN}重新配置--成功$END"||echo -e "${RED}重新配置--失败$END"
          ;;
	      *)
            echo -e "$RED\t输入错误，请重新输入$END"
        esac
      done
    ;;
    4)
      single_4 && echo -e "${GREEN}编译插件${name}--成功$END" || echo -e "${RED}编译插件${name}--失败$END"
	;;
    *)
      echo -e "$RED\t输入错误，请重新输入$END"
  esac
done
