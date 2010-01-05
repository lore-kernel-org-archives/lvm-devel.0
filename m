From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 5 Jan 2010 16:09:35 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20100105160935.25925.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-01-05 16:09:34

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/locking    : locking.h 
	lib/metadata   : metadata.c 

Log message:
	Propagate commit and revert metadata event to other nodes in cluster.
	
	This patch tries to correctly track changes in lvmcache related to commit/revert.
	
	For vg_commit: if there is cached precommitted metadata, after successfull commit
	these metadata must be tracked as committed.
	
	For vg_revert: remote nodes must drop precommitted metadata and its flag in lvmcache.
	
	(N.B. Patch do not touch LV locks here in any way.)
	
	All this machinery is needed to properly solve remote node cache invalidaton which
	cause several problems recently observed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1360&r2=1.1361
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.307&r2=1.308

--- LVM2/WHATS_NEW	2010/01/05 16:07:56	1.1360
+++ LVM2/WHATS_NEW	2010/01/05 16:09:33	1.1361
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Propagate commit and revert metadata notification to other nodes in cluster.
   Use proper mask for VG lock mode in clvmd.
   Add possibility to drop precommitted metadata in lvmcache.
   Move processing of VG locks to separate function in clvmd.
--- LVM2/daemons/clvmd/lvm-functions.c	2010/01/05 16:06:42	1.81
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/01/05 16:09:33	1.82
@@ -680,6 +680,7 @@
  */
 void do_lock_vg(unsigned char command, unsigned char lock_flags, char *resource)
 {
+	uint32_t lock_cmd = command;
 	char *vgname = resource + 2;
 
 	DEBUGLOG("do_lock_vg: resource '%s', cmd = %s, flags = %s, memlock = %d\n",
@@ -691,9 +692,29 @@
 		return;
 	}
 
+	lock_cmd &= (LCK_SCOPE_MASK | LCK_TYPE_MASK | LCK_HOLD);
+
+	/*
+	 * Check if LCK_CACHE should be set. All P_ locks except # are cache related.
+	 */
+	if (strncmp(resource, "P_#", 3) && !strncmp(resource, "P_", 2))
+		lock_cmd |= LCK_CACHE;
+
 	pthread_mutex_lock(&lvm_lock);
-	DEBUGLOG("Dropping metadata for VG %s\n", vgname);
-	lvmcache_drop_metadata(vgname, 0);
+	switch (lock_cmd) {
+		case LCK_VG_COMMIT:
+			DEBUGLOG("vg_commit notification for VG %s\n", vgname);
+			lvmcache_commit_metadata(vgname);
+			break;
+		case LCK_VG_REVERT:
+			DEBUGLOG("vg_revert notification for VG %s\n", vgname);
+			lvmcache_drop_metadata(vgname, 1);
+			break;
+		case LCK_VG_DROP_CACHE:
+		default:
+			DEBUGLOG("Invalidating cached metadata for VG %s\n", vgname);
+			lvmcache_drop_metadata(vgname, 0);
+	}
 	pthread_mutex_unlock(&lvm_lock);
 }
 
--- LVM2/lib/locking/locking.h	2009/10/01 14:15:34	1.52
+++ LVM2/lib/locking/locking.h	2010/01/05 16:09:34	1.53
@@ -33,7 +33,8 @@
  *   Use VG_ORPHANS to lock all orphan PVs.
  *   Use VG_GLOBAL as a global lock and to wipe the internal cache.
  *   char *vol holds volume group name.
- *   Set the LCK_CACHE flag to invalidate 'vol' in the internal cache.
+ *   Set LCK_CACHE flag when manipulating 'vol' metadata in the internal cache.
+ *   (Like commit, revert or invalidate metadata.)
  *   If more than one lock needs to be held simultaneously, they must be
  *   acquired in alphabetical order of 'vol' (to avoid deadlocks).
  *
@@ -48,6 +49,8 @@
  *   LCK_VG: Uses prefix V_ unless the vol begins with # (i.e. #global or #orphans)
  *           or the LCK_CACHE flag is set when it uses the prefix P_.
  * If LCK_CACHE is set, we do not take out a real lock.
+ * NB In clustered situations, LCK_CACHE is not propagated directly to remote nodes.
+ * (It can be deduced from lock name.)
  */
 
 /*
@@ -107,6 +110,11 @@
 #define LCK_VG_WRITE		(LCK_VG | LCK_WRITE | LCK_HOLD)
 #define LCK_VG_UNLOCK		(LCK_VG | LCK_UNLOCK)
 #define LCK_VG_DROP_CACHE	(LCK_VG | LCK_WRITE | LCK_CACHE)
+
+/* FIXME: LCK_HOLD abused here */
+#define LCK_VG_COMMIT		(LCK_VG | LCK_WRITE | LCK_CACHE | LCK_HOLD)
+#define LCK_VG_REVERT		(LCK_VG | LCK_READ  | LCK_CACHE | LCK_HOLD)
+
 #define LCK_VG_BACKUP		(LCK_VG | LCK_CACHE)
 
 #define LCK_LV_EXCLUSIVE	(LCK_LV | LCK_EXCL)
@@ -142,6 +150,10 @@
 	lock_lv_vol(cmd, lv, LCK_LV_DEACTIVATE | LCK_LOCAL)
 #define drop_cached_metadata(vg)	\
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_DROP_CACHE)
+#define remote_commit_cached_metadata(vg)	\
+	lock_vol((vg)->cmd, (vg)->name, LCK_VG_COMMIT)
+#define remote_revert_cached_metadata(vg)	\
+	lock_vol((vg)->cmd, (vg)->name, LCK_VG_REVERT)
 #define remote_backup_metadata(vg)	\
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_BACKUP)
 
--- LVM2/lib/metadata/metadata.c	2010/01/05 16:01:22	1.307
+++ LVM2/lib/metadata/metadata.c	2010/01/05 16:09:34	1.308
@@ -2331,6 +2331,12 @@
 		}
 	}
 
+	/*
+	 * Instruct remote nodes to upgrade cached metadata.
+	 */
+	if (cache_updated)
+		remote_commit_cached_metadata(vg);
+
 	/* If update failed, remove any cached precommitted metadata. */
 	if (!cache_updated && !drop_cached_metadata(vg))
 		log_error("Attempt to drop cached metadata failed "
@@ -2356,6 +2362,8 @@
 		log_error("Attempt to drop cached metadata failed "
 			  "after reverted update for VG %s.", vg->name);
 
+	remote_revert_cached_metadata(vg);
+
 	return 1;
 }
 


