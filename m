From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Oct 2010 16:28:18 -0000
Subject: LVM2 daemons/dmeventd/plugins/snapshot/dmevent ...
Message-ID: <20101015162818.18715.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-15 16:28:16

Modified files:
	daemons/dmeventd/plugins/snapshot: dmeventd_snapshot.c 
	doc            : example.conf.in 
	lib/config     : defaults.h 
	test           : test-utils.sh 
	tools          : commands.h lvresize.c 
Added files:
	test           : t-lvextend-snapshot-dmeventd.sh 
	                 t-lvextend-snapshot-policy.sh 

Log message:
	Implement automatic snapshot extension with dmeventd, and add two new options
	to lvm.conf in the activation section: 'snapshot_autoextend_threshold' and
	'snapshot_autoextend_percent', that define how to handle automatic snapshot
	extension. The former defines when the snapshot should be extended: when its
	space usage exceeds this many percent. The latter defines how much extra space
	should be allocated for the snapshot, in percent of its current size.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvextend-snapshot-dmeventd.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvextend-snapshot-policy.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.155&r2=1.156
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.123&r2=1.124

--- LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2010/07/09 15:34:41	1.10
+++ LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2010/10/15 16:28:14	1.11
@@ -26,8 +26,10 @@
 
 /* First warning when snapshot is 80% full. */
 #define WARNING_THRESH 80
-/* Further warnings at 85%, 90% and 95% fullness. */
-#define WARNING_STEP 5
+/* Run a check every 5%. */
+#define CHECK_STEP 5
+/* Do not bother checking snapshots less than 50% full. */
+#define CHECK_MINIMUM 50
 
 struct snap_status {
 	int invalid;
@@ -69,6 +71,28 @@
 	status->max = atoi(p);
 }
 
+static int _extend(const char *device)
+{
+	char *vg = NULL, *lv = NULL, *layer = NULL;
+	char cmd_str[1024];
+	int r = 0;
+
+	if (!dm_split_lvm_name(dmeventd_lvm2_pool(), device, &vg, &lv, &layer)) {
+		syslog(LOG_ERR, "Unable to determine VG name from %s.", device);
+		return 0;
+	}
+	if (sizeof(cmd_str) <= snprintf(cmd_str, sizeof(cmd_str),
+					"lvextend --use-policies %s/%s", vg, lv)) {
+		syslog(LOG_ERR, "Unable to form LVM command: Device name too long.");
+		return 0;
+	}
+
+	r = dmeventd_lvm2_run(cmd_str);
+	syslog(LOG_INFO, "Extension of snapshot %s/%s %s.", vg, lv,
+	       (r == ECMD_PROCESSED) ? "finished successfully" : "failed");
+	return r == ECMD_PROCESSED;
+}
+
 void process_event(struct dm_task *dmt,
 		   enum dm_event_mask event __attribute__((unused)),
 		   void **private)
@@ -79,10 +103,10 @@
 	char *params;
 	struct snap_status status = { 0 };
 	const char *device = dm_task_get_name(dmt);
-	int percent, *percent_warning = (int*)private;
+	int percent, *percent_check = (int*)private;
 
 	/* No longer monitoring, waiting for remove */
-	if (!*percent_warning)
+	if (!*percent_check)
 		return;
 
 	dmeventd_lvm2_lock();
@@ -92,21 +116,27 @@
 		goto out;
 
 	_parse_snapshot_params(params, &status);
+
 	/*
 	 * If the snapshot has been invalidated or we failed to parse
 	 * the status string. Report the full status string to syslog.
 	 */
 	if (status.invalid || !status.max) {
 		syslog(LOG_ERR, "Snapshot %s changed state to: %s\n", device, params);
-		*percent_warning = 0;
+		*percent_check = 0;
 		goto out;
 	}
 
 	percent = 100 * status.used / status.max;
