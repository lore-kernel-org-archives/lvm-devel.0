From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:41:12 +0000 (UTC)
Subject: master - segments: mark more of them unzeroable
Message-ID: <20141024144112.63F0460CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=298de1f5c3c2a84eb4c12f4697c110016a98237e
Commit:        298de1f5c3c2a84eb4c12f4697c110016a98237e
Parent:        784c216d2beb21bf793d33d1ebf600ab30454bb7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 20 14:57:24 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:32 2014 +0200

segments: mark more of them unzeroable

Use segment flags to avoid zeroing of cache, cache pool
snapshot and thin pool segments.

We never want to zero these segment types.

Note:
Snapshot COW and Cache origin are created as stripes
thus are then properly zeroed.
---
 WHATS_NEW                 |    1 +
 lib/cache_segtype/cache.c |    2 +-
 lib/snapshot/snapshot.c   |    2 +-
 lib/thin/thin.c           |    2 +-
 4 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b1f8410..1bdb884 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Mark pools and snapshots as unzeroable volumes.
   Check for zeroing of volume after segment type is fully detected.
   Better support for persistent major and minor options with lvcreate.
   Refactor lvcreate towards more complete validation of all supported options.
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 9927688..8c2ff78 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -391,7 +391,7 @@ int init_cache_segtypes(struct cmd_context *cmd,
 	segtype->cmd = cmd;
 
 	segtype->name = "cache-pool";
-	segtype->flags = SEG_CACHE_POOL;
+	segtype->flags = SEG_CACHE_POOL | SEG_CANNOT_BE_ZEROED;
 	segtype->ops = &_cache_pool_ops;
 	segtype->private = NULL;
 
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 18e8111..aefab3a 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -262,7 +262,7 @@ struct segment_type *init_segtype(struct cmd_context *cmd)
 	segtype->ops = &_snapshot_ops;
 	segtype->name = "snapshot";
 	segtype->private = NULL;
-	segtype->flags = SEG_SNAPSHOT;
+	segtype->flags = SEG_SNAPSHOT | SEG_CANNOT_BE_ZEROED;
 
 #ifdef DEVMAPPER_SUPPORT
 #  ifdef DMEVENTD
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 9ae237e..bb13b2b 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -753,7 +753,7 @@ int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *segl
 		const char name[16];
 		uint32_t flags;
 	} reg_segtypes[] = {
-		{ &_thin_pool_ops, "thin-pool", SEG_THIN_POOL },
+		{ &_thin_pool_ops, "thin-pool", SEG_THIN_POOL | SEG_CANNOT_BE_ZEROED },
 		/* FIXME Maybe use SEG_THIN_VOLUME instead of SEG_VIRTUAL */
 		{ &_thin_ops, "thin", SEG_THIN_VOLUME | SEG_VIRTUAL }
 	};


