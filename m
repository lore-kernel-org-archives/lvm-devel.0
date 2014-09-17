From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 17 Sep 2014 12:42:37 +0000 (UTC)
Subject: master - locking: add locking_supports_remote_queries
Message-ID: <20140917124237.ECF7861087@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f90bc22ca532f5852aeaab92e0c40b36d65ef62d
Commit:        f90bc22ca532f5852aeaab92e0c40b36d65ef62d
Parent:        9d57aa9a0fe00322cb188ad1f3103d57392546e7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 17 14:21:41 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 17 14:36:38 2014 +0200

locking: add locking_supports_remote_queries

Add function to detect whether locking could be used to
query for lock type so we could recognize exclusive
activation.
---
 lib/locking/cluster_locking.c |    2 +-
 lib/locking/locking.c         |    5 +++++
 lib/locking/locking.h         |    1 +
 lib/locking/locking_types.h   |    1 +
 4 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index 0a11262..f2f4c80 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -611,7 +611,7 @@ int init_cluster_locking(struct locking_type *locking, struct cmd_context *cmd,
 	locking->query_resource = _query_resource;
 	locking->fin_locking = _locking_end;
 	locking->reset_locking = _reset_locking;
-	locking->flags = LCK_PRE_MEMLOCK | LCK_CLUSTERED;
+	locking->flags = LCK_PRE_MEMLOCK | LCK_CLUSTERED | LCK_SUPPORTS_REMOTE_QUERIES;
 
 	_clvmd_sock = _open_local_sock(suppress_messages);
 	if (_clvmd_sock == -1)
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 9432f84..544751e 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -492,6 +492,11 @@ int locking_is_clustered(void)
 	return (_locking.flags & LCK_CLUSTERED) ? 1 : 0;
 }
 
+int locking_supports_remote_queries(void)
+{
+	return (_locking.flags & LCK_SUPPORTS_REMOTE_QUERIES) ? 1 : 0;
+}
+
 int remote_lock_held(const char *vol, int *exclusive)
 {
 	int mode = LCK_NULL;
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 284ce7a..1351cd2 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -26,6 +26,7 @@ void fin_locking(void);
 void reset_locking(void);
 int vg_write_lock_held(void);
 int locking_is_clustered(void);
+int locking_supports_remote_queries(void);
 
 int remote_lock_held(const char *vol, int *exclusive);
 
diff --git a/lib/locking/locking_types.h b/lib/locking/locking_types.h
index 6e4adcc..5fa5cba 100644
--- a/lib/locking/locking_types.h
+++ b/lib/locking/locking_types.h
@@ -25,6 +25,7 @@ typedef void (*reset_lock_fn) (void);
 
 #define LCK_PRE_MEMLOCK	0x00000001	/* Is memlock() needed before calls? */
 #define LCK_CLUSTERED	0x00000002
+#define LCK_SUPPORTS_REMOTE_QUERIES	0x00000004
 
 struct locking_type {
 	uint32_t flags;


