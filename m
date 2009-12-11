From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Dec 2009 13:11:57 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM tools/pvresize ...
Message-ID: <20091211131157.19255.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2009-12-11 13:11:56

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	tools          : pvresize.c toollib.c 

Log message:
	Fix unlocking vg in some pvresize and toollib error paths.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1350&r2=1.1351
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.321&r2=1.322
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.179&r2=1.180

--- LVM2/WHATS_NEW	2009/12/09 19:53:39	1.1350
+++ LVM2/WHATS_NEW	2009/12/11 13:11:56	1.1351
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Fix unlocking vg in some pvresize and toollib error paths.
   Explicitly call suspend for temporary mirror layer.
   Allow use precommited metadata when a PV is missing.
   Add memlock information to do_lock_lv debug output.
--- LVM2/WHATS_NEW_DM	2009/12/07 12:03:47	1.321
+++ LVM2/WHATS_NEW_DM	2009/12/11 13:11:56	1.322
@@ -1,5 +1,6 @@
 Version 1.02.41 -
 ====================================
+  Fix coredump and memory leak for 'dmsetup help -c'.
   Disable udev rules for change events with DISK_RO set.
 
 Version 1.02.40 - 19th November 2009
--- LVM2/tools/pvresize.c	2009/09/14 22:47:49	1.33
+++ LVM2/tools/pvresize.c	2009/12/11 13:11:56	1.34
@@ -60,8 +60,12 @@
 
 		vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 
-		if (vg_read_error(vg))
-			goto bad;
+		if (vg_read_error(vg)) {
+			vg_release(vg);
+			log_error("Unable to read volume group \"%s\".",
+				  vg_name);
+			return 0;
+		}
 
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
 			log_error("Unable to find \"%s\" in volume group \"%s\"",
--- LVM2/tools/toollib.c	2009/11/24 16:13:03	1.179
+++ LVM2/tools/toollib.c	2009/12/11 13:11:56	1.180
@@ -315,7 +315,7 @@
 						  dm_pool_strdup(cmd->mem,
 							      lv_name + 1))) {
 					log_error("strlist allocation failed");
-					vg_release(vg);
+					unlock_and_release_vg(cmd, vg, vgname);
 					return ECMD_FAILED;
 				}
 			}
@@ -367,8 +367,8 @@
 		if (!(pvl = find_pv_in_vg(vg, pv_dev_name(pv)))) {
 			 log_error("Unable to find %s in volume group %s",
 				   pv_dev_name(pv), vg_name);
-			vg_release(vg);
-			return ECMD_FAILED;
+			 unlock_and_release_vg(cmd, vg, vg_name);
+			 return ECMD_FAILED;
 		}
 
 		pv = pvl->pv;


