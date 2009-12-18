From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 18 Dec 2009 12:44:21 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20091218124421.2378.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-12-18 12:44:20

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Remove missing flag if PV reappeared and is empty.
	
	When PV device reappears with old metadata, it is
	always updated to new version byt atutomatic metadata
	repair.
	
	Remove missing flag if device is empty.
	
	If device contains allocated extents, issue warning that
	user must remove volumes and re-add this PV before
	manipulating with this volume.
	
	This partially solves bug 547842 when one PV (log) is failed,
	dmeventd removes that device and later this device reappears and
	is wrongly added into VG marked missing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1352&r2=1.1353
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.304&r2=1.305

--- LVM2/WHATS_NEW	2009/12/11 13:14:44	1.1352
+++ LVM2/WHATS_NEW	2009/12/18 12:44:20	1.1353
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Remove missing flag in metadata if PV reappeared and is empty.
   Destroy allocated mempool in _vg_read_orphans() error path.
   Fix unlocking vg in some pvresize and toollib error paths.
   Explicitly call suspend for temporary mirror layer.
--- LVM2/lib/metadata/metadata.c	2009/12/16 19:26:20	1.304
+++ LVM2/lib/metadata/metadata.c	2009/12/18 12:44:20	1.305
@@ -2457,6 +2457,25 @@
 	return ret;
 }
 
+static void check_reappeared_pv(struct volume_group *correct_vg,
+				struct physical_volume *pv)
+{
+	struct pv_list *pvl;
+
+	dm_list_iterate_items(pvl, &correct_vg->pvs)
+		if (pv->dev == pvl->pv->dev && pvl->pv->status & MISSING_PV) {
+			log_warn("Missing device %s reappeared, updating "
+				 "metadata for VG %s to version %u.",
+				 pv_dev_name(pvl->pv),  pv_vg_name(pvl->pv), 
+				 correct_vg->seqno);
+			if (pvl->pv->pe_alloc_count == 0) {
+				pv->status &= ~MISSING_PV;
+				pvl->pv->status &= ~MISSING_PV;
+			} else
+				log_warn("Device still marked missing because of alocated data "
+					 "on it, remove volumes and consider vgreduce --removemissing.");
+		}
+}
 /* Caller sets consistent to 1 if it's safe for vg_read_internal to correct
  * inconsistent metadata on disk (i.e. the VG write lock is held).
  * This guarantees only consistent metadata is returned.
@@ -2737,6 +2756,13 @@
 		log_warn("WARNING: Inconsistent metadata found for VG %s - updating "
 			 "to use version %u", vgname, correct_vg->seqno);
 
+		/*
+		 * If PV is marked missing but we found it,
+		 * update metadata and remove MISSING flag
+		 */
+		dm_list_iterate_items(pvl, &all_pvs)
+			check_reappeared_pv(correct_vg, pvl->pv);
+
 		cmd->handles_missing_pvs = 1;
 		if (!vg_write(correct_vg)) {
 			log_error("Automatic metadata correction failed");


