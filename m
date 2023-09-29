From: Eric Wheeler <lvm-devel@lists.ewheeler.net>
Date: Fri, 29 Sep 2023 12:18:07 -0700 (PDT)
Subject: dmeventd is not respecting /etc/lvm/devices/system.devices
Message-ID: <fd47987d-5137-ee79-3e81-2c3228f2c9b3@ewheeler.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello all,

I am not sure how to resolve the dmeventd warning below, maybe you can 
help. It appears that dmeventd is finding PVs attached to VMs, but those 
volumes are not listed in /etc/lvm/devices/system.devices so, presumably, 
they should be ignored by dmeventd.

We used to use `global_filter` and that worked fine, but that seems to be 
deprecated starting in el9 in favor of system.devices. If we try to enable 
the filters in lvm.conf, then pvs/lvs/vgs commands complain about the 
filter options being used together with `use_devicesfile=1`. Note that we 
have PVs on LVs for ssd allocation to different VGs, so `scan_lvs=1` is 
enabled.  (Maybe turning off scan_lvs would "fix" dmeventd, but I can't 
test that because we need PVs on LVs for this deployment.)

Except for the very noisy dmeventd logs, the system works just fine.

Questions:

- Is there an option somewhere to make dmeventd behave, or is this a bug?

- In the log example below, dmeventd on the hypervisor is scanning logical 
  volumes that contain PVs/VGs in use by VMs, for which multiple VMs have 
  unrelated volume groups called "data" (directly on the volume, no 
  partitions)...but those volumes are _not_ in 
  /etc/lvm/devices/system.devices so shouldn't dmeventd ignore them?


More info:

== /var/log/messages ==
Aug 28 15:25:29 hv1.ewheeler.net dmeventd[886522]: WARNING: VG name data is used by VGs pcqIki-TjE0-iFMN-D8MH-19Er-ypSm-djfl5D and 9UEiuo-DYzj-UTLi-XYCi-KiBO-wQi2-w5QUtX.
Aug 28 15:25:29 hv1.ewheeler.net dmeventd[886522]: Fix duplicate VG names with vgrename uuid, a device filter, or system IDs.
Aug 28 15:25:29 hv1.ewheeler.net dmeventd[886522]: WARNING: VG name data is used by VGs H0qj4Q-M6dR-hW0v-PbmL-Jrz1-sJ2N-paWdPI and 9UEiuo-DYzj-UTLi-XYCi-KiBO-wQi2-w5QUtX.
Aug 28 15:25:29 hv1.ewheeler.net dmeventd[886522]: Fix duplicate VG names with vgrename uuid, a device filter, or system IDs.
Aug 28 15:25:29 hv1.ewheeler.net dmeventd[886522]: WARNING: VG name data is used by VGs fPVczf-ehDy-fQti-lKQE-LJkW-g0gt-0ZiikJ and 9UEiuo-DYzj-UTLi-XYCi-KiBO-wQi2-w5QUtX.
Aug 28 15:25:29 hv1.ewheeler.net dmeventd[886522]: Fix duplicate VG names with vgrename uuid, a device filter, or system IDs.
Aug 28 15:25:29 hv1.ewheeler.net dmeventd[886522]: WARNING: VG name data is used by VGs NzRLdW-ST9X-O7X5-ZnGz-0uge-i0lb-lk5xjV and 9UEiuo-DYzj-UTLi-XYCi-KiBO-wQi2-w5QUtX.
Aug 28 15:25:29 hv1.ewheeler.net dmeventd[886522]: Fix duplicate VG names with vgrename uuid, a device filter, or system IDs.
Aug 28 15:25:29 hv1.ewheeler.net dmeventd[886522]: WARNING: VG name data is used by VGs z6fwJ2-S3oK-J0W5-pVHC-ZlDG-FjmP-RUWF7h and 9UEiuo-DYzj-UTLi-XYCi-KiBO-wQi2-w5QUtX.
Aug 28 15:25:29 hv1.ewheeler.net dmeventd[886522]: Fix duplicate VG names with vgrename uuid, a device filter, or system IDs.
Aug 28 15:25:29 hv1.ewheeler.net dmeventd[886522]: WARNING: VG name data is used by VGs R1oDQS-JP4G-cNFe-3EwV-kk2Z-KZou-w3uisW and 9UEiuo-DYzj-UTLi-XYCi-KiBO-wQi2-w5QUtX.
Aug 28 15:25:29 hv1.ewheeler.net dmeventd[886522]: Fix duplicate VG names with vgrename uuid, a device filter, or system IDs.
Aug 28 15:25:29 hv1.ewheeler.net dmeventd[886522]: WARNING: VG name data is used by VGs jcQyYa-dcCn-3nB6-iKYl-nI1n-EPr7-IHHWbs and 9UEiuo-DYzj-UTLi-XYCi-KiBO-wQi2-w5QUtX.
Aug 28 15:25:29 hv1.ewheeler.net dmeventd[886522]: Fix duplicate VG names with vgrename uuid, a device filter, or system IDs.
Aug 28 15:25:29 hv1.ewheeler.net dmeventd[886522]: WARNING: VG name data is used by VGs lPkJve-7oGk-6zcC-I2JL-nVuK-VY7d-Ar1pFK and 9UEiuo-DYzj-UTLi-XYCi-KiBO-wQi2-w5QUtX.
Aug 28 15:25:29 hv1.ewheeler.net dmeventd[886522]: Fix duplicate VG names with vgrename uuid, a device filter, or system IDs.
Aug 28 15:25:29 hv1.ewheeler.net dmeventd[886522]: WARNING: VG name data is used by VGs bAiQsf-Thbq-KPAU-Iykv-vmtr-AvwV-Ey078P and 9UEiuo-DYzj-UTLi-XYCi-KiBO-wQi2-w5QUtX.
Aug 28 15:25:29 hv1.ewheeler.net dmeventd[886522]: Fix duplicate VG names with vgrename uuid, a device filter, or system IDs.
Aug 28 15:25:29 hv1.ewheeler.net dmeventd[886522]: Multiple VGs found with the same name: skipping data 

