From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  1 Dec 2015 12:04:49 +0000 (UTC)
Subject: master - lib: pass mem pool to check_transient_status
Message-ID: <20151201120449.5917160CF9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6336ef98d41b8c5b1435de08855aa66c8fd527c2
Commit:        6336ef98d41b8c5b1435de08855aa66c8fd527c2
Parent:        c717ea5fc0b5096a1655313017611b4305e883d3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 30 21:24:31 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 1 13:01:28 2015 +0100

lib: pass mem pool to check_transient_status

check_transient_status() may need to allocate some memory,
so pass in already existing mem pool.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    2 +-
 lib/metadata/segtype.h     |    3 ++-
 lib/mirror/mirrored.c      |    2 +-
 4 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d2bdb58..dcd2b22 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.137 -
 =====================================
+  Add mem pool arg for check_transient_status() target function.
   Avoid misleading error with -m is omitted with lvconvert to raid types.
 
 Version 2.02.136 - 28th November 2015
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 4b37845..4eff5cb 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1114,7 +1114,7 @@ int dev_manager_transient(struct dev_manager *dm, const struct logical_volume *l
 		}
 
 		if (seg->segtype->ops->check_transient_status &&
-		    !seg->segtype->ops->check_transient_status(seg, params))
+		    !seg->segtype->ops->check_transient_status(dm->mem, seg, params))
 			goto_out;
 
 	} while (next);
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 72c64f9..41adf92 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -192,7 +192,8 @@ struct segtype_handler {
 				struct dm_tree_node *node, uint64_t len,
 				uint32_t *pvmove_mirror_count);
 	int (*target_status_compatible) (const char *type);
-	int (*check_transient_status) (struct lv_segment *seg, char *params);
+	int (*check_transient_status) (struct dm_pool *mem,
+				       struct lv_segment *seg, char *params);
 	int (*target_percent) (void **target_state,
 			       dm_percent_t *percent,
 			       struct dm_pool * mem,
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 6e189b2..b810c70 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -213,7 +213,7 @@ static int _mirrored_target_percent(void **target_state,
 	return 1;
 }
 
-static int _mirrored_transient_status(struct lv_segment *seg, char *params)
+static int _mirrored_transient_status(struct dm_pool *mem, struct lv_segment *seg, char *params)
 {
 	unsigned i, j;
 	struct logical_volume *lv = seg->lv;


