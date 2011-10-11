From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Oct 2011 09:05:21 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-singlenode.c
Message-ID: <20111011090521.32309.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-11 09:05:20

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-singlenode.c 

Log message:
	Use condition instead of sleep
	
	Replace usleep with pthread condition to increase speed testing
	(for simplicity just 1 condition for all locks).
	
	Use thread mutex also for unlock resource (so it wakes up awaiting
	threads)
	
	Better check some error states and return error in fail case with
	unlocked mutex.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2154&r2=1.2155
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-singlenode.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/WHATS_NEW	2011/10/11 08:59:42	1.2154
+++ LVM2/WHATS_NEW	2011/10/11 09:05:20	1.2155
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Use pthread condition for SINGLENODE lock implementation.
   Improve backtrace reporting for some dev_manager_ functions.
   Change message severity to log_warn when symlink creation fails.
   Add ability to convert mirror segtype to RAID1 segtype.
--- LVM2/daemons/clvmd/clvmd-singlenode.c	2011/09/29 08:57:21	1.13
+++ LVM2/daemons/clvmd/clvmd-singlenode.c	2011/10/11 09:05:20	1.14
@@ -147,6 +147,8 @@
 
 static int _lock_max = 1;
 static pthread_mutex_t _lock_mutex = PTHREAD_MUTEX_INITIALIZER;
+/* Using one common condition for all locks for simplicity */
+static pthread_cond_t _lock_cond = PTHREAD_COND_INITIALIZER;
 
 /* Real locking */
 static int _lock_resource(const char *resource, int mode, int flags, int *lockid)
@@ -155,11 +157,11 @@
 	char **_resources_1;
 	int i, j;
 
-	DEBUGLOG("lock_resource '%s', flags=%d, mode=%d\n",
+	DEBUGLOG("Locking resource %s, flags=%d, mode=%d\n",
 		 resource, flags, mode);
 
- retry:
 	pthread_mutex_lock(&_lock_mutex);
+retry:
 
 	/* look for an existing lock for this resource */
 	for (i = 1; i < _lock_max; ++i) {
@@ -168,12 +170,12 @@
 		if (!strcmp(_resources[i], resource)) {
 			if ((_locks[i] & LCK_TYPE_MASK) == LCK_WRITE ||
 			    (_locks[i] & LCK_TYPE_MASK) == LCK_EXCL) {
-				DEBUGLOG("%s already write/exclusively locked...\n", resource);
+				DEBUGLOG("Resource %s already write/exclusively locked...\n", resource);
 				goto maybe_retry;
 			}
 			if ((mode & LCK_TYPE_MASK) == LCK_WRITE ||
 			    (mode & LCK_TYPE_MASK) == LCK_EXCL) {
-				DEBUGLOG("%s already locked and WRITE/EXCL lock requested...\n",
+				DEBUGLOG("Resource %s already locked and WRITE/EXCL lock requested...\n",
 					 resource);
 				goto maybe_retry;
 			}
@@ -181,15 +183,14 @@
 	}
 
 	if (i == _lock_max) { /* out of lock slots, extend */
-		_locks_1 = dm_realloc(_locks, 2 * _lock_max * sizeof(int));
-		if (!_locks_1)
-			return 1; /* fail */
+		if (!(_locks_1 = dm_realloc(_locks, 2 * _lock_max * sizeof(int))))
+			goto_bad;
+
 		_locks = _locks_1;
-		_resources_1 = dm_realloc(_resources, 2 * _lock_max * sizeof(char *));
-		if (!_resources_1) {
+		if (!(_resources_1 = dm_realloc(_resources, 2 * _lock_max * sizeof(char *))))
 			/* _locks may get realloc'd twice, but that should be safe */
-			return 1; /* fail */
-		}
+			goto_bad;
+
 		_resources = _resources_1;
 		/* clear the new resource entries */
 		for (j = _lock_max; j < 2 * _lock_max; ++j)
@@ -198,40 +199,52 @@
 	}
 
 	/* resource is not currently locked, grab it */
+	if (!(_resources[i] = dm_strdup(resource)))
+		goto_bad;
 
 	*lockid = i;
 	_locks[i] = mode;
-	_resources[i] = dm_strdup(resource);
-
-	DEBUGLOG("%s locked -> %d\n", resource, i);
 
+	DEBUGLOG("Locked resource %s, lockid=%d\n", resource, i);
 	pthread_mutex_unlock(&_lock_mutex);
+
 	return 0;
- maybe_retry:
-	pthread_mutex_unlock(&_lock_mutex);
+
+maybe_retry:
 	if (!(flags & LCK_NONBLOCK)) {
-		usleep(10000);
+		pthread_cond_wait(&_lock_cond, &_lock_mutex);
 		goto retry;
 	}
+bad:
+	DEBUGLOG("Failed to lock resource %s\n", resource);
+	pthread_mutex_unlock(&_lock_mutex);
 
 	return 1; /* fail */
 }
 
 static int _unlock_resource(const char *resource, int lockid)
 {
-	DEBUGLOG("unlock_resource: %s lockid: %x\n", resource, lockid);
-	if(!_resources[lockid]) {
-		DEBUGLOG("(%s) %d not locked\n", resource, lockid);
+	DEBUGLOG("Unlocking resource %s, lockid=%d\n", resource, lockid);
+	pthread_mutex_lock(&_lock_mutex);
+
+	if (!_resources[lockid]) {
+		pthread_mutex_unlock(&_lock_mutex);
+		DEBUGLOG("Resource %s, lockid=%d is not locked\n", resource, lockid);
 		return 1;
 	}
-	if(strcmp(_resources[lockid], resource)) {
-		DEBUGLOG("%d has wrong resource (requested %s, got %s)\n",
+
+	if (strcmp(_resources[lockid], resource)) {
+		pthread_mutex_unlock(&_lock_mutex);
+		DEBUGLOG("Resource %d has wrong resource (requested %s, got %s)\n",
 			 lockid, resource, _resources[lockid]);
 		return 1;
 	}
 
 	dm_free(_resources[lockid]);
 	_resources[lockid] = 0;
+	pthread_cond_broadcast(&_lock_cond); /* wakeup waiters */
+	pthread_mutex_unlock(&_lock_mutex);
+
 	return 0;
 }
 


