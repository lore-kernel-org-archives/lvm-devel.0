From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  8 Apr 2015 21:20:30 +0000 (UTC)
Subject: master - clvmd: singlenode signals only when lock changes
Message-ID: <20150408212030.991066055A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4459413225eaa10278bd47fc33e30b85794ad7f6
Commit:        4459413225eaa10278bd47fc33e30b85794ad7f6
Parent:        f32973c78e981226577e88db662a285ea6c11bd5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 8 23:12:29 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 8 23:19:34 2015 +0200

clvmd: singlenode signals only when lock changes

There is no benefit in waking-up all the waiters
when there is no actual change in lock state.
This avoid some unnecessarily ping-pong effects like:

 Resource V_LVMTEST15724vg retrying lock in mode:WRITE...
 Resource V_LVMTEST15724vg already locked lockid=40, mode:WRITE
 Resource V_LVMTEST15724vg retrying lock in mode:WRITE...
 Resource V_LVMTEST15724vg already locked lockid=40, mode:WRITE
---
 WHATS_NEW                        |    1 +
 daemons/clvmd/clvmd-singlenode.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 79136f9..6f43437 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.119 - 
 ==================================
+  More efficient clvmd singlenode locking emulation.
   Don't skip invalidation of cached orphans if vg write lck is held (2.02.118).
   Log relevant PV tags when using cling allocation.
   Add str_list_add_list() to combine two lists.
diff --git a/daemons/clvmd/clvmd-singlenode.c b/daemons/clvmd/clvmd-singlenode.c
index e6d2b0d..dc9360d 100644
--- a/daemons/clvmd/clvmd-singlenode.c
+++ b/daemons/clvmd/clvmd-singlenode.c
@@ -208,8 +208,6 @@ static int _lock_resource(const char *resource, int mode, int flags, int *lockid
 	pthread_mutex_lock(&_lock_mutex);
 
 retry:
-	pthread_cond_broadcast(&_lock_cond); /* to wakeup waiters */
-
 	if (!(head = dm_hash_lookup(_locks, resource))) {
 		if (flags & LCKF_CONVERT) {
 			/* In real DLM, lock is identified only by lockid, resource is not used */
@@ -269,12 +267,14 @@ retry:
 		dm_list_add(head, &lck->list);
 	}
 out:
+	pthread_cond_broadcast(&_lock_cond); /* to wakeup waiters */
 	pthread_mutex_unlock(&_lock_mutex);
 	DEBUGLOG("Locked resource %s, lockid=%d, mode=%s\n",
 		 resource, lck->lockid, _get_mode(lck->mode));
 
 	return 0;
 bad:
+	pthread_cond_broadcast(&_lock_cond); /* to wakeup waiters */
 	pthread_mutex_unlock(&_lock_mutex);
 	DEBUGLOG("Failed to lock resource %s\n", resource);
 


