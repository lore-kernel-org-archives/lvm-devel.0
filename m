From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 13 Apr 2011 18:26:40 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf.in lib/metad ...
Message-ID: <20110413182640.13819.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2011-04-13 18:26:39

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf.in 
	lib/metadata   : pv_manip.c 
	man            : lvm.conf.5.in 

Log message:
	Improve the discard documentation.  Also improve discard code in
	pv_manip.c to properly account for case when pe_start=0 and the first
	physical extent is to be released (currently skip the first extent to
	avoid discarding the PV label).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1971&r2=1.1972
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_manip.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.in.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/WHATS_NEW	2011/04/12 21:59:01	1.1971
+++ LVM2/WHATS_NEW	2011/04/13 18:26:39	1.1972
@@ -1,7 +1,7 @@
 Version 2.02.85 - 
 ===================================
   Add "devices/issue_discards" to lvm.conf.
-  Issue discards on lvremove if enabled and both storage and kernel have support.
+  Issue discards on lvremove, lvreduce, etc if enabled and supported.
   Fix incorrect tests for dm_snprintf() failure.
   Fix some unmatching sign comparation gcc warnings in the code.
   Allow lv_extend() to work on zero length intrinsically layered LVs.
--- LVM2/doc/example.conf.in	2011/04/12 21:59:01	1.21
+++ LVM2/doc/example.conf.in	2011/04/13 18:26:39	1.22
@@ -152,11 +152,15 @@
     # pv_min_size = 2048
     pv_min_size = 512
 
-    # Issue discards to an LV's underlying PV(s) when the LV is removed.
-    # Discards inform the storage that a region is no longer in use.  If set
+    # Issue discards to a logical volumes's underlying physical volume(s) when
+    # the logical volume is no longer using the physical volumes' space (e.g.
+    # lvremove, lvreduce, etc).  Discards inform the storage that a region is
+    # no longer in use.  Storage that supports discards advertise the protocol
+    # specific way discards should be issued by the kernel (TRIM, UNMAP, or
+    # WRITE SAME with UNMAP bit set).  Not all storage will support or benefit
+    # from discards but SSDs and thinly provisioned LUNs generally do.  If set
     # to 1, discards will only be issued if both the storage and kernel provide
-    # support.  Not all storage will support or benefit from discards but SSDs
-    # or thinly provisioned LUNs generally do.
+    # support.
     # 1 enables; 0 disables.
     issue_discards = 0
 }
--- LVM2/lib/metadata/pv_manip.c	2011/04/12 22:04:04	1.30
+++ LVM2/lib/metadata/pv_manip.c	2011/04/13 18:26:39	1.31
@@ -191,9 +191,9 @@
 
 int release_pv_segment(struct pv_segment *peg, uint32_t area_reduction)
 {
-	uint64_t discard_offset;
+	uint64_t discard_offset_sectors;
 	uint64_t pe_start = peg->pv->pe_start;
-	uint32_t discard_area_reduction = area_reduction;
+	uint64_t discard_area_reduction = area_reduction;
 
 	if (!peg->lvseg) {
 		log_error("release_pv_segment with unallocated segment: "
@@ -209,16 +209,20 @@
 				  "devices/issue_discards", DEFAULT_ISSUE_DISCARDS) &&
 	    dev_discard_max_bytes(peg->pv->fmt->cmd->sysfs_dir, peg->pv->dev) &&
 	    dev_discard_granularity(peg->pv->fmt->cmd->sysfs_dir, peg->pv->dev)) {
-		if (!pe_start) {
-			/* skip the first extent */
-			pe_start = peg->pv->vg->extent_size;
+		discard_offset_sectors = (peg->pe + peg->lvseg->area_len - area_reduction) *
+			peg->pv->vg->extent_size + pe_start;
+		if (!discard_offset_sectors) {
+			/*
+			 * pe_start=0 and the PV's first extent contains the label.
+			 * Must skip past the first extent.
+			 */
+			discard_offset_sectors = peg->pv->vg->extent_size;
 			discard_area_reduction--;
 		}
-		discard_offset = peg->pe + peg->lvseg->area_len - area_reduction;
-		discard_offset = (discard_offset * peg->pv->vg->extent_size) + pe_start;
-		log_debug("Discarding %" PRIu32 " extents offset %" PRIu64 " sectors on %s.",
-			 discard_area_reduction, discard_offset, dev_name(peg->pv->dev));
-		if (!dev_discard_blocks(peg->pv->dev, discard_offset << SECTOR_SHIFT,
+		log_debug("Discarding %" PRIu64 " extents offset %" PRIu64 " sectors on %s.",
+			  discard_area_reduction, discard_offset_sectors, dev_name(peg->pv->dev));
+		if (discard_area_reduction &&
+		    !dev_discard_blocks(peg->pv->dev, discard_offset_sectors << SECTOR_SHIFT,
 					discard_area_reduction * peg->pv->vg->extent_size * SECTOR_SIZE))
 			return_0;
 	}
--- LVM2/man/lvm.conf.5.in	2011/04/12 21:59:02	1.19
+++ LVM2/man/lvm.conf.5.in	2011/04/13 18:26:39	1.20
@@ -181,11 +181,14 @@
 pv_min_size = 2048
 .IP
 \fBissue_discards\fP \(em
-Issue discards to an LV's underlying PV(s) when the LV is removed.  Discards
-inform the storage that a region is no longer in use.  If set to 1, discards will
-only be issued if both the storage and kernel provide support.  Not all storage
-will support or benefit from discards but SSDs or thinly provisioned LUNs
-generally do.
+Issue discards to a logical volumes's underlying physical volume(s) when the
+logical volume is no longer using the physical volumes' space (e.g. lvremove,
+lvreduce, etc).  Discards inform the storage that a region is no longer in use.
+Storage that supports discards advertise the protocol specific way discards
+should be issued by the kernel (TRIM, UNMAP, or WRITE SAME with UNMAP bit set).
+Not all storage will support or benefit from discards but SSDs and thinly
+provisioned LUNs generally do.  If set to 1, discards will only be issued if
+both the storage and kernel provide support.  
 .IP
 .TP
 \fBallocation\fP \(em Space allocation policies


