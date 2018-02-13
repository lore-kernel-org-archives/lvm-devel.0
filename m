From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 13 Feb 2018 13:12:14 -0500
Subject: master - segtype: replace mempool allocation
Message-ID: <201802131812.w1DICEBE028531@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=32febed8d55d0761fdbe86015c02da90e026b359
Commit:        32febed8d55d0761fdbe86015c02da90e026b359
Parent:        e40768ac32e6de5e6f9614ae0ad702c93a4e1330
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 13 19:00:47 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 13 19:11:28 2018 +0100

segtype: replace mempool allocation

So this is a bit more complex and possibly worth futher checking.

ATM  clvmd drops  cmd->mem  mempool AFTER refresh of cmd.
So anything allocating from cmd->mem during toolcontext init
will likely die at some point in time.

As a quick fix - just use regular malloc/free for 'dso' alloction.

It's worth to note -  cmd->libmem seems to be often misused
causing hidden memleaking for clvmd.
---
 lib/activate/activate.c |    2 +-
 lib/mirror/mirrored.c   |    1 +
 lib/raid/raid.c         |    8 ++++++--
 lib/snapshot/snapshot.c |    1 +
 lib/thin/thin.c         |    1 +
 5 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index bd1dc18..1b870f7 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1692,7 +1692,7 @@ char *get_monitor_dso_path(struct cmd_context *cmd, int id)
 
 	get_shared_library_path(cmd, libpath, path, sizeof(path));
 
-	return dm_pool_strdup(cmd->mem, path);
+	return dm_strdup(path);
 }
 
 static char *_build_target_uuid(struct cmd_context *cmd, const struct logical_volume *lv)
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 2d9c3de..1a8f1bb 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -531,6 +531,7 @@ static int _mirrored_modules_needed(struct dm_pool *mem,
 
 static void _mirrored_destroy(struct segment_type *segtype)
 {
+	dm_free(segtype->dso);
 	dm_free(segtype);
 }
 
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index e835160..8ae679e 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -363,6 +363,7 @@ static int _raid_target_status_compatible(const char *type)
 
 static void _raid_destroy(struct segment_type *segtype)
 {
+	dm_free(segtype->dso);
 	dm_free((void *) segtype);
 }
 
@@ -629,7 +630,8 @@ static struct segment_type *_init_raid_segtype(struct cmd_context *cmd,
 	segtype->flags = SEG_RAID | SEG_ONLY_EXCLUSIVE | rt->extra_flags;
 
 	/* Never monitor raid0 or raid0_meta LVs */
-	if (!segtype_is_any_raid0(segtype)) {
+	if (!segtype_is_any_raid0(segtype) &&
+	    dso && (dso = dm_strdup(dso))) {
 		segtype->dso = dso;
 		segtype->flags |= monitored;
 	}
@@ -650,7 +652,7 @@ int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *segl
 #endif
 {
 	struct segment_type *segtype;
-	const char *dso;
+	const char *dso = NULL;
 	unsigned i;
 	uint64_t monitored = 0;
 
@@ -669,5 +671,7 @@ int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *segl
 			/* segtype is already destroyed */
 			return_0;
 
+	dm_free(dso);
+
 	return 1;
 }
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 1105204..e99acf1 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -224,6 +224,7 @@ static int _snap_modules_needed(struct dm_pool *mem,
 
 static void _snap_destroy(struct segment_type *segtype)
 {
+	dm_free(segtype->dso);
 	dm_free(segtype);
 }
 
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index dad1bf2..a679784 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -745,6 +745,7 @@ static int _thin_target_present(struct cmd_context *cmd,
 
 static void _thin_destroy(struct segment_type *segtype)
 {
+	dm_free(segtype->dso);
 	dm_free(segtype);
 }
 


