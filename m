From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 30 Jul 2014 21:02:52 +0000 (UTC)
Subject: master - activation: Fix upgrades using uuid suffixes.
Message-ID: <20140730210252.95BB660C28@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7cff640d9ae20a94647610e5adbb4151b7652fe5
Commit:        7cff640d9ae20a94647610e5adbb4151b7652fe5
Parent:        c4484d90503c4e5c2bc945461da50a6b85c5d7e7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jul 30 21:55:11 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jul 30 21:55:11 2014 +0100

activation: Fix upgrades using uuid suffixes.

2.02.106 added suffixes to some LV uuids in the kernel.

If any of these LVs is activated with 2.02.105 or earlier,
and then a later version is used, the LVs appear invisible and
activation commands fail.

The code now has to check the kernel for both old and new uuids.
---
 WHATS_NEW                  |    1 +
 WHATS_NEW_DM               |    1 +
 lib/activate/dev_manager.c |   29 ++++++++++++++++++++++++++++-
 lib/misc/lvm-string.c      |    1 +
 libdm/libdevmapper.h       |    5 +++++
 libdm/libdm-deptree.c      |   41 +++++++++++++++++++++++++++++++++++++++--
 6 files changed, 75 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 64b174b..ace357b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.109 - 
 =================================
+  Handle upgrade from 2.02.105 when an LV now gaining a uuid suffix is active.
 
 Version 2.02.108 - 23rd July 2014
 =================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index ad25215..b663bfc 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.88 - 
 ================================
+  Add dm_tree_set_optional_uuid_suffixes to handle upgrades.
 
 Version 1.02.87 - 23rd July 2014
 ================================
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index d5fe620..2cf0b65 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -41,6 +41,9 @@ typedef enum {
 	CLEAN
 } action_t;
 
