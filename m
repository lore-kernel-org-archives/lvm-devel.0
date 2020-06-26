From: Marian Csontos <mcsontos@redhat.com>
Date: Fri, 26 Jun 2020 17:15:25 +0200
Subject: Question: build and install LVM2 on Centos7
In-Reply-To: <20200626111614.GC28664@leoy-ThinkPad-X240s>
References: <20200626111614.GC28664@leoy-ThinkPad-X240s>
Message-ID: <2c8b274a-7083-b64b-7f51-433d656bce60@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 6/26/20 1:16 PM, Leo Yan wrote:
> Hi there,
> 
> When built and installed LVM2 (with tag v2_02_187) on Centos7, I used
> below commands:
> 
>    # ./configure --prefix=/usr --includedir=/include --mandir=/share/man \
>      --infodir=/share/info --sysconfdir=/etc --localstatedir=/var \
>      --disable-silent-rules --sbindir=/sbin --enable-blkid_wiping \
>      --enable-cmdlib --enable-dmeventd --enable-dbus-service \
>      --enable-lvmlockd-sanlock --enable-lvmpolld --enable-notify-dbus \
>      --enable-pkgconfig --enable-readline --enable-udev_rules \
>      --enable-udev_sync --with-thin-check=/usr/sbin/thin_check \
>      --with-thin-dump=/usr/sbin/thin_dump \
>      --with-thin-repair=/usr/sbin/thin_repair \
>      --with-cache=internal --with-thin=internal
>    # make
>    # make install
> 
> I found the libs will be installed into /usr/lib/ rather than into
> /usr/lib64:
> 
>    # make V=1 install | grep "\/usr\/lib"
>    /usr/bin/install -c -m 555  -D libdevmapper-event-lvm2.so /usr/lib/libdevmapper-event-lvm2.so.2.02
>    /usr/bin/install -c -m 755 -d /usr/lib
>    ln -s -f libdevmapper-event-lvm2.so.2.02 /usr/lib/libdevmapper-event-lvm2.so
>    /usr/bin/install -c -m 555  -D libdevmapper-event-lvm2snapshot.so /usr/lib/device-mapper/libdevmapper-event-lvm2snapshot.so
>    ln -s -f device-mapper/libdevmapper-event-lvm2snapshot.so /usr/lib/libdevmapper-event-lvm2snapshot.so
>    /usr/bin/install -c -m 555  -D libdevmapper-event-lvm2raid.so /usr/lib/device-mapper/libdevmapper-event-lvm2raid.so
>    ln -s -f device-mapper/libdevmapper-event-lvm2raid.so /usr/lib/libdevmapper-event-lvm2raid.so
>    /usr/bin/install -c -m 555  -D libdevmapper-event-lvm2thin.so /usr/lib/device-mapper/libdevmapper-event-lvm2thin.so
>    ln -s -f device-mapper/libdevmapper-event-lvm2thin.so /usr/lib/libdevmapper-event-lvm2thin.so
>    /usr/bin/install -c -m 555  -D libdevmapper-event-lvm2mirror.so /usr/lib/device-mapper/libdevmapper-event-lvm2mirror.so
>    ln -s -f device-mapper/libdevmapper-event-lvm2mirror.so /usr/lib/libdevmapper-event-lvm2mirror.so
>    /usr/bin/install -c -m 555  -D libdevmapper-event-lvm2vdo.so /usr/lib/device-mapper/libdevmapper-event-lvm2vdo.so
>    ln -s -f device-mapper/libdevmapper-event-lvm2vdo.so /usr/lib/libdevmapper-event-lvm2vdo.so
>    /usr/bin/install -c -m 555  -D libdevmapper-event.so /usr/lib/libdevmapper-event.so.1.02
> 
>    [...]
> 
> So at the end, if my Centos7's rootFS is logical volumes, this will
> lead to booting failure.  The reason is at the booting time, the lvm
> tool (should also include dmeventd) have been updated with myself built
> binaries, the default lib path should be /usr/lib64 but not the folder
> /usr/lib, so the upgraded binaries cannot find the appropriate libs.
> This is why we rescured the system by copying libdevmapper related libs
> from /usr/lib to /usr/lib64.
> 
> I can manually copy libs from /usr/lib to /usr/lib64 for libdevmapper-*,
> but seems to me this is not the formal way to do.  My question is how I
> can smoothly upgrade self built LVM tools on Centos7?


I think you should just do what rpm macro `%configure` used in EL7 spec 
file does. That expands to rather long statement:


./configure --build=x86_64-redhat-linux-gnu 
--host=x86_64-redhat-linux-gnu --program-prefix= 
--disable-dependency-tracking --prefix=/usr --exec-prefix=/usr 
--bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc 
--datadir=/usr/share --includedir=/usr/include --libdir=/usr/lib64 
--libexecdir=/usr/libexec --localstatedir=/var --sharedstatedir=/var/lib 
--mandir=/usr/share/man --infodir=/usr/share/info

> Thanks,
> Leo
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
> 


