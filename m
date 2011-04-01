From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 1 Apr 2011 13:44:52 -0000
Subject: LVM2/liblvm lvm_vg.c
Message-ID: <20110401134452.31221.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-04-01 13:44:51

Modified files:
	liblvm         : lvm_vg.c 

Log message:
	Finalize PV format instances properly in lvm_vg_write fn.
	
	lvm_vg_write fn reinitializes the vg->removed_pvs list. We have to finalize
	all PV format instances attached to PVs found in the original list.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52

--- LVM2/liblvm/lvm_vg.c	2011/02/18 14:47:30	1.51
+++ LVM2/liblvm/lvm_vg.c	2011/04/01 13:44:51	1.52
@@ -147,6 +147,7 @@
 	if (! dm_list_empty(&vg->removed_pvs)) {
 		dm_list_iterate_items(pvl, &vg->removed_pvs) {
 			pv_write_orphan(vg->cmd, pvl->pv);
+			pv_set_fid(pvl->pv, NULL);
 			/* FIXME: do pvremove / label_remove()? */
 		}
 		dm_list_init(&vg->removed_pvs);


