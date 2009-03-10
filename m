From: Milan Broz <mbroz@redhat.com>
Date: Tue, 10 Mar 2009 18:41:47 +0100
Subject: [PATCH 1/2] clvmd: tidy lock hash manipulation
Message-ID: <49B6A65B.7020805@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Tidy lv_hash[_lock] use inside clvmd.

 - Rename unlock_all to destroy_lvhash,
this function is called in cluster shutdown
unlocks everything and clean up allocated info space.

 - Tidy lv_hash_lock use
 
Except adding free(lvi) in lv_hash destructor
there is no functional change.

(just cleaning code before the next patch)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 daemons/clvmd/clvmd-cman.c     |    2 +-
 daemons/clvmd/clvmd-corosync.c |    2 +-
 daemons/clvmd/clvmd-gulm.c     |    2 +-
 daemons/clvmd/clvmd-openais.c  |    2 +-
 daemons/clvmd/lvm-functions.c  |   95 ++++++++++++++++++++++++++--------------
 daemons/clvmd/lvm-functions.h  |    2 +-
 6 files changed, 67 insertions(+), 38 deletions(-)

diff --git a/daemons/clvmd/clvmd-cman.c b/daemons/clvmd/clvmd-cman.c
index a853b3b..dec6331 100644
--- a/daemons/clvmd/clvmd-cman.c
+++ b/daemons/clvmd/clvmd-cman.c
@@ -263,7 +263,7 @@ static void _add_up_node(const char *csid)
 
 static void _cluster_closedown()
 {
-	unlock_all();
+	destroy_lvhash();
 	dlm_release_lockspace(LOCKSPACE_NAME, lockspace, 1);
 	cman_finish(c_handle);
 }
diff --git a/daemons/clvmd/clvmd-corosync.c b/daemons/clvmd/clvmd-corosync.c
index 9cacc30..4a4f788 100644
--- a/daemons/clvmd/clvmd-corosync.c
+++ b/daemons/clvmd/clvmd-corosync.c
@@ -359,7 +359,7 @@ static int _init_cluster(void)
 static void _cluster_closedown(void)
 {
 	DEBUGLOG("cluster_closedown\n");
-	unlock_all();
+	destroy_lvhash();
 
 	dlm_release_lockspace(LOCKSPACE_NAME, lockspace, 0);
 	cpg_finalize(cpg_handle);
diff --git a/daemons/clvmd/clvmd-gulm.c b/daemons/clvmd/clvmd-gulm.c
index 5d4d3a7..4bb1b65 100644
--- a/daemons/clvmd/clvmd-gulm.c
+++ b/daemons/clvmd/clvmd-gulm.c
@@ -248,7 +248,7 @@ static void _cluster_closedown(void)
 {
     DEBUGLOG("cluster_closedown\n");
     in_shutdown = 1;
-    unlock_all();
+    destroy_lvhash();
     lg_lock_logout(gulm_if);
     lg_core_logout(gulm_if);
     lg_release(gulm_if);
diff --git a/daemons/clvmd/clvmd-openais.c b/daemons/clvmd/clvmd-openais.c
index 58da43a..3101069 100644
--- a/daemons/clvmd/clvmd-openais.c
+++ b/daemons/clvmd/clvmd-openais.c
@@ -382,7 +382,7 @@ static int _init_cluster(void)
 static void _cluster_closedown(void)
 {
 	DEBUGLOG("cluster_closedown\n");
-	unlock_all();
+	destroy_lvhash();
 
 	saLckFinalize(lck_handle);
 	cpg_finalize(cpg_handle);
diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 25ae49b..2b8dfdb 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -157,32 +157,79 @@ char *get_last_lvm_error()
 	return last_error;
 }
 
-/* Return the mode a lock is currently held at (or -1 if not held) */
-static int get_current_lock(char *resource)
+/*
+ * Hasked lock info helpers
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
 
@@ -195,10 +242,7 @@ int hold_lock(char *resource, int mode, int flags)
 
 	flags &= LKF_NOQUEUE;	/* Only LKF_NOQUEUE is valid here */
 
-	pthread_mutex_lock(&lv_hash_lock);
-	lvi = dm_hash_lookup(lv_hash, resource);
-	pthread_mutex_unlock(&lv_hash_lock);
-	if (lvi) {
+	if ((lvi = lookup_info(resource))) {
 		/* Already exists - convert it */
 		status =
 		    sync_lock(resource, mode, LKF_CONVERT | flags,
@@ -224,11 +268,9 @@ int hold_lock(char *resource, int mode, int flags)
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
@@ -241,10 +283,7 @@ int hold_unlock(char *resource)
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
@@ -252,9 +291,7 @@ int hold_unlock(char *resource)
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
@@ -699,14 +736,6 @@ static void check_config()
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
diff --git a/daemons/clvmd/lvm-functions.h b/daemons/clvmd/lvm-functions.h
index bf42dbe..0b6866a 100644
--- a/daemons/clvmd/lvm-functions.h
+++ b/daemons/clvmd/lvm-functions.h
@@ -28,10 +28,10 @@ extern int do_check_lvm1(const char *vgname);
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
 



