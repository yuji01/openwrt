RED='\e[1;31m'
YELLOW='\e[1;33m'
GREEN='\e[1;32m'
OTHER="\e[1;$[RANDOM%7+31]m"
END='\e[0m'
trap '' int quit
echo "此脚本用于编译openwrt固件，不要使用CentOS系统"
read -p "`echo -e "$YELLOW请选择工作空间，默认为/data    $END"`" INPUT
DIR=${INPUT:-/data}
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
  if [ ! -d $DIR ];then
  mkdir -p $DIR
  fi
  if [ -d $DIR/openwrt/ ];then
    echo -e "$RED已经存在了相同的文件$END"
  else
    cd $DIR/ && git clone https://github.com/openwrt/openwrt.git
  fi
}
src2(){
  cd $DIR/openwrt/
  [ ! -e feeds.conf.default.bak ] && cp feeds.conf.default feeds.conf.default.bak
  vi feeds.conf.default
}
feed(){
  echo -e "$YELLOW更新feed$END"
  cd $DIR/openwrt/scripts/
  /usr/bin/env  perl feeds update -a
  echo -e "$YELLOW安装feed$END"
  cd $DIR/openwrt/scripts/
  /usr/bin/env  perl feeds install -a
}
config(){
  cd $DIR/openwrt/ && echo -e "$OTHER开始配置文件吧$END"
  make menuconfig
}
dl(){
  cd $DIR/openwrt/
  read -p "`echo -e "$YELLOW请选择下载次数：$END"`" input
  [[ $input =~ [^0-9] ]] && { echo -e "\t$RED请输入数字$END";dl; }
  for ((i=1;i<=$input;i++));do
    echo -e "$OTHER开始第$i次下载DL库$END"
    make -j8 download V=s && echo -e "$OTHER第$i次下载DL库完成$END"
  done
}
make1(){
  cd $DIR/openwrt/
  export FORCE_UNSAFE_CONFIGURE=1
  export FORCE=1
  echo -e "$OTHER开始编译咯！$END"
  make -j1 V=s
}
make2(){
  cd $DIR/openwrt/
  export FORCE_UNSAFE_CONFIGURE=1
  export FORCE=1
  read -p "`echo -e "$YELLOW请选择编译线程数，第一次建议1线程：$END"`" input
  [[ $input =~ [^0-9] ]] && { echo -e "\t$RED请输入数字$END";make2; }
  echo -e "$OTHER开始编译咯！$END"
  make -j$input V=s
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
  cd $DIR/openwrt/
  rm -rf build_dir/ staging_dir/ tmp/
}
qt5_3(){
  cd $DIR/openwrt/dl/
  wget https://download.qt.io/archive/qt/5.9/5.9.8/single/qt-everywhere-opensource-src-5.9.8.tar.xz
}
re_config3(){
  cd $DIR/openwrt/
  rm -rf ./tmp && rm -rf .config
}
single_4(){
  config
  echo -e "${YELLOW}开始下载DL库:  $END"
  dl && echo -e "${GREEN}下载DL库--成功$END"||echo -e "${RED}下载DL库--失败$END"
  read -p "`echo -e "${YELLOW}请输入单独编译插件的名字:  $END"`" name
  echo -e "${YELLOW}你输入的插件名字为$END $RED${name}$END"
  echo -e "${YELLOW}编译开始$END"
  make package/${name}/compile V=99
}
while :;do
printf "$OTHER%s\n$END" '(0) 退出脚本' '(1) 首次编译' '(2) 二次编译' '(3) 其他' '(4) 编译插件'
read -p "请输入: "
  case $REPLY in 
    0)
      echo -e "$OTHER感谢使用此脚本，欢迎下次使用！$END"
      break
    ;;
    1)
      while :;do
      printf "$GREEN%s\n$END" '(0) 返回上一级' '(1) 安装相关依赖' '(2) 下载源码' '(3) feed更新及安装' '(4) 配置菜单' '(5) 下载DL库' '(6) 编译' '(7) 全部执行'
      read -p "请输入: "
        case $REPLY in
          0)
            break
          ;;
          1)
	    apt1 && echo -e "${GREEN}安装依赖--成功$END"||echo -e "${RED}安装依赖--失败$END"
          ;;
          2)
	    git1 && echo -e "${GREEN}下载源码--成功$END"||echo -e "${RED}下载源码--失败$END"
          ;;
          3)
	    feed && echo -e "${GREEN}feed更新及安装--成功$END"||echo -e "${RED}feed更新及安装--失败$END"
          ;;
          4)
	    config && echo -e "${GREEN}配置菜单--成功$END"||echo -e "${RED}配置菜单--失败$END"
          ;;
          5)
	    dl && echo -e "${GREEN}下载DL库--成功$END"||echo -e "${RED}下载DL库--失败$END"
          ;;
          6)
	    make1 && echo -e "${GREEN}编译--成功$END" || echo -e "${RED}编译--失败$END"
          ;;
          7)
	    apt1;git1;feed;config;dl;make1 && echo -e "${GREEN}编译--成功$END" || echo -e "${RED}编译--失败$END"
          ;;
	  *)
            echo -e "$RED\t输入错误，请重新输入$END"
        esac
      done
    ;;
    2)
      while :;do
      printf "$YELLOW%s\n$END" '(0) 返回上一级' '(1) 清理所有编译文件' '(2) git pull' '(3) 编辑src-git' '(4) feed更新及安装' '(5) make defconfig' '(6) 配置菜单' '(7) 下载DL库' '(8) 编译'
      read -p "请输入: "
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
	    dl && echo -e "${GREEN}下载DL库--成功$END"||echo -e "${RED}下载DL库--失败$END"
          ;;
          8)
	    make2 && echo -e "${GREEN}编译--成功$END"||echo -e "${RED}编译--失败$END"
          ;;
	  *)
            echo -e "$RED\t输入错误，请重新输入$END"
        esac
      done
    ;;
    3)
      while :;do
      printf "$RED%s\n$END" '(0) 返回上一级' '(1) 删除build_dir、staging_dir以及tmp' '(2) 下载qt5包' '(3) 重新配置'
      read -p "请输入: "
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
