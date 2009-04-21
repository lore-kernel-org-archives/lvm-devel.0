From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 21 Apr 2009 13:11:30 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-cman.c da ...
Message-ID: <20090421131130.8858.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-21 13:11:29

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-cman.c clvmd-corosync.c clvmd-gulm.c 
	                 clvmd-openais.c lvm-functions.c lvm-functions.h 

Log message:
	Tidy lv_hash[_lock] use inside clvmd.
	
	- Rename unlock_all to destroy_lvhash,
	this function is called in cluster shutdown
	unlocks everything and clean up allocated info space.
	
	- Tidy lv_hash_lock use
	.
	Except adding free(lvi) in lv_has destructror
	there is no functional change.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1089&r2=1.1090
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-cman.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-corosync.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-gulm.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-openais.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/WHATS_NEW	2009/04/21 12:59:18	1.1089
+++ LVM2/WHATS_NEW	2009/04/21 13:11:28	1.1090
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Tidy clvmd volume lock cache functions.
   Fix pvs report for orphan PVs when segment attributes are requested.
   Fix pvs -a output to not read volume groups from non-PV devices.
   Add MMC (mmcblk) device type to filters.
--- LVM2/daemons/clvmd/clvmd-cman.c	2009/02/10 11:52:40	1.25
+++ LVM2/daemons/clvmd/clvmd-cman.c	2009/04/21 13:11:28	1.26
@@ -263,7 +263,7 @@
 
 static void _cluster_closedown()
 {
-	unlock_all();
+	destroy_lvhash();
 	dlm_release_lockspace(LOCKSPACE_NAME, lockspace, 1);
 	cman_finish(c_handle);
 }
