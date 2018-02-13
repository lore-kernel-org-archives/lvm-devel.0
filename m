From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 13 Feb 2018 14:01:39 -0500
Subject: master - gcc: remove warns about free of const
Message-ID: <201802131901.w1DJ1dVH007321@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c3642957c5427d69b6aac45d2d1088786967cabd
Commit:        c3642957c5427d69b6aac45d2d1088786967cabd
Parent:        0eb9daf602281d233c83e5823b3c6297fb541deb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 13 19:53:07 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 13 19:56:02 2018 +0100

gcc: remove warns about free of const

---
 lib/mirror/mirrored.c   |    2 +-
 lib/raid/raid.c         |    6 +++---
 lib/snapshot/snapshot.c |    2 +-
 lib/thin/thin.c         |    2 +-
 lib/unknown/unknown.c   |    2 +-
 5 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 1a8f1bb..a46cc29 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -531,7 +531,7 @@ static int _mirrored_modules_needed(struct dm_pool *mem,
 
 static void _mirrored_destroy(struct segment_type *segtype)
 {
-	dm_free(segtype->dso);
+	dm_free((void *) segtype->dso);
 	dm_free(segtype);
 }
 
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 8ae679e..31a0ac0 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -363,8 +363,8 @@ static int _raid_target_status_compatible(const char *type)
 
 static void _raid_destroy(struct segment_type *segtype)
 {
-	dm_free(segtype->dso);
-	dm_free((void *) segtype);
+	dm_free((void *) segtype->dso);
+	dm_free(segtype);
 }
 
 #ifdef DEVMAPPER_SUPPORT
@@ -652,7 +652,7 @@ int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *segl
 #endif
 {
 	struct segment_type *segtype;
-	const char *dso = NULL;
+	char *dso = NULL;
 	unsigned i;
 	uint64_t monitored = 0;
 
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index e99acf1..5fd39e9 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -224,7 +224,7 @@ static int _snap_modules_needed(struct dm_pool *mem,
 
 static void _snap_destroy(struct segment_type *segtype)
 {
-	dm_free(segtype->dso);
+	dm_free((void *) segtype->dso);
 	dm_free(segtype);
 }
 
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index a679784..b6eb3aa 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -745,7 +745,7 @@ static int _thin_target_present(struct cmd_context *cmd,
 
 static void _thin_destroy(struct segment_type *segtype)
 {
-	dm_free(segtype->dso);
+	dm_free((void *) segtype->dso);
 	dm_free(segtype);
 }
 
diff --git a/lib/unknown/unknown.c b/lib/unknown/unknown.c
index 8f6083a..7728545 100644
--- a/lib/unknown/unknown.c
+++ b/lib/unknown/unknown.c
@@ -49,7 +49,7 @@ static int _unknown_text_export(const struct lv_segment *seg, struct formatter *
 
 static void _unknown_destroy(struct segment_type *segtype)
 {
-	dm_free(segtype->name);
+	dm_free((void *) segtype->name);
 	dm_free(segtype);
 }
 


