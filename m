From: Eric Ren <zren@suse.com>
Date: Wed, 27 Dec 2017 16:03:10 +0800
Subject: [PATCH 0/2] LVM2: fix lvmetad udev rules for CHANGE events
In-Reply-To: <1513943697.4257.14.camel@suse.com>
References: <20171221115705.5055-1-mwilck@suse.com>
	<1513943697.4257.14.camel@suse.com>
Message-ID: <b041c704-6f2a-b20f-c33e-a93e7504ad4d@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Martin and all,

Thanks for you reproducing guide. I have reproduce this problem on the very
recent openSUSE tumbleweed and fedora distro. Please see the attachments 
for the
details.

- reproducer-on-s390.sh
The patches passed the reproducer on s390.

- reproduced-on-fedora28.txt on x86_64
Reproduced, but not tried the patches on fedora yet.

- very-confusing-result-with-patches.txt on x86_64
This patches fixed the issue on the second testing, but re-occurs at the
third testing. After that, I cannot get the PV back again.

@Martin, can you try to repeat the steps more than 2 times on your testing
machine?

Some special notice to reproduce:

1. reboot after you partitioned the disk and create the LV on it, 
otherwise the following
command will output nothing:

"""

# udevadm info /dev/sdf1  | grep SYSTEMD
(no output)

"""

2. after booting up, the first round testing is always fine, but the problem
will 100% happen at the second round.

I don't know why, do you have an explanation on that?

Thanks,
Eric