--- LVM2/daemons/clvmd/clvmd-corosync.c	2009/04/01 07:51:06	1.8
+++ LVM2/daemons/clvmd/clvmd-corosync.c	2009/04/21 13:11:28	1.9
@@ -359,7 +359,7 @@
 static void _cluster_closedown(void)
 {
 	DEBUGLOG("cluster_closedown\n");
-	unlock_all();
+	destroy_lvhash();
 
 	dlm_release_lockspace(LOCKSPACE_NAME, lockspace, 1);
 	cpg_finalize(cpg_handle);
--- LVM2/daemons/clvmd/clvmd-gulm.c	2008/11/04 16:41:47	1.25
+++ LVM2/daemons/clvmd/clvmd-gulm.c	2009/04/21 13:11:28	1.26
@@ -248,7 +248,7 @@
 {
     DEBUGLOG("cluster_closedown\n");
     in_shutdown = 1;
-    unlock_all();
+    destroy_lvhash();
     lg_lock_logout(gulm_if);
     lg_core_logout(gulm_if);
     lg_release(gulm_if);
--- LVM2/daemons/clvmd/clvmd-openais.c	2009/02/02 14:34:25	1.10
+++ LVM2/daemons/clvmd/clvmd-openais.c	2009/04/21 13:11:28	1.11
@@ -382,7 +382,7 @@
 static void _cluster_closedown(void)
 {
 	DEBUGLOG("cluster_closedown\n");
-	unlock_all();
+	destroy_lvhash();
 
 	saLckFinalize(lck_handle);
 	cpg_finalize(cpg_handle);
--- LVM2/daemons/clvmd/lvm-functions.c	2009/04/10 10:00:04	1.59
+++ LVM2/daemons/clvmd/lvm-functions.c	2009/04/21 13:11:28	1.60
@@ -157,32 +157,79 @@
 	return last_error;
 }
 
-/* Return the mode a lock is currently held at (or -1 if not held) */
-static int get_current_lock(char *resource)
+/*
+ * Hash lock info helpers
+ */
+static struct lv_info *lookup_info(const char *resource)
 {
 	struct lv_info *lvi;
 
 	pthread_mutex_lock(&lv_hash_lock);
 	lvi = dm_hash_lookup(lv_hash, resource);
 	pthread_mutex_unlock(&lv_hash_lock);
-	if (lvi) {
+
+	return lvi;
+}
+
+static void insert_info(const char *resource, struct lv_info *lvi)
+{
+	pthread_mutex_lock(&lv_hash_lock);
+	dm_hash_insert(lv_hash, resource, lvi);
+	pthread_mutex_unlock(&lv_hash_lock);
+}
+
+static void remove_info(const char *resource)
+{
+	pthread_mutex_lock(&lv_hash_lock);
+	dm_hash_remove(lv_hash, resource);
+	pthread_mutex_unlock(&lv_hash_lock);
+}
+
+/*
+ * Return the mode a lock is currently held at (or -1 if not held)
+ */
+static int get_current_lock(char *resource)
+{
+	struct lv_info *lvi;
+
+	if ((lvi = lookup_info(resource)))
 		return lvi->lock_mode;
-	} else {
-		return -1;
-	}
+
+	return -1;
+}
+
+
+void init_lvhash()
+{
+	/* Create hash table for keeping LV locks & status */
+	lv_hash = dm_hash_create(100);
+	pthread_mutex_init(&lv_hash_lock, NULL);
+	pthread_mutex_init(&lvm_lock, NULL);
 }
 
 /* Called at shutdown to tidy the lockspace */
-void unlock_all()
+void destroy_lvhash()
 {
 	struct dm_hash_node *v;
+	struct lv_info *lvi;
+	char *resource;
+	int status;
 
 	pthread_mutex_lock(&lv_hash_lock);
+
 	dm_hash_iterate(v, lv_hash) {
-		struct lv_info *lvi = dm_hash_get_data(lv_hash, v);
+		lvi = dm_hash_get_data(lv_hash, v);
+		resource = dm_hash_get_key(lv_hash, v);
 
-		sync_unlock(dm_hash_get_key(lv_hash, v), lvi->lock_id);
+		if ((status = sync_unlock(resource, lvi->lock_id)))
+			DEBUGLOG("unlock_all. unlock failed(%d): %s\n",
+				 status,  strerror(errno));
+		free(lvi);
 	}
+
+	dm_hash_destroy(lv_hash);
+	lv_hash = NULL;
+
 	pthread_mutex_unlock(&lv_hash_lock);
 }
 
@@ -195,10 +242,7 @@
 
 	flags &= LKF_NOQUEUE;	/* Only LKF_NOQUEUE is valid here */
 
-	pthread_mutex_lock(&lv_hash_lock);
-	lvi = dm_hash_lookup(lv_hash, resource);
-	pthread_mutex_unlock(&lv_hash_lock);
-	if (lvi) {
+	if ((lvi = lookup_info(resource))) {
 		/* Already exists - convert it */
 		status =
 		    sync_lock(resource, mode, LKF_CONVERT | flags,
@@ -224,11 +268,9 @@
 			free(lvi);
 			DEBUGLOG("hold_lock. lock at %d failed: %s\n", mode,
 				 strerror(errno));
-		} else {
-		        pthread_mutex_lock(&lv_hash_lock);
-			dm_hash_insert(lv_hash, resource, lvi);
-			pthread_mutex_unlock(&lv_hash_lock);
-		}
+		} else
+			insert_info(resource, lvi);
+
 		errno = saved_errno;
 	}
 	return status;
@@ -241,10 +283,7 @@
 	int status;
 	int saved_errno;
 
-	pthread_mutex_lock(&lv_hash_lock);
-	lvi = dm_hash_lookup(lv_hash, resource);
-	pthread_mutex_unlock(&lv_hash_lock);
-	if (!lvi) {
+	if (!(lvi = lookup_info(resource))) {
 		DEBUGLOG("hold_unlock, lock not already held\n");
 		return 0;
 	}
@@ -252,9 +291,7 @@
 	status = sync_unlock(resource, lvi->lock_id);
 	saved_errno = errno;
 	if (!status) {
-	    	pthread_mutex_lock(&lv_hash_lock);
-		dm_hash_remove(lv_hash, resource);
-		pthread_mutex_unlock(&lv_hash_lock);
+		remove_info(resource);
 		free(lvi);
 	} else {
 		DEBUGLOG("hold_unlock. unlock failed(%d): %s\n", status,
@@ -699,14 +736,6 @@
 	log_error("locking_type not set correctly in lvm.conf, cluster operations will not work.");
 }
 
-void init_lvhash()
-{
-	/* Create hash table for keeping LV locks & status */
-	lv_hash = dm_hash_create(100);
-	pthread_mutex_init(&lv_hash_lock, NULL);
-	pthread_mutex_init(&lvm_lock, NULL);
-}
-
 /* Backups up the LVM metadata if it's changed */
 void lvm_do_backup(const char *vgname)
 {
--- LVM2/daemons/clvmd/lvm-functions.h	2008/05/09 15:13:20	1.8
+++ LVM2/daemons/clvmd/lvm-functions.h	2009/04/21 13:11:28	1.9
@@ -28,10 +28,10 @@
 extern int do_refresh_cache(void);
 extern int init_lvm(int using_gulm);
 extern void init_lvhash(void);
+extern void destroy_lvhash(void);
 extern void lvm_do_backup(const char *vgname);
 extern int hold_unlock(char *resource);
 extern int hold_lock(char *resource, int mode, int flags);
-extern void unlock_all(void);
 extern char *get_last_lvm_error(void);
 extern void drop_metadata(const char *vgname);
 


