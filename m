From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Sep 2013 08:42:21 +0000 (UTC)
Subject: master - tests: singlenode updates
Message-ID: <20130912084221.A135660F67@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a6abcb80a0b29334484325318aa643fd024fde8
Commit:        2a6abcb80a0b29334484325318aa643fd024fde8
Parent:        7b5f2e7f34e3236382f4ca8351a12de73956117d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 11 23:46:20 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 12 10:40:39 2013 +0200

tests: singlenode updates

Add more 'realistic' simulation of dlm locking.
Previous version was not capable to maintain multiple locks.
Current version doesn't handle multiqueues for locks,
so the ordering is different.
---
 WHATS_NEW                        |    1 +
 daemons/clvmd/clvmd-singlenode.c |  178 ++++++++++++++++++++++++++------------
 2 files changed, 122 insertions(+), 57 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2245d56..c61070e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Improve of clvmd singlenode locking simulation.
   Disallow thinpools on mirror logical volumes.
   Direct udev to use 3min timeout for LVM devices. Recent udev has default 30s.
   Do not scan multipath or RAID components and avoid incorrect autoactivation.
diff --git a/daemons/clvmd/clvmd-singlenode.c b/daemons/clvmd/clvmd-singlenode.c
index 756c589..8103dcc 100644
--- a/daemons/clvmd/clvmd-singlenode.c
+++ b/daemons/clvmd/clvmd-singlenode.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2009-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -32,10 +32,14 @@ static int listen_fd = -1;
 static struct dm_hash_table *_locks;
 static int _lockid;
 
+static pthread_mutex_t _lock_mutex = PTHREAD_MUTEX_INITIALIZER;
+/* Using one common condition for all locks for simplicity */
+static pthread_cond_t _lock_cond = PTHREAD_COND_INITIALIZER;
+
 struct lock {
+	struct dm_list list;
 	int lockid;
 	int mode;
-	int excl;
 };
 
 static void close_comms(void)
@@ -118,9 +122,13 @@ static void _cluster_closedown(void)
 
 	DEBUGLOG("cluster_closedown\n");
 	destroy_lvhash();
+	/* If there is any awaited resource, kill it softly */
+	pthread_mutex_lock(&_lock_mutex);
 	dm_hash_destroy(_locks);
 	_locks = NULL;
 	_lockid = 0;
+	pthread_cond_broadcast(&_lock_cond); /* wakeup waiters */
+	pthread_mutex_unlock(&_lock_mutex);
 }
 
 static void _get_our_csid(char *csid)
