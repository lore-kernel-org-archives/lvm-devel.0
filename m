From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 23 Oct 2006 11:46:17 -0000
Subject: LVM2 ./WHATS_NEW tools/lvremove.c
Message-ID: <20061023114617.11262.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2006-10-23 11:46:16

Modified files:
	.              : WHATS_NEW 
	tools          : lvremove.c 

Log message:
	Don't allow a node to remove an LV that's exclusively active on anther node.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.476&r2=1.477
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvremove.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/WHATS_NEW	2006/10/21 23:18:43	1.476
+++ LVM2/WHATS_NEW	2006/10/23 11:46:15	1.477
@@ -1,5 +1,6 @@
 Version 2.02.13 -
 ===================================
+  Don't allow a node to remove an LV that's exclusively active on anther node.
   Cope if same PV is included more than once in cmdline PE range list.
   Set PV size to current device size if it is found to be zero.
   Add segment parameter to target_present functions.
--- LVM2/tools/lvremove.c	2006/05/09 21:23:51	1.48
+++ LVM2/tools/lvremove.c	2006/10/23 11:46:16	1.49
@@ -75,6 +75,16 @@
 	if (!archive(vg))
 		return ECMD_FAILED;
 
+	/* If the VG is clustered then make sure no-one else is using the LV
+	   we are about to remove */
+	if (vg->status & CLUSTERED) {
+		if (!activate_lv_excl(cmd, lv)) {
+			log_error("Can't get exclusive access to volume \"%s\"",
+				  lv->name);
+			return ECMD_FAILED;
+		}
+	}
+
 	/* FIXME Snapshot commit out of sequence if it fails after here? */
 	if (!deactivate_lv(cmd, lv)) {
 		log_error("Unable to deactivate logical volume \"%s\"",


