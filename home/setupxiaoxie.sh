#! /bin/bash
# Sysconfig script version: CentOS8.2-0.1
curpath=$(pwd)
upath=/opt/APP/utility
upath_dpdk=/opt/APP/utility/DPDK
#upath_lib=/opt/APP/utility/Libvirt
#upath_qemu=/opt/APP/utility/QEMU
#upath_ovs=/opt/APP/utility/OVS
dpath=/opt/APP/driver
spath=/opt/APP/script
fpath=/opt/APP/Firmwares

network_ifcfg=/etc/sysconfig/network-scripts
network_port=ifcfg-enp5s0

chmod +x *
#date -s "2020-8-11 11:22:50"
hwclock -w
ln -s /usr/bin/python3 /usr/bin/python
uname -r | tee $spath/install_info
echo "post install script starting" |tee -a $spath/install_info
date | tee -a $spath/install_info
######################################################
######################################################
##### POST INSTALL SCRIPT for the UPDATED KERNEL #####
######################################################
######################################################

#runningKernelVersion=$(uname -r | grep rt |sed 's/.*\(^[[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*\).*/\1/')
runningKernelVersion=$(uname -r |sed 's/.*\(^[[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*\).*/\1/')
#if [ "$runningKernelVersion" == "4.18.0" ]; then
		echo "Start post-installation, please wait for a while..."
		## add pop-up message on the GUI
		export DISPLAY=':0'
		notify-send "Message" "Please wait... System will reboot after the post-installation." -t 600000
		## Start installation
		dhclient 

		
		##########################copy liuning setup.sh #
		## repos ##
		#mv /etc/apt/sources.list /etc/apt/sources.list_old
		#cp $spath/sources.list /etc/apt/
		#apt-get update
		## noninteractive mode ##
		export DEBIAN_FRONTEND=noninteractive
		## basic libs ##
		apt-get install make gcc g++ ethtool vim dracut libelf-dev net-tools build-essential -y
		## install Qemu ##
		apt-get install qemu-kvm virtinst bridge-utils cpu-checker libcurl4-gnutls-dev -y
		## QAT ##
		apt-get install libssl-dev libudev-dev libboost-all-dev initramfs-tools pkg-config -y
		## spdk ##
		apt-get install libcunit1-dev libaio-dev libssl-dev git astyle pep8 lcov clang uuid-dev -y
		## collectd ##
		apt-get install flex bison automake pkg-config libtool -y
		## libvirtd ##
		apt-get install libyajl-dev libxml2-dev libdevmapper-dev libpciaccess-dev libgnutls-dev libcurl4-gnutls-dev python-dev uuid-dev libvirt-dev libnl-route-3-dev libvirt-clients libvirt-daemon-system virt-manager -y
		apt-get install libvirt-clients libvirt-daemon-system libvirt-bin gawk -y
		## nvme ##
		apt-get install nvme-cli -y
  	        ln -s /usr/bin/python3 /usr/bin/python
			########################################################
		######
		###### install i40e driver ######
		if [ -e $dpath/i40e/i40e*.tar.gz ]; then
			tar zxvf $dpath/i40e/i40e*.tar.gz -C $dpath/i40e
			cd $dpath/i40e/i40e-*/src
			make 
			make install 
			rmmod i40e
			modprobe i40e
			echo "install i40e "| tee -a $spath/install_info
			date | tee -a $spath/install_info
		fi
		######
		###### install ice driver ######
		if [ -e $dpath/ice/ice*.tar.gz ]; then
			tar zxvf $dpath/ice/ice*.tar.gz -C $dpath/ice
			cd $dpath/ice/ice-*/src
			make 
			make install 
			rmmod ice
			modprobe ice
		fi
		######
		###### install iavf driver ######
		if [ -e $dpath/iavf/iavf*.tar.gz ]; then
			tar zxvf $dpath/iavf/iavf*.tar.gz -C $dpath/iavf
			cd $dpath/iavf/iavf-*/src
			make 
			make install 
			rmmod iavf
			modprobe iavf
		fi
		######
		###### install irdma driver ######
		#if [ -e $dpath/irdma/irdma*.tgz ]; then
		#	tar xvf $dpath/irdma/irdma*.tgz -C $dpath/irdma
		#	cd $dpath/irdma/irdma-*/
		#	./build.sh $dpath/ice/ice-*/
		#	modprobe irdma
		#fi
		######		
		###### install DPDK ######
		if [ -e $upath_dpdk/dpdk-*.tar.xz ]; then
			cd $upath_dpdk
			###### install python dependency #########
			apt-get install  python3-pip -y
			pip3 --proxy http://proxy-prc.intel.com:911 install pyelftools
			###### install meson ######
			apt-get install meson -y
		 
			###### install dpdk ######
			cd $upath_dpdk
			tar -xf dpdk-*.tar.xz
			cd $upath_dpdk/dpdk-*/
 
			meson -Denable_kmods=true -Dexamples=all build
			cd build
			ninja
			ninja install
			ldconfig
 
			echo "DPDK installtion complete" | tee -a $spath/install_info
			date | tee -a $spath/install_info
		fi
		######
		###### install Libvirt ######
