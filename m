From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:36:28 -0500
Subject: master - cache: improve profile support for cache_set_policy
Message-ID: <201703101836.v2AIaSGU028482@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=21c265adcffa5a2a8b5f308556e53dbe46c242d7
Commit:        21c265adcffa5a2a8b5f308556e53dbe46c242d7
Parent:        4d0793f0ec7c02fb4bec9ad092746e6fe027823f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 7 23:54:01 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:01 2017 +0100

cache: improve profile support for cache_set_policy

---
 lib/metadata/cache_manip.c |   63 ++++++++++++++++++++++---------------------
 1 files changed, 32 insertions(+), 31 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 536a444..a3e4d95 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -682,30 +682,36 @@ int cache_set_policy(struct lv_segment *seg, const char *name,
 	const struct dm_config_node *cns;
 	struct dm_config_tree *old = NULL, *new = NULL, *tmp = NULL;
 	int r = 0;
-	const int passed_seg_is_cache = seg_is_cache(seg);
 	struct profile *profile = seg->lv->profile;
 
-	if (passed_seg_is_cache)
+	if (seg_is_cache(seg))
 		seg = first_seg(seg->pool_lv);
+	else if (seg_is_cache_pool(seg)) {
+		if (!name && !settings)
+			return 1; /* Policy and settings can be selected later when caching LV */
+	} else {
+		log_error(INTERNAL_ERROR "Cannot set cache metadata format for non cache volume %s.",
+			  display_lvname(seg->lv));
+		return 0;
+	}
 
 	if (name) {
 		if (!(seg->policy_name = dm_pool_strdup(seg->lv->vg->vgmem, name))) {
 			log_error("Failed to duplicate policy name.");
 			return 0;
 		}
-	} else if (!seg->policy_name && passed_seg_is_cache) {
+	} else if (!seg->policy_name) {
 		if (!(seg->policy_name = find_config_tree_str(seg->lv->vg->cmd, allocation_cache_policy_CFG,
 							      profile)) &&
 		    !(seg->policy_name = _get_default_cache_policy(seg->lv->vg->cmd)))
 			return_0;
-	}
-
-	if (settings) {
 		if (!seg->policy_name) {
 			log_error(INTERNAL_ERROR "Can't set policy settings without policy name.");
 			return 0;
 		}
+	}
 
+	if (settings) {
 		if (seg->policy_settings) {
 			if (!(old = dm_config_create()))
 				goto_out;
@@ -721,31 +727,26 @@ int cache_set_policy(struct lv_segment *seg, const char *name,
 		if ((cn = dm_config_find_node((tmp) ? tmp->root : settings->root, "policy_settings")) &&
 		    !(seg->policy_settings = dm_config_clone_node_with_mem(seg->lv->vg->vgmem, cn, 0)))
 			goto_out;
-	} else if (passed_seg_is_cache && /* Look for command's profile cache_policies */
-		   (cns = find_config_tree_node(seg->lv->vg->cmd, allocation_cache_settings_CFG_SECTION,
-						seg->lv->profile))) {
-		/* Try to find our section for given policy */
-		for (cn = cns->child; cn; cn = cn->sib) {
-			/* Only matching section names */
-			if (cn->v || strcmp(cn->key, seg->policy_name) != 0)
-				continue;
-
-			if (!cn->child)
-				break;
-
-			if (!(new = dm_config_create()))
-				goto_out;
-
-			if (!(new->root = dm_config_clone_node_with_mem(new->mem,
-									cn->child, 1)))
-				goto_out;
-
-			if (!(seg->policy_settings = dm_config_create_node(new, "policy_settings")))
-				goto_out;
-
-			seg->policy_settings->child = new->root;
-
-			break; /* Only first match counts */
+	} else if (!seg->policy_settings) {
+		if ((cns = find_config_tree_node(seg->lv->vg->cmd, allocation_cache_settings_CFG_SECTION,
+						 profile))) {
+			/* Try to find our section for given policy */
+			for (cn = cns->child; cn; cn = cn->sib) {
+				if (!cn->child)
+					continue; /* Ignore section without settings */
+
+				if (cn->v || strcmp(cn->key, seg->policy_name) != 0)
+					continue; /* Ignore mismatching sections */
+
+				/* Clone nodes with policy name */
+				if (!(seg->policy_settings = dm_config_clone_node_with_mem(seg->lv->vg->vgmem,
+											   cn, 0)))
+					return_0;
+
+				/* Replace policy name key with 'policy_settings' */
+				seg->policy_settings->key = "policy_settings";
+				break; /* Only first match counts */
+			}
 		}
 	}
 


