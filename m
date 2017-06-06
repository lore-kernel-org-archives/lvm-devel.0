From: Eric Ren <zren@suse.com>
Date: Tue, 6 Jun 2017 20:13:06 +0800
Subject: Asking for help with LVM testing
In-Reply-To: <f39f1f95-33a1-496b-6cbf-1adf80b5bd8b@redhat.com>
References: <80696c5c-d275-7306-36f0-c64c23885a83@suse.com>
	<f39f1f95-33a1-496b-6cbf-1adf80b5bd8b@redhat.com>
Message-ID: <ec3380fa-3adc-2438-2b1c-7b731c77801a@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdenek,

On 06/06/17 18:14, Zdenek Kabelac wrote:
> Dne 6.6.2017 v 05:27 Eric Ren napsal(a):
>> Hi Zdenek and all,
>>
>> I'm facing some problems with using LVM test code.  Please help give confirmation,
>> or suggestion on questions below:
>>
>> 1. Is upstream running LVM testsuite upon every new commit?
>
> basically yes

Great!

>
>
>
>> I hope I can setup a CI testing machine for upstream code. Unfortunately,
>> I cannot even successfully run testsuite from source code as follows:
>>
>> =========
>> # ./configure
>> ...  no errors ...
>
> plain configure is hardly every useful enough - in reality you need to pass number of 
> flags  (distro packager's work)

Yes, it's easy to extract from RPM building log :-P

>
> here is an example of my testing one...
>
> configure --prefix=/var/tmp/lvm --cache-file config.cache --with-clvmd=singlenode 
> --enable-dmeventd --enable-udev_sync --enable-ocf --enable-debug --with-optimisation=-g 
> --enable-valgrind-pool --enable-cmdlib --enable-applib --enable-lvmetad --enable-lvmpolld 
> --enable-dmfilemapd --enable-pkgconfig --with-confdir=/var/tmp/lvm/etc 
> --with-default-system-dir=/var/tmp/lvm/etc/lvm

Thanks for the reference!

>
>
>
>> # make
>> ... no errors ...
>> # make install
>> ... no errors ...
>> # make -C test
>> ... no errors...
>> # make -C test install
>> ...
>> /usr/bin/install -c -m 755 -d /usr/share/lvm2-testsuite/{shell,api,lib,dbus} 
>> /libexec/lvm2-testsuite
>> /usr/bin/install -c -p -m 444 shell/*.sh /usr/share/lvm2-testsuite/shell
>> /usr/bin/install -c -p -m 444 api/*.sh /usr/share/lvm2-testsuite/api
>> /usr/bin/install -c -p -m 444 lib/mke2fs.conf /usr/share/lvm2-testsuite/lib
>> /usr/bin/install -c -m 555  api/*.{t,py} /usr/share/lvm2-testsuite/api
>> /usr/bin/install: cannot stat ?api/*.t?: No such file or directory
>> make: *** [install] Error 1
>> make: Leaving directory `/root/lvm2/test'
>> # lvm2-testsuite
>> lvm2-testsuite: /lib64/libstdc++.so.6: version `CXXABI_1.3.9' not found (required by 
>> lvm2-testsuite)
>> lvm2-testsuite: /lib64/libstdc++.so.6: version `GLIBCXX_3.4.21' not found (required by 
>> lvm2-testsuite)
>
> for test suite you need installed   g++  & libstdc++

But I did install them:

# yum install gcc-c++ libstdc++
Package gcc-c++-4.8.5-11.el7.x86_64 already installed and latest version
Package libstdc++-4.8.5-11.el7.x86_64 already installed and latest version

Never mind, I just want to take centOS for example.
>
>
>> =======
>> # ./configure --help|grep test
>>    --enable-testing        enable testing targets in the makefile
>> [root at centos1 lvm2]# ./configure --enable-testing
>> ...
>> checking for CUNIT... no
>> configure: error: Package requirements (cunit >= 2.0) were not met:
>>
>
> these unit 'testings' are extra (not enabled by default) as they do require
> extra KnowHow to use and evaluate them and the are not all the useful..
>
>
>> No package 'cunit' found
>> # yum search cunit
>> Warning: No matches found for: cunit
>
> On my rawhide: CUnit-2.1.3-14.fc26.x86_64

Got it!

>
>> 2. Are all LVM testcases passed for upstream code now?
>
> Mostly yes - but they are some issues and problems for resolving.

Do they have a BZ? Anyway, I'd search around on RHBZ, so that I can
know which bugs are SUSE specific :-P

>
>>
>> I found many failed testcases on Tumbleweed 20170602:
>>
>> ======
>> # rpm -qa | grep lvm2
>> lvm2-2.02.170-3.2.x86_64
>> lvm2-testsuite-2.02.170-3.2.x86_64
>>
>> # lvm2-testsuite --flavours udev-lvmetad
>> ....
>> ### 277 tests: 227 passed, 26 skipped, 0 timed out, 6 warned, 18 failed
>
>
> Doesn't look right
>
> I'd recommend to go to:
>
> cd tests
> make check_local
>
> you may add 'VERBOSE=1' i.e.:  'make check_local T=lvcreate VERBOSE=1'
> (see 'make help' in /test for more opts)
>

Yeah, thanks!

>
>>
>> # cat list | grep failed
>> udev-lvmetad:shell/fsadm.sh failed
>
> without passing actual log of test (stored in 'results') subdir  I cannot give any 
> recommendation what's wrong  (but I may just guess you've configured your lvm2 without 
> udev support - thus most of test will simply fail on udev system).

Thanks, I got my answer - "most of this issues are *not* with upstream". So,
I'd look into what's wrong on our side, before wasting your time :-P

BTW, I did configure lvm2 with "--enable-udev_rules".
# lvm version
   LVM version:     2.02.172(2)-git (2017-05-03)
   Library version: 1.02.141-git (2017-05-03)
   Driver version:  4.35.0
   Configuration:   ./configure --host=x86_64-suse-linux-gnu --build=x86_64-suse-linux-gnu 
--program-prefix= --disable-dependency-tracking
--prefix=/usr --exec-prefix=/usr --bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc 
--datadir=/usr/share --includedir=/usr/include --libdir=/usr/lib64
--libexecdir=/usr/lib --localstatedir=/var --sharedstatedir=/usr/com --mandir=/usr/share/man 
--infodir=/usr/share/info
--with-usrlibdir=/usr/lib64 --with-usrsbindir=/usr/sbin --sbindir=/sbin --enable-dmeventd 
--enable-udev_sync --enable-udev_rules
--enable-cmdlib --enable-applib --enable-dmeventd --enable-realtime --enable-pkgconfig 
--enable-selinux --with-clvmd=corosync
--with-cluster=internal --datarootdir=/usr/share --with-default-locking-dir=/run/lock/lvm 
--enable-cmirrord --enable-lvmetad --with-default-pid-dir=/run
--with-default-dm-run-dir=/run --with-default-run-dir=/run/lvm 
--with-tmpfilesdir=/usr/lib/tmpfiles.d --with-thin=internal --with-device-gid=6 
--with-device-mode=0640
--with-device-uid=0 --with-dmeventd-path=/sbin/dmeventd 
--with-thin-check=/usr/sbin/thin_check --with-thin-dump=/usr/sbin/thin_dump
--with-thin-repair=/usr/sbin/thin_repair --with-udev-prefix=/usr/ --enable-blkid-wiping

Such long configurations... I'd try your *configuration* to see if the result changes.
>
>
>> udev-lvmetad:shell/lvchange-cache-old.sh failed
>> udev-lvmetad:shell/lvchange-cache.sh failed
>> udev-lvmetad:shell/lvchange-raid.sh failed
>> udev-lvmetad:shell/lvconvert-cache-thin.sh failed
>> udev-lvmetad:shell/lvconvert-raid-takeover.sh failed
>> udev-lvmetad:shell/lvconvert-thin-external-cache.sh failed
>> udev-lvmetad:shell/lvcreate-cache-snapshot.sh failed
>> udev-lvmetad:shell/lvcreate-cache.sh failed
>> udev-lvmetad:shell/lvcreate-usage.sh failed
>> udev-lvmetad:shell/lvmetad-pvscan-nomda-bg.sh failed
>> udev-lvmetad:shell/lvmetad-pvscan-nomda.sh failed
>> udev-lvmetad:shell/lvrename-cache-thin.sh failed
>> udev-lvmetad:shell/lvresize-full.sh failed
>> udev-lvmetad:shell/metadata.sh failed
>> udev-lvmetad:shell/pvmove-cache-segtypes.sh failed
>> udev-lvmetad:shell/read-ahead.sh failed
>> udev-lvmetad:shell/thin-overprovisioning.sh failed
>> =====
>>
>> Curiously, some of them failed caused by, like lvcreate-usage.sh failed:
>>
>> ======
>> field="lv_kernel_read_ahead", actual="512.00k", expected="128.00k"
>> But, on openSUSE:
>> # cat /sys/dev/block/253\:8/bdi/read_ahead_kb
>> 512
>> On centos 7.3.1611:
>> # cat /sys/dev/block/253\:2/bdi/read_ahead_kb
>> 4096
>
> Well clearly Suse box is not so far in our running setup - thus some extra kernel patches 
> which do change some kernel defaults may need some 'tunning'....

Sure, but as you can see, the *actual* values are not equal to "expected" value, neither on 
Suse nor CentOS. That's weird, hah

>
> Patches are welcome...

Happy to contribute!

>
>> ======
>>
>> some of failed cases disappeared when manually testing individually...
>>
>> So, I'm wondering if upstream code also has some of the issues. That's why I want to
>> directly run testcases from source code, more than RPMs :-P
>
> Yep preferred is in sources - but  we also do use rpm installed one and run
> them with systems' native installed tools

Yes, our QA team also runs such package taesting regularly using openQA.

Thanks a lot!
Eric

>
>
>
>
> Regards
>
>
> Zdenek
>


