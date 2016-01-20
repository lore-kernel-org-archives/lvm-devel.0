From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 20 Jan 2016 00:59:23 +0000 (UTC)
Subject: master - locking: Add node parameter to query_resource.
Message-ID: <20160120005923.1BECB60EDA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c812c2dbc7ced09a715e5689f941ba255821f0bc
Commit:        c812c2dbc7ced09a715e5689f941ba255821f0bc
Parent:        7f6a1e6bbac41bb5d0e18876c23a7442c8c0d263
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jan 19 21:42:22 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jan 19 21:42:22 2016 +0000

locking: Add node parameter to query_resource.

---
 daemons/clvmd/clvm.h          |    8 +++++---
 lib/activate/activate.c       |    2 +-
 lib/locking/cluster_locking.c |    7 +++----
 lib/locking/locking.c         |    4 ++--
 lib/locking/locking.h         |    7 ++++++-
 lib/locking/locking_types.h   |    2 +-
 lib/locking/no_locking.c      |    2 +-
 7 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/daemons/clvmd/clvm.h b/daemons/clvmd/clvm.h
index 716af40..10ef852 100644
--- a/daemons/clvmd/clvm.h
+++ b/daemons/clvmd/clvm.h
@@ -76,8 +76,10 @@ static const char CLVMD_SOCKNAME[]= DEFAULT_RUN_DIR "/clvmd.sock";
 #define CLVMD_CMD_SYNC_NAMES	    45
 
 /* Used internally by some callers, but not part of the protocol.*/
-#define NODE_ALL	"*"
-#define NODE_LOCAL	"."
-#define NODE_REMOTE	"^"
+#ifndef NODE_ALL
+#  define NODE_ALL	"*"
+#  define NODE_LOCAL	"."
+#  define NODE_REMOTE	"^"
+#endif
 
 #endif
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 8f5b72b..4cd268e 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1371,7 +1371,7 @@ static int _lv_is_active(const struct logical_volume *lv,
 	if (l && !exclusive)
 		goto out;
 
-	if ((r = remote_lock_held(lv->lvid.s, &e)) >= 0)
+	if ((r = cluster_lock_held(lv->lvid.s, "", &e)) >= 0)
 		goto out;
 
 	/*
diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index 800f33d..517d09c 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -34,7 +34,7 @@
 
 #ifndef CLUSTER_LOCKING_INTERNAL
 int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags, const struct logical_volume *lv __attribute__((unused)));
-int query_resource(const char *resource, int *mode);
+int query_resource(const char *resource, const char *node, int *mode);
 void locking_end(void);
 int locking_init(int type, struct dm_config_tree *cf, uint32_t *flags);
 #endif
@@ -530,13 +530,12 @@ static int decode_lock_type(const char *response)
 }
 
 #ifdef CLUSTER_LOCKING_INTERNAL
-static int _query_resource(const char *resource, int *mode)
+static int _query_resource(const char *resource, const char *node, int *mode)
 #else
-int query_resource(const char *resource, int *mode)
+int query_resource(const char *resource, const char *node, int *mode)
 #endif
 {
 	int i, status, len, num_responses, saved_errno;
-	const char *node = "";
 	char *args;
 	lvm_response_t *response = NULL;
 
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 22e83d2..a11c09b 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -498,7 +498,7 @@ int locking_supports_remote_queries(void)
 	return (_locking.flags & LCK_SUPPORTS_REMOTE_QUERIES) ? 1 : 0;
 }
 
-int remote_lock_held(const char *vol, int *exclusive)
+int cluster_lock_held(const char *vol, const char *node, int *exclusive)
 {
 	int mode = LCK_NULL;
 
@@ -511,7 +511,7 @@ int remote_lock_held(const char *vol, int *exclusive)
 	/*
 	 * If an error occured, expect that volume is active
 	 */
-	if (!_locking.query_resource(vol, &mode)) {
+	if (!_locking.query_resource(vol, node, &mode)) {
 		stack;
 		return 1;
 	}
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 706b59e..cb4f923 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -28,7 +28,12 @@ int vg_write_lock_held(void);
 int locking_is_clustered(void);
 int locking_supports_remote_queries(void);
 
-int remote_lock_held(const char *vol, int *exclusive);
+#ifndef NODE_ALL
+#  define NODE_ALL     "*"
+#  define NODE_LOCAL   "."
+#  define NODE_REMOTE  "^"
+#endif
+int cluster_lock_held(const char *vol, const char *node, int *exclusive);
 
 /*
  * LCK_VG:
diff --git a/lib/locking/locking_types.h b/lib/locking/locking_types.h
index 64d13db..5f0cd6b 100644
--- a/lib/locking/locking_types.h
+++ b/lib/locking/locking_types.h
@@ -18,7 +18,7 @@
 
 typedef int (*lock_resource_fn) (struct cmd_context * cmd, const char *resource,
 				 uint32_t flags, const struct logical_volume *lv);
-typedef int (*query_resource_fn) (const char *resource, int *mode);
+typedef int (*query_resource_fn) (const char *resource, const char *node, int *mode);
 
 typedef void (*fin_lock_fn) (void);
 typedef void (*reset_lock_fn) (void);
diff --git a/lib/locking/no_locking.c b/lib/locking/no_locking.c
index 6b0ac63..e909a24 100644
--- a/lib/locking/no_locking.c
+++ b/lib/locking/no_locking.c
@@ -70,7 +70,7 @@ static int _no_lock_resource(struct cmd_context *cmd, const char *resource,
 	return 1;
 }
 
-static int _no_query_resource(const char *resource, int *mode)
+static int _no_query_resource(const char *resource, const char *node, int *mode)
 {
 	log_very_verbose("Locking is disabled: Treating lock %s as not held.",
 			 resource);