On 12/22/2017 07:54 PM, Martin Wilck wrote:
> On Thu, 2017-12-21 at 12:57 +0100, Martin Wilck wrote:
>> The current logic in 69-dm-lvm-metad.rules is broken for the default
>> "enable-udev-systemd-background-jobs" case. Detailed information
>> about the
>> problem can be found in the commit message of the 2nd patch in the
>> set.
> A few more remarks may be in order here.
>
> Firstly, in addition to the patch I sent, it might make sense to call
> "systemctl stop lvm-pvscan@$major.minor.service" in the LVM_PV_REMOVED
> case in 69-dm-lvm-metad.rules rather than just "pvscan --cache
> $major:minor". By doing the latter, udev informs lvmetad about the
> removed PV, but not systemd. Comments welcome.
>
> Secondly, you may have a hard time reproducing the issue on a typical
> x86/SCSI setup. The problem has been reported to us for s390x DASDs,
> using this command sequence:
>
> chccwdev -e $CCW  # generates ADD, then CHANGE event
> vgchange -an $VG
> chccwdev -d $CCW  # generates CHANGE+LVM_PV_REMOVED, then REMOVE event
> chccwdev -e $CCW
> => PV is not seen by lvmetad.
>
> Doing the same thing with SCSI is quite tricky. Maybe someone else
> finds a more elegant reproduce. Below is what I came up with.
>
> Martin
>
> Situation after booting, PV (sdf1) is live and registered in udev,
> systemd, and lvmetad. I start "udevadm monitor" in the background to
> see the uevents. Note the "Following" property below, which represents
> the effect of SYSTEMD_ALIAS for the PV.
>
>> # udevadm monitor -u -s block &
>> # pvs
>>    PV         VG Fmt  Attr PSize PFree
>>    /dev/sdf1  vg lvm2 a--  1.70g 712.00m
>>
>> # systemctl show -p ActiveState -p BindsTo lvm2-pvscan at 8:81.service
>> BindsTo=dev-block-8:81.device
>> ActiveState=active
>>
>> # systemctl show -p ActiveState -p BoundBy -p Following dev-block-
> 8:81.device
>> Following=sys-devices-pci0000:00-0000:00:14.0-host18-target18:0:4-
> 18:0:4:0-block-sdf-sdf1.device
>> BoundBy=lvm2-pvscan at 8:81.service
>> ActiveState=active
>>
>> # udevadm info /dev/sdf1  | grep SYSTEMD
>> E: SYSTEMD_ALIAS=/dev/block/8:81
>> E: SYSTEMD_READY=1
>> E: SYSTEMD_WANTS=lvm2-pvscan at 8:81.service
> Now we generate a CHANGE event by simulating a close-after-write. The
> SYSTEMD variables are lost in the udev db, but systemd state is still
> ok:
>
>> # python -c 'open("/dev/sdf1", "w")'
>> UDEV  [507.991529]
> change   /devices/pci0000:00/0000:00:14.0/host18/target18:0:4/18:0:4:0/
> block/sdf/sdf1 (block)
>> # udevadm info /dev/sdf1  | grep SYSTEMD
>> (no output)
>> # systemctl show -p ActiveState -p BoundBy -p Following dev-block-
> 8:81.device
>> Following=sys-devices-pci0000:00-0000:00:14.0-host18-target18:0:4-
> 18:0:4:0-block-sdf-sdf1.device
>> BoundBy=lvm2-pvscan at 8:81.service
>> ActiveState=active
> systemctl daemon-reload makes systemd loose the connection between the
> "alias"  dev-block-8:81.device and the real device unit "sys-devices-
> pci0000:00-0000:00:14.0-host18-target18:0:4-18:0:4:0-block-sdf-
> sdf1.device". The pvscan unit is unaffected. pvs still works.
>
>> # systemctl daemon-reload
>> # systemctl show -p ActiveState -p BoundBy -p Following dev-block-
> 8:81.device
>> Following=
>> BoundBy=lvm2-pvscan at 8:81.service
>> ActiveState=inactive
>>
>> # systemctl show -p ActiveState -p BindsTo lvm2-pvscan at 8:81.service
>> BindsTo=dev-block-8:81.device
>> ActiveState=active
>>
>> # pvs
>>    PV         VG Fmt  Attr PSize PFree
>>    /dev/sdf1  vg lvm2 a--  1.70g 712.00m
> Next we simulate device removal. It's a bit tricky to do exactly as
> chccwdev does it.
>    - deactivate LVs (not strictly necessary, but customer did it)
>    - make sure blkid can't read from page cache
>    - make disk unreadable
>    - synthesize CHANGE event (this triggers the LVM_PV_GONE case in 69-
> dm-lvmetad.rules, and removes the PV from lvmetad's cache)
>    - make disk readable again
>
>> # vgchange -an vg
>> # echo 3 >/proc/sys/vm/drop_caches #
>> # echo transport-offline  >/sys/block/sdd/device/state
>> # python -c 'open("/dev/sdf1", "w")'
>> UDEV  [863.996418]
> change   /devices/pci0000:00/0000:00:14.0/host18/target18:0:4/18:0:4:0/
> block/sdf/sdf1 (block)
>> # echo running  >/sys/block/sdf/device/state
>> # pvs
>> (no output)
> But the pvscan service is still active (of course, nothing happened
> that would change its state).
>
>> # systemctl show -p ActiveState -p BindsTo lvm2-pvscan at 8:81.service
>> BindsTo=dev-block-8:81.device
>> ActiveState=active
> Now we delete the device, and see the pvscan service is *still* active.
> THIS IS THE ERROR.
>> # echo 1 >/sys/block/sdf/device/delete
>>
>> # systemctl show -p ActiveState -p BindsTo lvm2-pvscan at 8:81.service
>> BindsTo=dev-block-8:81.device
>> ActiveState=active
> We add the disk again. After that we see the pvscan still running (but
> with start date 1/2h in the past), and no physical volumes shown by
> "pvs".
>
> [ Remark: on my test system, the kernel would sometimes assign a
> different block device to the disk at this point, breaking the
> reproducer. I didn't investigate this further. The problem is only
> reproduced if the dev_t remains the same after re-adding the disk.
> This is always the case with s390 DASDs, AFAICS. ]
>
>> # echo - - - >/sys/class/scsi_host/host18/scan
>> UDEV  [1524.967155]
> add      /devices/pci0000:00/0000:00:14.0/host18/target18:0:4/18:0:4:0/
> block/sdf (block)
>> UDEV  [1524.973179]
> add      /devices/pci0000:00/0000:00:14.0/host18/target18:0:4/18:0:4:0/
> block/sdf/sdf1 (block)
>> # pvs
>> (no output)
>> # systemctl show -p ActiveState -p BindsTo -p ExecMainStartTimestamp
> lvm2-pvscan at 8:81.service
>> BindsTo=dev-block-8:81.device
>> ActiveState=active
>> ExecMainStartTimestamp=Fri 2017-12-22 11:56:35 CET
>> # date
>> Fri Dec 22 12:22:21 CET 2017
> Restarting the pvscan service brings back the PV.
>
>> # systemctl restart lvm2-pvscan at 8:81.service
>> # pvs
>>    PV         VG Fmt  Attr PSize PFree
>>    /dev/sdf1  vg lvm2 a--  1.70g 712.00m

-------------- next part --------------
A non-text attachment was scrubbed...
Name: reproducer-on-s390.sh
Type: application/x-shellscript
Size: 360 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20171227/4bf6c26a/attachment.bin>
-------------- next part --------------
[root at localhost ~]# cat /etc/redhat-release 
Fedora release 28 (Rawhide)
[root at localhost ~]# rpm -qa|grep lvm2
lvm2-2.02.176-1.fc28.x86_64

========== 1st testing on fedora==========
[root at localhost ~]# udevadm monitor -u -s block &
[1] 3043
monitor will print the received events for:
UDEV - the event which udev sends out after rule processing

[root at localhost ~]# udevadm info /dev/sdb1 | grep SYSTEMD
E: SYSTEMD_ALIAS=/dev/block/8:17
E: SYSTEMD_READY=1
E: SYSTEMD_WANTS=lvm2-pvscan at 8:17.service

[root at localhost ~]# python -c 'open("/dev/sdb1", "w")'
[root at localhost ~]# UDEV  [1704.670470] change   /devices/pci0000:00/0000:00:01.1/ata2/host1/target1:0:1/1:0:1:0/block/sdb/sdb1 (block)

[root at localhost ~]# udevadm info /dev/sdb1 | grep SYSTEMD

[root at localhost ~]# systemctl show -p ActiveState -p BoundBy -p Following dev-block-8:17.device
Following=sys-devices-pci0000:00-0000:00:01.1-ata2-host1-target1:0:1-1:0:1:0-block-sdb-sdb1.device
BoundBy=lvm2-pvscan at 8:17.service
ActiveState=active

[root at localhost ~]# systemctl daemon-reload
[root at localhost ~]# systemctl show -p ActiveState -p BoundBy -p Following dev-block-8:17.device
Following=
BoundBy=lvm2-pvscan at 8:17.service
ActiveState=inactive
[root at localhost ~]# systemctl show -p ActiveState -p BindsTo lvm2-pvscan at 8:17.service
BindsTo=dev-block-8:17.device
ActiveState=active
[root at localhost ~]# pvs
  PV         VG     Fmt  Attr PSize   PFree   
  /dev/sda2  fedora lvm2 a--  <19.00g 1020.00m
  /dev/sdb1  vg1    lvm2 a--   <2.00g 1020.00m

[root@localhost ~]# echo 3 >/proc/sys/vm/drop_caches 
[root at localhost ~]# echo transport-offline >/sys/block/sdb/device/state 
[root at localhost ~]# python -c 'open("/dev/sdb1", "w")'
[root at localhost ~]# UDEV  [1781.479578] change   /devices/pci0000:00/0000:00:01.1/ata2/host1/target1:0:1/1:0:1:0/block/sdb/sdb1 (block)

[root at localhost ~]# echo running >/sys/block/sdb/device/state 
[root at localhost ~]# pvs
  PV         VG     Fmt  Attr PSize   PFree   
  /dev/sda2  fedora lvm2 a--  <19.00g 1020.00m
[root at localhost ~]# systemctl show -p ActiveState -p BindsTo lvm2-pvscan at 8:17.service
BindsTo=dev-block-8:17.device
ActiveState=active

[root@localhost ~]# echo 1 >/sys/block/sdb/device/delete 
[root at localhost ~]# UDEV  [1803.200393] remove   /devices/pci0000:00/0000:00:01.1/ata2/host1/target1:0:1/1:0:1:0/block/sdb/sdb1 (block)
UDEV  [1803.208113] remove   /devices/pci0000:00/0000:00:01.1/ata2/host1/target1:0:1/1:0:1:0/block/sdb (block)

[root at localhost ~]# systemctl show -p ActiveState -p BindsTo lvm2-pvscan at 8:17.service
BindsTo=dev-block-8:17.device
ActiveState=active
[root at localhost ~]#  echo - - - >/sys/class/scsi_host/host1/scan 
[root at localhost ~]# UDEV  [1817.722955] add      /devices/pci0000:00/0000:00:01.1/ata2/host1/target1:0:1/1:0:1:0/block/sdc (block)
UDEV  [1817.768257] add      /devices/pci0000:00/0000:00:01.1/ata2/host1/target1:0:1/1:0:1:0/block/sdc/sdc1 (block)
UDEV  [1818.042588] change   /devices/virtual/block/dm-2 (block)

[root at localhost ~]# pvs
  PV         VG     Fmt  Attr PSize   PFree   
  /dev/sda2  fedora lvm2 a--  <19.00g 1020.00m
  /dev/sdc1  vg1    lvm2 a--   <2.00g 1020.00m

========== END of 1st testing on fedora=================

============== 2st testing on fedora=====================
[root at localhost ~]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   20G  0 disk
??sda1            8:1    0    1G  0 part /boot
??sda2            8:2    0   19G  0 part
  ??fedora-root 253:0    0   17G  0 lvm  /
  ??fedora-swap 253:1    0    1G  0 lvm
sdc               8:32   0   10G  0 disk
??sdc1            8:33   0    2G  0 part
  ??vg1-lv1     253:2    0    1G  0 lvm

[root at localhost ~]# udevadm info /dev/sdc1 | grep SYSTEMD
E: SYSTEMD_ALIAS=/dev/block/8:33
E: SYSTEMD_READY=1
E: SYSTEMD_WANTS=lvm2-pvscan at 8:33.service
[root at localhost ~]# python -c 'open("/dev/sdc1", "w")'
[root at localhost ~]# UDEV  [1925.268635] change   /devices/pci0000:00/0000:00:01.1/ata2/host1/target1:0:1/1:0:1:0/block/sdc/sdc1 (block)
[root at localhost ~]# udevadm info /dev/sdc1 | grep SYSTEMD

[root at localhost ~]# systemctl show -p ActiveState -p BoundBy -p Following dev-block-8:33.device
Following=sys-devices-pci0000:00-0000:00:01.1-ata2-host1-target1:0:1-1:0:1:0-block-sdc-sdc1.device
BoundBy=lvm2-pvscan at 8:33.service
ActiveState=active
[root at localhost ~]# systemctl daemon-reload
[root at localhost ~]# systemctl show -p ActiveState -p BoundBy -p Following dev-block-8:33.device
Following=
BoundBy=lvm2-pvscan at 8:33.service
ActiveState=inactive
[root at localhost ~]# pvs
  PV         VG     Fmt  Attr PSize   PFree
  /dev/sda2  fedora lvm2 a--  <19.00g 1020.00m
  /dev/sdc1  vg1    lvm2 a--   <2.00g 1020.00m

[root@localhost ~]# echo 3 >/proc/sys/vm/drop_caches
[root at localhost ~]# echo transport-offline >/sys/block/sdc/device/state
[root at localhost ~]# udevadm info /dev/sdc1 | grep SYSTEMD
[root at localhost ~]# python -c 'open("/dev/sdc1", "w")'
[root at localhost ~]# UDEV  [1975.250949] change   /devices/pci0000:00/0000:00:01.1/ata2/host1/target1:0:1/1:0:1:0/block/sdc/sdc1 (block)
echo transport-offline >/sys/block/sdc/device/state
[root at localhost ~]# echo running >/sys/block/sdc/device/state
[root at localhost ~]# pvs
  PV         VG     Fmt  Attr PSize   PFree
  /dev/sda2  fedora lvm2 a--  <19.00g 1020.00m
[root at localhost ~]# systemctl show -p ActiveState -p BoundBy -p Following dev-block-8:33.device
Following=
BoundBy=lvm2-pvscan at 8:33.service
ActiveState=inactive
[root at localhost ~]# systemctl show -p ActiveState -p BindsTo lvm2-pvscan at 8:33.service
BindsTo=dev-block-8:33.device
ActiveState=active

[root@localhost ~]# echo 1 >/sys/block/sdc/device/delete
UDEV  [2035.593916] remove   /devices/pci0000:00/0000:00:01.1/ata2/host1/target1:0:1/1:0:1:0/block/sdc/sdc1 (block)
UDEV  [2035.602933] remove   /devices/pci0000:00/0000:00:01.1/ata2/host1/target1:0:1/1:0:1:0/block/sdc (block)
[root at localhost ~]# systemctl show -p ActiveState -p BindsTo lvm2-pvscan at 8:33.service
BindsTo=dev-block-8:33.device
ActiveState=active
[root at localhost ~]# echo - - - >/sys/class/scsi_host/host1/scan
[root at localhost ~]# UDEV  [2060.525945] add      /devices/pci0000:00/0000:00:01.1/ata2/host1/target1:0:1/1:0:1:0/block/sdb (block)
UDEV  [2060.566225] add      /devices/pci0000:00/0000:00:01.1/ata2/host1/target1:0:1/1:0:1:0/block/sdb/sdb1 (block)
[root at localhost ~]# pvs
  /dev/vg1/lv1: read failed after 0 of 4096 at 0: Input/output error
  /dev/vg1/lv1: read failed after 0 of 4096 at 1073676288: Input/output error
  /dev/vg1/lv1: read failed after 0 of 4096 at 1073733632: Input/output error
  /dev/vg1/lv1: read failed after 0 of 4096 at 4096: Input/output error
  PV         VG     Fmt  Attr PSize   PFree
  /dev/sda2  fedora lvm2 a--  <19.00g 1020.00m

============== END of 2st testing on fedora=====================
-------------- next part --------------
=========1st testing with patches ============

linux-gahs:~ # udevadm info /dev/sdb1 | grep SYSTEMD
E: SYSTEMD_ALIAS=/dev/block/8:17
E: SYSTEMD_READY=1
E: SYSTEMD_WANTS=lvm2-pvscan at 8:17.service
linux-gahs:~ # python -c 'open("/dev/sdb1", "w")'
linux-gahs:~ # UDEV  [436.216943] change   /devices/pci0000:00/0000:00:1f.2/ata2/host1/target1:0:0/1:0:0:0/block/sdb/sdb1 (block)
linux-gahs:~ # udevadm info /dev/sdb1 | grep SYSTEMD
E: SYSTEMD_ALIAS=/dev/block/8:17
E: SYSTEMD_READY=1
E: SYSTEMD_WANTS=lvm2-pvscan at 8:17.service

linux-gahs:~ # systemctl show -p ActiveState -p BoundBy -p Following dev-block-8:17.device
Following=sys-devices-pci0000:00-0000:00:1f.2-ata2-host1-target1:0:0-1:0:0:0-block-sdb-sdb1.device
BoundBy=lvm2-pvscan at 8:17.service
ActiveState=active
linux-gahs:~ # systemctl daemon-reload
linux-gahs:~ # systemctl show -p ActiveState -p BoundBy -p Following dev-block-8:17.device
Following=sys-devices-pci0000:00-0000:00:1f.2-ata2-host1-target1:0:0-1:0:0:0-block-sdb-sdb1.device
BoundBy=lvm2-pvscan at 8:17.service
ActiveState=active

linux-gahs:~ # systemctl show -p ActiveState -p BindsTo lvm2-pvscan@8:17.service
BindsTo=dev-block-8:17.device
ActiveState=active
linux-gahs:~ # pvs
  PV         VG       Fmt  Attr PSize   PFree  
  /dev/sda2  systemvg lvm2 a--  425.76g 295.76g
  /dev/sdb1  vg1      lvm2 a--   10.00g   9.00g

linux-gahs:~ # echo 3 >/proc/sys/vm/drop_caches 
linux-gahs:~ # echo transport-offline >/sys/block/sdb/device/state 
linux-gahs:~ #  python -c 'open("/dev/sdb1", "w")'
linux-gahs:~ # UDEV  [529.237372] change   /devices/pci0000:00/0000:00:1f.2/ata2/host1/target1:0:0/1:0:0:0/block/sdb/sdb1 (block)

linux-gahs:~ # echo running >/sys/block/sdb/device/state 
linux-gahs:~ # pvs
  PV         VG       Fmt  Attr PSize   PFree  
  /dev/sda2  systemvg lvm2 a--  425.76g 295.76g
linux-gahs:~ # systemctl show -p ActiveState -p BindsTo lvm2-pvscan at 8:17.service
BindsTo=dev-block-8:17.device
ActiveState=active
linux-gahs:~ # echo 1 >/sys/block/sdb/device/delete
UDEV  [564.155452] remove   /devices/pci0000:00/0000:00:1f.2/ata2/host1/target1:0:0/1:0:0:0/block/sdb/sdb1 (block)
UDEV  [564.156012] remove   /devices/pci0000:00/0000:00:1f.2/ata2/host1/target1:0:0/1:0:0:0/block/sdb (block)
linux-gahs:~ # systemctl show -p ActiveState -p BindsTo lvm2-pvscan at 8:17.service
BindsTo=dev-block-8:17.device
ActiveState=inactive
linux-gahs:~ # echo - - - >/sys/class/scsi_host/host1/scan 
linux-gahs:~ # UDEV  [586.438757] add      /devices/pci0000:00/0000:00:1f.2/ata2/host1/target1:0:0/1:0:0:0/block/sdd (block)
UDEV  [586.729698] add      /devices/pci0000:00/0000:00:1f.2/ata2/host1/target1:0:0/1:0:0:0/block/sdd/sdd1 (block)
UDEV  [586.909397] change   /devices/virtual/block/dm-6 (block)
linux-gahs:~ # pvs
  PV         VG       Fmt  Attr PSize   PFree  
  /dev/sda2  systemvg lvm2 a--  425.76g 295.76g
  /dev/sdd1  vg1      lvm2 a--   10.00g   9.00g

========================== END ==============================

===========2st testing with patches==========================

linux-gahs:~ # udevadm info /dev/sdd1 | grep SYSTEMD
E: SYSTEMD_ALIAS=/dev/block/8:49
E: SYSTEMD_READY=1
E: SYSTEMD_WANTS=lvm2-pvscan at 8:49.service
linux-gahs:~ # systemctl show -p ActiveState -p BoundBy -p Following dev-block-8:49.device
Following=sys-devices-pci0000:00-0000:00:1f.2-ata2-host1-target1:0:0-1:0:0:0-block-sdd-sdd1.device
BoundBy=lvm2-pvscan at 8:49.service
ActiveState=active
linux-gahs:~ #  systemctl daemon-reload
linux-gahs:~ # systemctl show -p ActiveState -p BoundBy -p Following dev-block-8:49.device
Following=sys-devices-pci0000:00-0000:00:1f.2-ata2-host1-target1:0:0-1:0:0:0-block-sdd-sdd1.device
BoundBy=lvm2-pvscan at 8:49.service
ActiveState=active
linux-gahs:~ # systemctl show -p ActiveState -p BindsTo lvm2-pvscan at 8:49.service
BindsTo=dev-block-8:49.device
ActiveState=active
linux-gahs:~ # pvs
  PV         VG       Fmt  Attr PSize   PFree  
  /dev/sda2  systemvg lvm2 a--  425.76g 295.76g
  /dev/sdd1  vg1      lvm2 a--   10.00g   9.00g
linux-gahs:~ # echo 3 >/proc/sys/vm/drop_caches
linux-gahs:~ # echo transport-offline >/sys/block/sdd/device/state 
linux-gahs:~ # python -c 'open("/dev/sdd1", "w")'
linux-gahs:~ # UDEV  [799.844660] change   /devices/pci0000:00/0000:00:1f.2/ata2/host1/target1:0:0/1:0:0:0/block/sdd/sdd1 (block)

linux-gahs:~ # echo running >/sys/block/sdd/device/state
linux-gahs:~ # pvs
  PV         VG       Fmt  Attr PSize   PFree  
  /dev/sda2  systemvg lvm2 a--  425.76g 295.76g
linux-gahs:~ # systemctl show -p ActiveState -p BindsTo lvm2-pvscan at 8:49.service
BindsTo=dev-block-8:49.device
ActiveState=active
linux-gahs:~ # echo 1 >/sys/block/sdd/device/delete
UDEV  [825.385230] remove   /devices/pci0000:00/0000:00:1f.2/ata2/host1/target1:0:0/1:0:0:0/block/sdd/sdd1 (block)
UDEV  [825.385532] remove   /devices/pci0000:00/0000:00:1f.2/ata2/host1/target1:0:0/1:0:0:0/block/sdd (block)
linux-gahs:~ # systemctl show -p ActiveState -p BindsTo lvm2-pvscan at 8:49.service
BindsTo=dev-block-8:49.device
ActiveState=inactive
linux-gahs:~ #  echo - - - >/sys/class/scsi_host/host1/scan 
linux-gahs:~ # UDEV  [845.103884] add      /devices/pci0000:00/0000:00:1f.2/ata2/host1/target1:0:0/1:0:0:0/block/sdb (block)
UDEV  [845.394752] add      /devices/pci0000:00/0000:00:1f.2/ata2/host1/target1:0:0/1:0:0:0/block/sdb/sdb1 (block)
UDEV  [845.566998] change   /devices/virtual/block/dm-6 (block)

linux-gahs:~ # pvs
  PV         VG       Fmt  Attr PSize   PFree  
  /dev/sda2  systemvg lvm2 a--  425.76g 295.76g
  /dev/sdb1  vg1      lvm2 a--   10.00g   9.00g

========================== END ==============================

========= 3st testing with patches ============
linux-gahs:~ # udevadm info /dev/sdd1 | grep SYSTEMD
E: SYSTEMD_ALIAS=/dev/block/8:49
E: SYSTEMD_READY=1
E: SYSTEMD_WANTS=lvm2-pvscan at 8:49.service
linux-gahs:~ # python -c 'open("/dev/sdd1", "w")'
linux-gahs:~ # UDEV  [5388.897557] change   /devices/pci0000:00/0000:00:1f.2/ata2/host1/target1:0:0/1:0:0:0/block/sdd/sdd1 (block)
linux-gahs:~ # udevadm info /dev/sdd1 | grep SYSTEMD
E: SYSTEMD_ALIAS=/dev/block/8:49
E: SYSTEMD_READY=1
E: SYSTEMD_WANTS=lvm2-pvscan at 8:49.service

linux-gahs:~ # systemctl show -p ActiveState -p BoundBy -p Following dev-block-8:49.device
Following=sys-devices-pci0000:00-0000:00:1f.2-ata2-host1-target1:0:0-1:0:0:0-block-sdd-sdd1.device
BoundBy=lvm2-pvscan at 8:49.service
ActiveState=active
linux-gahs:~ # systemctl daemon-reload
linux-gahs:~ # systemctl show -p ActiveState -p BoundBy -p Following dev-block-8:49.device
Following=sys-devices-pci0000:00-0000:00:1f.2-ata2-host1-target1:0:0-1:0:0:0-block-sdd-sdd1.device
BoundBy=lvm2-pvscan at 8:49.service
ActiveState=active

linux-gahs:~ # systemctl show -p ActiveState -p BindsTo lvm2-pvscan at 8:49.service
BindsTo=dev-block-8:49.device
ActiveState=active
linux-gahs:~ # pvs
  PV         VG       Fmt  Attr PSize   PFree
  /dev/sda2  systemvg lvm2 a--  425.76g 295.76g
  /dev/sdd1  vg1      lvm2 a--   10.00g   9.00g
linux-gahs:~ # echo 3 >/proc/sys^Cm/drop_caches
linux-gahs:~ # echo transport-offline >/sys/block/sdd/device/state
linux-gahs:~ # python -c 'open("/dev/sdd1", "w")'
linux-gahs:~ # UDEV  [5504.004925] change   /devices/pci0000:00/0000:00:1f.2/ata2/host1/target1:0:0/1:0:0:0/block/sdd/sdd1 (block)
linux-gahs:~ #  echo running >/sys/block/sdd/device/state
linux-gahs:~ # pvs
  PV         VG       Fmt  Attr PSize   PFree
  /dev/sda2  systemvg lvm2 a--  425.76g 295.76g
linux-gahs:~ #  systemctl show -p ActiveState -p BindsTo lvm2-pvscan at 8:49.service
BindsTo=dev-block-8:49.device
ActiveState=active

linux-gahs:~ # echo 1 >/sys/block/sdd/device/delete
UDEV  [5531.152051] remove   /devices/pci0000:00/0000:00:1f.2/ata2/host1/target1:0:0/1:0:0:0/block/sdd/sdd1 (block)
UDEV  [5531.152464] remove   /devices/pci0000:00/0000:00:1f.2/ata2/host1/target1:0:0/1:0:0:0/block/sdd (block)
linux-gahs:~ # systemctl show -p ActiveState -p BindsTo lvm2-pvscan at 8:49.service
BindsTo=dev-block-8:49.device
ActiveState=inactive
linux-gahs:~ # echo - - - >/sys/class/scsi_host/host1/scan
linux-gahs:~ # UDEV  [5561.620805] add      /devices/pci0000:00/0000:00:1f.2/ata2/host1/target1:0:0/1:0:0:0/block/sdb (block)
UDEV  [5561.622683] add      /devices/pci0000:00/0000:00:1f.2/ata2/host1/target1:0:0/1:0:0:0/block/sdb/sdb1 (block)

linux-gahs:~ # pvs
  /dev/vg1/lv1: read failed after 0 of 4096 at 0: Input/output error
  /dev/vg1/lv1: read failed after 0 of 4096 at 1073676288: Input/output error
  /dev/vg1/lv1: read failed after 0 of 4096 at 1073733632: Input/output error
  /dev/vg1/lv1: read failed after 0 of 4096 at 4096: Input/output error
  PV         VG       Fmt  Attr PSize   PFree
  /dev/sda2  systemvg lvm2 a--  425.76g 295.76g

  linux-gahs:~ # lsblk
NAME                        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
...
sdb                           8:16   0   149G  0 disk
??sdb1                        8:17   0    10G  0 part
linux-gahs:~ # udevadm info /dev/sdb1 | grep SYSTEMD
Unknown device, --name=, --path=, or absolute path in /dev/ or /sys expected.
....
linux-gahs:~ # pvscan --cache
  /dev/vg1/lv1: read failed after 0 of 4096 at 0: Input/output error
  /dev/vg1/lv1: read failed after 0 of 4096 at 1073676288: Input/output error
  /dev/vg1/lv1: read failed after 0 of 4096 at 1073733632: Input/output error
  /dev/vg1/lv1: read failed after 0 of 4096 at 4096: Input/output error
linux-gahs:~ # systemctl show -p ActiveState -p BoundBy -p Following dev-block-8:49.device
Following=
BoundBy=lvm2-pvscan at 8:49.service
ActiveState=inactive
linux-gahs:~ # systemctl show -p ActiveState -p BoundBy -p Following dev-block-8:17.device
Following=
BoundBy=lvm2-pvscan at 8:17.service
ActiveState=inactive
================== END ===============================================
