From: Eric Ren <zren@suse.com>
Date: Tue, 6 Jun 2017 11:27:51 +0800
Subject: Asking for help with LVM testing
Message-ID: <80696c5c-d275-7306-36f0-c64c23885a83@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdenek and all,

I'm facing some problems with using LVM test code.  Please help give confirmation,
or suggestion on questions below:

1. Is upstream running LVM testsuite upon every new commit?

I hope I can setup a CI testing machine for upstream code. Unfortunately,
I cannot even successfully run testsuite from source code as follows:

=========
# ./configure
...  no errors ...
# make
... no errors ...
# make install
... no errors ...
# make -C test
... no errors...
# make -C test install
...
/usr/bin/install -c -m 755 -d /usr/share/lvm2-testsuite/{shell,api,lib,dbus} 
/libexec/lvm2-testsuite
/usr/bin/install -c -p -m 444 shell/*.sh /usr/share/lvm2-testsuite/shell
/usr/bin/install -c -p -m 444 api/*.sh /usr/share/lvm2-testsuite/api
/usr/bin/install -c -p -m 444 lib/mke2fs.conf /usr/share/lvm2-testsuite/lib
/usr/bin/install -c -m 555  api/*.{t,py} /usr/share/lvm2-testsuite/api
/usr/bin/install: cannot stat ?api/*.t?: No such file or directory
make: *** [install] Error 1
make: Leaving directory `/root/lvm2/test'
# lvm2-testsuite
lvm2-testsuite: /lib64/libstdc++.so.6: version `CXXABI_1.3.9' not found (required by 
lvm2-testsuite)
lvm2-testsuite: /lib64/libstdc++.so.6: version `GLIBCXX_3.4.21' not found (required by 
lvm2-testsuite)
# cat /etc/centos-release
CentOS Linux release 7.3.1611 (Core)
========

or

=======
# ./configure --help|grep test
   --enable-testing        enable testing targets in the makefile
[root at centos1 lvm2]# ./configure --enable-testing
...
checking for CUNIT... no
configure: error: Package requirements (cunit >= 2.0) were not met:

No package 'cunit' found
# yum search cunit
Warning: No matches found for: cunit
=======

Is this a known issue?  I'm likely doing something wrong...

2. Are all LVM testcases passed for upstream code now?

I found many failed testcases on Tumbleweed 20170602:

======
# rpm -qa | grep lvm2
lvm2-2.02.170-3.2.x86_64
lvm2-testsuite-2.02.170-3.2.x86_64

# lvm2-testsuite --flavours udev-lvmetad
....
### 277 tests: 227 passed, 26 skipped, 0 timed out, 6 warned, 18 failed

# cat list | grep failed
udev-lvmetad:shell/fsadm.sh failed
udev-lvmetad:shell/lvchange-cache-old.sh failed
udev-lvmetad:shell/lvchange-cache.sh failed
udev-lvmetad:shell/lvchange-raid.sh failed
udev-lvmetad:shell/lvconvert-cache-thin.sh failed
udev-lvmetad:shell/lvconvert-raid-takeover.sh failed
udev-lvmetad:shell/lvconvert-thin-external-cache.sh failed
udev-lvmetad:shell/lvcreate-cache-snapshot.sh failed
udev-lvmetad:shell/lvcreate-cache.sh failed
udev-lvmetad:shell/lvcreate-usage.sh failed
udev-lvmetad:shell/lvmetad-pvscan-nomda-bg.sh failed
udev-lvmetad:shell/lvmetad-pvscan-nomda.sh failed
udev-lvmetad:shell/lvrename-cache-thin.sh failed
udev-lvmetad:shell/lvresize-full.sh failed
udev-lvmetad:shell/metadata.sh failed
udev-lvmetad:shell/pvmove-cache-segtypes.sh failed
udev-lvmetad:shell/read-ahead.sh failed
udev-lvmetad:shell/thin-overprovisioning.sh failed
=====

Curiously, some of them failed caused by, like lvcreate-usage.sh failed:

======
field="lv_kernel_read_ahead", actual="512.00k", expected="128.00k"
But, on openSUSE:
# cat /sys/dev/block/253\:8/bdi/read_ahead_kb
512
On centos 7.3.1611:
# cat /sys/dev/block/253\:2/bdi/read_ahead_kb
4096
======

some of failed cases disappeared when manually testing individually...

So, I'm wondering if upstream code also has some of the issues. That's why I want to
directly run testcases from source code, more than RPMs :-P

Regards,
Eric




