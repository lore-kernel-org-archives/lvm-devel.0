From: agk@sourceware.org <agk@sourceware.org>
Date: 8 May 2008 18:06:59 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20080508180659.13485.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-05-08 18:06:59

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Drop metadata cache before writing precommitted metadata instead of after.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.867&r2=1.868
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.174&r2=1.175

--- LVM2/WHATS_NEW	2008/04/30 14:34:02	1.867
+++ LVM2/WHATS_NEW	2008/05/08 18:06:58	1.868
@@ -1,9 +1,13 @@
-Version 2.02.37 - 
+Version 2.02.38 - 
 =================================
-  Don't touch /dev in vgrename if activation is disabled.
   Check lv_count in vg_validate.
   Add --prefixes to reporting tools for field name prefix output format.
 
+Version 2.02.37 - 
+=================================
+  Drop metadata cache before writing precommitted metadata instead of after.
+  Don't touch /dev in vgrename if activation is disabled.
+
 Version 2.02.36 - 29th April 2008
 =================================
   Fix fsadm.sh to work with older blockdev, blkid & readlink binaries.
--- LVM2/lib/metadata/metadata.c	2008/04/29 16:11:27	1.174
+++ LVM2/lib/metadata/metadata.c	2008/05/08 18:06:58	1.175
@@ -1278,6 +1278,11 @@
 		return 0;
 	}
 
+	if (!drop_cached_metadata(vg)) {
+		log_error("Unable to drop cached metadata for VG %s.", vg->name);
+		return 0;
+	}
+
 	vg->seqno++;
 
 	/* Write to each copy of the metadata area */
@@ -1343,11 +1348,6 @@
 		return cache_updated;
 	}
 
-	if (!drop_cached_metadata(vg)) {
-		log_error("Unable to drop cached metadata for VG %s.", vg->name);
-		return 0;
-	}
-
 	/* Commit to each copy of the metadata area */
 	list_iterate_items(mda, &vg->fid->metadata_areas) {
 		failed = 0;


