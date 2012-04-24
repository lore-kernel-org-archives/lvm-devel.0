From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Apr 2012 12:16:41 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-singlenode.c
Message-ID: <20120424121641.30698.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-04-24 12:16:40

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-singlenode.c 

Log message:
	Update singlenode locking
	
	Support lock conversion
	Work also with LCK_READ
	TODO: do more validation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2388&r2=1.2389
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-singlenode.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/WHATS_NEW	2012/04/24 12:13:29	1.2388
+++ LVM2/WHATS_NEW	2012/04/24 12:16:40	1.2389
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Improve clmvd singlenode locking for better testing.
   Update and correct lvs man page with supported column names.
   Handle replacement of an active device that goes missing with an error device.
   Change change raid1 segtype always to request a flush when suspending.
--- LVM2/daemons/clvmd/clvmd-singlenode.c	2011/11/07 17:11:23	1.15
+++ LVM2/daemons/clvmd/clvmd-singlenode.c	2012/04/24 12:16:40	1.16
@@ -28,8 +28,15 @@
 
 static const char SINGLENODE_CLVMD_SOCKNAME[] = DEFAULT_RUN_DIR "/clvmd_singlenode.sock";
 static int listen_fd = -1;
-static int *_locks = NULL;
-static char **_resources = NULL;
+
+static struct dm_hash_table *_locks;
+static int _lockid;
+
+struct lock {
+	int lockid;
+	int mode;
+	int excl;
+};
 
 static void close_comms(void)
 {
@@ -88,9 +95,16 @@
 {
 	int r;
 
+	if (!(_locks = dm_hash_create(128))) {
+		DEBUGLOG("Failed to allocate single-node hash table.\n");
+		return 1;
+	}
+
 	r = init_comms();
-	if (r)
+	if (r) {
+		dm_hash_destroy(_locks);
 		return r;
+	}
 
 	DEBUGLOG("Single-node cluster initialised.\n");
 	return 0;
@@ -102,10 +116,9 @@
 
 	DEBUGLOG("cluster_closedown\n");
 	destroy_lvhash();
-	dm_free(_locks);
-	dm_free(_resources);
+	dm_hash_destroy(_locks);
 	_locks = NULL;
-	_resources = NULL;
+	_lockid = 0;
 }
 
 static void _get_our_csid(char *csid)
@@ -145,7 +158,6 @@
 
 int _lock_file(const char *file, uint32_t flags);
 
-static int _lock_max = 1;
 static pthread_mutex_t _lock_mutex = PTHREAD_MUTEX_INITIALIZER;
 /* Using one common condition for all locks for simplicity */
 static pthread_cond_t _lock_cond = PTHREAD_COND_INITIALIZER;
@@ -153,66 +165,46 @@
 /* Real locking */
 static int _lock_resource(const char *resource, int mode, int flags, int *lockid)
 {
-	int *_locks_1;
-	char **_resources_1;
-	int i, j;
-
-	if (mode == LCK_READ) { /* only track PREAD, aka PROTECTED READ */
-		DEBUGLOG("Not tracking CONCURRENT READ lock: %s, flags=%d, mode=%d\n",
-			 resource, flags, mode);
-		*lockid = -1;
-		return 0;
-	}
+	struct lock *lck;
 
 	DEBUGLOG("Locking resource %s, flags=%d, mode=%d\n",
 		 resource, flags, mode);
 
+	mode &= LCK_TYPE_MASK;
 	pthread_mutex_lock(&_lock_mutex);
 retry:
-
-	/* look for an existing lock for this resource */
-	for (i = 1; i < _lock_max; ++i) {
-		if (!_resources[i])
-			break;
-		if (!strcmp(_resources[i], resource)) {
-			if ((_locks[i] & LCK_TYPE_MASK) == LCK_WRITE ||
-			    (_locks[i] & LCK_TYPE_MASK) == LCK_EXCL) {
-				DEBUGLOG("Resource %s already write/exclusively locked...\n", resource);
-				goto maybe_retry;
-			}
-			if ((mode & LCK_TYPE_MASK) == LCK_WRITE ||
-			    (mode & LCK_TYPE_MASK) == LCK_EXCL) {
-				DEBUGLOG("Resource %s already locked and WRITE/EXCL lock requested...\n",
-					 resource);
-				goto maybe_retry;
-			}
-		}
-	}
-
-	if (i == _lock_max) { /* out of lock slots, extend */
-		if (!(_locks_1 = dm_realloc(_locks, 2 * _lock_max * sizeof(int))))
-			goto_bad;
-
-		_locks = _locks_1;
-		if (!(_resources_1 = dm_realloc(_resources, 2 * _lock_max * sizeof(char *))))
-			/* _locks may get realloc'd twice, but that should be safe */
-			goto_bad;
-
-		_resources = _resources_1;
-		/* clear the new resource entries */
-		for (j = _lock_max; j < 2 * _lock_max; ++j)
-			_resources[j] = NULL;
-		_lock_max = 2 * _lock_max;
-	}
-
-	/* resource is not currently locked, grab it */
-	if (!(_resources[i] = dm_strdup(resource)))
-		goto_bad;
-
-	*lockid = i;
-	_locks[i] = mode;
-
-	DEBUGLOG("Locked resource %s, lockid=%d\n", resource, i);
+	if (!(lck = dm_hash_lookup(_locks, resource))) {
+		/* Add new locked resource */
+		if (!(lck = dm_zalloc(sizeof(struct lock))) ||
+		    !dm_hash_insert(_locks, resource, lck))
+			goto bad;
+
+		lck->lockid = ++_lockid;
+		goto out;
+	}
+
+        /* Update/convert lock */
+	if (flags == LCKF_CONVERT) {
+		if (lck->excl)
+			mode = LCK_EXCL;
+	} else if ((lck->mode == LCK_WRITE) || (lck->mode == LCK_EXCL)) {
+		DEBUGLOG("Resource %s already %s locked (%d)...\n", resource,
+			 (lck->mode == LCK_WRITE) ? "write" : "exclusively", lck->lockid);
+		goto maybe_retry;
+	} else if (lck->mode > mode) {
+		DEBUGLOG("Resource %s already locked and %s lock requested...\n",
+			 resource,
+			 (mode == LCK_READ) ? "READ" :
+			 (mode == LCK_WRITE) ? "WRITE" : "EXCLUSIVE");
+		goto maybe_retry;
+	}
+
+out:
+	*lockid = lck->lockid;
+	lck->mode = mode;
+	lck->excl |= (mode == LCK_EXCL);
+	DEBUGLOG("Locked resource %s, lockid=%d, mode=%d\n", resource, lck->lockid, mode);
+	pthread_cond_broadcast(&_lock_cond); /* wakeup waiters */
 	pthread_mutex_unlock(&_lock_mutex);
 
 	return 0;
@@ -220,6 +212,7 @@
 maybe_retry:
 	if (!(flags & LCK_NONBLOCK)) {
 		pthread_cond_wait(&_lock_cond, &_lock_mutex);
+		DEBUGLOG("Resource %s RETRYING lock...\n", resource);
 		goto retry;
 	}
 bad:
@@ -231,6 +224,8 @@
 
 static int _unlock_resource(const char *resource, int lockid)
 {
+	struct lock *lck;
+
 	if (lockid < 0) {
 		DEBUGLOG("Not tracking unlock of lockid -1: %s, lockid=%d\n",
 			 resource, lockid);
@@ -240,21 +235,21 @@
 	DEBUGLOG("Unlocking resource %s, lockid=%d\n", resource, lockid);
 	pthread_mutex_lock(&_lock_mutex);
 
-	if (!_resources[lockid]) {
+	if (!(lck = dm_hash_lookup(_locks, resource))) {
 		pthread_mutex_unlock(&_lock_mutex);
-		DEBUGLOG("Resource %s, lockid=%d is not locked\n", resource, lockid);
+		DEBUGLOG("Resource %s, lockid=%d is not locked.\n", resource, lockid);
 		return 1;
 	}
 
-	if (strcmp(_resources[lockid], resource)) {
+	if (lck->lockid != lockid) {
 		pthread_mutex_unlock(&_lock_mutex);
-		DEBUGLOG("Resource %d has wrong resource (requested %s, got %s)\n",
-			 lockid, resource, _resources[lockid]);
+		DEBUGLOG("Resource %s has wrong lockid %d, expected %d.\n",
+			 resource, lck->lockid, lockid);
 		return 1;
 	}
 
-	dm_free(_resources[lockid]);
-	_resources[lockid] = 0;
+	dm_hash_remove(_locks, resource);
+	dm_free(lck);
 	pthread_cond_broadcast(&_lock_cond); /* wakeup waiters */
 	pthread_mutex_unlock(&_lock_mutex);
 


