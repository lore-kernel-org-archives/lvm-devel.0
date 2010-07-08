From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Jul 2010 12:24:05 -0000
Subject: LVM2 lib/activate/activate.c ./WHATS_NEW
Message-ID: <20100708122405.556.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-07-08 12:24:04

Modified files:
	lib/activate   : activate.c 
	.              : WHATS_NEW 

Log message:
	Do not log backtrace in valid _lv_resume() code path

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.170&r2=1.171
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1658&r2=1.1659

--- LVM2/lib/activate/activate.c	2010/05/24 15:32:20	1.170
+++ LVM2/lib/activate/activate.c	2010/07/08 12:24:04	1.171
@@ -961,8 +961,10 @@
 		goto_out;
 
 	if (!info.exists || !info.suspended) {
-		r = error_if_not_active ? 0 : 1;
-		goto_out;
+		if (error_if_not_active)
+			goto_out;
+		r = 1;
+		goto out;
 	}
 
 	if (!_lv_activate_lv(lv))
--- LVM2/WHATS_NEW	2010/07/07 19:02:50	1.1658
+++ LVM2/WHATS_NEW	2010/07/08 12:24:04	1.1659
@@ -1,5 +1,7 @@
 Version 2.02.71 -
 ===============================
+  Do not log backtrace in valid _lv_resume() code path.
+  Cleanup help strings in configure.in.
   Prompt if metadataignore with vgextend or pvchange would adjust vg_mda_copies.
   Adjust vg_mda_copies if metadataignore given with vgextend or pvchange.
   Adjust auto-metadata repair and caching logic to try to cope with empty mdas.


