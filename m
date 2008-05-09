From: agk@sourceware.org <agk@sourceware.org>
Date: 9 May 2008 15:13:21 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c ...
Message-ID: <20080509151321.32241.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-05-09 15:13:20

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c lvm-functions.c lvm-functions.h 
	lib/cache      : lvmcache.c 

Log message:
	Add missing mutex around clvmd lvmcache_drop_metadata library call.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.872&r2=1.873
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/WHATS_NEW	2008/05/09 09:59:39	1.872
+++ LVM2/WHATS_NEW	2008/05/09 15:13:20	1.873
@@ -1,13 +1,14 @@
 Version 2.02.38 - 
 =================================
-  Fix uninitialised mutex in clvmd if all daemons are not running at startup.
   Make clvmd-cman use a hash rather than an array for node updown info.
   Check lv_count in vg_validate.
   Add --prefixes to reporting tools for field name prefix output format.
 
 Version 2.02.37 - 
 =================================
-  Avoid unnecessary unlock attempts with LCK_CACHE pseudo-locks.
+  Add missing mutex around clvmd lvmcache_drop_metadata library call.
+  Fix uninitialised mutex in clvmd if all daemons are not running at startup.
+  Avoid using DLM locks with LCK_CACHE type P_ lock requests.
   When asked to drop cached committed VG metadata, invalidate cached PV labels.
   Drop metadata cache before writing precommitted metadata instead of after.
   Don't touch /dev in vgrename if activation is disabled.
--- LVM2/daemons/clvmd/clvmd-command.c	2008/04/15 14:46:18	1.21
+++ LVM2/daemons/clvmd/clvmd-command.c	2008/05/09 15:13:20	1.22
@@ -122,7 +122,7 @@
 		if (strcmp(lockname, "P_#global") == 0)
 		      do_refresh_cache();
 		else if (strncmp(lockname, "P_", 2) == 0)
-			lvmcache_drop_metadata(lockname + 2);
+			drop_metadata(lockname + 2);
 
 		break;
 
@@ -253,7 +253,11 @@
 		break;
 
 	case CLVMD_CMD_LOCK_VG:
-       	        status = lock_vg(client);
+		lockname = &args[2];
+		/* Do not use lock for cache related commands */
+		if (!strncmp(lockname, "V_", 2) ||
+		    !strcmp(lockname, "P_#global"))
+			status = lock_vg(client);
 		break;
 
 	case CLVMD_CMD_LOCK_LV:
--- LVM2/daemons/clvmd/lvm-functions.c	2008/04/08 13:03:13	1.39
+++ LVM2/daemons/clvmd/lvm-functions.c	2008/05/09 15:13:20	1.40
@@ -500,6 +500,16 @@
 }
 
 /*
+ * Drop lvmcache metadata
+ */
+void drop_metadata(const char *vgname)
+{
+	pthread_mutex_lock(&lvm_lock);
+	lvmcache_drop_metadata(vgname);
+	pthread_mutex_unlock(&lvm_lock);
+}
+
+/*
  * Ideally, clvmd should be started before any LVs are active
  * but this may not be the case...
  * I suppose this also comes in handy if clvmd crashes, not that it would!
--- LVM2/daemons/clvmd/lvm-functions.h	2007/12/05 13:17:18	1.7
+++ LVM2/daemons/clvmd/lvm-functions.h	2008/05/09 15:13:20	1.8
@@ -33,5 +33,6 @@
 extern int hold_lock(char *resource, int mode, int flags);
 extern void unlock_all(void);
 extern char *get_last_lvm_error(void);
+extern void drop_metadata(const char *vgname);
 
 #endif
--- LVM2/lib/cache/lvmcache.c	2008/05/08 18:28:27	1.48
+++ LVM2/lib/cache/lvmcache.c	2008/05/09 15:13:20	1.49
@@ -158,7 +158,7 @@
 void lvmcache_drop_metadata(const char *vgname)
 {
 	/* For VG_ORPHANS, we need to invalidate all labels on orphan PVs. */
-	if (strcmp(vgname, VG_ORPHANS)) {
+	if (!strcmp(vgname, VG_ORPHANS)) {
 		_drop_metadata(FMT_TEXT_ORPHAN_VG_NAME);
 		_drop_metadata(FMT_LVM1_ORPHAN_VG_NAME);
 		_drop_metadata(FMT_POOL_ORPHAN_VG_NAME);


