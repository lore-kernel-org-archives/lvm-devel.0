From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Mon, 6 Dec 2021 11:41:27 +0530
Subject: thin vol write performance variance
In-Reply-To: <CAFe+wq0k0HKJyngKQL6vgoZvW2Ht0xzDbFpnEgY43WeGWt42eg@mail.gmail.com>
References: <CAFe+wq3DUszqSVG6O5vOSMBv-EsAQ3Nru5jrhSK1nbz4uUPNgA@mail.gmail.com>
	<0e77c758-d804-61b6-73f1-3a268b03b6b2@redhat.com>
	<CAFe+wq2FRw7O_j0YeaKZANkPpqdus9DR675MO9Z42+kOiKPVyw@mail.gmail.com>
	<CAFe+wq2KVpPoESYEAhMW1dzzNSWRj6jwJ0m90bxA_AfW=UxvOg@mail.gmail.com>
	<CAFe+wq0k0HKJyngKQL6vgoZvW2Ht0xzDbFpnEgY43WeGWt42eg@mail.gmail.com>
Message-ID: <CAFe+wq1hhi9v3q09edkpg5eFf-8SNO2n8dLtY51TT1d3v-FO=Q@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Bumping this thread, any inputs would be appreciated.

Best regards

On Tue, Nov 23, 2021 at 2:37 PM Lakshmi Narasimhan Sundararajan
<lsundararajan@purestorage.com> wrote:
>
> On Mon, Nov 22, 2021 at 10:53 PM Lakshmi Narasimhan Sundararajan
> <lsundararajan@purestorage.com> wrote:
> >
> > Hi Team,
> > I am following up with the poor write/sync performance issue over dm
> > thin volumes.
> > I need your inputs to help me understand better.
> >
> > System has physical SSD drives.
> > In this simple case, MD raid0 volume is mapped over the 3 SSDs.
> > A thin pool is created over the MD volume.
> > A thin volume is created over the thin pool.
> > And this test involves checking write IO performance over this thin volume.
> >
> > The summary of my finding is dmthin volume buffered is very slow.
> > On direct volume this issue is not seen.
> > Looking at the inflight requests, there is a huge amount of IO in flight.
> > Given all block device have a max limit 'nr_request', i cannot imagine
> > how its possible to have
> > that many enqueued requests inflight. See below.
> >
> > [root at ip-70-0-192-7 ~]# cat /sys/block/dm-5/queue/nr_requests
> > 128
> > [root at ip-70-0-192-7 ~]# cat /sys/block/dm-5/inflight
> >        0   296600
> >
> > It is not surprising then that a sync call would take forever given
> > the amount of pending IOs.
> >
> > Can you please help me understand how that many inflight requests are possible?
> > Why is the device queue limit not honoured for dm thin devices?
> > Any other possible areas/pointers to follow up?
> >
> > Below are more details on the setup and the fio used for pumping traffic.
> >
> > * thin device under test:
> > /dev/mapped/pwx0-717475775864529330
> >
> > * fio cmdline, where the above device (formatted with ext4 and mounted
> > at /mnt/1)
> > sudo fio --blocksize=16k --directory=/mnt/1 --filename=sample.txt
> > --ioengine=libaio --readwrite=write --size=1G --name=test
> > --verify_pattern=0xDeadBeef --direct=0 --gtod_reduce=1 --iodepth=32
> > --randrepeat=1 --disable_lat=0 --gtod_reduce=0
> >
> > * devices:
> > [root at ip-70-0-192-7 ~]# ls -lh /dev/mapper/
> > total 0
> > crw------- 1 root root 10, 236 Nov 19 23:17 control
> > lrwxrwxrwx 1 root root       7 Nov 19 23:17 pwx0-717475775864529330 -> ../dm-5
> > lrwxrwxrwx 1 root root       7 Nov 19 23:17 pwx0-pxMetaFS -> ../dm-4
> > lrwxrwxrwx 1 root root       7 Nov 19 23:17 pwx0-pxpool -> ../dm-3
> > lrwxrwxrwx 1 root root       7 Nov 19 23:17 pwx0-pxpool_tdata -> ../dm-1
> > lrwxrwxrwx 1 root root       7 Nov 19 23:17 pwx0-pxpool_tmeta -> ../dm-0
> > lrwxrwxrwx 1 root root       7 Nov 19 23:17 pwx0-pxpool-tpool -> ../dm-2
> >
> > * iostat:
> > Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s
> > avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
> > sdb               0.00     0.00    0.00    0.00     0.00     0.00
> > 0.00     0.00    0.00    0.00    0.00   0.00   0.00
> > sda               0.00     0.00    0.00    0.00     0.00     0.00
> > 0.00     0.00    0.00    0.00    0.00   0.00   0.00
> > sdc               0.00     0.00    0.00    2.00     0.00     0.01
> > 5.50     0.03   14.50    0.00   14.50  14.50   2.90
> > sde               0.00  1216.00    0.00  832.00     0.00     8.00
> > 19.69     3.35    4.03    0.00    4.03   0.43  35.50
> > sdf               0.00  1146.00    0.00  902.00     0.00     8.00
> > 18.16     4.84    5.37    0.00    5.37   0.50  45.10
> > sdd               0.00  1136.00    1.00 1011.00     0.00     8.39
> > 16.98     4.41    4.36    7.00    4.36   0.41  41.70
> > md127             0.00     0.00    0.00 6243.00     0.00    24.39
> > 8.00     0.00    0.00    0.00    0.00   0.00   0.00
> > dm-0              0.00     0.00    0.00    0.00     0.00     0.00
> > 0.00     0.00    0.00    0.00    0.00   0.00   0.00
> > dm-1              0.00     0.00    0.00 6243.00     0.00    24.39
> > 8.00    57.37    9.19    0.00    9.19   0.16 101.30
> > dm-2              0.00     0.00    0.00 6243.00     0.00    24.39
> > 8.00    57.39    9.19    0.00    9.19   0.16 101.30
> > dm-4              0.00     0.00    0.00    0.00     0.00     0.00
> > 0.00     0.00    0.00    0.00    0.00   0.00   0.00
> > dm-5              0.00     0.00    0.00    0.00     0.00     0.00
> > 0.00 259962.13    0.00    0.00    0.00   0.00 101.30
> >
> > [root at ip-70-0-192-7 ~]# cat /sys/block/dm-5/queue/nr_requests
> > 128
> > [root at ip-70-0-192-7 ~]# cat /sys/block/dm-5/inflight
> >        0   296600
> >
> > [root at ip-70-0-192-7 ~]# dmsetup table
> > pwx0-pxMetaFS: 0 134217728 thin 253:2 1
> > pwx0-717475775864529330: 0 20971520 thin 253:2 2
> > pwx0-pxpool-tpool: 0 125689856 thin-pool 253:0 253:1 128 0 0
> > pwx0-pxpool_tdata: 0 125689856 linear 9:127 4196352
> > pwx0-pxpool_tmeta: 0 4194304 linear 9:127 129886208
> > pwx0-pxpool: 0 125689856 linear 253:2 0
> >
> >
> > [root at ip-70-0-192-7 ~]# dmsetup ls --tree
> > pwx0-pxMetaFS (253:4)
> >  ??pwx0-pxpool-tpool (253:2)
> >     ??pwx0-pxpool_tdata (253:1)
> >     ?  ?? (9:127)
> >     ??pwx0-pxpool_tmeta (253:0)
> >        ?? (9:127)
> > pwx0-pxpool (253:3)
> >  ??pwx0-pxpool-tpool (253:2)
> >     ??pwx0-pxpool_tdata (253:1)
> >     ?  ?? (9:127)
> >     ??pwx0-pxpool_tmeta (253:0)
> >        ?? (9:127)
> > pwx0-717475775864529330 (253:5)
> >  ??pwx0-pxpool-tpool (253:2)
> >     ??pwx0-pxpool_tdata (253:1)
> >     ?  ?? (9:127)
> >     ??pwx0-pxpool_tmeta (253:0)
> >        ?? (9:127)
> >
> > [root at ip-70-0-78-192 ~]# lsblk
>
> Please ignore this output, as it's taken from another test on the same
> setup. But the drive details are the same.
>
> > NAME                             MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
> > sdf                                8:80   0    64G  0 disk
> > sdd                                8:48   0    64G  0 disk
> > sdb                                8:16   0    32G  0 disk
> > sdg                                8:96   0    64G  0 disk
> > sde                                8:64   0    64G  0 disk
> > sdc                                8:32   0    64G  0 disk
> > ??md127                            9:127  0    64G  0 raid0
> >   ??pwx0-pxpool_tdata            253:1    0    60G  0 lvm
> >   ? ??pwx0-pxpool-tpool          253:2    0    60G  0 lvm
> >   ?   ??pwx0-pxMetaFS            253:4    0    64G  0 lvm
> >   ?   ??pwx0-717475775864529330  253:5    0    10G  0 lvm
> >   ?   ??pwx0-pxpool              253:3    0    60G  0 lvm
> >   ??pwx0-pxpool_tmeta            253:0    0     2G  0 lvm
> >     ??pwx0-pxpool-tpool          253:2    0    60G  0 lvm
> >       ??pwx0-pxMetaFS            253:4    0    64G  0 lvm
> >       ??pwx0-717475775864529330  253:5    0    10G  0 lvm
> >       ??pwx0-pxpool              253:3    0    60G  0 lvm
> > sda                                8:0    0   128G  0 disk
> > ??sda2                             8:2    0 124.3G  0 part  /
> > ??sda1                             8:1    0   3.7G  0 part  /boot
> > [root at ip-70-0-78-192 ~]#
> >
> > [root at ip-70-0-78-192 ~]# cat /sys/block/sdc/queue/rotational
> > 0
> > sdc is a SSD drive.
> >
> > ==== system config =====
> > [root at ip-70-0-78-192 ~]# lvm version
> >   LVM version:     2.02.187(2)-RHEL7 (2020-03-24)
> >   Library version: 1.02.170-RHEL7 (2020-03-24)
> >   Driver version:  4.42.0
> >   Configuration:   ./configure --build=x86_64-redhat-linux-gnu
> > --host=x86_64-redhat-linux-gnu --program-prefix=
> > --disable-dependency-tracking --prefix=/usr --exec-prefix=/usr
> > --bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc
> > --datadir=/usr/share --includedir=/usr/include --libdir=/usr/lib64
> > --libexecdir=/usr/libexec --localstatedir=/var
> > --sharedstatedir=/var/lib --mandir=/usr/share/man
> > --infodir=/usr/share/info --with-default-dm-run-dir=/run
> > --with-default-run-dir=/run/lvm --with-default-pid-dir=/run
> > --with-default-locking-dir=/run/lock/lvm --with-usrlibdir=/usr/lib64
> > --enable-lvm1_fallback --enable-fsadm --with-pool=internal
> > --enable-write_install --with-user= --with-group= --with-device-uid=0
> > --with-device-gid=6 --with-device-mode=0660 --enable-pkgconfig
> > --enable-applib --enable-cmdlib --enable-dmeventd
> > --enable-blkid_wiping --enable-python2-bindings
> > --with-cluster=internal --with-clvmd=corosync --enable-cmirrord
> > --with-udevdir=/usr/lib/udev/rules.d --enable-udev_sync
> > --with-thin=internal --enable-lvmetad --with-cache=internal
> > --enable-lvmpolld --enable-lvmlockd-dlm --enable-lvmlockd-sanlock
> > --enable-dmfilemapd
> > [root at ip-70-0-78-192 ~]# uname -a
> > Linux ip-70-0-78-192.brbnca.spcsdns.net 5.7.12-1.el7.elrepo.x86_64 #1
> > SMP Fri Jul 31 16:18:28 EDT 2020 x86_64 x86_64 x86_64 GNU/Linux
> > [root at ip-70-0-78-192 ~]# cat /etc/os-release
> > NAME="CentOS Linux"
> > VERSION="7 (Core)"
> > ID="centos"
> > ID_LIKE="rhel fedora"
> > VERSION_ID="7"
> > PRETTY_NAME="CentOS Linux 7 (Core)"
> > ANSI_COLOR="0;31"
> > CPE_NAME="cpe:/o:centos:centos:7"
> > HOME_URL="https://www.centos.org/"
> > BUG_REPORT_URL="https://bugs.centos.org/"
> >
> > CENTOS_MANTISBT_PROJECT="CentOS-7"
> > CENTOS_MANTISBT_PROJECT_VERSION="7"
> > REDHAT_SUPPORT_PRODUCT="centos"
> > REDHAT_SUPPORT_PRODUCT_VERSION="7"
> >
> > [root at ip-70-0-78-192 ~]#
> >
> > This system has 16G RAM and 8 cpu cores.
> >
> >
> > Thanks
> >
> > LN
> >
> > On Tue, Sep 28, 2021 at 3:34 PM Lakshmi Narasimhan Sundararajan
> > <lsundararajan@purestorage.com> wrote:
> > >
> > > On Fri, Sep 17, 2021 at 1:29 AM Zdenek Kabelac <zkabelac@redhat.com> wrote:
> > > >
> > > > Dne 15. 09. 21 v 9:02 Lakshmi Narasimhan Sundararajan napsal(a):
> > > > > Hi Team,
> > > > > A very good day to you.
> > > > >
> > > > > I have a lvm2 thin pool and thin volumes in my environment.
> > > > > I see a huge variance in write performance over those thin volumes.
> > > > > As one can observe from the logs below, the same quantum of write
> > > > > (~1.5G) to the thin volume (/dev/pwx0/608561273872404373) completes
> > > > > between 2s to 40s.
> > > > > The metadata is  defined as 128 sectors (64KB) on the thin pool.
> > > > > I understand that there is a late mapping of segments to thin volumes
> > > > > as IO requests come in.
> > > > > Is there a way to test/quantity that the overhead is because of this
> > > > > lazy mapping?
> > > > > Are there any other config/areas that I can tune to control this behavior?
> > > > > Are there any tunables/ioctl to control mapping regions ahead of time
> > > > > (ala readahead)?
> > > > > Any other options available to confirm this behavior is because of the
> > > > > lazy mapping and ways to improve it?
> > > > >
> > > > > My intention is to improve this behavior and control the variance to a
> > > > > more tight bound.
> > > > > Looking forward to your inputs in helping me understand this better.
> > > > >
> > > >
> > > > Hi
> > > >
> > > > I think we need to 'decipher' first some origins of your problems.
> > > >
> > > > So what is your backend 'storage' in use?
> > > > Do you use fast device like ssd/nvme to store thin-pool metadata?
> > > >
> > > > Do you measure your time *after* sync all of 'unwritten/buffered' data on disk ?
> > > >
> > > > What is actually your hw in use  - RAM, CPU ?
> > > >
> > > > Which kernel and lvm2 version is being used ?
> > > >
> > > > Do you use/need zeroing of provisioned blocks (which may impact performance
> > > > and can be disabled with lvcreate -Zn) ?
> > > >
> > > > Do you measure writes while provisioning thin chunks or on already provisioned
> > > > device?
> > > >
> > >
> > > Hi Zdenek,
> > > These are traditional HDDs. Both the thin pool data/metadata reside on
> > > the same set of drive(s).
> > > I understand where you are going with this, I will look further into
> > > defining the hardware/disk before I bring it to your attention.
> > >
> > > This run was not on an already provisioned device. I do see improved
> > > performance of the same volume after the first write.
> > > I understand this perf gain to be the overhead that is avoided during
> > > the subsequent run where no mappings need to be established.
> > >
> > > But, you mentioned zeroing of provisioned blocks as an issue.
> > > 1/ during lvcreate -Z from the man pages reports only controls the
> > > first 4K block. And also implies this is a MUST otherwise fs may hang.
> > > So, we are using this. Are you saying this controls zeroing of each
> > > chunk that's mapped to the thin volume?
> > >
> > > 2/ The other about zeroing all the data chunks mapped to the thin
> > > volume, I could see only reference in the lvm.conf under
> > > thin_pool_zero,
> > > This is default enabled. So are you suggesting I disable this?
> > >
> > > Please confirm the above items. I will come back with more precise
> > > details on the details you had requested for.
> > >
> > > Thanks.
> > > LN
> > >
> > >
> > >
> > >
> > >
> > >
> > >
> > >
> > >
> > > >
> > > > Regards
> > > >
> > > > Zdenek
> > > >



