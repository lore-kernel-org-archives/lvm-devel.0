From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Oct 2014 23:00:39 +0000 (UTC)
Subject: master - segtype: drop cmdcontex pointer
Message-ID: <20141030230039.00F82607B8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=97cccfbf1c000e597cf751e26284614a15f77cb5
Commit:        97cccfbf1c000e597cf751e26284614a15f77cb5
Parent:        87fc3b710c3b8fc656dcf48ec453e1da280ec696
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 27 10:50:52 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 30 23:58:49 2014 +0100

segtype: drop cmdcontex pointer

Users of context provide their cmd pointer,
so don't keep it inside segtype.
---
 lib/cache_segtype/cache.c  |    4 ----
 lib/commands/toolcontext.c |    1 -
 lib/error/errseg.c         |    2 --
 lib/freeseg/freeseg.c      |    2 --
 lib/metadata/segtype.h     |    1 -
 lib/mirror/mirrored.c      |    2 --
 lib/raid/raid.c            |    2 +-
 lib/snapshot/snapshot.c    |    2 --
 lib/striped/striped.c      |    2 --
 lib/unknown/unknown.c      |    2 --
 lib/zero/zero.c            |    2 --
 tools/reporter.c           |    1 -
 12 files changed, 1 insertions(+), 22 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 8c2ff78..93027d7 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -388,12 +388,10 @@ int init_cache_segtypes(struct cmd_context *cmd,
 		log_error("Failed to allocate memory for cache_pool segtype");
 		return 0;
 	}
-	segtype->cmd = cmd;
 
 	segtype->name = "cache-pool";
 	segtype->flags = SEG_CACHE_POOL | SEG_CANNOT_BE_ZEROED;
 	segtype->ops = &_cache_pool_ops;
-	segtype->private = NULL;
 
 	if (!lvm_register_segtype(seglib, segtype))
 		return_0;
@@ -404,12 +402,10 @@ int init_cache_segtypes(struct cmd_context *cmd,
 		log_error("Failed to allocate memory for cache segtype");
 		return 0;
 	}
-	segtype->cmd = cmd;
 
 	segtype->name = "cache";
 	segtype->flags = SEG_CACHE;
 	segtype->ops = &_cache_ops;
