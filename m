From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 20 Jan 2012 21:56:01 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20120120215601.25088.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2012-01-20 21:56:01

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Lookup snapshot usage percent of origin when a snapshot is merging.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2228&r2=1.2229
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.261&r2=1.262

--- LVM2/WHATS_NEW	2012/01/20 16:59:58	1.2228
+++ LVM2/WHATS_NEW	2012/01/20 21:56:01	1.2229
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Lookup snapshot usage percent of origin when a snapshot is merging.
   Update lvdisplay with backward compat. config opt. lvm1_compatible_display.
   Do not report linear segtype for non-striped targets.
   Keep info about creation host and time for each logical volume.
--- LVM2/lib/activate/dev_manager.c	2012/01/19 15:27:54	1.261
+++ LVM2/lib/activate/dev_manager.c	2012/01/20 21:56:01	1.262
@@ -742,6 +742,7 @@
 				 const struct logical_volume *lv,
 				 percent_t *percent)
 {
+	const struct logical_volume *snap_lv;
 	char *name;
 	const char *dlid;
 	int fail_if_percent_unsupported = 0;
@@ -761,13 +762,19 @@
 		fail_if_percent_unsupported = 1;
 	}
 
+	if (lv_is_merging_cow(lv)) {
+		/* must check percent of origin for a merging snapshot */
+		snap_lv = origin_from_cow(lv);
+	} else
+		snap_lv = lv;
+
 	/*
 	 * Build a name for the top layer.
 	 */
-	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, NULL)))
+	if (!(name = dm_build_dm_name(dm->mem, snap_lv->vg->name, snap_lv->name, NULL)))
 		return_0;
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, NULL)))
+	if (!(dlid = build_dm_uuid(dm->mem, snap_lv->lvid.s, NULL)))
 		return_0;
 
 	/*


