From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Sep 2013 09:31:11 +0000 (UTC)
Subject: master - tests: singlenode cleanup for prev commit
Message-ID: <20130912093111.9A6D160E67@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4dc16684679fb4bb9e8dbc2424e3760055788da2
Commit:        4dc16684679fb4bb9e8dbc2424e3760055788da2
Parent:        2a6abcb80a0b29334484325318aa643fd024fde8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 12 11:29:18 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 12 11:29:18 2013 +0200

tests: singlenode cleanup for prev commit

Add few more comments and cleanup some warnings.
---
 daemons/clvmd/clvmd-singlenode.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/daemons/clvmd/clvmd-singlenode.c b/daemons/clvmd/clvmd-singlenode.c
index 8103dcc..cad9acb 100644
--- a/daemons/clvmd/clvmd-singlenode.c
+++ b/daemons/clvmd/clvmd-singlenode.c
@@ -195,7 +195,7 @@ static int _lock_resource(const char *resource, int mode, int flags, int *lockid
 	/* EX */ { 1,	 0,	 0,	 0,	 0,	 0}
 	};
 
-	struct lock *lck, *lckt;
+	struct lock *lck = NULL, *lckt;
 	struct dm_list *head;
 
 	DEBUGLOG("Locking resource %s, flags=0x%02x (%s%s%s), mode=%s (%d)\n",
@@ -213,6 +213,11 @@ retry:
 	pthread_cond_broadcast(&_lock_cond); /* to wakeup waiters */
 
 	if (!(head = dm_hash_lookup(_locks, resource))) {
+		if (flags & LCKF_CONVERT) {
+			/* In real DLM, lock is identified only by lockid, resource is not used */
+			DEBUGLOG("Unlocked resource %s cannot be converted\n", resource);
+			goto_bad;
+		}
 		/* Add new locked resource */
 		if (!(head = dm_malloc(sizeof(struct dm_list))) ||
 		    !dm_hash_insert(_locks, resource, head)) {
@@ -223,14 +228,13 @@ retry:
 		dm_list_init(head);
 	} else	/* Update/convert locked resource */
 		dm_list_iterate_items(lck, head) {
-			/* FIXME Unsure what is LCKF_CONVERT about....*/
+			/* Check is all locks are compatible with requested lock */
 			if (flags & LCKF_CONVERT) {
 				if (lck->lockid != *lockid)
 					continue;
 
 				DEBUGLOG("Converting resource %s lockid=%d mode:%s -> %s...\n",
 					 resource, lck->lockid, _get_mode(lck->mode), _get_mode(mode));
-				/* Check if converted lock is compatible with locks we already have */
 				dm_list_iterate_items(lckt, head) {
 					if ((lckt->lockid != *lockid) &&
 					    !_dlm_table[mode][lckt->mode]) {
@@ -297,7 +301,7 @@ static int _unlock_resource(const char *resource, int lockid)
 
 	if (!(head = dm_hash_lookup(_locks, resource))) {
 		pthread_mutex_unlock(&_lock_mutex);
-		DEBUGLOG("Resource %s is not locked.\n", resource, lockid);
+		DEBUGLOG("Resource %s is not locked.\n", resource);
 		return 1;
 	}
 


