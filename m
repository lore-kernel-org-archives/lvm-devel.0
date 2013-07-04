From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  4 Jul 2013 11:34:24 +0000 (UTC)
Subject: master - thin: move alloc_pool_metadata
Message-ID: <20130704113424.DBB6460EA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f88f5a1ca3b0c77a2c353460ff35d802bbb05a34
Commit:        f88f5a1ca3b0c77a2c353460ff35d802bbb05a34
Parent:        f88497079778b00fe5ed9a43d890af64d272c325
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 4 11:04:05 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 4 13:33:41 2013 +0200

thin: move alloc_pool_metadata

Move function from /tool to /lib to thin_manip.c
Since lvm2api will need to move many things into /lib anyway.
---
 lib/metadata/metadata-exported.h |    5 ++++
 lib/metadata/thin_manip.c        |   40 ++++++++++++++++++++++++++++++++++
 tools/lvconvert.c                |    9 ++++---
 tools/toollib.c                  |   44 --------------------------------------
 tools/toollib.h                  |    5 ----
 5 files changed, 50 insertions(+), 53 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 7b7ac3c..ee3ae66 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -657,6 +657,11 @@ int update_pool_params(struct cmd_context *cmd, unsigned attr, int passed_args,
 		       uint64_t *pool_metadata_size);
 int get_pool_discards(const char *str, thin_discards_t *discards);
 const char *get_pool_discards_name(thin_discards_t discards);
+struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
+					   const char *name, uint32_t read_ahead,
+					   uint32_t stripes, uint32_t stripe_size,
+					   uint64_t size, alloc_policy_t alloc,
+					   struct dm_list *pvh);
 
 /*
  * Activation options
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 4ff647a..f40fd74 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -681,3 +681,43 @@ const char *get_pool_discards_name(thin_discards_t discards)
 
 	return "unknown";
 }
+
+struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
+					   const char *name, uint32_t read_ahead,
+					   uint32_t stripes, uint32_t stripe_size,
+					   uint64_t size, alloc_policy_t alloc,
+					   struct dm_list *pvh)
+{
+	struct logical_volume *metadata_lv;
+	/* FIXME: Make lvm2api usable */
+	struct lvcreate_params lvc = {
+		.activate = CHANGE_ALY,
+		.alloc = alloc,
+		.lv_name = name,
+		.major = -1,
+		.minor = -1,
+		.permission = LVM_READ | LVM_WRITE,
+		.pvh = pvh,
+		.read_ahead = read_ahead,
+		.stripe_size = stripe_size,
+		.stripes = stripes,
+		.vg_name = pool_lv->vg->name,
+		.zero = 1,
+	};
+
+	dm_list_init(&lvc.tags);
+
+	if (!(lvc.extents = extents_from_size(pool_lv->vg->cmd, size,
+					      pool_lv->vg->extent_size)))
+		return_0;
+
+	if (!(lvc.segtype = get_segtype_from_string(pool_lv->vg->cmd, "striped")))
+		return_0;
+
+	/* FIXME: allocate properly space for metadata_lv */
+
+	if (!(metadata_lv = lv_create_single(pool_lv->vg, &lvc)))
+		return_0;
+
+	return metadata_lv;
+}
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ccc8420..c2041c0 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2145,10 +2145,11 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
 			return_0;
 
-		if (!(metadata_lv = alloc_pool_metadata(pool_lv, lp->alloc, metadata_name,
-							lp->pvh, lp->read_ahead,
-							lp->stripes, lp->stripe_size,
-							lp->poolmetadata_size)))
+		if (!(metadata_lv = alloc_pool_metadata(pool_lv, metadata_name,
+							lp->read_ahead,	lp->stripes,
+							lp->stripe_size,
+							lp->poolmetadata_size,
+							lp->alloc, lp->pvh)))
 			return_0;
 	}
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 1a6fbee..5db537f 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1601,50 +1601,6 @@ int get_pool_params(struct cmd_context *cmd,
 	return 1;
 }
 
-struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
-					   alloc_policy_t alloc,
-					   const char *name,
-					   struct dm_list *pvh,
-					   uint32_t read_ahead,
-					   uint32_t stripes,
-					   uint32_t stripe_size,
-					   uint64_t size)
-{
-	struct logical_volume *metadata_lv;
-	struct lvcreate_params lvc;
-
-	/* FIXME: Make lvm2api usable */
-	memset(&lvc, 0, sizeof(lvc));
-
-	if (!(lvc.extents = extents_from_size(pool_lv->vg->cmd, size,
-					      pool_lv->vg->extent_size)))
-		return_0;
-
-	if (!(lvc.segtype = get_segtype_from_string(pool_lv->vg->cmd, "striped")))
-		return_0;
-
-	dm_list_init(&lvc.tags);
-
-	/* FIXME: allocate properly space for metadata_lv */
-	lvc.activate = CHANGE_ALY;
-	lvc.alloc = alloc;
-	lvc.lv_name = name;
-	lvc.major = -1;
-	lvc.minor = -1;
-	lvc.permission = LVM_READ | LVM_WRITE;
-	lvc.pvh = pvh;
-	lvc.read_ahead = read_ahead;
-	lvc.stripe_size = stripe_size;
-	lvc.stripes = stripes;
-	lvc.vg_name = pool_lv->vg->name;
-	lvc.zero = 1;
-
-	if (!(metadata_lv = lv_create_single(pool_lv->vg, &lvc)))
-		return_0;
-
-	return metadata_lv;
-}
-
 /*
  * Generic stripe parameter checks.
  */
diff --git a/tools/toollib.h b/tools/toollib.h
index 32884db..cfcb934 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -122,11 +122,6 @@ int get_pool_params(struct cmd_context *cmd,
 		    uint64_t *pool_metadata_size,
 		    int *zero);
 
-struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
-					   alloc_policy_t alloc, const char *name,
-					   struct dm_list *pvh, uint32_t read_ahead,
-					   uint32_t stripes, uint32_t stripe_size,
-					   uint64_t size);
 int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
 		      uint32_t *stripe_size);
 


