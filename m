From: Martin Wilck <mwilck@suse.com>
Date: Fri, 22 Dec 2017 12:54:57 +0100
Subject: [PATCH 0/2] LVM2: fix lvmetad udev rules for CHANGE events
In-Reply-To: <20171221115705.5055-1-mwilck@suse.com>
References: <20171221115705.5055-1-mwilck@suse.com>
Message-ID: <1513943697.4257.14.camel@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 2017-12-21 at 12:57 +0100, Martin Wilck wrote:
> The current logic in 69-dm-lvm-metad.rules is broken for the default
> "enable-udev-systemd-background-jobs" case. Detailed information
> about the
> problem can be found in the commit message of the 2nd patch in the
> set.

A few more remarks may be in order here. 

Firstly, in addition to the patch I sent, it might make sense to call
"systemctl stop lvm-pvscan@$major.minor.service" in the LVM_PV_REMOVED
case in 69-dm-lvm-metad.rules rather than just "pvscan --cache
$major:minor". By doing the latter, udev informs lvmetad about the
removed PV, but not systemd. Comments welcome.

Secondly, you may have a hard time reproducing the issue on a typical
x86/SCSI setup. The problem has been reported to us for s390x DASDs,
using this command sequence:

chccwdev -e $CCW  # generates ADD, then CHANGE event
vgchange -an $VG
chccwdev -d $CCW  # generates CHANGE+LVM_PV_REMOVED, then REMOVE event
chccwdev -e $CCW
=> PV is not seen by lvmetad.

Doing the same thing with SCSI is quite tricky. Maybe someone else
finds a more elegant reproduce. Below is what I came up with.

Martin

Situation after booting, PV (sdf1) is live and registered in udev,
systemd, and lvmetad. I start "udevadm monitor" in the background to
see the uevents. Note the "Following" property below, which represents
the effect of SYSTEMD_ALIAS for the PV.

> # udevadm monitor -u -s block &
> # pvs
>   PV         VG Fmt  Attr PSize PFree  
>   /dev/sdf1  vg lvm2 a--  1.70g 712.00m
> 
> # systemctl show -p ActiveState -p BindsTo lvm2-pvscan at 8:81.service
> BindsTo=dev-block-8:81.device
> ActiveState=active
> 
> # systemctl show -p ActiveState -p BoundBy -p Following dev-block-
8:81.device
> Following=sys-devices-pci0000:00-0000:00:14.0-host18-target18:0:4-
18:0:4:0-block-sdf-sdf1.device
> BoundBy=lvm2-pvscan at 8:81.service
> ActiveState=active
> 
> # udevadm info /dev/sdf1  | grep SYSTEMD
> E: SYSTEMD_ALIAS=/dev/block/8:81
> E: SYSTEMD_READY=1
> E: SYSTEMD_WANTS=lvm2-pvscan at 8:81.service

Now we generate a CHANGE event by simulating a close-after-write. The
SYSTEMD variables are lost in the udev db, but systemd state is still
ok:

> # python -c 'open("/dev/sdf1", "w")'
> UDEV  [507.991529]
change   /devices/pci0000:00/0000:00:14.0/host18/target18:0:4/18:0:4:0/
block/sdf/sdf1 (block)
> 
> # udevadm info /dev/sdf1  | grep SYSTEMD
> (no output)
> # systemctl show -p ActiveState -p BoundBy -p Following dev-block-
8:81.device
> Following=sys-devices-pci0000:00-0000:00:14.0-host18-target18:0:4-
18:0:4:0-block-sdf-sdf1.device
> BoundBy=lvm2-pvscan at 8:81.service
> ActiveState=active

systemctl daemon-reload makes systemd loose the connection between the
"alias"  dev-block-8:81.device and the real device unit "sys-devices-
pci0000:00-0000:00:14.0-host18-target18:0:4-18:0:4:0-block-sdf-
sdf1.device". The pvscan unit is unaffected. pvs still works.

> # systemctl daemon-reload
> # systemctl show -p ActiveState -p BoundBy -p Following dev-block-
8:81.device
> Following=
> BoundBy=lvm2-pvscan at 8:81.service
> ActiveState=inactive
> 
> # systemctl show -p ActiveState -p BindsTo lvm2-pvscan at 8:81.service
> BindsTo=dev-block-8:81.device
> ActiveState=active
> 
> # pvs
>   PV         VG Fmt  Attr PSize PFree  
>   /dev/sdf1  vg lvm2 a--  1.70g 712.00m

Next we simulate device removal. It's a bit tricky to do exactly as
chccwdev does it.
  - deactivate LVs (not strictly necessary, but customer did it)
  - make sure blkid can't read from page cache
  - make disk unreadable
  - synthesize CHANGE event (this triggers the LVM_PV_GONE case in 69-
dm-lvmetad.rules, and removes the PV from lvmetad's cache)
  - make disk readable again

> # vgchange -an vg
> # echo 3 >/proc/sys/vm/drop_caches # 
> # echo transport-offline  >/sys/block/sdd/device/state
> # python -c 'open("/dev/sdf1", "w")'
> UDEV  [863.996418]
change   /devices/pci0000:00/0000:00:14.0/host18/target18:0:4/18:0:4:0/
block/sdf/sdf1 (block)
> # echo running  >/sys/block/sdf/device/state
> # pvs
> (no output)

But the pvscan service is still active (of course, nothing happened
that would change its state).

> # systemctl show -p ActiveState -p BindsTo lvm2-pvscan at 8:81.service
> BindsTo=dev-block-8:81.device
> ActiveState=active

Now we delete the device, and see the pvscan service is *still* active.
THIS IS THE ERROR.
> # echo 1 >/sys/block/sdf/device/delete
> 
> # systemctl show -p ActiveState -p BindsTo lvm2-pvscan at 8:81.service
> BindsTo=dev-block-8:81.device
> ActiveState=active

We add the disk again. After that we see the pvscan still running (but
with start date 1/2h in the past), and no physical volumes shown by
"pvs".

[ Remark: on my test system, the kernel would sometimes assign a
different block device to the disk at this point, breaking the
reproducer. I didn't investigate this further. The problem is only
reproduced if the dev_t remains the same after re-adding the disk. 
This is always the case with s390 DASDs, AFAICS. ]

> # echo - - - >/sys/class/scsi_host/host18/scan 
> UDEV  [1524.967155]
add      /devices/pci0000:00/0000:00:14.0/host18/target18:0:4/18:0:4:0/
block/sdf (block)
> UDEV  [1524.973179]
add      /devices/pci0000:00/0000:00:14.0/host18/target18:0:4/18:0:4:0/
block/sdf/sdf1 (block)
> # pvs
> (no output)
> # systemctl show -p ActiveState -p BindsTo -p ExecMainStartTimestamp 
lvm2-pvscan at 8:81.service
> BindsTo=dev-block-8:81.device
> ActiveState=active
> ExecMainStartTimestamp=Fri 2017-12-22 11:56:35 CET
> # date
> Fri Dec 22 12:22:21 CET 2017

Restarting the pvscan service brings back the PV.

> # systemctl restart lvm2-pvscan at 8:81.service
> # pvs
>   PV         VG Fmt  Attr PSize PFree  
>   /dev/sdf1  vg lvm2 a--  1.70g 712.00m

-- 
Dr. Martin Wilck <mwilck@suse.com>, Tel. +49 (0)911 74053 2107
SUSE Linux GmbH, GF: Felix Imend?rffer, Jane Smithard, Graham Norton
HRB 21284 (AG N?rnberg)


