From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Aug 2007 15:02:27 -0000
Subject: LVM2 tools/pvscan.c tools/vgscan.c ./WHATS_NEW ...
Message-ID: <20070823150227.10210.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-08-23 15:02:26

Modified files:
	tools          : pvscan.c vgscan.c 
	.              : WHATS_NEW 
	lib/locking    : cluster_locking.c file_locking.c locking.h 

Log message:
	Introduce VG_GLOBAL lock type for vgscan/pvscan to trigger clvmd -R.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgscan.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.693&r2=1.694
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.34&r2=1.35

--- LVM2/tools/pvscan.c	2007/08/20 20:55:30	1.41
+++ LVM2/tools/pvscan.c	2007/08/23 15:02:26	1.42
@@ -124,12 +124,19 @@
 			  arg_count(cmd, exported_ARG) ?
 			  "of exported volume group(s)" : "in no volume group");
 
+	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_WRITE)) {
+		log_error("Unable to obtain global lock.");
+		return ECMD_FAILED;
+	}
+
 	persistent_filter_wipe(cmd->filter);
 	lvmcache_destroy();
 
 	log_verbose("Walking through all physical volumes");
-	if (!(pvslist = get_pvs(cmd)))
+	if (!(pvslist = get_pvs(cmd))) {
+		unlock_vg(cmd, VG_GLOBAL);
 		return ECMD_FAILED;
+	}
 
 	/* eliminate exported/new if required */
 	list_iterate_items(pvl, pvslist) {
@@ -181,6 +188,7 @@
 
 	if (!pvs_found) {
 		log_print("No matching physical volumes found");
+		unlock_vg(cmd, VG_GLOBAL);
 		return ECMD_PROCESSED;
 	}
 
@@ -191,5 +199,7 @@
 		  display_size(cmd, (size_total - size_new)),
 		  new_pvs_found, display_size(cmd, size_new));
 
+	unlock_vg(cmd, VG_GLOBAL);
+
 	return ECMD_PROCESSED;
 }
--- LVM2/tools/vgscan.c	2007/08/20 20:55:30	1.27
+++ LVM2/tools/vgscan.c	2007/08/23 15:02:26	1.28
@@ -51,6 +51,11 @@
 		return EINVALID_CMD_LINE;
 	}
 
+	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_WRITE)) {
+		log_error("Unable to obtain global lock.");
+		return ECMD_FAILED;
+	}
+
 	persistent_filter_wipe(cmd->filter);
 	lvmcache_destroy();
 
@@ -65,5 +70,6 @@
 			maxret = ret;
 	}
 
+	unlock_vg(cmd, VG_GLOBAL);
 	return maxret;
 }
--- LVM2/WHATS_NEW	2007/08/23 12:19:12	1.693
+++ LVM2/WHATS_NEW	2007/08/23 15:02:26	1.694
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Introduce VG_GLOBAL lock type for vgscan/pvscan to trigger clvmd -R.
   Fix clvmd -R, so it fully refreshes the caches.
   Change lvconvert_mirrors to use mirror segtype not striped.
   Fix lvconvert_mirrors detection of number of existing mirrors.
--- LVM2/lib/locking/cluster_locking.c	2007/08/22 14:38:17	1.19
+++ LVM2/lib/locking/cluster_locking.c	2007/08/23 15:02:26	1.20
@@ -382,8 +382,10 @@
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
 		/* If the VG name is empty then lock the unused PVs */
-		if (!*resource)
+		if (!*resource)	/* FIXME Deprecated */
 			dm_snprintf(lockname, sizeof(lockname), "P_orphans");
+		else if (*resource == '#')
+			dm_snprintf(lockname, sizeof(lockname), "P_%s", resource + 1);
 		else
 			dm_snprintf(lockname, sizeof(lockname), "V_%s",
 				     resource);
--- LVM2/lib/locking/file_locking.c	2007/08/22 14:38:17	1.31
+++ LVM2/lib/locking/file_locking.c	2007/08/23 15:02:26	1.32
@@ -212,9 +212,12 @@
 
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
-		if (!*resource)
+		if (!*resource)	/* FIXME Deprecated */
 			dm_snprintf(lockfile, sizeof(lockfile),
 				     "%s/P_orphans", _lock_dir);
+		else if (*resource == '#')
+			dm_snprintf(lockfile, sizeof(lockfile),
+				     "%s/P_%s", _lock_dir, resource + 1);
 		else
 			dm_snprintf(lockfile, sizeof(lockfile),
 				     "%s/V_%s", _lock_dir, resource);
--- LVM2/lib/locking/locking.h	2007/08/22 14:38:17	1.34
+++ LVM2/lib/locking/locking.h	2007/08/23 15:02:26	1.35
@@ -28,7 +28,7 @@
 /*
  * LCK_VG:
  *   Lock/unlock on-disk volume group data
- *   Use "" to lock orphan PVs
+ *   Use VG_ORPHANS to lock orphan PVs
  *   char *vol holds volume group name
  *
  * LCK_LV:
@@ -77,6 +77,11 @@
 #define LCK_MIRROR_NOSYNC_MODE	0x00000002U	/* Mirrors don't require sync */
 #define LCK_DMEVENTD_MONITOR_MODE	0x00000004U	/* Register with dmeventd */
 
+/*
+ * Special cases of VG locks.
+ */
+#define VG_ORPHANS	"#orphans"
+#define VG_GLOBAL	"#global"
 
 /*
  * Common combinations