#		apt-get install libpciaccess-devel yajl-devel device-mapper-devel -y
#		apt-get install libpciaccess-devel yajl-devel device-mapper-devel -y
#		if [ "$?" != "0" ];then
#			echo "libvirt depended tools apt-get install Failed" | tee -a $spath/install_info
#			reboot
#		else
#			echo "libvirt depended tools apt-get installed" | tee -a $spath/install_info			 
#		fi
#		if [ -e $upath_lib/libvirt-*.tar.xz ]; then
#			cd $upath_lib
#		  	tar -xf libvirt-*.tar.xz
#		  	cd /$upath_lib/libvirt-*/
#		  	./configure --prefix=/usr
#		  	make -j
#		  	make -j install
#		  	cd /lib64/
#		  	ldconfig
#			echo "Libvirt installtion complete"| tee -a $spath/install_info
#			date | tee -a $spath/install_info
#		fi
		######
		###### install Qemu ######
		ln -s /usr/libexec/qemu-kvm /usr/bin/qemu-system-x86_64
#		if [ -e $upath_qemu/qemu-*.tar.xz ]; then
#			#mkdir $upath/qemu
#			cd $upath_qemu
#			tar -xf $upath_qemu/qemu-*.tar.xz 
#			cd $upath_qemu/qemu-*/
#			./configure 
#			make -j30 
#			make -j install
#			echo "Qemu installtion complete"| tee -a $spath/install_info
#			date | tee -a $spath/install_info
#		fi
		######
#		###### install OVS ######
		if [ -e $upath_ovs/openvswitch-*.tar.gz ]; then
			apt-get install autoconf automake libtool -y
			apt-get install libffi-dev -y 
			export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig
			tar -xvf $upath_ovs/openvswitch-*.tar.gz -C $upath_ovs
			cd  $upath_ovs/openvswitch-*/
			./boot.sh
			./configure --with-dpdk=static
			make
			make install
                	echo "OVS installtion complete"| tee -a $spath/install_info
			date | tee -a $spath/install_info
		fi
		
#		###### install QAT ######
		if [ -e $dpath/QAT/QAT*.tar.gz ]; then
			cd $dpath/QAT
			###### install dependency ###########
			apt-get install libnl* -y
			apt-get install yasm -y
			
			cd $dpath/QAT
			tar -zxvf QAT*.tar.gz
#			./configure --enable-icp-sriov=host
			./configure
#			make
			make install
#			make samples
			make samples-install
			echo "QAT installtion complete"| tee -a $spath/install_info
			date | tee -a $spath/install_info
		fi
		######
		###### install docker #####
#			apt-get-config-manager     --add-repo     https://download.docker.com/linux/centos/docker-ce.repo
#			apt-get install docker-ce docker-ce-cli containerd.io
#			apt-get list docker-ce --showduplicates | sort -r
#			dnf install docker-ce --nobest
#			systemctl enable --now docker
#			systemctl status docker
		######
		#update-initramfs -k $(uname -r) -u
		dracut --force /boot/initramfs-`uname -r`.img `uname -r`

		####### update-grub ##########
		cat /etc/default/grub |grep "iommu"
		if [ "$?" != "0" ]; then 
			cp $spath/grub /etc/default/ -f
			#sed -i 's/quiet/&\ intel\_iommu=on\ iommu=pt\ default\_hugepagesz\=1G\ hugepagesz\=1G\ hugepages\=50 nomodeset\ clock=pit\ no\_timer\_check\ clocksource=tsc\ tsc=perfect\ nmi_watchdog\=0\ softlockup\_panic\=0\ kthread\_cpus\=0\ irqaffinity\=0\ idle=poll\ rcu\_nocb\_poll\ rcu\_nocbs=\1-7\ isolcpus\=1\-7\ nohz\_full\=1\-7\ console\=ttyS0\,115200\ loglevel\=7\ console\=tty0\' /etc/default/grub
			grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
		fi

		####### showdown GUI ##########
		systemctl set-default multi-user.target
		
#else
#		echo "Rt kernel not installed" >> /etc/rc.d/kernel_update_info
#fi


chmod +x $spath/install_check.sh
. $spath/install_check.sh
date | tee -a $spath/install_info
t_time=`date | awk '{print $4}'|sed 's/\://g'`
	
egrep -i "fail|not\ matched" $spath/install_info
if [ "$?" != "0" ];then
	echo "Post-install completed!!!"| tee -a $spath/install_info
	mv $spath/install_info $spath/install_info_$t_time 
	mv $spath/setup.sh $spath/setup-done.sh
	echo "Drives all installed, System will reboot after 5sec"
	sleep 5
	reboot
else
	echo "Post-install not finished !!!"| tee -a $spath/install_info
	mv $spath/install_info $spath/install_info_$t_time 
	mv $spath/setup.sh $spath/setup-done.sh
fi
		




