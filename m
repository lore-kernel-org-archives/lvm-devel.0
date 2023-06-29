From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2023 18:25:04 +0000 (GMT)
Subject: main - pool: avoid using artificial name internally
Message-ID: <20230629182504.E4DAD3858C00@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e84b00964fd6374c5afcfd86d3f61a7fda58b29d
Commit:        e84b00964fd6374c5afcfd86d3f61a7fda58b29d
Parent:        3596558861e62ca0c6f37bfba6a4e80e46dcca47
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 13:53:43 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 13:55:27 2023 +0200

pool: avoid using artificial name internally

---
 lib/metadata/metadata-exported.h | 2 +-
 lib/metadata/pool_manip.c        | 5 +----
 tools/lvconvert.c                | 3 +--
 3 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index ded0389b1..9f8c4d876 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -916,7 +916,7 @@ struct lv_status_thin {
 const char *get_pool_discards_name(thin_discards_t discards);
 int set_pool_discards(thin_discards_t *discards, const char *str);
 struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
-					   const char *name, uint32_t read_ahead,
+					   uint32_t read_ahead,
 					   uint32_t stripes, uint32_t stripe_size,
 					   uint32_t extents, alloc_policy_t alloc,
 					   struct dm_list *pvh);
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 559b07ba8..8a908a58d 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -607,7 +607,7 @@ bad:
 }
 
 struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
-					   const char *name, uint32_t read_ahead,
+					   uint32_t read_ahead,
 					   uint32_t stripes, uint32_t stripe_size,
 					   uint32_t extents, alloc_policy_t alloc,
 					   struct dm_list *pvh)
@@ -639,9 +639,6 @@ struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 	if (!(metadata_lv = lv_create_single(pool_lv->vg, &lvc)))
 		return_0;
 
-	if (!lv_rename_update(pool_lv->vg->cmd, metadata_lv, name, 0))
-		return_0;
-
 	return metadata_lv;
 }
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0e928d39c..84659d3f4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3269,7 +3269,6 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		meta_alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
 
 		if (!(metadata_lv = alloc_pool_metadata(lv,
-							meta_name,
 							meta_readahead,
 							meta_stripes,
 							meta_stripe_size,
@@ -3426,7 +3425,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	 * Rename deactivated metadata LV to have _tmeta suffix.
 	 * Implicit checks if metadata_lv is visible.
 	 */
-	if (pool_metadata_name &&
+	if ((strcmp(metadata_lv->name, meta_name) != 0) &&
 	    !lv_rename_update(cmd, metadata_lv, meta_name, 0))
 		goto_bad;
 

