From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 18 Jun 2014 13:00:42 +0000 (UTC)
Subject: master - cleanup: use insert_layer_for_lv implicit rename
Message-ID: <20140618130042.CD64A610B3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=597de5c807c4d5bdd7070359cb62222f454ec1f0
Commit:        597de5c807c4d5bdd7070359cb62222f454ec1f0
Parent:        e6a4cc9c316ce7c86e664c4dea2192433ff9bab4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 18 14:58:09 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 18 15:00:18 2014 +0200

cleanup: use insert_layer_for_lv implicit rename

There is implicit rename for certain layered device.
Do it now for _tdata, _cdata and _corig.

TODO: use better API here...
---
 lib/metadata/cache_manip.c |   17 -----------------
 lib/metadata/lv_manip.c    |   15 +++++++++------
 2 files changed, 9 insertions(+), 23 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 456bc86..6a0f0f6 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -91,8 +91,6 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool,
 	struct cmd_context *cmd = pool->vg->cmd;
 	struct logical_volume *cache_lv;
 	struct lv_segment *seg;
-	int origin_name_len = strlen(origin->name);
-	char origin_name[origin_name_len + 7]; /* + "_corig" and NULL */
 
 	if (!lv_is_cache_pool(pool)) {
 		log_error(INTERNAL_ERROR
@@ -124,21 +122,6 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool,
 	if (!(segtype = get_segtype_from_string(cmd, "cache")))
 		return_NULL;
 
-	/*
-	 * insert_layer_for_lv does not rename the sub-LVs when adding
-	 * the suffix.  So, we rename everything here and then change
-	 * only the top-level LV back before adding the layer.
-	 */
-	sprintf(origin_name, "%s_corig", origin->name);
-	if (!lv_rename_update(cmd, origin, origin_name, 0)) {
-		log_error("Failed to rename origin LV, %s", origin->name);
-		return NULL;
-	}
-
-	origin_name[origin_name_len] = '\0';
-	if (!(origin->name = dm_pool_strdup(origin->vg->vgmem, origin_name)))
-		return_0;
-
 	cache_lv = origin;
 	if (!(origin = insert_layer_for_lv(cmd, cache_lv, CACHE, "_corig")))
 		return_NULL;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b05f6cc..44f94f4 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5384,6 +5384,7 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 					   uint64_t status,
 					   const char *layer_suffix)
 {
+	static char _suffixes[][8] = { "_tdata", "_cdata", "_corig" };
 	int r;
 	char *name;
 	size_t len;
@@ -5493,12 +5494,14 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 	 *   currently supported only for thin data layer
 	 *   FIXME: without strcmp it breaks mirrors....
 	 */
-	if (strcmp(layer_suffix, "_tdata") == 0) {
-		lv_names.old = lv_where->name;
-		lv_names.new = layer_lv->name;
-		if (!for_each_sub_lv(layer_lv, _rename_cb, (void *) &lv_names))
-			return 0;
-	}
+	for (r = 0; r < DM_ARRAY_SIZE(_suffixes); ++r)
+		if (strcmp(layer_suffix, _suffixes[r]) == 0) {
+			lv_names.old = lv_where->name;
+			lv_names.new = layer_lv->name;
+			if (!for_each_sub_lv(layer_lv, _rename_cb, (void *) &lv_names))
+				return 0;
+			break;
+		}
 
 	return layer_lv;
 }


