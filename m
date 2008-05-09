From: agk@sourceware.org <agk@sourceware.org>
Date: 9 May 2008 18:45:16 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c ...
Message-ID: <20080509184516.25532.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-05-09 18:45:15

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c lvm-functions.c 
	lib/cache      : lvmcache.c 
	lib/locking    : cluster_locking.c file_locking.c locking.c 

Log message:
	More P_ and V_ lock cleanup.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.873&r2=1.874
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/WHATS_NEW	2008/05/09 15:13:20	1.873
+++ LVM2/WHATS_NEW	2008/05/09 18:45:14	1.874
@@ -6,6 +6,7 @@
 
 Version 2.02.37 - 
 =================================
+  Add assertions to trap deprecated P_ and V_ lock usage.
   Add missing mutex around clvmd lvmcache_drop_metadata library call.
   Fix uninitialised mutex in clvmd if all daemons are not running at startup.
   Avoid using DLM locks with LCK_CACHE type P_ lock requests.
--- LVM2/daemons/clvmd/clvmd-command.c	2008/05/09 15:13:20	1.22
+++ LVM2/daemons/clvmd/clvmd-command.c	2008/05/09 18:45:14	1.23
@@ -118,10 +118,10 @@
 		lockname = &args[2];
 		/* Check to see if the VG is in use by LVM1 */
 		status = do_check_lvm1(lockname);
-		/* P_#global causes a cache refresh */
-		if (strcmp(lockname, "P_#global") == 0)
-		      do_refresh_cache();
-		else if (strncmp(lockname, "P_", 2) == 0)
+		/* P_#global causes a full cache refresh */
+		if (!strcmp(lockname, "P_#global"))
+			do_refresh_cache();
+		else
 			drop_metadata(lockname + 2);
 
 		break;
@@ -254,9 +254,9 @@
 
 	case CLVMD_CMD_LOCK_VG:
 		lockname = &args[2];
-		/* Do not use lock for cache related commands */
+		/* We take out a real lock unless LCK_CACHE was set */
 		if (!strncmp(lockname, "V_", 2) ||
-		    !strcmp(lockname, "P_#global"))
+		    !strncmp(lockname, "P_#", 3))
 			status = lock_vg(client);
 		break;
 
--- LVM2/daemons/clvmd/lvm-functions.c	2008/05/09 15:13:20	1.40
+++ LVM2/daemons/clvmd/lvm-functions.c	2008/05/09 18:45:14	1.41
@@ -472,7 +472,8 @@
 	    popen
 	    ("lvm pvs  --config 'log{command_names=0 prefix=\"\"}' --nolocking --noheadings -o vg_name", "r");
 
-	sync_unlock("P_orphans", LCK_EXCL);
+	sync_unlock("P_#orphans", LCK_EXCL);
+	sync_unlock("P_#global", LCK_EXCL);
 
 	if (!vgs)
 		return;
--- LVM2/lib/cache/lvmcache.c	2008/05/09 15:13:20	1.49
+++ LVM2/lib/cache/lvmcache.c	2008/05/09 18:45:14	1.50
@@ -162,6 +162,9 @@
 		_drop_metadata(FMT_TEXT_ORPHAN_VG_NAME);
 		_drop_metadata(FMT_LVM1_ORPHAN_VG_NAME);
 		_drop_metadata(FMT_POOL_ORPHAN_VG_NAME);
+
+		/* Indicate that PVs could now be missing from the cache */
+		init_full_scan_done(0);
 	} else
 		_drop_metadata(vgname);
 }
--- LVM2/lib/locking/cluster_locking.c	2008/04/15 14:46:19	1.28
+++ LVM2/lib/locking/cluster_locking.c	2008/05/09 18:45:15	1.29
@@ -387,13 +387,12 @@
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
 		/* If the VG name is empty then lock the unused PVs */
-		if (!*resource)	/* FIXME Deprecated */
-			dm_snprintf(lockname, sizeof(lockname), "P_orphans");
-		else if (*resource == '#' || (flags & LCK_CACHE))
-			dm_snprintf(lockname, sizeof(lockname), "P_%s", resource);
+		if (*resource == '#' || (flags & LCK_CACHE))
+			dm_snprintf(lockname, sizeof(lockname), "P_%s",
+				    resource);
 		else
 			dm_snprintf(lockname, sizeof(lockname), "V_%s",
-				     resource);
+				    resource);
 
 		lock_scope = "VG";
 		cluster_cmd = CLVMD_CMD_LOCK_VG;
--- LVM2/lib/locking/file_locking.c	2008/04/15 14:46:19	1.37
+++ LVM2/lib/locking/file_locking.c	2008/05/09 18:45:15	1.38
@@ -214,10 +214,7 @@
 			lvmcache_drop_metadata(resource);
 			break;
 		}
-		if (!*resource)	/* FIXME Deprecated */
-			dm_snprintf(lockfile, sizeof(lockfile),
-				     "%s/P_orphans", _lock_dir);
-		else if (*resource == '#')
+		if (*resource == '#')
 			dm_snprintf(lockfile, sizeof(lockfile),
 				     "%s/P_%s", _lock_dir, resource + 1);
 		else
--- LVM2/lib/locking/locking.c	2008/05/08 18:35:58	1.48
+++ LVM2/lib/locking/locking.c	2008/05/09 18:45:15	1.49
@@ -323,6 +323,16 @@
 
 	assert(resource);
 
+	if (!*resource) {
+		log_error("Internal error: Use of P_orphans is deprecated.");
+		return 0;
+	}
+
+	if (*resource == '#' && (flags & LCK_CACHE)) {
+		log_error("Internal error: P_%s referenced", resource);
+		return 0;
+	}
+
 	if ((ret = _locking.lock_resource(cmd, resource, flags))) {
 		if ((flags & LCK_SCOPE_MASK) == LCK_VG &&
 		    !(flags & LCK_CACHE)) {


