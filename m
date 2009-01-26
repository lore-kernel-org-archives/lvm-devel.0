From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Jan 2009 22:43:00 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20090126224300.12986.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-01-26 22:43:00

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Replace internal vg_check_status() implementation.  (mornfall)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1029&r2=1.1030
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.199&r2=1.200

--- LVM2/WHATS_NEW	2009/01/26 19:01:32	1.1029
+++ LVM2/WHATS_NEW	2009/01/26 22:42:59	1.1030
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Replace internal vg_check_status() implementation.
   Rename vg_read() to vg_read_internal().
 
 Version 2.02.44 - 26th January 2009
--- LVM2/lib/metadata/metadata.c	2009/01/26 22:22:07	1.199
+++ LVM2/lib/metadata/metadata.c	2009/01/26 22:43:00	1.200
@@ -2377,7 +2377,14 @@
 	return 1;
 }
 
-static uint32_t _vg_check_status(const struct volume_group *vg, uint32_t status)
+/*
+ * Performs a set of checks against a VG according to bits set in status
+ * and returns FAILED_* bits for those that aren't acceptable.
+ *
+ * FIXME Remove the unnecessary duplicate definitions and return bits directly.
+ */
+static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
+				    uint32_t status)
 {
 	uint32_t failure = 0;
 
@@ -2414,38 +2421,10 @@
  * vg_check_status - check volume group status flags and log error
  * @vg - volume group to check status flags
  * @status - specific status flags to check (e.g. EXPORTED_VG)
- *
- * Returns:
- * 0 - fail
- * 1 - success
  */
 int vg_check_status(const struct volume_group *vg, uint32_t status)
 {
-	if ((status & CLUSTERED) &&
-	    (vg_is_clustered(vg)) && !locking_is_clustered() &&
-	    !lockingfailed()) {
-		log_error("Skipping clustered volume group %s", vg->name);
-		return 0;
-	}
-
-	if ((status & EXPORTED_VG) &&
-	    (vg->status & EXPORTED_VG)) {
-		log_error("Volume group %s is exported", vg->name);
-		return 0;
-	}
-
-	if ((status & LVM_WRITE) &&
-	    !(vg->status & LVM_WRITE)) {
-		log_error("Volume group %s is read-only", vg->name);
-		return 0;
-	}
-	if ((status & RESIZEABLE_VG) &&
-	    !(vg->status & RESIZEABLE_VG)) {
-		log_error("Volume group %s is not resizeable.", vg->name);
-		return 0;
-	}
-
-	return 1;
+	return !_vg_bad_status_bits(vg, status);
 }
 
 /*
@@ -2616,7 +2595,7 @@
 		}
 	
 
-	failure |= _vg_check_status(vg, status_flags & ~CLUSTERED);
+	failure |= _vg_bad_status_bits(vg, status_flags & ~CLUSTERED);
 	if (failure)
 		goto_bad;
 


