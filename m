From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 09:02:36 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20120125090236.28846.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 09:02:35

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Thin check for lv_thin_pool_percent error status
	
	Check has been missing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.349&r2=1.350

--- LVM2/lib/metadata/lv_manip.c	2012/01/25 08:57:25	1.349
+++ LVM2/lib/metadata/lv_manip.c	2012/01/25 09:02:35	1.350
@@ -4340,9 +4340,13 @@
 	init_dmeventd_monitor(lp->activation_monitoring);
 
 	if (seg_is_thin(lp)) {
-		/* For thin snapshot suspend active thin origin first */
+		/* For snapshot, suspend active thin origin first */
 		if (org && lv_is_active(org)) {
-			lv_thin_pool_percent(first_seg(org)->pool_lv, 0, &percent);
+			/* Check if the pool is bellow threshold (Works only for active thin) */
+			if (!lv_thin_pool_percent(first_seg(org)->pool_lv, 0, &percent)) {
+				stack;
+				goto revert_new_lv;
+			}
 			percent /= PERCENT_1;
 			if (percent >= (find_config_tree_int(cmd, "activation/thin_pool_autoextend_threshold",
 							     DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD))) {