@@ -160,63 +168,110 @@ static int _cluster_do_node_callback(struct local_client *master_client,
 
 int _lock_file(const char *file, uint32_t flags);
 
-static pthread_mutex_t _lock_mutex = PTHREAD_MUTEX_INITIALIZER;
-/* Using one common condition for all locks for simplicity */
-static pthread_cond_t _lock_cond = PTHREAD_COND_INITIALIZER;
+static const char *_get_mode(int mode)
+{
+	switch (mode) {
+	case LCK_NULL: return "NULL";
+	case LCK_READ: return "READ";
+	case LCK_PREAD: return "PREAD";
+	case LCK_WRITE: return "WRITE";
+	case LCK_EXCL: return "EXCLUSIVE";
+	case LCK_UNLOCK: return "UNLOCK";
+	default: return "????";
+	}
+}
 
 /* Real locking */
 static int _lock_resource(const char *resource, int mode, int flags, int *lockid)
 {
-	struct lock *lck;
-
-	DEBUGLOG("Locking resource %s, flags=%d, mode=%d\n",
-		 resource, flags, mode);
+	/* DLM table of allowed transition states */
+	static const int _dlm_table[6][6] = {
+	/* Mode	   NL	CR	CW	PR	PW	EX */
+	/* NL */ { 1,	 1,	 1,	 1,	 1,	 1},
+	/* CR */ { 1,	 1,	 1,	 1,	 1,	 0},
+	/* CW */ { 1,	 1,	 1,	 0,	 0,	 0},
+	/* PR */ { 1,	 1,	 0,	 1,	 0,	 0},
+	/* PW */ { 1,	 1,	 0,	 0,	 0,	 0},
+	/* EX */ { 1,	 0,	 0,	 0,	 0,	 0}
+	};
+
+	struct lock *lck, *lckt;
+	struct dm_list *head;
+
+	DEBUGLOG("Locking resource %s, flags=0x%02x (%s%s%s), mode=%s (%d)\n",
+		 resource, flags,
+		 (flags & LCKF_NOQUEUE) ? "NOQUEUE" : "",
+		 ((flags & (LCKF_NOQUEUE | LCKF_CONVERT)) ==
+		  (LCKF_NOQUEUE | LCKF_CONVERT)) ? "|" : "",
+		 (flags & LCKF_CONVERT) ? "CONVERT" : "",
+		 _get_mode(mode), mode);
 
 	mode &= LCK_TYPE_MASK;
 	pthread_mutex_lock(&_lock_mutex);
-retry:
-	if (!(lck = dm_hash_lookup(_locks, resource))) {
-		/* Add new locked resource */
-		if (!(lck = dm_zalloc(sizeof(struct lock))) ||
-		    !dm_hash_insert(_locks, resource, lck))
-			goto bad;
 
-		lck->lockid = ++_lockid;
-		goto out;
-	}
+retry:
+	pthread_cond_broadcast(&_lock_cond); /* to wakeup waiters */
 
-        /* Update/convert lock */
-	if (flags == LCKF_CONVERT) {
-		if (lck->excl)
-			mode = LCK_EXCL;
-	} else if ((lck->mode == LCK_WRITE) || (lck->mode == LCK_EXCL)) {
-		DEBUGLOG("Resource %s already %s locked (%d)...\n", resource,
-			 (lck->mode == LCK_WRITE) ? "write" : "exclusively", lck->lockid);
-		goto maybe_retry;
-	} else if (lck->mode > mode) {
-		DEBUGLOG("Resource %s already locked and %s lock requested...\n",
-			 resource,
-			 (mode == LCK_READ) ? "READ" :
-			 (mode == LCK_WRITE) ? "WRITE" : "EXCLUSIVE");
-		goto maybe_retry;
+	if (!(head = dm_hash_lookup(_locks, resource))) {
+		/* Add new locked resource */
+		if (!(head = dm_malloc(sizeof(struct dm_list))) ||
+		    !dm_hash_insert(_locks, resource, head)) {
+			dm_free(head);
+			goto_bad;
+		}
+
+		dm_list_init(head);
+	} else	/* Update/convert locked resource */
+		dm_list_iterate_items(lck, head) {
+			/* FIXME Unsure what is LCKF_CONVERT about....*/
+			if (flags & LCKF_CONVERT) {
+				if (lck->lockid != *lockid)
+					continue;
+
+				DEBUGLOG("Converting resource %s lockid=%d mode:%s -> %s...\n",
+					 resource, lck->lockid, _get_mode(lck->mode), _get_mode(mode));
+				/* Check if converted lock is compatible with locks we already have */
+				dm_list_iterate_items(lckt, head) {
+					if ((lckt->lockid != *lockid) &&
+					    !_dlm_table[mode][lckt->mode]) {
+						if (!(flags & LCKF_NOQUEUE) &&
+						    /* TODO: Real dlm uses here conversion queues */
+						    !pthread_cond_wait(&_lock_cond, &_lock_mutex) &&
+						    _locks) /* End of the game? */
+							goto retry;
+						goto bad;
+					}
+				}
+				lck->mode = mode; /* Lock is now converted */
+				goto out;
+			} else if (!_dlm_table[mode][lck->mode]) {
+				DEBUGLOG("Resource %s already locked lockid=%d, mode:%s\n",
+					 resource, lck->lockid, _get_mode(lck->mode));
+				if (!(flags & LCKF_NOQUEUE) &&
+				    !pthread_cond_wait(&_lock_cond, &_lock_mutex) &&
+				    _locks) { /* End of the game? */
+					DEBUGLOG("Resource %s retrying lock in mode:%s...\n",
+						 resource, _get_mode(mode));
+					goto retry;
+				}
+				goto bad;
+			}
+		}
+
+	if (!(flags & LCKF_CONVERT)) {
+		if (!(lck = dm_malloc(sizeof(struct lock))))
+			goto_bad;
+
+		*lockid = lck->lockid = ++_lockid;
+		lck->mode = mode;
+		dm_list_add(head, &lck->list);
 	}
-
 out:
-	*lockid = lck->lockid;
-	lck->mode = mode;
-	lck->excl |= (mode == LCK_EXCL);
-	DEBUGLOG("Locked resource %s, lockid=%d, mode=%d\n", resource, lck->lockid, mode);
-	pthread_cond_broadcast(&_lock_cond); /* wakeup waiters */
 	pthread_mutex_unlock(&_lock_mutex);
+	DEBUGLOG("Locked resource %s, lockid=%d, mode=%s\n",
+		 resource, lck->lockid, _get_mode(lck->mode));
 
 	return 0;
-
-maybe_retry:
-	if (!(flags & LCK_NONBLOCK)) {
-		pthread_cond_wait(&_lock_cond, &_lock_mutex);
-		DEBUGLOG("Resource %s RETRYING lock...\n", resource);
-		goto retry;
-	}
 bad:
 	pthread_mutex_unlock(&_lock_mutex);
 	DEBUGLOG("Failed to lock resource %s\n", resource);
@@ -227,35 +282,44 @@ bad:
 static int _unlock_resource(const char *resource, int lockid)
 {
 	struct lock *lck;
+	struct dm_list *head;
+	int r = 1;
 
 	if (lockid < 0) {
 		DEBUGLOG("Not tracking unlock of lockid -1: %s, lockid=%d\n",
 			 resource, lockid);
-		return 0;
+		return 1;
 	}
 
 	DEBUGLOG("Unlocking resource %s, lockid=%d\n", resource, lockid);
 	pthread_mutex_lock(&_lock_mutex);
+	pthread_cond_broadcast(&_lock_cond); /* wakeup waiters */
 
-	if (!(lck = dm_hash_lookup(_locks, resource))) {
+	if (!(head = dm_hash_lookup(_locks, resource))) {
 		pthread_mutex_unlock(&_lock_mutex);
-		DEBUGLOG("Resource %s, lockid=%d is not locked.\n", resource, lockid);
+		DEBUGLOG("Resource %s is not locked.\n", resource, lockid);
 		return 1;
 	}
 
-	if (lck->lockid != lockid) {
-		pthread_mutex_unlock(&_lock_mutex);
-		DEBUGLOG("Resource %s has wrong lockid %d, expected %d.\n",
-			 resource, lck->lockid, lockid);
-		return 1;
+	dm_list_iterate_items(lck, head)
+		if (lck->lockid == lockid) {
+			dm_list_del(&lck->list);
+			dm_free(lck);
+			r = 0;
+			goto out;
+		}
+
+	DEBUGLOG("Resource %s has wrong lockid %d.\n", resource, lockid);
+out:
+	if (dm_list_empty(head)) {
+		//DEBUGLOG("Resource %s is no longer hashed (lockid=%d).\n", resource, lockid);
+		dm_hash_remove(_locks, resource);
+		dm_free(head);
 	}
 
-	dm_hash_remove(_locks, resource);
-	pthread_cond_broadcast(&_lock_cond); /* wakeup waiters */
 	pthread_mutex_unlock(&_lock_mutex);
-	dm_free(lck);
 
-	return 0;
+	return r;
 }
 
 static int _is_quorate(void)


