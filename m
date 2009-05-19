From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 19 May 2009 09:51:03 -0000
Subject: LVM2 ./WHATS_NEW test/t-pvmove-basic.sh tools/ ...
Message-ID: <20090519095103.29853.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-19 09:51:03

Modified files:
	.              : WHATS_NEW 
	test           : t-pvmove-basic.sh 
	tools          : pvmove.c 

Log message:
	If pvmove fails activating mirror volume, try restore to previous state.
	
	pvmove now keep suspended devices if temporary mirror creation fails.
	
	We can try to restore previous state if it is first attempt to activate
	pvmove (code basically run the same code as --abort automatically).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1113&r2=1.1114
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvmove-basic.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59

--- LVM2/WHATS_NEW	2009/05/19 09:48:32	1.1113
+++ LVM2/WHATS_NEW	2009/05/19 09:51:02	1.1114
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Fix pvmove to revert operation if temporary mirror creation fails.
   Fix metadata export for VG with missing PVs.
   Add vgimportclone and install it and the man page by default.
   Force max_lv restriction only for newly created LV.
--- LVM2/test/t-pvmove-basic.sh	2008/11/10 12:41:52	1.4
+++ LVM2/test/t-pvmove-basic.sh	2009/05/19 09:51:03	1.5
@@ -370,3 +370,8 @@
 lvcreate -l4 -n $lv1 $vg $dev1
 pvmove $dev1
 
+#COMM "pvmove fails activating mirror, properly restores state before pvmove"
+dmsetup create "$vg-pvmove0" --notable
+not pvmove -i 1 $dev2
+test $(dmsetup info --noheadings -c -o suspended "$vg-$lv1") = "Active"
+dmsetup remove "$vg-pvmove0"
--- LVM2/tools/pvmove.c	2009/05/13 21:28:31	1.58
+++ LVM2/tools/pvmove.c	2009/05/19 09:51:03	1.59
@@ -274,6 +274,10 @@
 	return activate_lv(cmd, lv_mirr);
 }
 
+static int _finish_pvmove(struct cmd_context *cmd, struct volume_group *vg,
+			  struct logical_volume *lv_mirr,
+			  struct dm_list *lvs_changed);
+
 static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 			    struct logical_volume *lv_mirr,
 			    struct dm_list *lvs_changed, unsigned flags)
@@ -315,12 +319,16 @@
 	/* FIXME: Add option to use a log */
 	if (first_time) {
 		if (!_activate_lv(cmd, lv_mirr, exclusive)) {
-			if (!test_mode())
-				log_error("ABORTING: Temporary mirror "
-					  "activation failed.  "
-					  "Run pvmove --abort.");
-			/* FIXME Resume using *original* metadata here! */
-			resume_lvs(cmd, lvs_changed);
+			if (test_mode())
+				goto out;
+
+			/*
+			 * Nothing changed yet, try to revert pvmove.
+			 */
+			log_error("Temporary pvmove mirror activation failed.");
+			if (!_finish_pvmove(cmd, vg, lv_mirr, lvs_changed))
+				log_error("ABORTING: Restoring original configuration "
+					  "before pvmove failed. Run pvmove --abort.");
 			goto out;
 		}
 	} else if (!resume_lv(cmd, lv_mirr)) {


