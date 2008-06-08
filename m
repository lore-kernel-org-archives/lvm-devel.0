From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Jun 2008 11:33:16 -0000
Subject: LVM2 lib/activate/activate.c ./WHATS_NEW
Message-ID: <20080608113316.15551.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-08 11:33:15

Modified files:
	lib/activate   : activate.c 
	.              : WHATS_NEW 

Log message:
	Revert assuming precommitted metadata is live when activating (unnecessary).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.136&r2=1.137
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.890&r2=1.891

--- LVM2/lib/activate/activate.c	2008/06/05 13:06:39	1.136
+++ LVM2/lib/activate/activate.c	2008/06/08 11:33:15	1.137
@@ -993,11 +993,7 @@
 	if (!activation())
 		goto activate;
 
-	/*
-	 * If we're activating and precommitted metadata is still cached,
-	 * we assume it matches the new live metadata.
-	 */
-	if (!(lv = lv_from_lvid(cmd, lvid_s, 1)))
+	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
 		return 0;
 
 	if (!_passes_activation_filter(cmd, lv)) {
@@ -1022,11 +1018,7 @@
 	if (!activation())
 		return 1;
 
-	/*
-	 * If we're activating and precommitted metadata is still cached,
-	 * we assume it matches the new live metadata.
-	 */
-	if (!(lv = lv_from_lvid(cmd, lvid_s, 1)))
+	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
 		return 0;
 
 	if (filter && !_passes_activation_filter(cmd, lv)) {
--- LVM2/WHATS_NEW	2008/06/06 19:32:35	1.890
+++ LVM2/WHATS_NEW	2008/06/08 11:33:15	1.891
@@ -1,5 +1,6 @@
 Version 2.02.38 - 
 =================================
+  Revert assuming precommitted metadata is live when activating (unnecessary).
   Drop cached metadata for disappearing VG in vgmerge.
   In script-processing mode, stop if any command fails.
   Warn if command exits with non-zero status code without a prior log_error.