-	if (percent >= *percent_warning) {
-		syslog(LOG_WARNING, "Snapshot %s is now %i%% full.\n", device, percent);
-		/* Print warning on the next multiple of WARNING_STEP. */
-		*percent_warning = (percent / WARNING_STEP) * WARNING_STEP + WARNING_STEP;
+	if (percent >= *percent_check) {
+		/* Usage has raised more than CHECK_STEP since the last
+		   time. Run actions. */
+		*percent_check = (percent / CHECK_STEP) * CHECK_STEP + CHECK_STEP;
+		if (percent >= WARNING_THRESH) /* Print a warning to syslog. */
+			syslog(LOG_WARNING, "Snapshot %s is now %i%% full.\n", device, percent);
+		/* Try to extend the snapshot, in accord with user-set policies */
+		if (!_extend(device))
+			syslog(LOG_ERR, "Failed to extend snapshot %s.", device);
 	}
 out:
 	dmeventd_lvm2_unlock();
@@ -118,10 +148,10 @@
 		    int minor __attribute__((unused)),
 		    void **private)
 {
-	int *percent_warning = (int*)private;
+	int *percent_check = (int*)private;
 	int r = dmeventd_lvm2_init();
 
-	*percent_warning = WARNING_THRESH; /* Print warning if snapshot is full */
+	*percent_check = CHECK_MINIMUM;
 
 	syslog(LOG_INFO, "Monitoring snapshot %s\n", device);
 	return r;
--- LVM2/doc/example.conf.in	2010/10/15 16:24:00	1.14
+++ LVM2/doc/example.conf.in	2010/10/15 16:28:15	1.15
@@ -428,6 +428,25 @@
     mirror_log_fault_policy = "allocate"
     mirror_image_fault_policy = "remove"
 
+    # 'snapshot_autoextend_threshold' and 'snapshot_autoextend_percent' define
+    # how to handle automatic snapshot extension. The former defines when the
+    # snapshot should be extended: when its space usage exceeds this many
+    # percent. The latter defines how much extra space should be allocated for
+    # the snapshot, in percent of its current size.
+    #
+    # For example, if you set snapshot_autoextend_threshold to 70 and
+    # snapshot_autoextend_percent to 20, whenever a snapshot exceeds 70% usage,
+    # it will be extended by another 20%. For a 1G snapshot, using up 700M will
+    # trigger a resize to 1.2G. When the usage exceeds 840M, the snapshot will
+    # be extended to 1.44G, and so on.
+    #
+    # Setting snapshot_autoextend_threshold to 100 disables automatic
+    # extensions. The minimum value is 50 (A setting below 50 will be treated
+    # as 50).
+
+    snapshot_autoextend_threshold = 100
+    snapshot_autoextend_percent = 20
+
     # While activating devices, I/O to devices being (re)configured is
     # suspended, and as a precaution against deadlocks, LVM2 needs to pin
     # any memory it is using so it is not paged out.  Groups of pages that
--- LVM2/lib/config/defaults.h	2010/10/13 15:40:39	1.69
+++ LVM2/lib/config/defaults.h	2010/10/15 16:28:15	1.70
@@ -148,5 +148,7 @@
 
 #define DEFAULT_MIRROR_DEVICE_FAULT_POLICY "remove"
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
+#define DEFAULT_SNAPSHOT_AUTOEXTEND_THRESHOLD 100
+#define DEFAULT_SNAPSHOT_AUTOEXTEND_PERCENT 20
 
 #endif				/* _LVM_DEFAULTS_H */
/cvs/lvm2/LVM2/test/t-lvextend-snapshot-dmeventd.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvextend-snapshot-dmeventd.sh
+++ -	2010-10-15 16:28:17.556859000 +0000
@@ -0,0 +1,51 @@
+#!/bin/bash
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. ./test-utils.sh
+
+extend() {
+	lvextend --use-policies --config "activation { snapshot_extend_threshold = $1 }" $vg/snap
+}
+
+write() {
+	mount $DM_DEV_DIR/$vg/snap mnt
+	dd if=/dev/zero of=mnt/file$1 bs=1k count=$2
+	umount mnt
+}
+
+percent() {
+	lvs $vg/snap -o snap_percent --noheadings | cut -c4- | cut -d. -f1
+}
+
+which mkfs.ext2 || exit 200
+
+aux prepare_vg 2
+aux prepare_dmeventd
+
+lvcreate -l 8 -n base $vg
+mkfs.ext2 $DM_DEV_DIR/$vg/base
+
+lvcreate -s -l 4 -n snap $vg/base
+lvchange --monitor y $vg/snap
+
+mkdir mnt
+
+write 1 4096
+pre=`percent`
+sleep 10 # dmeventd only checks every 10 seconds :(
+post=`percent`
+
+test $pre = $post
+write 2 5000
+pre=`percent`
+sleep 10 # dmeventd only checks every 10 seconds :(
+post=`percent`
+test $pre -gt $post
/cvs/lvm2/LVM2/test/t-lvextend-snapshot-policy.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvextend-snapshot-policy.sh
+++ -	2010-10-15 16:28:17.692973000 +0000
@@ -0,0 +1,47 @@
+#!/bin/bash
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. ./test-utils.sh
+
+extend() {
+	lvextend --use-policies --config "activation { snapshot_extend_threshold = $1 }" $vg/snap
+}
+
+write() {
+	mount $DM_DEV_DIR/$vg/snap mnt
+	dd if=/dev/zero of=mnt/file$1 bs=1k count=$2
+	umount mnt
+}
+
+percent() {
+	lvs $vg/snap -o snap_percent --noheadings | cut -c4- | cut -d. -f1
+}
+
+which mkfs.ext2 || exit 200
+
+aux prepare_vg 2
+lvcreate -l 8 -n base $vg
+mkfs.ext2 $DM_DEV_DIR/$vg/base
+
+lvcreate -s -l 4 -n snap $vg/base
+mkdir mnt
+
+write 1 4096
+pre=`percent`
+extend 50
+post=`percent`
+
+test $pre = $post
+write 2 4096
+pre=`percent`
+extend 50
+post=`percent`
+test $pre -gt $post
--- LVM2/test/test-utils.sh	2010/10/12 16:13:43	1.51
+++ LVM2/test/test-utils.sh	2010/10/15 16:28:15	1.52
@@ -394,6 +394,8 @@
     udev_sync = 1
     udev_rules = 1
     polling_interval = 0
+    snapshot_autoextend_percent = 50
+    snapshot_autoextend_threshold = 50
   }
 EOF
 	# FIXME remove this workaround after mmap & truncating file problems solved
