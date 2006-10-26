From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Oct 2006 18:22:11 -0000
Subject: LVM2 ./WHATS_NEW tools/lvcreate.c
Message-ID: <20061026182211.15667.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-10-26 18:22:10

Modified files:
	.              : WHATS_NEW 
	tools          : lvcreate.c 

Log message:
	When adding snapshot leave cow LV mapped device active after zeroing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.482&r2=1.483
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129

--- LVM2/WHATS_NEW	2006/10/24 19:07:32	1.482
+++ LVM2/WHATS_NEW	2006/10/26 18:22:10	1.483
@@ -1,5 +1,6 @@
 Version 2.02.13 -
 ===================================
+  When adding snapshot leave cow LV mapped device active after zeroing.
   Fix a clvmd debug message.
   Add dev_flush() to set_lv().
   Add lvchange --resync.
--- LVM2/tools/lvcreate.c	2006/10/18 18:01:53	1.128
+++ LVM2/tools/lvcreate.c	2006/10/26 18:22:10	1.129
@@ -761,13 +761,14 @@
 		return 0;
 	}
 
-	if (!activate_lv(cmd, lv)) {
-		if (lp->snapshot)
-			/* FIXME Remove the failed lv we just added */
+	if (lp->snapshot) {
+		if (!activate_lv_excl(cmd, lv)) {
 			log_error("Aborting. Failed to activate snapshot "
 				  "exception store. Remove new LV and retry.");
-		else
-			log_error("Failed to activate new LV.");
+			return 0;
+		}
+	} else if (!activate_lv(cmd, lv)) {
+		log_error("Failed to activate new LV.");
 		return 0;
 	}
 
@@ -787,10 +788,8 @@
 		/* Reset permission after zeroing */
 		if (!(lp->permission & LVM_WRITE))
 			lv->status &= ~LVM_WRITE;
-		if (!deactivate_lv(cmd, lv)) {
-			log_err("Couldn't deactivate new snapshot.");
-			return 0;
-		}
+
+		/* cow LV remains active and becomes snapshot LV */
 
 		if (!vg_add_snapshot(vg->fid, NULL, org, lv, NULL,
 				     org->le_count, lp->chunk_size)) {