+/* This list must match lib/misc/lvm-string.c:build_dm_uuid(). */
+const char *uuid_suffix_list[] = { "pool", "cdata", "cmeta", "tdata", "tmeta", NULL};
+
 struct dev_manager {
 	struct dm_pool *mem;
 
@@ -482,11 +485,31 @@ static int _info(const char *dlid, int with_open_count, int with_read_ahead,
 		 struct dm_info *info, uint32_t *read_ahead)
 {
 	int r = 0;
+	char old_style_dlid[sizeof(UUID_PREFIX) + 2 * ID_LEN];
+	const char *suffix, *suffix_position;
+	unsigned i = 0;
 
+	/* Check for dlid */
 	if ((r = _info_run(NULL, dlid, info, read_ahead, 0, with_open_count,
 			   with_read_ahead, 0, 0)) && info->exists)
 		return 1;
-	else if ((r = _info_run(NULL, dlid + sizeof(UUID_PREFIX) - 1, info,
+
+	/* Check for original version of dlid before the suffixes got added in 2.02.106 */
+	if ((suffix_position = rindex(dlid, '-'))) {
+		while ((suffix = uuid_suffix_list[i++])) {
+			if (strcmp(suffix_position + 1, suffix))
+				continue;
+
+			(void) strncpy(old_style_dlid, dlid, sizeof(old_style_dlid));
+			old_style_dlid[sizeof(old_style_dlid) - 1] = '\0';
+			if ((r = _info_run(NULL, old_style_dlid, info, read_ahead, 0, with_open_count,
+					   with_read_ahead, 0, 0)) && info->exists)
+				return 1;
+		}
+	}
+
+	/* Check for dlid before UUID_PREFIX was added */
+	if ((r = _info_run(NULL, dlid + sizeof(UUID_PREFIX) - 1, info,
 				read_ahead, 0, with_open_count,
 				with_read_ahead, 0, 0)) && info->exists)
 		return 1;
@@ -2011,6 +2034,8 @@ static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, struct logi
 		return NULL;
 	}
 
+	dm_tree_set_optional_uuid_suffixes(dtree, &uuid_suffix_list[0]);
+
 	if (!_add_lv_to_dtree(dm, dtree, lv, (lv_is_origin(lv) || lv_is_thin_volume(lv)) ? origin_only : 0))
 		goto_bad;
 
@@ -3001,6 +3026,8 @@ int dev_manager_device_uses_vg(struct device *dev,
 		return r;
 	}
 
+	dm_tree_set_optional_uuid_suffixes(dtree, &uuid_suffix_list[0]);
+
 	if (!dm_tree_add_dev(dtree, (uint32_t) MAJOR(dev->dev), (uint32_t) MINOR(dev->dev))) {
 		log_error("Failed to add device %s (%" PRIu32 ":%" PRIu32") to dtree",
 			  dev_name(dev), (uint32_t) MAJOR(dev->dev), (uint32_t) MINOR(dev->dev));
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 5858638..84c8708 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -185,6 +185,7 @@ char *build_dm_uuid(struct dm_pool *mem, const struct logical_volume *lv,
 		 * an internal LV they should not scan.
 		 * Should also make internal detection simpler.
 		 */
+		/* Suffixes used here MUST match lib/activate/dev_manager.c */
 		layer = lv_is_cache_pool_data(lv) ? "cdata" :
 			lv_is_cache_pool_metadata(lv) ? "cmeta" :
 			// FIXME: dm-tree needs fixes for mirrors/raids
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index dc3da78..e37ee39 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -526,6 +526,11 @@ struct dm_tree *dm_tree_create(void);
 void dm_tree_free(struct dm_tree *tree);
 
 /*
+ * List of suffixes to be ignored when matching uuids against existing devices.
+ */
+void dm_tree_set_optional_uuid_suffixes(struct dm_tree *dtree, const char **optional_uuid_suffixes);
+
+/*
  * Add nodes to the tree for a given device and all the devices it uses.
  */
 int dm_tree_add_dev(struct dm_tree *tree, uint32_t major, uint32_t minor);
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index f34c40f..55f061a 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -16,6 +16,7 @@
 #include "libdm-targets.h"
 #include "libdm-common.h"
 #include "kdev_t.h"
+#include "dm-ioctl.h"
 
 #include <stdarg.h>
 #include <sys/param.h>
@@ -300,6 +301,7 @@ struct dm_tree {
 	int no_flush;			/* 1 sets noflush (mirrors/multipath) */
 	int retry_remove;		/* 1 retries remove if not successful */
 	uint32_t cookie;
+	const char **optional_uuid_suffixes;	/* uuid suffixes ignored when matching */
 };
 
 /*
@@ -325,6 +327,7 @@ struct dm_tree *dm_tree_create(void)
 	dtree->skip_lockfs = 0;
 	dtree->no_flush = 0;
 	dtree->mem = dmem;
+	dtree->optional_uuid_suffixes = NULL;
 
 	if (!(dtree->devs = dm_hash_create(8))) {
 		log_error("dtree hash creation failed");
@@ -539,23 +542,57 @@ static struct dm_tree_node *_find_dm_tree_node(struct dm_tree *dtree,
 				     sizeof(dev));
 }
 
+void dm_tree_set_optional_uuid_suffixes(struct dm_tree *dtree, const char **optional_uuid_suffixes)
+{
+	dtree->optional_uuid_suffixes = optional_uuid_suffixes;
+}
+
 static struct dm_tree_node *_find_dm_tree_node_by_uuid(struct dm_tree *dtree,
 						       const char *uuid)
 {
 	struct dm_tree_node *node;
 	const char *default_uuid_prefix;
 	size_t default_uuid_prefix_len;
+	const char *suffix, *suffix_position;
+	char uuid_without_suffix[DM_UUID_LEN];
+	unsigned i = 0;
+	const char **suffix_list = dtree->optional_uuid_suffixes;
 
-	if ((node = dm_hash_lookup(dtree->uuids, uuid)))
+	if ((node = dm_hash_lookup(dtree->uuids, uuid))) {
+		log_debug("Matched uuid %s in deptree.", uuid);
 		return node;
+	}
 
 	default_uuid_prefix = dm_uuid_prefix();
 	default_uuid_prefix_len = strlen(default_uuid_prefix);
 
+	if (suffix_list && (suffix_position = rindex(uuid, '-'))) {
+		while ((suffix = suffix_list[i++])) {
+			if (strcmp(suffix_position + 1, suffix))
+				continue;
+
+			(void) strncpy(uuid_without_suffix, uuid, sizeof(uuid_without_suffix));
+			uuid_without_suffix[suffix_position - uuid] = '\0';
+
+			if ((node = dm_hash_lookup(dtree->uuids, uuid_without_suffix))) {
+				log_debug("Matched uuid %s (missing suffix -%s) in deptree.", uuid_without_suffix, suffix);
+				return node;
+			}
+
+			break;
+		};
+	}
+	
 	if (strncmp(uuid, default_uuid_prefix, default_uuid_prefix_len))
 		return NULL;
 
-	return dm_hash_lookup(dtree->uuids, uuid + default_uuid_prefix_len);
+	if ((node = dm_hash_lookup(dtree->uuids, uuid + default_uuid_prefix_len))) {
+		log_debug("Matched uuid %s (missing prefix) in deptree.", uuid + default_uuid_prefix_len);
+		return node;
+	}
+
+	log_debug("Not matched uuid %s in deptree.", uuid + default_uuid_prefix_len);
+	return NULL;
 }
 
 void dm_tree_node_set_udev_flags(struct dm_tree_node *dnode, uint16_t udev_flags)


