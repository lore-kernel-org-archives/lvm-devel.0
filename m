From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Dec 2011 13:10:54 -0000
Subject: LVM2 doc/example.conf.in lib/config/defaults.h ...
Message-ID: <20111221131054.26283.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-21 13:10:53

Modified files:
	doc            : example.conf.in 
	lib/config     : defaults.h 
	tools          : lvresize.c 

Log message:
	Thin automatic policy based extension

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.144&r2=1.145

--- LVM2/doc/example.conf.in	2011/12/21 13:08:13	1.39
+++ LVM2/doc/example.conf.in	2011/12/21 13:10:52	1.40
@@ -603,6 +603,25 @@
     snapshot_autoextend_threshold = 100
     snapshot_autoextend_percent = 20
 
+    # 'thin_pool_autoextend_threshold' and 'thin_pool_autoextend_percent' define
+    # how to handle automatic pool extension. The former defines when the
+    # pool should be extended: when its space usage exceeds this many
+    # percent. The latter defines how much extra space should be allocated for
+    # the pool, in percent of its current size.
+    #
+    # For example, if you set thin_pool_autoextend_threshold to 70 and
+    # thin_pool_autoextend_percent to 20, whenever a pool exceeds 70% usage,
+    # it will be extended by another 20%. For a 1G pool, using up 700M will
+    # trigger a resize to 1.2G. When the usage exceeds 840M, the pool will
+    # be extended to 1.44G, and so on.
+    #
+    # Setting thin_pool_autoextend_threshold to 100 disables automatic
+    # extensions. The minimum value is 50 (A setting below 50 will be treated
+    # as 50).
+
+    thin_pool_autoextend_threshold = 100
+    thin_pool_autoextend_percent = 20
+
     # While activating devices, I/O to devices being (re)configured is
     # suspended, and as a precaution against deadlocks, LVM2 needs to pin
     # any memory it is using so it is not paged out.  Groups of pages that
--- LVM2/lib/config/defaults.h	2011/12/21 13:08:13	1.91
+++ LVM2/lib/config/defaults.h	2011/12/21 13:10:52	1.92
@@ -170,5 +170,7 @@
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
 #define DEFAULT_SNAPSHOT_AUTOEXTEND_THRESHOLD 100
 #define DEFAULT_SNAPSHOT_AUTOEXTEND_PERCENT 20
+#define DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD 100
+#define DEFAULT_THIN_POOL_AUTOEXTEND_PERCENT 20
 
 #endif				/* _LVM_DEFAULTS_H */
--- LVM2/tools/lvresize.c	2011/12/01 00:13:16	1.144
+++ LVM2/tools/lvresize.c	2011/12/21 13:10:53	1.145
@@ -285,23 +285,40 @@
 	percent_t percent;
 	int policy_threshold, policy_amount;
 
-	policy_threshold =
-		find_config_tree_int(cmd, "activation/snapshot_autoextend_threshold",
-				     DEFAULT_SNAPSHOT_AUTOEXTEND_THRESHOLD) * PERCENT_1;
-	policy_amount =
-		find_config_tree_int(cmd, "activation/snapshot_autoextend_percent",
-				     DEFAULT_SNAPSHOT_AUTOEXTEND_PERCENT);
+	if (lv_is_thin_pool(lv)) {
+		policy_threshold =
+			find_config_tree_int(cmd, "activation/thin_pool_autoextend_threshold",
+					     DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD) * PERCENT_1;
+		policy_amount =
+			find_config_tree_int(cmd, "activation/thin_pool_autoextend_percent",
+					     DEFAULT_THIN_POOL_AUTOEXTEND_PERCENT);
+	} else {
+		policy_threshold =
+			find_config_tree_int(cmd, "activation/snapshot_autoextend_threshold",
+					     DEFAULT_SNAPSHOT_AUTOEXTEND_THRESHOLD) * PERCENT_1;
+		policy_amount =
+			find_config_tree_int(cmd, "activation/snapshot_autoextend_percent",
+					     DEFAULT_SNAPSHOT_AUTOEXTEND_PERCENT);
+	}
 
 	if (policy_threshold >= PERCENT_100)
 		return 1; /* nothing to do */
 
-	if (!lv_snapshot_percent(lv, &percent))
-		return_0;
-
-	if (!(PERCENT_0 < percent && percent < PERCENT_100) || percent <= policy_threshold)
-		return 1; /* nothing to do */
+	if (lv_is_thin_pool(lv)) {
+		if (!lv_thin_pool_percent(lv, &percent))
+			return_0;
+		if (!(PERCENT_0 < percent && percent <= PERCENT_100) ||
+		    percent <= policy_threshold)
+			return 1; /* nothing to do */
+	} else {
+		if (!lv_snapshot_percent(lv, &percent))
+			return_0;
+		if (!(PERCENT_0 < percent && percent < PERCENT_100) || percent <= policy_threshold)
+			return 1; /* nothing to do */
+	}
 
 	lp->extents = policy_amount;
+
 	return 1;
 }
 
@@ -399,8 +416,9 @@
 	lv = lvl->lv;
 
 	if (use_policy) {
-		if (!lv_is_cow(lv)) {
-			log_error("Can't use policy-based resize for non-snapshot volumes.");
+		if (!lv_is_cow(lv) &&
+		    !lv_is_thin_pool(lv)) {
+			log_error("Policy-based resize is supported only for snapshot and thin pool volumes.");
 			return ECMD_FAILED;
 		}
 		_adjust_policy_params(cmd, lv, lp);


