From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 25 Feb 2011 14:08:58 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c ...
Message-ID: <20110225140858.644.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-25 14:08:55

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 
	lib/metadata   : metadata.c 

Log message:
	Allow only orphan PVs to be resized even with two metadata areas.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1925&r2=1.1926
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.168&r2=1.169
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.435&r2=1.436

--- LVM2/WHATS_NEW	2011/02/25 14:02:53	1.1925
+++ LVM2/WHATS_NEW	2011/02/25 14:08:54	1.1926
@@ -2,7 +2,7 @@
 ===================================
   Fix metadata balance code to work with recent changes in metadata handling.
   Add old_uuid field to physical_volume and fix pvchange -u for recent changes.
-  Allow pvresize on a PV with two metadata areas.
+  Allow pvresize on a PV with two metadata areas (for PVs not in a VG).
   Change pvcreate to use new metadata handling interface.
   Restructure existing pv_setup and pv_write fn, add pv_initialise fn.
   Add internal interface to support adding and removing metadata areas.
--- LVM2/lib/format_text/format-text.c	2011/02/25 13:59:47	1.168
+++ LVM2/lib/format_text/format-text.c	2011/02/25 14:08:55	1.169
@@ -2161,6 +2161,17 @@
 	/* If there's an mda at the end, move it to a new position. */
 	if ((mda = fid_get_mda_indexed(fid, pvid, ID_LEN, 1)) &&
 	    (mdac = mda->metadata_locn)) {
+		/*
+		 * FIXME: Remove this restriction - we need to
+		 *        allow writing PV labels on non-orphan VGs
+		 *        for this to work correctly.
+		 */
+		if (vg) {
+			log_error("Resizing a PV with two metadata areas "
+				  "that is part of a VG is not supported.");
+			return 0;
+		}
+
 		/* FIXME: Maybe MDA0 size would be better? */
 		mda_size = mdac->area.size >> SECTOR_SHIFT;
 		mda_ignored = mda_is_ignored(mda);
--- LVM2/lib/metadata/metadata.c	2011/02/25 14:02:54	1.435
+++ LVM2/lib/metadata/metadata.c	2011/02/25 14:08:55	1.436
@@ -3543,6 +3543,12 @@
 		return 0;
 	}
 
+	/*
+	 * FIXME: Try to remove this restriction. This requires checking
+	 *        that the PV and the VG are in a consistent state. We need
+	 *        to provide some revert mechanism since PV label together
+	 *        with VG metadata write is not atomic.
+	 */
 	if (!is_orphan_vg(pv->vg_name) || pv->pe_alloc_count) {
 		log_error("Assertion failed: can't _pv_write non-orphan PV "
 			  "(in VG %s)", pv->vg_name);


