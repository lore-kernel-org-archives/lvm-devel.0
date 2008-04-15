From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 15 Apr 2008 14:46:20 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c ...
Message-ID: <20080415144620.20263.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-04-15 14:46:19

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c 
	lib/cache      : lvmcache.c lvmcache.h 
	lib/locking    : cluster_locking.c file_locking.c locking.c 
	                 locking.h 
	lib/metadata   : metadata.c 

Log message:
	Drop cached VG metadata before and after committing changes to it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.850&r2=1.851
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.170&r2=1.171

--- LVM2/WHATS_NEW	2008/04/15 11:36:46	1.850
+++ LVM2/WHATS_NEW	2008/04/15 14:46:18	1.851
@@ -1,5 +1,6 @@
 Version 2.02.35 - 
 =================================
+  Drop cached VG metadata before and after committing changes to it.
   Rename P_global to P_#global.
   Don't attempt remote metadata backups of non-clustered VGs. (2.02.29)
   Don't store fid in VG metadata cache to avoid clvmd segfault. (2.02.34)
--- LVM2/daemons/clvmd/clvmd-command.c	2008/04/15 11:36:46	1.20
+++ LVM2/daemons/clvmd/clvmd-command.c	2008/04/15 14:46:18	1.21
@@ -121,6 +121,8 @@
 		/* P_#global causes a cache refresh */
 		if (strcmp(lockname, "P_#global") == 0)
 		      do_refresh_cache();
+		else if (strncmp(lockname, "P_", 2) == 0)
+			lvmcache_drop_metadata(lockname + 2);
 
 		break;
 
--- LVM2/lib/cache/lvmcache.c	2008/04/14 19:24:15	1.44
+++ LVM2/lib/cache/lvmcache.c	2008/04/15 14:46:18	1.45
@@ -130,6 +130,16 @@
 	_update_cache_vginfo_lock_state(vginfo, locked);
 }
 
+void lvmcache_drop_metadata(const char *vgname)
+{
+	struct lvmcache_vginfo *vginfo;
+
+	if (!(vginfo = vginfo_from_vgname(vgname, NULL)))
+		return;
+
+	_free_cached_vgmetadata(vginfo);
+}
+
 void lvmcache_lock_vgname(const char *vgname, int read_only __attribute((unused)))
 {
 	if (!_lock_hash && !lvmcache_init()) {
--- LVM2/lib/cache/lvmcache.h	2008/04/14 19:24:16	1.21
+++ LVM2/lib/cache/lvmcache.h	2008/04/15 14:46:18	1.22
@@ -111,5 +111,6 @@
 
 /* Returns cached volume group metadata. */
 struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted);
+void lvmcache_drop_metadata(const char *vgname);
 
 #endif
--- LVM2/lib/locking/cluster_locking.c	2008/04/15 11:36:46	1.27
+++ LVM2/lib/locking/cluster_locking.c	2008/04/15 14:46:19	1.28
@@ -389,7 +389,7 @@
 		/* If the VG name is empty then lock the unused PVs */
 		if (!*resource)	/* FIXME Deprecated */
 			dm_snprintf(lockname, sizeof(lockname), "P_orphans");
-		else if (*resource == '#')
+		else if (*resource == '#' || (flags & LCK_CACHE))
 			dm_snprintf(lockname, sizeof(lockname), "P_%s", resource);
 		else
 			dm_snprintf(lockname, sizeof(lockname), "V_%s",
--- LVM2/lib/locking/file_locking.c	2008/04/07 19:17:29	1.36
+++ LVM2/lib/locking/file_locking.c	2008/04/15 14:46:19	1.37
@@ -21,6 +21,7 @@
 #include "defaults.h"
 #include "lvm-file.h"
 #include "lvm-string.h"
+#include "lvmcache.h"
 
 #include <limits.h>
 #include <unistd.h>
@@ -209,6 +210,10 @@
 
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
+		if (flags & LCK_CACHE) {
+			lvmcache_drop_metadata(resource);
+			break;
+		}
 		if (!*resource)	/* FIXME Deprecated */
 			dm_snprintf(lockfile, sizeof(lockfile),
 				     "%s/P_orphans", _lock_dir);
--- LVM2/lib/locking/locking.c	2008/04/09 12:56:34	1.46
+++ LVM2/lib/locking/locking.c	2008/04/15 14:46:19	1.47
@@ -324,7 +324,8 @@
 	assert(resource);
 
 	if ((ret = _locking.lock_resource(cmd, resource, flags))) {
-		if ((flags & LCK_SCOPE_MASK) == LCK_VG) {
+		if ((flags & LCK_SCOPE_MASK) == LCK_VG &&
+		    !(flags & LCK_CACHE)) {
 			if ((flags & LCK_TYPE_MASK) == LCK_UNLOCK)
 				lvmcache_unlock_vgname(resource);
 			else
--- LVM2/lib/locking/locking.h	2008/04/10 17:09:31	1.39
+++ LVM2/lib/locking/locking.h	2008/04/15 14:46:19	1.40
@@ -69,6 +69,7 @@
 #define LCK_HOLD	0x00000020U	/* Hold lock when lock_vol returns? */
 #define LCK_LOCAL	0x00000040U	/* Don't propagate to other nodes */
 #define LCK_CLUSTER_VG	0x00000080U	/* VG is clustered */
+#define LCK_CACHE	0x00000100U	/* Operation on cache using P_ lock */
 
 /*
  * Additional lock bits for cluster communication
@@ -91,6 +92,7 @@
 #define LCK_VG_READ		(LCK_VG | LCK_READ | LCK_HOLD)
 #define LCK_VG_WRITE		(LCK_VG | LCK_WRITE | LCK_HOLD)
 #define LCK_VG_UNLOCK		(LCK_VG | LCK_UNLOCK)
+#define LCK_VG_DROP_CACHE	(LCK_VG | LCK_WRITE | LCK_CACHE)
 
 #define LCK_LV_EXCLUSIVE	(LCK_LV | LCK_EXCL | LCK_NONBLOCK)
 #define LCK_LV_SUSPEND		(LCK_LV | LCK_WRITE | LCK_NONBLOCK)
@@ -116,6 +118,8 @@
 	lock_lv_vol(cmd, lv, LCK_LV_ACTIVATE | LCK_HOLD | LCK_LOCAL)
 #define deactivate_lv_local(cmd, lv)	\
 	lock_lv_vol(cmd, lv, LCK_LV_DEACTIVATE | LCK_LOCAL)
+#define drop_cached_metadata(vg)	\
+	lock_vol((vg)->cmd, (vg)->name, LCK_VG_DROP_CACHE)
 
 /* Process list of LVs */
 int suspend_lvs(struct cmd_context *cmd, struct list *lvs);
--- LVM2/lib/metadata/metadata.c	2008/04/10 19:59:42	1.170
+++ LVM2/lib/metadata/metadata.c	2008/04/15 14:46:19	1.171
@@ -1333,6 +1333,11 @@
 		return cache_updated;
 	}
 
+	if (!drop_cached_metadata(vg)) {
+		log_error("Unable to drop cached metadata for VG %s.", vg->name);
+		return 0;
+	}
+
 	/* Commit to each copy of the metadata area */
 	list_iterate_items(mda, &vg->fid->metadata_areas) {
 		failed = 0;
@@ -1348,6 +1353,10 @@
 		}
 	}
 
+	if (!drop_cached_metadata(vg))
+		log_error("Attempt to drop cached metadata failed "
+			  "after commit for VG %s.", vg->name);
+
 	/* If at least one mda commit succeeded, it was committed */
 	return cache_updated;
 }


