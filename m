From: malahal@us.ibm.com <malahal@us.ibm.com>
Date: Tue, 10 Nov 2009 11:56:15 -0800
Subject: compiling lvm2 source on ppc64 arch
Message-ID: <20091110195615.GA24686@us.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

RHEL5.4 installed a 32 bit LVM2 rpm by default on a ppc64 machine. I
downloaded the corresponding source rpm and ran "rpmbuild -bb
--target=ppc <spec-file>" to build my own 32 bit rpm for debugging. It
failed with the following errors.  Note that it can build ppc64 binary
rpm fine but doesn't work for me (I get errors while loading some shared
objects).  How do I build a 32 bit rpm on ppc64 using lvm2 source rpm?
Thank you for any info.

gcc -o dmsetup.static dmsetup.o -O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m32 -O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m32 -fPIC -Wall -Wundef -Wshadow -Wcast-align -Wwrite-strings -Wmissing-prototypes -Wmissing-declarations -Wnested-externs -Winline -Wmissing-noreturn -Wformat-security -O2 -O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m32 -fPIC -Wall -Wundef -Wshadow -Wcast-align -Wwrite-strings -Wmissing-prototypes -Wmissing-declarations -Wnested-externs -Winline -Wmissing-noreturn -Wformat-security -O2 -Wl,--export-dynamic -L../libdm -L../lib -L../daemons/dmeventd -static \
	      -L../libdm/ioctl -ldevmapper -lreadline -lrt -lselinux -ldl -lncurses  \
	      -lpthread
/usr/lib/gcc/ppc64-redhat-linux/4.1.2/../../../../lib/libselinux.a(load_policy.o): In function `selinux_mkload_policy':
(.text+0x154): undefined reference to `sepol_policy_kern_vers_max'
/usr/lib/gcc/ppc64-redhat-linux/4.1.2/../../../../lib/libselinux.a(load_policy.o): In function `selinux_mkload_policy':
(.text+0x1b0): undefined reference to `sepol_policy_kern_vers_min'
/usr/lib/gcc/ppc64-redhat-linux/4.1.2/../../../../lib/libselinux.a(load_policy.o): In function `selinux_mkload_policy':
(.text+0x2cc): undefined reference to `sepol_policy_file_create'
/usr/lib/gcc/ppc64-redhat-linux/4.1.2/../../../../lib/libselinux.a(load_policy.o): In function `selinux_mkload_policy':

Thanks, Malahal.
PS: I was able to compile 32 bit binary rpm by removing
"--enable-static_link and --enable-readline" and fixing other things in the
spec file that are directly related to static_link.