--- LVM2/tools/commands.h	2010/10/13 10:34:32	1.155
+++ LVM2/tools/commands.h	2010/10/15 16:28:16	1.156
@@ -259,6 +259,7 @@
    "\t{-l|--extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}] |\n"
    "\t -L|--size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-m|--mirrors Mirrors]\n"
+   "\t[--use-policies]\n"
    "\t[-n|--nofsck]\n"
    "\t[--noudevsync]\n"
    "\t[-r|--resizefs]\n"
@@ -270,7 +271,7 @@
 
    alloc_ARG, autobackup_ARG, extents_ARG, force_ARG, mirrors_ARG,
    nofsck_ARG, noudevsync_ARG, resizefs_ARG, size_ARG, stripes_ARG,
-   stripesize_ARG, test_ARG, type_ARG)
+   stripesize_ARG, test_ARG, type_ARG, use_policies_ARG)
 
 xx(lvmchange,
    "With the device mapper, this is obsolete and does nothing.",
--- LVM2/tools/lvresize.c	2010/08/17 16:25:35	1.123
+++ LVM2/tools/lvresize.c	2010/10/15 16:28:16	1.124
@@ -186,6 +186,7 @@
 	const char *cmd_name;
 	char *st;
 	unsigned dev_dir_found = 0;
+	int use_policy = arg_count(cmd, use_policies_ARG);
 
 	lp->sign = SIGN_NONE;
 	lp->resize = LV_ANY;
@@ -196,34 +197,41 @@
 	if (!strcmp(cmd_name, "lvextend"))
 		lp->resize = LV_EXTEND;
 
-	/*
-	 * Allow omission of extents and size if the user has given us
-	 * one or more PVs.  Most likely, the intent was "resize this
-	 * LV the best you can with these PVs"
-	 */
-	if ((arg_count(cmd, extents_ARG) + arg_count(cmd, size_ARG) == 0) &&
-	    (argc >= 2)) {
-		lp->extents = 100;
-		lp->percent = PERCENT_PVS;
+	if (use_policy) {
+		/* do nothing; _lvresize will handle --use-policies itself */
+		lp->extents = 0;
 		lp->sign = SIGN_PLUS;
-	} else if ((arg_count(cmd, extents_ARG) +
-		    arg_count(cmd, size_ARG) != 1)) {
-		log_error("Please specify either size or extents but not "
-			  "both.");
-		return 0;
-	}
-
-	if (arg_count(cmd, extents_ARG)) {
-		lp->extents = arg_uint_value(cmd, extents_ARG, 0);
-		lp->sign = arg_sign_value(cmd, extents_ARG, SIGN_NONE);
-		lp->percent = arg_percent_value(cmd, extents_ARG, PERCENT_NONE);
-	}
-
-	/* Size returned in kilobyte units; held in sectors */
-	if (arg_count(cmd, size_ARG)) {
-		lp->size = arg_uint64_value(cmd, size_ARG, UINT64_C(0));
-		lp->sign = arg_sign_value(cmd, size_ARG, SIGN_NONE);
-		lp->percent = PERCENT_NONE;
+		lp->percent = PERCENT_LV;
+	} else {
+		/*
+		 * Allow omission of extents and size if the user has given us
+		 * one or more PVs.  Most likely, the intent was "resize this
+		 * LV the best you can with these PVs"
+		 */
+		if ((arg_count(cmd, extents_ARG) + arg_count(cmd, size_ARG) == 0) &&
+		    (argc >= 2)) {
+			lp->extents = 100;
+			lp->percent = PERCENT_PVS;
+			lp->sign = SIGN_PLUS;
+		} else if ((arg_count(cmd, extents_ARG) +
+			    arg_count(cmd, size_ARG) != 1)) {
+			log_error("Please specify either size or extents but not "
+				  "both.");
+			return 0;
+		}
+
+		if (arg_count(cmd, extents_ARG)) {
+			lp->extents = arg_uint_value(cmd, extents_ARG, 0);
+			lp->sign = arg_sign_value(cmd, extents_ARG, SIGN_NONE);
+			lp->percent = arg_percent_value(cmd, extents_ARG, PERCENT_NONE);
+		}
+
+		/* Size returned in kilobyte units; held in sectors */
+		if (arg_count(cmd, size_ARG)) {
+			lp->size = arg_uint64_value(cmd, size_ARG, 0);
+			lp->sign = arg_sign_value(cmd, size_ARG, SIGN_NONE);
+			lp->percent = PERCENT_NONE;
+		}
 	}
 
 	if (lp->resize == LV_EXTEND && lp->sign == SIGN_MINUS) {
@@ -269,6 +277,33 @@
 	return 1;
 }
 
+static int _adjust_policy_params(struct cmd_context *cmd,
+				 struct logical_volume *lv, struct lvresize_params *lp)
+{
+	float percent;
+	percent_range_t range;
+	int policy_threshold, policy_amount;
+
+	policy_threshold =
+		find_config_tree_int(cmd, "activation/snapshot_autoextend_threshold",
+				     DEFAULT_SNAPSHOT_AUTOEXTEND_THRESHOLD);
+	policy_amount =
+		find_config_tree_int(cmd, "activation/snapshot_autoextend_percent",
+				     DEFAULT_SNAPSHOT_AUTOEXTEND_PERCENT);
+
+	if (policy_threshold >= 100)
+		return 1; /* nothing to do */
+
+	if (!lv_snapshot_percent(lv, &percent, &range))
+		return_0;
+
+	if (range != PERCENT_0_TO_100 || percent <= policy_threshold)
+		return 1; /* nothing to do */
+
+	lp->extents = policy_amount;
+	return 1;
+}
+
 static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		     struct lvresize_params *lp)
 {
@@ -287,6 +322,7 @@
 	uint32_t seg_extents;
 	uint32_t sz, str;
 	struct dm_list *pvh = NULL;
+	int use_policy = arg_count(cmd, use_policies_ARG);
 
 	/* does LV exist? */
 	if (!(lvl = find_lv_in_vg(vg, lp->lv_name))) {
@@ -319,6 +355,14 @@
 
 	lv = lvl->lv;
 
+	if (use_policy) {
+		if (!lv_is_cow(lv)) {
+			log_error("Can't use policy-based resize for non-snapshot volumes.");
+			return ECMD_FAILED;
+		}
+		_adjust_policy_params(cmd, lv, lp);
+	}
+
 	if (!lv_is_visible(lv)) {
 		log_error("Can't resize internal logical volume %s", lv->name);
 		return ECMD_FAILED;
@@ -404,6 +448,8 @@
 	}
 
 	if (lp->extents == lv->le_count) {
+		if (use_policy)
+			return ECMD_PROCESSED; /* Nothing to do. */
 		if (!lp->resizefs) {
 			log_error("New size (%d extents) matches existing size "
 				  "(%d extents)", lp->extents, lv->le_count);


