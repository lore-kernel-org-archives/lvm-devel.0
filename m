From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Jun 2008 19:32:37 -0000
Subject: LVM2 ./WHATS_NEW tools/vgmerge.c
Message-ID: <20080606193237.24394.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-06 19:32:36

Modified files:
	.              : WHATS_NEW 
	tools          : vgmerge.c 

Log message:
	Drop cached metadata for disappearing VG in vgmerge.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.889&r2=1.890
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/WHATS_NEW	2008/06/06 19:28:33	1.889
+++ LVM2/WHATS_NEW	2008/06/06 19:32:35	1.890
@@ -1,5 +1,6 @@
 Version 2.02.38 - 
 =================================
+  Drop cached metadata for disappearing VG in vgmerge.
   In script-processing mode, stop if any command fails.
   Warn if command exits with non-zero status code without a prior log_error.
   Check lv_count in vg_validate.
--- LVM2/tools/vgmerge.c	2008/04/23 12:53:10	1.48
+++ LVM2/tools/vgmerge.c	2008/06/06 19:32:35	1.49
@@ -49,6 +49,8 @@
 	if (!archive(vg_from) || !archive(vg_to))
 		goto_bad;
 
+	drop_cached_metadata(vg_from);
+
 	/* Merge volume groups */
 	while (!list_empty(&vg_from->pvs)) {
 		struct list *pvh = vg_from->pvs.n;


