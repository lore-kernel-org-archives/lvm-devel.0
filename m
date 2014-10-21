From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 21 Oct 2014 13:15:40 +0200
Subject: device mapper library update
In-Reply-To: <f277c43b-8d1a-43f2-838c-b2fb33bcc67d@aliyun.com>
References: 20141007001622.823F66036F@fedorahosted.org
	<f277c43b-8d1a-43f2-838c-b2fb33bcc67d@aliyun.com>
Message-ID: <5446405C.9030109@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/21/2014 12:24 PM, lilofile wrote:
> when I download LVM2.2.02.104.tgz source code, tar xvf
> ./configure;make;make install
> 
> then use lvcreate --version, the result display
> [root at localhost ~]# lvcreate  --version
>   LVM version:     2.02.104(2) (2013-11-13)
>   Library version: 1.02.79-RHEL6 (2013-10-23)
>   Driver version:  4.24.0
> [root at localhost ~]#
> 
> why the Library version is not updated?
>  when I see the source code ,
> include/configure.h:#define DM_LIB_VERSION "1.02.83 (2013-11-13)"
> lib/misc/configure.h:#define DM_LIB_VERSION "1.02.83 (2013-11-13)"
> 
> the version display is 1.02.83? 

Make sure you have proper configure line used, mainly checkthe library
paths. This is the exact configure line used for official RHEL6 builds
(considering you're now running with RHEL 6.5 and x86_64 arch):

./configure --build=x86_64-redhat-linux-gnu --host=x86_64-redhat-linux-gnu --target=x86_64-redhat-linux-gnu --program-prefix= --prefix=/usr --exec-prefix= --bindir=/bin --sbindir=/sbin --sysconfdir=/etc --datadir=/usr/share --includedir=/usr/include --libdir=/lib64 --libexecdir=/libexec --localstatedir=/var --sharedstatedir=/var/lib --mandir=/usr/share/man --infodir=/usr/share/info --enable-lvm1_fallback --enable-fsadm --with-pool=internal --with-user= --with-group= --with-usrlibdir=/usr/lib64 --with-usrsbindir=/usr/sbin --with-udevdir=/lib/udev/rules.d --enable-udev-rule-exec-detection --with-device-uid=0 --with-device-gid=6 --with-device-mode=0660 --enable-pkgconfig --enable-applib --enable-cmdlib --enable-dmeventd --enable-udev_sync --with-thin=internal --with-thin-check=/usr/sbin/thin_check --with-thin-dump=/usr/sbin/thin_dump --with-thin-repair=/usr/sbin/thin_repair --enable-lvmetad --with-cluster=internal --with-clvmd=cman --enable-cmirrord

-- 
Peter


