From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Sep 2011 10:39:48 -0000
Subject: LVM2 ./WHATS_NEW test/t-fsadm.sh tools/lvresize.c
Message-ID: <20110921103948.18576.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-21 10:39:47

Modified files:
	.              : WHATS_NEW 
	test           : t-fsadm.sh 
	tools          : lvresize.c 

Log message:
	Add missing log_error() to lvresize command when fsadm tool fails
	
	Also add test case

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2124&r2=1.2125
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-fsadm.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.137&r2=1.138

--- LVM2/WHATS_NEW	2011/09/19 19:36:52	1.2124
+++ LVM2/WHATS_NEW	2011/09/21 10:39:47	1.2125
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add missing log_error() to lvresize command when fsadm tool fails.
   Add support for DM_DEV_DIR device path into fsadm script.
   Support different PATH setting for fsadm script testing.
   Surround all executed commands with quotes in fsadm script.
--- LVM2/test/t-fsadm.sh	2011/09/19 19:37:26	1.8
+++ LVM2/test/t-fsadm.sh	2011/09/21 10:39:47	1.9
@@ -83,6 +83,7 @@
 	fscheck_ext3
 	mount $dev_vg_lv $mount_dir
 	not fsadm -y --lvresize resize $vg_lv 4M
+	echo n | not lvresize -L4M -r -n $vg_lv
 	lvresize -L+20M -r -n $vg_lv
 	umount $mount_dir
 	fscheck_ext3
--- LVM2/tools/lvresize.c	2011/09/15 18:51:11	1.137
+++ LVM2/tools/lvresize.c	2011/09/21 10:39:47	1.138
@@ -676,15 +676,15 @@
 		if (!lp->nofsck &&
 		    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_CHECK, &status)) {
 			if (status != FSADM_CHECK_FAILS_FOR_MOUNTED) {
-				stack;
+				log_error("Filesystem check failed.");
 				return ECMD_FAILED;
 			}
-                        /* some filesystems supports online resize */
+			/* some filesystems supports online resize */
 		}
 
 		if ((lp->resize == LV_REDUCE) &&
 		    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE, NULL)) {
-			stack;
+			log_error("Filesystem resize failed.");
 			return ECMD_FAILED;
 		}
 	}


