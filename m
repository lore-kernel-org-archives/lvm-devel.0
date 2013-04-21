From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 21 Apr 2013 21:17:17 +0000 (UTC)
Subject: master - test: singlenode minor cleanups
Message-ID: <20130421211717.981F816CF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=994c32272e7c36f45defda12848d3856590a0d1f
Commit:        994c32272e7c36f45defda12848d3856590a0d1f
Parent:        9cdcde494f2824dbf8e549638331ab65b1f56b3a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 18 18:01:52 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:15:07 2013 +0200

test: singlenode minor cleanups

Move unnecessary code out of locks.
---
 daemons/clvmd/clvmd-singlenode.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/daemons/clvmd/clvmd-singlenode.c b/daemons/clvmd/clvmd-singlenode.c
index b968c5f..a79100f 100644
--- a/daemons/clvmd/clvmd-singlenode.c
+++ b/daemons/clvmd/clvmd-singlenode.c
@@ -218,8 +218,8 @@ maybe_retry:
 		goto retry;
 	}
 bad:
-	DEBUGLOG("Failed to lock resource %s\n", resource);
 	pthread_mutex_unlock(&_lock_mutex);
+	DEBUGLOG("Failed to lock resource %s\n", resource);
 
 	return 1; /* fail */
 }
@@ -251,9 +251,9 @@ static int _unlock_resource(const char *resource, int lockid)
 	}
 
 	dm_hash_remove(_locks, resource);
-	dm_free(lck);
 	pthread_cond_broadcast(&_lock_cond); /* wakeup waiters */
 	pthread_mutex_unlock(&_lock_mutex);
+	dm_free(lck);
 
 	return 0;
 }
@@ -312,6 +312,6 @@ struct cluster_ops *init_singlenode_cluster(void)
 {
 	if (!_init_cluster())
 		return &_cluster_singlenode_ops;
-	else
-		return NULL;
+
+	return NULL;
 }


