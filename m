From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Nov 2007 21:59:11 -0000
Subject: LVM2 ./WHATS_NEW tools/lvmcmdline.c tools/vgsp ...
Message-ID: <20071115215911.9602.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-15 21:59:11

Modified files:
	.              : WHATS_NEW 
	tools          : lvmcmdline.c vgsplit.c 

Log message:
	Fix --addtag to drop @ prefix from name

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.737&r2=1.738
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41

--- LVM2/WHATS_NEW	2007/11/15 10:16:14	1.737
+++ LVM2/WHATS_NEW	2007/11/15 21:59:10	1.738
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Fix --addtag to drop @ prefix from name.
   Stop clvmd going haywire if a pre_function fails.
   Convert some vg_reads into vg_lock_and_reads.
   Avoid nested vg_reads when processing PVs in VGs and fix associated locking.
--- LVM2/tools/lvmcmdline.c	2007/11/14 00:08:25	1.55
+++ LVM2/tools/lvmcmdline.c	2007/11/15 21:59:11	1.56
@@ -333,6 +333,8 @@
 	if (!validate_name(pos))
 		return 0;
 
+	a->value = pos;
+
 	return 1;
 }
 
--- LVM2/tools/vgsplit.c	2007/11/15 02:53:49	1.40
+++ LVM2/tools/vgsplit.c	2007/11/15 21:59:11	1.41
@@ -243,6 +243,7 @@
 	if ((vg_to = vg_lock_and_read(cmd, vg_name_to, NULL,
 				      LCK_VG_WRITE | LCK_NONBLOCK,
 				      0, 0))) {
+		/* FIXME Remove this restriction */
 		log_error("Volume group \"%s\" already exists", vg_name_to);
 		unlock_vg(cmd, vg_name_from);
 		return ECMD_FAILED;


