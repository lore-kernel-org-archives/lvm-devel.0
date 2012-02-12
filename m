From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Feb 2012 21:42:43 -0000
Subject: LVM2/lib/metadata thin_manip.c
Message-ID: <20120212214243.20680.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-12 21:42:43

Modified files:
	lib/metadata   : thin_manip.c 

Log message:
	use stack consistently if 0 is considered an error

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/lib/metadata/thin_manip.c	2012/02/08 13:05:39	1.33
+++ LVM2/lib/metadata/thin_manip.c	2012/02/12 21:42:43	1.34
@@ -225,22 +225,18 @@
 				     DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD);
 
 	/* Data */
-	if (!lv_thin_pool_percent(pool_seg->lv, 0, &percent)) {
-		stack;
-		return 0;
-	}
+	if (!lv_thin_pool_percent(pool_seg->lv, 0, &percent))
+		return_0;
 
 	if (percent >= threshold)
-		return 0;
+		return_0;
 
 	/* Metadata */
-	if (!lv_thin_pool_percent(pool_seg->lv, 1, &percent)) {
-		stack;
-		return 0;
-	}
+	if (!lv_thin_pool_percent(pool_seg->lv, 1, &percent))
+		return_0;
 
 	if (percent >= threshold)
-		return 0;
+		return_0;
 
 	return 1;
 }


