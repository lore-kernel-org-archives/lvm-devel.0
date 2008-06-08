From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Jun 2008 14:18:45 -0000
Subject: LVM2 lib/metadata/metadata.c ./WHATS_NEW
Message-ID: <20080608141845.11431.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-08 14:18:45

Modified files:
	lib/metadata   : metadata.c 
	.              : WHATS_NEW 

Log message:
	Tweak detection of invalid fid after changes to PVs in VG in _vg_read.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.180&r2=1.181
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.891&r2=1.892

--- LVM2/lib/metadata/metadata.c	2008/06/06 19:28:34	1.180
+++ LVM2/lib/metadata/metadata.c	2008/06/08 14:18:44	1.181
@@ -1531,16 +1531,16 @@
 	if (use_precommitted && !(fmt->features & FMT_PRECOMMIT))
 		use_precommitted = 0;
 
-	/* Store pvids for later so we can check if any are missing */
-	if (!(pvids = lvmcache_get_pvids(cmd, vgname, vgid)))
-		return_NULL;
-
 	/* create format instance with appropriate metadata area */
 	if (!(fid = fmt->ops->create_instance(fmt, vgname, vgid, NULL))) {
 		log_error("Failed to create format instance");
 		return NULL;
 	}
 
+	/* Store pvids for later so we can check if any are missing */
+	if (!(pvids = lvmcache_get_pvids(cmd, vgname, vgid)))
+		return_NULL;
+
 	/* Ensure contents of all metadata areas match - else do recovery */
 	list_iterate_items(mda, &fid->metadata_areas) {
 		if ((use_precommitted &&
--- LVM2/WHATS_NEW	2008/06/08 11:33:15	1.891
+++ LVM2/WHATS_NEW	2008/06/08 14:18:44	1.892
@@ -1,5 +1,6 @@
 Version 2.02.38 - 
 =================================
+  Tweak detection of invalid fid after changes to PVs in VG in _vg_read.
   Revert assuming precommitted metadata is live when activating (unnecessary).
   Drop cached metadata for disappearing VG in vgmerge.
   In script-processing mode, stop if any command fails.