== /etc/lvm/devices/system.devices ==
# LVM uses devices listed in this file.
# Created by LVM command lvs pid 2549 at Sat Sep 23 12:37:29 2023
VERSION=1.1.16
IDTYPE=sys_wwid IDNAME=naa.60027e370b5750002af3f68fd1e3b01c DEVNAME=/dev/sda3 PVID=HcTMIGPbMd2j1QrV84oKx6W402wzYAe9 PART=3
IDTYPE=md_uuid IDNAME=46faca15-b9b8-9393-120c-33d72c4de014 DEVNAME=/dev/md0 PVID=E1DCFhfN0D6vTnxnSMVOBkouNgNlVgvs
IDTYPE=devname IDNAME=/dev/bcache0 DEVNAME=/dev/bcache0 PVID=kZPEaDEk2Be2j05EgrBc05zjkrwEifeN
IDTYPE=lvmlv_uuid IDNAME=LVM-XSrtW65TBeE9rfMfGQZvDXAowpdkklsdZrCnfSeMxKo0eP10wdGtw66tHRXZfcfX DEVNAME=/dev/ssd/pv-tmeta PVID=w1LcofA64NPZakz45HPHAvuiw7YAs4P8

Running `pvs` shows only the volumes listed in system.devices, so that part works correctly:

0 [root at hv1:devices]# pvs
  PV                VG     Fmt  Attr PSize    PFree  
  /dev/bcache0      data   lvm2 a--    27.28t   1.02t
  /dev/md0          ssd    lvm2 a--  <953.73g <90.73g
  /dev/sda3         hv1    lvm2 a--   108.41g  97.41g
  /dev/ssd/pv-tmeta data   lvm2 a--   <49.86g  <4.86g


--
Eric Wheeler

