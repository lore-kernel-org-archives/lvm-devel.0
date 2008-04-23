From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 23 Apr 2008 09:53:50 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-openais.c
Message-ID: <20080423095350.32558.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2008-04-23 09:53:49

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-openais.c 

Log message:
	Simplify locking code by using saLckResourceLock rather than
	saLckResourceLockAsync.
	
	Thanks to Xinwei Hu for the patch.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.857&r2=1.858
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-openais.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/WHATS_NEW	2008/04/22 12:54:32	1.857
+++ LVM2/WHATS_NEW	2008/04/23 09:53:49	1.858
@@ -1,5 +1,6 @@
 Version 2.02.36 - 
 =================================
+  Simply clvmd-openais by using non-async saLckResourceLock.
   Check lv_count in vg_validate.
   Fix internal LV counter when a snapshot is removed.
   Fix metadata corruption writing lvm1-formatted metadata with snapshots.
--- LVM2/daemons/clvmd/clvmd-openais.c	2007/07/11 12:07:39	1.3
+++ LVM2/daemons/clvmd/clvmd-openais.c	2008/04/23 09:53:49	1.4
@@ -50,11 +50,6 @@
 /* Timeout value for several openais calls */
 #define TIMEOUT 10
 
-static void lck_lock_callback(SaInvocationT invocation,
-			      SaLckLockStatusT lockStatus,
-			      SaAisErrorT error);
-static void lck_unlock_callback(SaInvocationT invocation,
-				SaAisErrorT error);
 static void cpg_deliver_callback (cpg_handle_t handle,
 				  struct cpg_name *groupName,
 				  uint32_t nodeid,
@@ -92,11 +87,6 @@
 	.cpg_confchg_fn =            cpg_confchg_callback,
 };
 
-SaLckCallbacksT lck_callbacks = {
-        .saLckLockGrantCallback      = lck_lock_callback,
-        .saLckResourceUnlockCallback = lck_unlock_callback
-};
-
 struct node_info
 {
 	enum {NODE_UNKNOWN, NODE_DOWN, NODE_UP, NODE_CLVMD} state;
@@ -305,32 +295,6 @@
 	num_nodes = joined_list_entries;
 }
 
-static void lck_lock_callback(SaInvocationT invocation,
-			      SaLckLockStatusT lockStatus,
-			      SaAisErrorT error)
-{
-	struct lock_wait *lwait = (struct lock_wait *)(long)invocation;
-
-	DEBUGLOG("lck_lock_callback, error = %d\n", error);
-
-	lwait->status = error;
-	pthread_mutex_lock(&lwait->mutex);
-	pthread_cond_signal(&lwait->cond);
-	pthread_mutex_unlock(&lwait->mutex);
-}
-
-static void lck_unlock_callback(SaInvocationT invocation,
-				SaAisErrorT error)
-{
-	struct lock_wait *lwait = (struct lock_wait *)(long)invocation;
-
-	DEBUGLOG("lck_unlock_callback\n");
-
-	lwait->status = SA_AIS_OK;
-	pthread_mutex_lock(&lwait->mutex);
-	pthread_cond_signal(&lwait->cond);
-	pthread_mutex_unlock(&lwait->mutex);
-}
 
 static int lck_dispatch(struct local_client *client, char *buf, int len,
 			const char *csid, struct local_client **new_client)
@@ -359,7 +323,7 @@
 	}
 
 	err = saLckInitialize(&lck_handle,
-			      &lck_callbacks,
+					NULL,
 			      &ver);
 	if (err != SA_AIS_OK) {
 		cpg_initialize(&cpg_handle, &cpg_callbacks);
@@ -495,15 +459,11 @@
 /* Real locking */
 static int _lock_resource(char *resource, int mode, int flags, int *lockid)
 {
-	struct lock_wait lwait;
 	struct lock_info *linfo;
 	SaLckResourceHandleT res_handle;
 	SaAisErrorT err;
 	SaLckLockIdT lock_id;
-
-	pthread_cond_init(&lwait.cond, NULL);
-	pthread_mutex_init(&lwait.mutex, NULL);
-	pthread_mutex_lock(&lwait.mutex);
+	SaLckLockStatusT lockStatus;
 
 	/* This needs to be converted from DLM/LVM2 value for OpenAIS LCK */
 	if (flags & LCK_NONBLOCK) flags = SA_LCK_LOCK_NO_QUEUE;
@@ -526,24 +486,24 @@
 		return ais_to_errno(err);
 	}
 
-	err = saLckResourceLockAsync(res_handle,
-				     (SaInvocationT)(long)&lwait,
-				     &lock_id,
-				     mode,
-				     flags,
-				     0);
-	if (err != SA_AIS_OK)
+	err = saLckResourceLock(
+			res_handle,
+			&lock_id,
+			mode,
+			flags,
+			0,
+			SA_TIME_END,
+			&lockStatus);
+	if (err != SA_AIS_OK && lockStatus != SA_LCK_LOCK_GRANTED)
 	{
 		free(linfo);
 		saLckResourceClose(res_handle);
 		return ais_to_errno(err);
 	}
-
+			
 	/* Wait for it to complete */
-	pthread_cond_wait(&lwait.cond, &lwait.mutex);
-	pthread_mutex_unlock(&lwait.mutex);
 
-	DEBUGLOG("lock_resource returning %d, lock_id=%llx\n", lwait.status,
+	DEBUGLOG("lock_resource returning %d, lock_id=%llx\n", err,
 		 lock_id);
 
 	linfo->lock_id = lock_id;
@@ -551,43 +511,34 @@
 
 	dm_hash_insert(lock_hash, resource, linfo);
 
-	return ais_to_errno(lwait.status);
+	return ais_to_errno(err);
 }
 
 
 static int _unlock_resource(char *resource, int lockid)
 {
-	struct lock_wait lwait;
 	SaAisErrorT err;
 	struct lock_info *linfo;
 
-	pthread_cond_init(&lwait.cond, NULL);
-	pthread_mutex_init(&lwait.mutex, NULL);
-	pthread_mutex_lock(&lwait.mutex);
-
 	DEBUGLOG("unlock_resource %s\n", resource);
 	linfo = dm_hash_lookup(lock_hash, resource);
 	if (!linfo)
 		return 0;
 
 	DEBUGLOG("unlock_resource: lockid: %llx\n", linfo->lock_id);
-	err = saLckResourceUnlockAsync((SaInvocationT)(long)&lwait, linfo->lock_id);
+	err = saLckResourceUnlock(linfo->lock_id, SA_TIME_END);
 	if (err != SA_AIS_OK)
 	{
 		DEBUGLOG("Unlock returned %d\n", err);
 		return ais_to_errno(err);
 	}
 
-	/* Wait for it to complete */
-	pthread_cond_wait(&lwait.cond, &lwait.mutex);
-	pthread_mutex_unlock(&lwait.mutex);
-
 	/* Release the resource */
 	dm_hash_remove(lock_hash, resource);
 	saLckResourceClose(linfo->res_handle);
 	free(linfo);
 
-	return ais_to_errno(lwait.status);
+	return ais_to_errno(err);
 }
 
 static int _sync_lock(const char *resource, int mode, int flags, int *lockid)


