From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Fri, 27 Aug 2021 14:53:20 +0530
Subject: Concurrent calls lvm create vs lvm remove
In-Reply-To: <f7b2ea74-7cc2-071c-ffa8-f5cccc7e6e7c@redhat.com>
References: <CAFe+wq3Ag7Br9TtukOn2jSvqmXJMNM=Cq_7DU8WH2rDJ6kYV+Q@mail.gmail.com>
	<f7b2ea74-7cc2-071c-ffa8-f5cccc7e6e7c@redhat.com>
Message-ID: <CAFe+wq26FEmQPe-AAao3Q1r-m9KQPw6MK0uE0GxGUrAw3fR_Yw@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdenek,
Thank you for your email explaining in some detail.

My environment is slightly convoluted and has a container.
I perform the following from within a container, which uses lvm2app to
make the call.
in a loop:
a/ lvm thin volume create.
b/ do read/write IOs to the lvol
c/ lvm thin volume delete.

It is observed every 100 loop the above loop fails at least once
during volume creation, with vg not found.

I enabled debug logs from the lvmetad running at the host. As one can
see, sometimes pv_gone message is received by lvmetad.
This removes the associated vg which has only a single pv that's
reported missing.
I believe at this point in time, when a vg lookup comes in, it does
not find the vg and so the lv create call fails.
This pv_remove is not received for every lv remove normally, but
happens only sometimes.
I could not figure out who posted the message to lvmetad.
So that's the current scenario, and I overcame this currently by doing
a retry in my app, which does lvm calls.
But I would appreciate it if you could point me to who could be the
one who initiates a pv_remove in this scenario, as this is not usually
seen.
And can you please confirm if the previous summary of lv create
failing if lvmetad has missing vg, is correct.

I thought I had a suspect, maybe there is a kernel dev change event,
that kick starts a udev rule that runs a "pvscan --cache" that posts a
pv_remove?
But if that be the case, it should happen every lv remove call, i am
not seeing it.
So your pointers will help.

Logs from lvmetad running at host.
```

Aug 19 14:31:39 ip-70-0-107-217 lvmetad: pv_gone
blZ3mg-nFiO-nYBU-dw3a-RqWD-Yn1K-9gAitx device 2431

^^^ When the last pv in a vg gets reported lost, the vg is also taken
down from cache.

Aug 19 14:31:39 ip-70-0-107-217 lvmetad: removing empty VG
3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: moving PV
blZ3mg-nFiO-nYBU-dw3a-RqWD-Yn1K-9gAitx to VG #orphan
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: vg_update vgid
3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h name pwx0
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: update_metadata begin
arg_vgid 3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h arg_name pwx0 pvid
none
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: update_metadata new name pwx0
and new vgid 3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: update_metadata_add_new for
pwx0 3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: moving PV
blZ3mg-nFiO-nYBU-dw3a-RqWD-Yn1K-9gAitx to VG
3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: update_metadata_add_new is
done for pwx0 3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: pv_found pvid
blZ3mg-nFiO-nYBU-dw3a-RqWD-Yn1K-9gAitx on device 2431 is new
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: pv_found new entry
device_to_pvid 2431 to blZ3mg-nFiO-nYBU-dw3a-RqWD-Yn1K-9gAitx
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: vg_clear_outdated_pvs vgid
3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: WARNING: Ignoring unsupported
value for cmd.
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: set info VG name none uuid
3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h cache_version 654 new_version
655
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: 9309 global info flags none
reason none token filter:3239235440 update_pid 0
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: 9309 global info flags none
reason none token filter:3239235440 update_pid 0
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: pv_list
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: vg_list
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: vg_lookup vgid
3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h name pwx0
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: WARNING: Ignoring unsupported
value for cmd.
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: vg_update vgid
3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h name pwx0
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: update_metadata begin
arg_vgid 3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h arg_name pwx0 pvid
none
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: update_metadata existing vgid
3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h and existing name pwx0
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: update_metadata for pwx0
3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h from 654 to 655
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: moving PV
blZ3mg-nFiO-nYBU-dw3a-RqWD-Yn1K-9gAitx to VG #orphan
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: moving PV
blZ3mg-nFiO-nYBU-dw3a-RqWD-Yn1K-9gAitx to VG
3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: update_metadata is done for
pwx0 3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: WARNING: Ignoring unsupported
value for cmd.
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: pv_found pvid
blZ3mg-nFiO-nYBU-dw3a-RqWD-Yn1K-9gAitx on device 2431 matches existing
Aug 19 14:31:39 ip-70-0-107-217 portworx: time="2021-08-19 14:31:39Z"
level=INFO msg="Removing backing storage for device
1516772061340186377 (pool: 0) on 3"
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: pv_gone
blZ3mg-nFiO-nYBU-dw3a-RqWD-Yn1K-9gAitx device 2431
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: removing empty VG
3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: moving PV
blZ3mg-nFiO-nYBU-dw3a-RqWD-Yn1K-9gAitx to VG #orphan
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: WARNING: Ignoring unsupported
value for cmd.
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: vg_lookup vgid none name pwx0
needs lookup

^^^^ Here pwx0 is not known in cache.

Aug 19 14:31:39 ip-70-0-107-217 lvmetad: vg_update vgid
3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h name pwx0
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: update_metadata begin
arg_vgid 3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h arg_name pwx0 pvid
none
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: update_metadata new name pwx0
and new vgid 3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: update_metadata_add_new for
pwx0 3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: moving PV
blZ3mg-nFiO-nYBU-dw3a-RqWD-Yn1K-9gAitx to VG
3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: update_metadata_add_new is
done for pwx0 3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: WARNING: Ignoring unsupported
value for cmd.
Aug 19 14:31:39 ip-70-0-107-217 lvmetad: vg_lookup vgid none name pwx0
needs lookup

^^^^ Here pwx0 is not known in cache.

Aug 19 14:31:39 ip-70-0-107-217 lvmetad: vg_lookup vgid
3CbXLT-dH0P-XvJh-wqgP-2lLm-0rAR-j89P8h name pwx0
```


