From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 29 Jan 2014 17:16:50 +0000 (UTC)
Subject: master - cache/misc: Revert commit 94377dfd
Message-ID: <20140129171650.C744360FD6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d9bec60a233ab3d6a4ac7450771940db9c0d48cf
Commit:        d9bec60a233ab3d6a4ac7450771940db9c0d48cf
Parent:        42fa0e6dd14a105d17ca329f73e27f1daa64e9f3
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Jan 28 11:26:05 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Jan 28 11:26:05 2014 -0600

cache/misc: Revert commit 94377dfd

I am reverting the commit below - removing the new 'dm_config_get_int'
function and simply calling 'dm_config_get_uint32' while casting the
'int *' pointer parameter.

Commit being reverted:
commit 94377dfd5ee7bbbdeb8836eeeea2198bc32c07f5
Author: Jonathan Brassow <jbrassow@redhat.com>
Date:   Mon Jan 27 05:26:19 2014 -0600

    Misc: New function for reading lvm config file fields

    Introduce 'dm_config_get_int', which will be used by the upcoming
    cachepool segment type.
---
 lib/cache_segtype/cache.c |    6 ++++--
 libdm/libdevmapper.h      |    1 -
 libdm/libdm-config.c      |   14 --------------
 3 files changed, 4 insertions(+), 17 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index bfc84c3..3e74495 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -97,7 +97,8 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 		if (!dm_config_has_node(sn, "core_argv"))
 			return SEG_LOG_ERROR("not all core arguments defined in");
 
-		if (!dm_config_get_int(sn, "core_argc", &seg->core_argc))
+		if (!dm_config_get_uint32(sn, "core_argc",
+					  (uint32_t *)&seg->core_argc))
 			return SEG_LOG_ERROR("Unable to read core_argc in");
 
 		str = dm_config_find_str(sn, "core_argv", NULL);
@@ -135,7 +136,8 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 			return SEG_LOG_ERROR("policy_name must be a string in");
 		seg->policy_name = dm_pool_strdup(mem, str);
 
-		if (!dm_config_get_int(sn, "policy_argc", &seg->policy_argc))
+		if (!dm_config_get_uint32(sn, "policy_argc",
+					  (uint32_t *)&seg->policy_argc))
 			return SEG_LOG_ERROR("Unable to read policy_argc in");
 
 		str = dm_config_find_str(sn, "policy_argv", NULL);
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 670c5e09..131bd3f 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1720,7 +1720,6 @@ int dm_config_tree_find_bool(const struct dm_config_tree *cft, const char *path,
 int dm_config_find_bool(const struct dm_config_node *cn, const char *path, int fail);
 int dm_config_value_is_bool(const struct dm_config_value *v);
 
-int dm_config_get_int(const struct dm_config_node *cn, const char *path, int *result);
 int dm_config_get_uint32(const struct dm_config_node *cn, const char *path, uint32_t *result);
 int dm_config_get_uint64(const struct dm_config_node *cn, const char *path, uint64_t *result);
 int dm_config_get_str(const struct dm_config_node *cn, const char *path, const char **result);
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index 3297621..ea1af2f 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -1047,20 +1047,6 @@ int dm_config_tree_find_bool(const struct dm_config_tree *cft, const char *path,
 
 /************************************/
 
-int dm_config_get_int(const struct dm_config_node *cn, const char *path,
-		      int *result)
-{
-	const struct dm_config_node *n;
-
-	n = _find_config_node(cn, path);
-
-	if (!n || !n->v || n->v->type != DM_CFG_INT)
-		return 0;
-
-	if (result)
-		*result = n->v->v.i;
-	return 1;
-}
 
 int dm_config_get_uint32(const struct dm_config_node *cn, const char *path,
 			 uint32_t *result)


