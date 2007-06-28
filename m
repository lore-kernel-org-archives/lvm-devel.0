From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 28 Jun 2007 17:59:35 -0000
Subject: LVM2 ./WHATS_NEW tools/vgsplit.c
Message-ID: <20070628175935.7684.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2007-06-28 17:59:34

Modified files:
	.              : WHATS_NEW 
	tools          : vgsplit.c 

Log message:
	Fix vgsplit if splitting all PVs from VG.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.642&r2=1.643
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31

--- LVM2/WHATS_NEW	2007/06/28 17:33:43	1.642
+++ LVM2/WHATS_NEW	2007/06/28 17:59:34	1.643
@@ -1,5 +1,6 @@
 Version 2.02.27 - 
 ================================
+  Fix vgsplit if splitting all PVs from VG.
   Fix lvmdiskscan volume reporting when run in the lvm shell
   Fix missing lvm_shell symbol in lvm2cmd library. (2.02.23)
   Add vg_status function and clean up vg->status in tools directory.
--- LVM2/tools/vgsplit.c	2007/06/15 22:16:55	1.30
+++ LVM2/tools/vgsplit.c	2007/06/28 17:59:34	1.31
@@ -320,7 +320,7 @@
 		goto error;
 
 	/* Split metadata areas and check if both vgs have at least one area */
-	if (!(vg_split_mdas(cmd, vg_from, vg_to))) {
+	if (!(vg_split_mdas(cmd, vg_from, vg_to)) && vg_from->pv_count) {
 		log_error("Cannot split: Nowhere to store metadata for new Volume Group");
 		goto error;
 	}
@@ -344,10 +344,12 @@
 	backup(vg_to);
 
 	/* Write out updated old VG */
-	if (!vg_write(vg_from) || !vg_commit(vg_from))
-		goto error;
+	if (vg_from->pv_count) {
+		if (!vg_write(vg_from) || !vg_commit(vg_from))
+			goto error;
 
-	backup(vg_from);
+		backup(vg_from);
+	}
 
 	/* Remove EXPORTED flag from new VG */
 	consistent = 1;


