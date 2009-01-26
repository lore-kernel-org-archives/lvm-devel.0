From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Jan 2009 22:22:08 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20090126222208.26258.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-01-26 22:22:08

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Properly enforce cluster locking in as-yet-unused _vg_lock_and_read. (mornfall)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.198&r2=1.199

--- LVM2/lib/metadata/metadata.c	2009/01/26 22:13:22	1.198
+++ LVM2/lib/metadata/metadata.c	2009/01/26 22:22:07	1.199
@@ -2600,6 +2600,12 @@
 		goto_bad;
 	}
 
+	if (vg_is_clustered(vg) && !locking_is_clustered()) {
+		log_error("Skipping clustered volume group %s", vg->name);
+		failure |= FAILED_CLUSTERED;
+		goto_bad;
+	}
+
 	/* consistent == 0 when VG is not found, but failed == FAILED_NOTFOUND */
 	if (!consistent && !failure)
 		if (!(vg = _recover_vg(cmd, lock_name, vg_name, vgid, lock_flags))) {
@@ -2610,7 +2616,7 @@
 		}
 	
 
-	failure |= _vg_check_status(vg, status_flags);
+	failure |= _vg_check_status(vg, status_flags & ~CLUSTERED);
 	if (failure)
 		goto_bad;
 