I fully understand few issues that may be a concern (i have no control
on the env, sorry).
a/ container runs old lvm version
b/ container and host are not same lvm version.
c/ host is latest lvm.
most of the lvm calls are routed to host, but some runs natively as in
this case.

container version
```
  LVM version:     2.02.176(2) (2017-11-03) <<<< Understood this is very old.
  Library version: 1.02.145 (2017-11-03)
  Driver version:  4.42.0
  Configuration:   ./configure --build=x86_64-linux-gnu --prefix=/usr
--includedir=${prefix}/include --mandir=${prefix}/share/man
--infodir=${prefix}/share/info --sysconfdir=/etc --localstatedir=/var
--disable-silent-rules --libdir=${prefix}/lib/x86_64-linux-gnu
--libexecdir=${prefix}/lib/x86_64-linux-gnu --runstatedir=/run
--disable-maintainer-mode --disable-dependency-tracking --exec-prefix=
--bindir=/bin --libdir=/lib/x86_64-linux-gnu --sbindir=/sbin
--with-usrlibdir=/usr/lib/x86_64-linux-gnu --with-optimisation=-O2
--with-cache=internal --with-clvmd=corosync --with-cluster=internal
--with-device-uid=0 --with-device-gid=6 --with-device-mode=0660
--with-default-pid-dir=/run --with-default-run-dir=/run/lvm
--with-default-locking-dir=/run/lock/lvm --with-thin=internal
--with-thin-check=/usr/sbin/thin_check
--with-thin-dump=/usr/sbin/thin_dump
--with-thin-repair=/usr/sbin/thin_repair --enable-applib
--enable-blkid_wiping --enable-cmdlib --enable-cmirrord
--enable-dmeventd --enable-dbus-service --enable-lvmetad
--enable-lvmlockd-dlm --enable-lvmlockd-sanlock --enable-lvmpolld
--enable-notify-dbus --enable-pkgconfig --enable-readline
--enable-udev_rules --enable-udev_sync
```