-	segtype->private = NULL;
 
 	if (!lvm_register_segtype(seglib, segtype))
 		return_0;
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 72525f5..3900179 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1174,7 +1174,6 @@ int lvm_register_segtype(struct segtype_library *seglib,
 	struct segment_type *segtype2;
 
 	segtype->library = seglib->lib;
-	segtype->cmd = seglib->cmd;
 
 	dm_list_iterate_items(segtype2, &seglib->cmd->segtypes) {
 		if (strcmp(segtype2->name, segtype->name))
diff --git a/lib/error/errseg.c b/lib/error/errseg.c
index af19e7d..fa0b9c0 100644
--- a/lib/error/errseg.c
+++ b/lib/error/errseg.c
@@ -94,10 +94,8 @@ struct segment_type *init_error_segtype(struct cmd_context *cmd)
 	if (!segtype)
 		return_NULL;
 
-	segtype->cmd = cmd;
 	segtype->ops = &_error_ops;
 	segtype->name = "error";
-	segtype->private = NULL;
 	segtype->flags = SEG_CAN_SPLIT | SEG_VIRTUAL | SEG_CANNOT_BE_ZEROED;
 
 	log_very_verbose("Initialised segtype: %s", segtype->name);
diff --git a/lib/freeseg/freeseg.c b/lib/freeseg/freeseg.c
index b4eba94..71d7f8c 100644
--- a/lib/freeseg/freeseg.c
+++ b/lib/freeseg/freeseg.c
@@ -32,10 +32,8 @@ struct segment_type *init_free_segtype(struct cmd_context *cmd)
 	if (!segtype)
 		return_NULL;
 
-	segtype->cmd = cmd;
 	segtype->ops = &_freeseg_ops;
 	segtype->name = "free";
-	segtype->private = NULL;
 	segtype->flags = SEG_VIRTUAL | SEG_CANNOT_BE_ZEROED;
 
 	log_very_verbose("Initialised segtype: %s", segtype->name);
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 749b188..4635681 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -81,7 +81,6 @@ struct dev_manager;
 
 struct segment_type {
 	struct dm_list list;		/* Internal */
-	struct cmd_context *cmd;	/* lvm_register_segtype() sets this. */
 
 	uint32_t flags;
 	uint32_t parity_devs;           /* Parity drives required by segtype */
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 46dfe02..7ab11c2 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -618,10 +618,8 @@ struct segment_type *init_segtype(struct cmd_context *cmd)
 	if (!segtype)
 		return_NULL;
 
-	segtype->cmd = cmd;
 	segtype->ops = &_mirrored_ops;
 	segtype->name = "mirror";
-	segtype->private = NULL;
 	segtype->flags = SEG_MIRROR | SEG_AREAS_MIRRORED;
 
 #ifdef DEVMAPPER_SUPPORT
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 7cc4301..6f4fe27 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -462,7 +462,7 @@ static struct segment_type *_init_raid_segtype(struct cmd_context *cmd,
 			  rt->name);
 		return NULL;
 	}
-	segtype->cmd = cmd;
+
 	segtype->ops = &_raid_ops;
 	segtype->name = rt->name;
 	segtype->flags = SEG_RAID | rt->extra_flags | monitored;
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index aefab3a..b64e533 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -258,10 +258,8 @@ struct segment_type *init_segtype(struct cmd_context *cmd)
 	if (!segtype)
 		return_NULL;
 
-	segtype->cmd = cmd;
 	segtype->ops = &_snapshot_ops;
 	segtype->name = "snapshot";
-	segtype->private = NULL;
 	segtype->flags = SEG_SNAPSHOT | SEG_CANNOT_BE_ZEROED;
 
 #ifdef DEVMAPPER_SUPPORT
diff --git a/lib/striped/striped.c b/lib/striped/striped.c
index dfd4518..1803077 100644
--- a/lib/striped/striped.c
+++ b/lib/striped/striped.c
@@ -228,10 +228,8 @@ struct segment_type *init_striped_segtype(struct cmd_context *cmd)
 	if (!segtype)
 		return_NULL;
 
-	segtype->cmd = cmd;
 	segtype->ops = &_striped_ops;
 	segtype->name = "striped";
-	segtype->private = NULL;
 	segtype->flags =
 	    SEG_CAN_SPLIT | SEG_AREAS_STRIPED | SEG_FORMAT1_SUPPORT;
 
diff --git a/lib/unknown/unknown.c b/lib/unknown/unknown.c
index 760f1c2..3712c66 100644
--- a/lib/unknown/unknown.c
+++ b/lib/unknown/unknown.c
@@ -67,10 +67,8 @@ struct segment_type *init_unknown_segtype(struct cmd_context *cmd, const char *n
 		return NULL;
 	}
 
-	segtype->cmd = cmd;
 	segtype->ops = &_unknown_ops;
 	segtype->name = dm_pool_strdup(cmd->libmem, name);
-	segtype->private = NULL;
 	segtype->flags = SEG_UNKNOWN | SEG_VIRTUAL | SEG_CANNOT_BE_ZEROED;
 
 	log_very_verbose("Initialised segtype: %s", segtype->name);
diff --git a/lib/zero/zero.c b/lib/zero/zero.c
index 9f9d06c..f07f288 100644
--- a/lib/zero/zero.c
+++ b/lib/zero/zero.c
@@ -90,10 +90,8 @@ struct segment_type *init_zero_segtype(struct cmd_context *cmd)
 	if (!segtype)
 		return_NULL;
 
-	segtype->cmd = cmd;
 	segtype->ops = &_zero_ops;
 	segtype->name = "zero";
-	segtype->private = NULL;
 	segtype->flags = SEG_CAN_SPLIT | SEG_VIRTUAL | SEG_CANNOT_BE_ZEROED;
 
 	log_very_verbose("Initialised segtype: %s", segtype->name);
diff --git a/tools/reporter.c b/tools/reporter.c
index 9688151..02f6064 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -100,7 +100,6 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 	struct lvinfo lvinfo = { .exists = 0 };
 
 	struct segment_type _freeseg_type = {
-		.cmd = cmd,
 		.name = "free",
 		.flags = SEG_VIRTUAL | SEG_CANNOT_BE_ZEROED,
 	};


