From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Jan 2012 15:39:42 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20120119153942.10748.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-19 15:39:41

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Thin disable snapshot creation when pool is over the threshold.
	
	Since snapshot needs to suspend origin - it might lead to pool userspace
	deadlock (as the pool will wait for new space in case it would be overfilled,
	but dmeventd would not be able to resize it, as the lvcreate operation would
	have kept the VG lock.)
	To minimize the risk of such scenario - we prevent to create new snapshot
	in case we are over the threshold - but beware, there is still small timewindow,
	so keep threshold at some reasonable level!

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.342&r2=1.343

--- LVM2/lib/metadata/lv_manip.c	2012/01/19 15:31:45	1.342
+++ LVM2/lib/metadata/lv_manip.c	2012/01/19 15:39:41	1.343
@@ -3996,6 +3996,7 @@
 	struct logical_volume *lv, *org = NULL;
 	struct logical_volume *pool_lv;
 	struct lv_list *lvl;
+	percent_t percent;
 	int origin_active = 0;
 	struct lvinfo info;
 
@@ -4315,6 +4316,14 @@
 	if (seg_is_thin(lp)) {
 		/* For thin snapshot suspend active thin origin first */
 		if (org && lv_is_active(org)) {
+			lv_thin_pool_percent(first_seg(org)->pool_lv, 0, &percent);
+			percent /= PERCENT_1;
+			if (percent >= (find_config_tree_int(cmd, "activation/thin_pool_autoextend_threshold",
+							     DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD))) {
+				log_error("Failed to create snapshot, pool is filled over "
+					  "the autoextend threshold (%d%%).", percent);
+				goto revert_new_lv;
+			}
 			if (!suspend_lv(cmd, org)) {
 				log_error("Failed to suspend thin origin %s.",
 					  org->name);


