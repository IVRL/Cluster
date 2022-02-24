#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

##### CHECK OS #####
lowercase(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

OS=`lowercase \`uname\``
KERNEL=`uname -r`
MACH=`uname -m`

if [ "{$OS}" == "windowsnt" ]; then
    OS=windows
elif [ "{$OS}" == "darwin" ]; then
    OS=mac
else
    OS=`uname`
    if [ "${OS}" = "SunOS" ] ; then
        OS=Solaris
        ARCH=`uname -p`
        OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
    elif [ "${OS}" = "AIX" ] ; then
        OSSTR="${OS} `oslevel` (`oslevel -r`)"
    elif [ "${OS}" = "Linux" ] ; then
        if [ -f /etc/redhat-release ] ; then
            DistroBasedOn='RedHat'
            DIST=`cat /etc/redhat-release |sed s/\ release.*//`
            PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
            REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
        elif [ -f /etc/SuSE-release ] ; then
            DistroBasedOn='SuSe'
            PSUEDONAME=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
            REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
        elif [ -f /etc/mandrake-release ] ; then
            DistroBasedOn='Mandrake'
            PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
            REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
        elif [ -f /etc/debian_version ] ; then
            DistroBasedOn='Debian'
            DIST=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
            PSUEDONAME=`cat /etc/lsb-release | grep '^DISTRIB_CODENAME' | awk -F=  '{ print $2 }'`
            REV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
        fi
        if [ -f /etc/UnitedLinux-release ] ; then
            DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
        fi
        OS=`lowercase $OS`
        DistroBasedOn=`lowercase $DistroBasedOn`
        readonly OS
        readonly DIST
        readonly DistroBasedOn
        readonly PSUEDONAME
        readonly REV
        readonly KERNEL
        readonly MACH
    fi

fi

## Check OS and do the install 
# Remove spaces
DISTRIB=${DIST// /-}                    

# Check OS
case "$DISTRIB" in
"Ubuntu") echo $DISTRIB

#########################################
apt-get update
curl -s http://install.iccluster.epfl.ch/scripts/icitsshkeys.sh >> icitsshkeys.sh ; chmod +x icitsshkeys.sh; ./icitsshkeys.sh

#########################################
# Add ivrldata1        
mkdir /ivrldata1
echo "#/ivrldata1" >> /etc/fstab
echo "ic1files.epfl.ch:/ic_ivrl_2_files_nfs      /ivrldata1     nfs     soft,intr,bg 0 0" >> /etc/fstab
# Add Sinergia data
mkdir /sinergia
echo "#/sinergia" >> /etc/fstab
echo "ic1files.epfl.ch:/ic_ivrl_3_files_nfs/sinergia      /sinergia     nfs     soft,intr,bg 0 0" >> /etc/fstab

#########################################
# Install LDAP + Autmount
apt update && apt-get install -y parted mc screen vim vim-scripts htop iftop wget dstat ntp nmap ntpdate man-db puppet git cmake software-properties-common tmux
curl --insecure https://install.iccluster.epfl.ch/keytab/${HOSTNAME%%.*}/krb5.keytab > /etc/krb5.keytab 
puppet module install epflsti-epfl_sso
puppet apply -e "class { 'quirks': }"
puppet apply -e "class { 'epfl_sso': join_domain => true, auth_source => 'AD', directory_source => 'AD', ad_automount_home => true, sshd_gssapi_auth  => true, allowed_users_and_groups => 'root (IVRL-StaffU) (ivrllogins_AppGrpU) (ICIT-StaffU) (IC-IT-StaffU)' }"
# Apply twice to add the server to the kerberos royaume
sleep 30
puppet apply -e "class { 'epfl_sso': join_domain => true, auth_source => 'AD', directory_source => 'AD', ad_automount_home => true, sshd_gssapi_auth  => true, allowed_users_and_groups => 'root (IVRL-StaffU) (ivrllogins_AppGrpU) (ICIT-StaffU) (IC-IT-StaffU)' }"

#########################################
# Allow members of the lab to run kill commands
# echo "%IVRL-StaffU  ALL=(ALL) /bin/kill" > /etc/sudoers.d/kill

#########################################
# Create /scratch 
# create /scratch before running the scratchVolume.sh script if no scratch disk is present 
# set default right on this folder to be writable anyway if no disk is mount
mkdir /scratch
chmod 1777 /scratch
curl -s http://install.iccluster.epfl.ch/scripts/it/scratchVolume.sh  >> scratchVolume.sh ; chmod +x scratchVolume.sh ; ./scratchVolume.sh

#########################################
# Install CUDA !!! INSTALL APRES REBOOT !!!
echo '#!/bin/sh -e' > /etc/rc.local

mkdir -p /opt/ivrl

# Make IVRL group sudo
# echo '#!/bin/bash
# # All the lab in sudoers
# GROUP=$(getent group $1 | awk -F: \'{print $4}\'| tr "," "\n")
# for user in $GROUP
# do
# usermod -aG sudo $user
# done' >> /opt/ivrl/sudos.sh
# chmod +x /opt/ivrl/sudos.sh
# ./opt/ivrl/sudos.sh
# #
# echo '

FLAG="/var/log/firstboot.cuda.log"
if [ ! -f $FLAG ]; then
    touch $FLAG
        curl -s http://install.iccluster.epfl.ch/scripts/soft/cuda/cuda_11.0.2_450.41.sh >> /opt/ivrl/cuda.sh ; chmod +x /opt/ivrl/cuda.sh; /opt/ivrl/cuda.sh;
fi' >> /etc/rc.local
echo '
FLAGSCRATCH="/var/log/firstboot.scratch.log"
if [ ! -f $FLAGSCRATCH ]; then
        touch $FLAGSCRATCH
        mkdir -p /scratch
        chmod 775 /scratch
        chown root:ivrllogins_AppGrpU /scratch
fi' >> /etc/rc.local
echo 'exit 0' >> /etc/rc.local
chmod +x /etc/rc.local
#########################################
# Python related stuff
wget https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh -O /tmp/anaconda.sh; bash /tmp/anaconda.sh -b -p /opt/anaconda3
echo PATH="/opt/anaconda3/bin:$PATH"  > /etc/environment
export PATH="/opt/anaconda3/bin:$PATH"
apt-get install -y python-pip python-dev python-setuptools build-essential python-numpy python-scipy python-matplotlib ipython ipython-notebook python-pandas python-sympy python-nose python3 python3-pip python3-dev python-wheel python3-wheel python-boto
#######################################
# TORCH
apt-get install -y libreadline-dev
curl -s https://raw.githubusercontent.com/torch/ezinstall/master/install-deps | bash
git clone https://github.com/torch/distro.git /opt/torch --recursive
cd /opt/torch; yes | ./install.sh
echo PATH="/opt/torch/install/bin:$PATH" > /etc/environment
######################################
# PyTorch 4
/opt/anaconda3/bin/conda install pytorch torchvision -c pytorch -y
######################################
# jupyter
# apt -y install python2.7 python-pip python-dev ipython ipython-notebook
# pip install jupyter
######################################
# caffe
# Add repo for GCC 7
# required to build caffe 
add-apt-repository ppa:ubuntu-toolchain-r/test -y
apt-get update
#########################################
# Install package for caffe
apt-get install -y g++-7
apt-get install -y build-essential cmake git pkg-config
apt-get install -y libprotobuf-dev libleveldb-dev libsnappy-dev protobuf-compiler
apt-get install -y libatlas-base-dev 
apt-get install -y --no-install-recommends libboost-all-dev
apt-get install -y libgflags-dev libgoogle-glog-dev liblmdb-dev
apt-get install -y libopencv-dev libhdf5-serial-dev
apt-get install -y libgtk2.0-dev pkg-config python-dev python-numpy libdc1394-22 libdc1394-22-dev libjpeg-dev libpng12-dev libtiff5-dev libjasper-dev libavcodec-dev libavformat-dev libswscale-dev libxine2-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev
apt-get install -y libv4l-dev libtbb-dev libqt4-designer libqt4-opengl libqt4-svg libqtgui4 libqtwebkit4 libfaac-dev 
apt-get install -y libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev x264 v4l-utils unzip dh-autoreconf 
conda update -y conda
conda install -y -c menpo opencv3
conda install -y libgcc
# Install caffe from source
git clone https://github.com/BVLC/caffe.git /usr/src/caffe --recursive
cd /usr/src/caffe && mkdir -p cmake_build && cd cmake_build
cmake .. -DBUILD_SHARED_LIB=ON
make all
make install
make pycaffe
conda install -y cython scikit-image ipython h5py nose pandas protobuf pyyaml jupyter
######################################
# Tensorflow
conda install -y -c anaconda tensorflow-gpu
#########################################
# Python Virtual env for Gabriel Autes
apt install -y python3-virtualenv
#########################################
# rmate for Ruofan Zhou #INC0272148
wget -O /usr/local/bin/rsub \https://raw.github.com/aurora/rmate/master/rmate
chmod a+x /usr/local/bin/rsub
#########################################
# Request by El Helou Majed on 2019.02.05
pip install tensorboardX
#########################################
# Request by Fayez Lahoud on 2019.04.03
pip install tifffile
#########################################
# Request by Ruofan Zhou on 2019.04.16
apt install -y ffmpeg
########################################
## Install Docker by Peter Grönquist on 2021.09.15
apt-get -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get -y -qq install docker-ce
## Install Docker-compose
curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
export PATH="/usr/local/bin/:$PATH"
    ;;
"CentOS-Linux") echo $DISTRIB
    ;;
*) echo "Invalid OS: " $DISTRIB
   ;;
esac
rm -- "$0"