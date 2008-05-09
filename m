From: agk@sourceware.org <agk@sourceware.org>
Date: 9 May 2008 19:26:58 -0000
Subject: LVM2 daemons/clvmd/clvmd-command.c daemons/clv ...
Message-ID: <20080509192658.24864.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-05-09 19:26:58

Modified files:
	daemons/clvmd  : clvmd-command.c lvm-functions.c 
	lib/locking    : file_locking.c locking.h 

Log message:
	more cleanup

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.40&r2=1.41

--- LVM2/daemons/clvmd/clvmd-command.c	2008/05/09 18:45:14	1.23
+++ LVM2/daemons/clvmd/clvmd-command.c	2008/05/09 19:26:58	1.24
@@ -119,7 +119,7 @@
 		/* Check to see if the VG is in use by LVM1 */
 		status = do_check_lvm1(lockname);
 		/* P_#global causes a full cache refresh */
-		if (!strcmp(lockname, "P_#global"))
+		if (!strcmp(lockname, "P_" VG_GLOBAL))
 			do_refresh_cache();
 		else
 			drop_metadata(lockname + 2);
--- LVM2/daemons/clvmd/lvm-functions.c	2008/05/09 18:45:14	1.41
+++ LVM2/daemons/clvmd/lvm-functions.c	2008/05/09 19:26:58	1.42
@@ -472,8 +472,8 @@
 	    popen
 	    ("lvm pvs  --config 'log{command_names=0 prefix=\"\"}' --nolocking --noheadings -o vg_name", "r");
 
-	sync_unlock("P_#orphans", LCK_EXCL);
-	sync_unlock("P_#global", LCK_EXCL);
+	sync_unlock("P_" VG_ORPHANS, LCK_EXCL);
+	sync_unlock("P_" VG_GLOBAL, LCK_EXCL);
 
 	if (!vgs)
 		return;
--- LVM2/lib/locking/file_locking.c	2008/05/09 18:45:15	1.38
+++ LVM2/lib/locking/file_locking.c	2008/05/09 19:26:58	1.39
@@ -210,10 +210,14 @@
 
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
-		if (flags & LCK_CACHE) {
+		/* Skip cache refresh for VG_GLOBAL - the caller handles it */
+		if (strcmp(resource, VG_GLOBAL))
 			lvmcache_drop_metadata(resource);
+
+		/* LCK_CACHE does not require a real lock */
+		if (flags & LCK_CACHE)
 			break;
-		}
+
 		if (*resource == '#')
 			dm_snprintf(lockfile, sizeof(lockfile),
 				     "%s/P_%s", _lock_dir, resource + 1);
--- LVM2/lib/locking/locking.h	2008/04/15 14:46:19	1.40
+++ LVM2/lib/locking/locking.h	2008/05/09 19:26:58	1.41
@@ -27,9 +27,11 @@
 
 /*
  * LCK_VG:
- *   Lock/unlock on-disk volume group data
- *   Use VG_ORPHANS to lock orphan PVs
- *   char *vol holds volume group name
+ *   Lock/unlock on-disk volume group data.
+ *   Use VG_ORPHANS to lock all orphan PVs.
+ *   Use VG_GLOBAL as a global lock and to wipe the internal cache.
+ *   char *vol holds volume group name.
+ *   Set the LCK_CACHE flag to invalidate 'vol' in the internal cache.
  *
  * LCK_LV:
  *   Lock/unlock an individual logical volume
@@ -38,6 +40,13 @@
 int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags);
 
 /*
+ * Internal locking representation.
+ *   LCK_VG: Uses prefix V_ unless the vol begins with # (i.e. #global or #orphans)
+ *           or the LCK_CACHE flag is set when it uses the prefix P_.
+ * If LCK_CACHE is set, we do not take out a real lock.
+ */
+
+/*
  * Does the LVM1 driver have this VG active?
  */
 int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
@@ -69,7 +78,7 @@
 #define LCK_HOLD	0x00000020U	/* Hold lock when lock_vol returns? */
 #define LCK_LOCAL	0x00000040U	/* Don't propagate to other nodes */
 #define LCK_CLUSTER_VG	0x00000080U	/* VG is clustered */
-#define LCK_CACHE	0x00000100U	/* Operation on cache using P_ lock */
+#define LCK_CACHE	0x00000100U	/* Operation on cache only using P_ lock */
 
 /*
  * Additional lock bits for cluster communication


