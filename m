From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Aug 2015 12:41:19 +0000 (UTC)
Subject: master - cleanup: indent
Message-ID: <20150812124119.1FDCE60072@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=48ed8ac50cd0c384c3ff4e5e7dbc79b8f1c24cef
Commit:        48ed8ac50cd0c384c3ff4e5e7dbc79b8f1c24cef
Parent:        ece758457de0c5a40b5b33b90cab2238de34d55e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 21 11:18:42 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 12 14:33:16 2015 +0200

cleanup: indent

---
 lib/cache_segtype/cache.c |    4 ++--
 lib/metadata/lv_manip.c   |    3 ++-
 libdm/libdm-deptree.c     |    2 --
 3 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 53c867e..85cba18 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -170,8 +170,8 @@ static void _destroy(struct segment_type *segtype)
 
 #ifdef DEVMAPPER_SUPPORT
 static int _target_present(struct cmd_context *cmd,
-				const struct lv_segment *seg __attribute__((unused)),
-				unsigned *attributes __attribute__((unused)))
+			   const struct lv_segment *seg __attribute__((unused)),
+			   unsigned *attributes __attribute__((unused)))
 {
 	/* List of features with their kernel target version */
 	static const struct feature {
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 116f099..c192d1b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6998,7 +6998,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 	if (seg_is_pool(lp))
 		status |= LVM_WRITE; /* Pool is always writable */
-        else if (seg_is_cache(lp) || seg_is_thin_volume(lp)) {
+	else if (seg_is_cache(lp) || seg_is_thin_volume(lp)) {
 		/* Resolve pool volume */
 		if (!lp->pool_name) {
 			/* Should be already checked */
@@ -7222,6 +7222,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	if (!archive(vg))
 		return_NULL;
 
+
 	if (pool_lv && seg_is_thin_volume(lp)) {
 		/* Ensure all stacked messages are submitted */
 		if ((pool_is_active(pool_lv) || is_change_activating(lp->activate)) &&
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 040a826..d28f0de 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -3405,7 +3405,6 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 	if (!_link_tree_nodes(node, seg->metadata))
 		return_0;
 
-
 	if (!(seg->origin = dm_tree_find_node_by_uuid(node->dtree,
 						      origin_uuid))) {
 		log_error("Missing cache's origin uuid %s.",
@@ -3434,7 +3433,6 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 		}
 	}
 
-
 	return 1;
 }
 


