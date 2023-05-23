FROM quay.io/centos/centos:centos7.9.2009

RUN echo "" \
  echo "** configuring cloudstack yum repo **" \
  echo [cloudstack] > /etc/yum.repos.d/cloudstack.repo \
  echo name=cloudstack >> /etc/yum.repos.d/cloudstack.repo \
  echo baseurl=http://download.cloudstack.org/centos/7/4.18/ >> /etc/yum.repos.d/cloudstack.repo \
  echo enabled=1 >> /etc/yum.repos.d/cloudstack.repo \
  echo gpgcheck=0 >> /etc/yum.repos.d/cloudstack.repo \
  cat /etc/yum.repos.d/cloudstack.repo \
  echo "" \
  echo "** prep for install **" \
  yum -y install deltarpm \
  echo "deltarpm=0" >> /etc/yum.conf \
  echo "" \
  echo "** installing ps **" \
  yum -y install procps \
  echo "** installing some missing libraries**" \
  yum -y install glibc.i686 \
  yum -y install libuuid \
  yum -y install libuuid.so.1 \
  echo "" \
  echo "** installing requirements **" \
  yum -y install chrony \
  yum -y install mysql \
  yum -y install wget \
  mkdir -p /usr/share/cloudstack-common/scripts/vm/hypervisor/xenserver \
  wget http://download.cloudstack.org/tools/vhd-util -O /usr/share/cloudstack-common/scripts/vm/hypervisor/xenserver/vhd-util \
  chmod 755 /usr/share/cloudstack-common/scripts/vm/hypervisor/xenserver/vhd-util \
  echo "" \
  echo "** installing cloudstack **" \
  yum -y install cloudstack-management \
  echo "" \
  echo "** configuring cloudstack **" \
  cloudstack-setup-databases cloud:password@cloudstack-mysql.cloudstack.svc --deploy-as=root:KIN6CdQHFc \
  echo "" \
  echo "** starting cloudstack **"

ENTRYPOINT ["cloudstack-setup-management"]
