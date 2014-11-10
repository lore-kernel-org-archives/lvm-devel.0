From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:12 +0000 (UTC)
Subject: master - segtype: add SEG_ONLY_EXCLUSIVE flag
Message-ID: <20141110210612.E515F608F1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e2c4a3ef67261d4a8d32b62906b05e4292b47f90
Commit:        e2c4a3ef67261d4a8d32b62906b05e4292b47f90
Parent:        0dc73f7dbd49308b1864444d1decfaf8e10d2d81
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 10 18:44:37 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 22:05:48 2014 +0100

segtype: add SEG_ONLY_EXCLUSIVE flag

Mark segtypes which do require exclusive activation in cluster.r
---
 lib/cache_segtype/cache.c |    4 ++--
 lib/metadata/lv.c         |   15 ++++++++++-----
 lib/metadata/segtype.h    |    2 ++
 lib/raid/raid.c           |    2 +-
 lib/snapshot/snapshot.c   |    2 +-
 lib/thin/thin.c           |    4 ++--
 6 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 93027d7..dceb3c0 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -390,7 +390,7 @@ int init_cache_segtypes(struct cmd_context *cmd,
 	}
 
 	segtype->name = "cache-pool";
-	segtype->flags = SEG_CACHE_POOL | SEG_CANNOT_BE_ZEROED;
+	segtype->flags = SEG_CACHE_POOL | SEG_CANNOT_BE_ZEROED | SEG_ONLY_EXCLUSIVE;
 	segtype->ops = &_cache_pool_ops;
 
 	if (!lvm_register_segtype(seglib, segtype))
@@ -404,7 +404,7 @@ int init_cache_segtypes(struct cmd_context *cmd,
 	}
 
 	segtype->name = "cache";
-	segtype->flags = SEG_CACHE;
+	segtype->flags = SEG_CACHE | SEG_ONLY_EXCLUSIVE;
 	segtype->ops = &_cache_ops;
 
 	if (!lvm_register_segtype(seglib, segtype))
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index ed21894..bdf98f8 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -858,11 +858,16 @@ char *lv_host_dup(struct dm_pool *mem, const struct logical_volume *lv)
 
 static int _lv_is_exclusive(struct logical_volume *lv)
 {
-	/* Some devices require exlusiveness */
-	return lv_is_raid(lv) ||
-		lv_is_origin(lv) ||
-		lv_is_thin_type(lv) ||
-		lv_is_cache_type(lv);
+	struct lv_segment *seg;
+
+	/* Some seg types require exclusive activation */
+	/* TODO: deep-scan of every segtype in use */
+	dm_list_iterate_items(seg, &lv->segments)
+		if (seg_only_exclusive(seg))
+			return 1;
+
+	/* Origin has no seg type require exlusiveness */
+	return lv_is_origin(lv);
 }
 
 int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 4635681..ecb598d 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -44,6 +44,7 @@ struct dev_manager;
 #define SEG_CACHE		0x00002000U
 #define SEG_CACHE_POOL		0x00004000U
 #define SEG_MIRROR		0x00008000U
+#define SEG_ONLY_EXCLUSIVE	0x00010000U /* In cluster only exlusive activation */
 #define SEG_UNKNOWN		0x80000000U
 
 #define segtype_is_cache(segtype)	((segtype)->flags & SEG_CACHE ? 1 : 0)
@@ -78,6 +79,7 @@ struct dev_manager;
 #define seg_can_split(seg)	((seg)->segtype->flags & SEG_CAN_SPLIT ? 1 : 0)
 #define seg_cannot_be_zeroed(seg) ((seg)->segtype->flags & SEG_CANNOT_BE_ZEROED ? 1 : 0)
 #define seg_monitored(seg)	((seg)->segtype->flags & SEG_MONITORED ? 1 : 0)
+#define seg_only_exclusive(seg)	((seg)->segtype->flags & SEG_ONLY_EXCLUSIVE ? 1 : 0)
 
 struct segment_type {
 	struct dm_list list;		/* Internal */
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 6f4fe27..39e3a06 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -465,7 +465,7 @@ static struct segment_type *_init_raid_segtype(struct cmd_context *cmd,
 
 	segtype->ops = &_raid_ops;
 	segtype->name = rt->name;
-	segtype->flags = SEG_RAID | rt->extra_flags | monitored;
+	segtype->flags = SEG_RAID | SEG_ONLY_EXCLUSIVE | rt->extra_flags | monitored;
 	segtype->parity_devs = rt->parity;
 
 	log_very_verbose("Initialised segtype: %s", segtype->name);
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index b64e533..0886206 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -260,7 +260,7 @@ struct segment_type *init_segtype(struct cmd_context *cmd)
 
 	segtype->ops = &_snapshot_ops;
 	segtype->name = "snapshot";
-	segtype->flags = SEG_SNAPSHOT | SEG_CANNOT_BE_ZEROED;
+	segtype->flags = SEG_SNAPSHOT | SEG_CANNOT_BE_ZEROED | SEG_ONLY_EXCLUSIVE;
 
 #ifdef DEVMAPPER_SUPPORT
 #  ifdef DMEVENTD
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index bb13b2b..f921bef 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -753,9 +753,9 @@ int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *segl
 		const char name[16];
 		uint32_t flags;
 	} reg_segtypes[] = {
-		{ &_thin_pool_ops, "thin-pool", SEG_THIN_POOL | SEG_CANNOT_BE_ZEROED },
+		{ &_thin_pool_ops, "thin-pool", SEG_THIN_POOL | SEG_CANNOT_BE_ZEROED | SEG_ONLY_EXCLUSIVE },
 		/* FIXME Maybe use SEG_THIN_VOLUME instead of SEG_VIRTUAL */
-		{ &_thin_ops, "thin", SEG_THIN_VOLUME | SEG_VIRTUAL }
+		{ &_thin_ops, "thin", SEG_THIN_VOLUME | SEG_VIRTUAL | SEG_ONLY_EXCLUSIVE }
 	};
 
 	struct segment_type *segtype;