host version
```
  LVM version:     2.02.187(2)-RHEL7 (2020-03-24)
  Library version: 1.02.170-RHEL7 (2020-03-24)
  Driver version:  4.42.0
  Configuration:   ./configure --build=x86_64-redhat-linux-gnu
--host=x86_64-redhat-linux-gnu --program-prefix=
--disable-dependency-tracking --prefix=/usr --exec-prefix=/usr
--bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc
--datadir=/usr/share --includedir=/usr/include --libdir=/usr/lib64
--libexecdir=/usr/libexec --localstatedir=/var
--sharedstatedir=/var/lib --mandir=/usr/share/man
--infodir=/usr/share/info --with-default-dm-run-dir=/run
--with-default-run-dir=/run/lvm --with-default-pid-dir=/run
--with-default-locking-dir=/run/lock/lvm --with-usrlibdir=/usr/lib64
--enable-lvm1_fallback --enable-fsadm --with-pool=internal
--enable-write_install --with-user= --with-group= --with-device-uid=0
--with-device-gid=6 --with-device-mode=0660 --enable-pkgconfig
--enable-applib --enable-cmdlib --enable-dmeventd
--enable-blkid_wiping --enable-python2-bindings
--with-cluster=internal --with-clvmd=corosync --enable-cmirrord
--with-udevdir=/usr/lib/udev/rules.d --enable-udev_sync
--with-thin=internal --enable-lvmetad --with-cache=internal
--enable-lvmpolld --enable-lvmlockd-dlm --enable-lvmlockd-sanlock
--enable-dmfilemapd
```

Many thanks,
LN


On Tue, Aug 24, 2021 at 5:56 PM Zdenek Kabelac <zkabelac@redhat.com> wrote:
>
> Dne 23. 08. 21 v 15:25 Lakshmi Narasimhan Sundararajan napsal(a):
> > Hi Team!
> > A very good day to you.
> > I want to understand how lvm concurrent calls between create and remove for
> > lvm volumes are handled.
> >
> > Very rarely, I see that when create and remove lvm volume (over a thin pool)
> > run in parallel, lvm create fails with no vg. Looking at lvm metadata debug
> > logs, they seem slightly different with
> > pv gone, removing empty VG, moving PV to #orphan, and a vg_update which
> > eventually brings back everything.
> >
> > How is this race between create and remove handled or more generally if it
> > applies, how are concurrent calls over lvm protected for consistency?
> > Are applications supposed to handle this? I would assume no.
> >
> > My environment is convoluted and may not apply directly, but your help in
> > pointing to current design and usage rules will help me immensely.
> >
>
> Hi
>
> I guess we need to dive a bit 'deeper' into the issue to actually see what
> kind of 'concurrent call' defect do you observe.
>
> Recently there has been submitted 'trial' to cover-up the problem which may
> cause failure of lvm2 commands during rapid changes of lvm2 metadata and
> scanning.  The problem is not 100% solved but should cover most users.
>
> But this error basically caused only error during metadata scanning
> (i.e. occasionally lvm2 reported broken metadata for a VG)
>
> If you have some other type of problem I'd highly recommend to open
> bugzilla so we could collect traces and see how the case with fixes evolves.
>
> Solving this issue over the mailing list isn't usually the best since
> tracking context becomes harder over the time.
>
> If you use RHEL - open bug for corresponding version of your RHEL,
> otherwise just go with community bug here:
>
> https://bugzilla.redhat.com/enter_bug.cgi?product=LVM%20and%20device-mapper
>
> Be sure you provide as much info (OS version and package version) as you can
> together with some logs (if possible) and some way how do you manage to
> reproduce your issue (for fixing it's always easiest/fastest if we can
> reproduce the issue ourself)
>
> And just some generic answers to yous questions:
>
> Manipulation with VG is protected by vgnamed lock - so 2 lvm commands cannot
> change lvm2 metadata for a VG at the same time - they need to wait to get
> 'write-lock' on a VG.
>
> Thin-pool itself may chain messages to thin-pool - however bugfixs or
> improvements have been made over the time to this communication mechanism - so
> it's very important you report your bug while you test latest release version
> of LVM (so we do not hunt for already fixed bugs)
>
> Regards
>
> Zdenek
>


