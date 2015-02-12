From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 12 Feb 2015 12:46:34 +0000 (UTC)
Subject: master - toollib: process_each_pv: use cmd->full_filter, not cmd->filter if we're getting full list of PV-capable devices (not just PVs)
Message-ID: <20150212124634.AF5FD60E04@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e52c998c490a4895fb7decfcde462455a68dc8e5
Commit:        e52c998c490a4895fb7decfcde462455a68dc8e5
Parent:        d38d047eecc16fdcaab7e7452ac68d673afdf674
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 12 13:36:05 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Feb 12 13:46:11 2015 +0100

toollib: process_each_pv: use cmd->full_filter, not cmd->filter if we're getting full list of PV-capable devices (not just PVs)

When lvmetad is used and at the same time we're getting list of all
PV-capable devices, we can't use cmd->filter (which is used to filter
out lvmetad responses - so we're sure that the devices are PVs already).

To get the list of PV-capable devices, we're bypassing lvmetad (since
lvmetad only caches PVs, not all the other devices which are not PVs).
For this reason, we have to use the "full_filter" filter chain (just
like we do when we're running without lvmetad).

Example scenario:
- sdo and sdp components of MD device md0
- sdq, sdr and sds components of mpatha multipath device
- mpatha multipath device partitioned
- vda device partitioned

=> sdo,sdp,sdr,sds, mpatha and vda should be filtered!

$ lsblk -o NAME,TYPE
NAME            TYPE
sdn             disk
sdo             disk
`-md0           raid0
sdp             disk
`-md0           raid0
sdq             disk
`-mpatha        mpath
  `-mpatha1     part
sdr             disk
`-mpatha        mpath
  `-mpatha1     part
sds             disk
`-mpatha        mpath
  `-mpatha1     part
vda             disk
|-vda1          part
`-vda2          part
  |-fedora-swap lvm
  `-fedora-root lvm

Before this patch:
==================
use_lvmetad=0 (correct behaviour!)
$ pvs -a
  PV                  VG     Fmt  Attr PSize PFree
  /dev/fedora/root                ---     0     0
  /dev/fedora/swap                ---     0     0
  /dev/mapper/mpatha1             ---     0     0
  /dev/md0                        ---     0     0
  /dev/sdn                        ---     0     0
  /dev/vda1                       ---     0     0
  /dev/vda2           fedora lvm2 a--  9.51g    0

use_lvmetad=1 (incorrect behaviour - sdo,sdp,sdq,sdr,sds and mpatha not filtered!)
$ pvs -a
  PV                  VG     Fmt  Attr PSize PFree
  /dev/fedora/root                ---     0     0
  /dev/fedora/swap                ---     0     0
  /dev/mapper/mpatha              ---     0     0
  /dev/mapper/mpatha1             ---     0     0
  /dev/md0                        ---     0     0
  /dev/sdn                        ---     0     0
  /dev/sdo                        ---     0     0
  /dev/sdp                        ---     0     0
  /dev/sdq                        ---     0     0
  /dev/sdr                        ---     0     0
  /dev/sds                        ---     0     0
  /dev/vda                        ---     0     0
  /dev/vda1                       ---     0     0
  /dev/vda2           fedora lvm2 a--  9.51g    0

With this patch applied:
========================
use_lvmetad=1
$ pvs -a
  PV                  VG     Fmt  Attr PSize PFree
  /dev/fedora/root                ---     0     0
  /dev/fedora/swap                ---     0     0
  /dev/mapper/mpatha1             ---     0     0
  /dev/md0                        ---     0     0
  /dev/sdn                        ---     0     0
  /dev/vda1                       ---     0     0
  /dev/vda2           fedora lvm2 a--  9.51g    0
---
 WHATS_NEW       |    1 +
 tools/toollib.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 99e0c08..7691649 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.117 - 
 ====================================
+  Fix pvs -a used with lvmetad to filter out devices unsuitable for PVs.
   Fix selection to recognize units for ba_start, vg_free and seg_start fields.
   Add support for -S/--select to vgexport and vgimport.
   Add support for -S/--select to vgdisplay, lvdisplay and pvdisplay without -C.
diff --git a/tools/toollib.c b/tools/toollib.c
index 410122c..6452605 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2339,7 +2339,7 @@ static int _get_all_devices(struct cmd_context *cmd, struct dm_list *all_devices
 
 	lvmcache_seed_infos_from_lvmetad(cmd);
 
-	if (!(iter = dev_iter_create(cmd->filter, 1))) {
+	if (!(iter = dev_iter_create(cmd->full_filter, 1))) {
 		log_error("dev_iter creation failed.");
 		return ECMD_FAILED;
 	}


