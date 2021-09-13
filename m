From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:36:03 +0000 (GMT)
Subject: main - cache: filter out unsupported policy settings
Message-ID: <20210913103603.9279E3858002@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4c3d7a01d4a28c83b7992749c0ae8b7e9c145f3a
Commit:        4c3d7a01d4a28c83b7992749c0ae8b7e9c145f3a
Parent:        6c4cd7b2f22a86a74f49104926ab96a24755e697
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 12 17:41:53 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

cache: filter out unsupported policy settings

Loading invalid MQ/SMQ policy settings table line cause immediate
rejection - to prevent such failure, automatically filter valid
settins before it is being uploaded by lvm2.

For invalid setting issue a warnning informing user how to remove
them.

This solution is used to keep running cached LVs that might had
been created in the past with invalid settings that have been actually
unused due to another code bug.
---
 WHATS_NEW                 |  1 +
 lib/cache_segtype/cache.c | 60 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 60 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9ff0be667..2da629297 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.14 - 
 ==================================
+  Filter out unsupported MQ/SMQ cache policy setting.
   Fix memleak in mpath filter.
   Support newer location for VDO statistics.
   Add support for VDO async-unsage write policy.
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 69b46a55b..93d4c5283 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -618,6 +618,9 @@ static int _cache_add_target_line(struct dev_manager *dm,
 {
 	struct lv_segment *cache_pool_seg;
 	struct lv_segment *setting_seg;
+	struct dm_config_node *policy_settings;
+	struct dm_config_node *cn;
+	unsigned  i, j;
 	union lvid metadata_lvid;
 	union lvid data_lvid;
 	char *metadata_uuid, *data_uuid, *origin_uuid;
@@ -718,6 +721,61 @@ static int _cache_add_target_line(struct dev_manager *dm,
 			return_0;
 	}
 
+	policy_settings = seg->cleaner_policy ? NULL : setting_seg->policy_settings;
+	if (policy_settings && cache_pool_seg->policy_name) {
+		static const struct act {
+			const char *name;
+			const char *settings[20];
+		} _accepted[] = {
+			{
+				"MQ", {
+					"migration_threshold", "sequential_threshold", "random_threshold",
+					"read_promote_adjustment", "write_promote_adjustment",
+					"discard_promote_adjustment", NULL
+				},
+			}, {
+				"SMQ", {
+					"migration_threshold", NULL
+				}
+			}
+		};
+
+                /* Check if cache settings are acceptable to knownm policies */
+		for (i = 0; i < DM_ARRAY_SIZE(_accepted); i++) {
+			if (strcasecmp(cache_pool_seg->policy_name, _accepted[i].name))
+				continue;
+
+			for (cn = policy_settings->child; cn; cn = cn->sib) {
+				for (j = 0; _accepted[i].settings[j]; j++)
+					if (strcmp(cn->key, _accepted[i].settings[j]) == 0)
+						break; /* -> Valid setting */
+
+				/* Have we found 'unsupported' cache setting? */
+				if (!_accepted[i].settings[j]) {
+					/* Make a copy of policy settings a remove unsupported settings and Warn */
+					if (!(policy_settings = dm_config_clone_node_with_mem(mem, policy_settings, 0)))
+						return_0;
+				restart:
+					for (cn = policy_settings->child; cn; cn = cn->sib) {
+						for (j = 0; _accepted[i].settings[j]; j++) {
+							if (strcmp(cn->key, _accepted[i].settings[j]) == 0)
+								break; /* need to be dropped */
+						}
+						if (!_accepted[i].settings[j]) {
+							log_warn("WARNING: %s cache policy does not support \"%s=" FMTu64 "\" setting, "
+								 "remove with 'lvchange --cachesettings \"%s=default\" ...'.",
+								 _accepted[i].name, cn->key, cn->v->v.i, cn->key);
+							dm_config_remove_node(policy_settings, cn);
+							goto restart;
+						}
+					}
+					break;
+				}
+			}
+			break;
+		}
+	}
+
 	if (!dm_tree_node_add_cache_target(node, len,
 					   feature_flags,
 					   metadata_uuid,
@@ -726,7 +784,7 @@ static int _cache_add_target_line(struct dev_manager *dm,
 					   seg->cleaner_policy ? "cleaner" :
 						   /* undefined policy name -> likely an old "mq" */
 						   cache_pool_seg->policy_name ? : "mq",
-					   seg->cleaner_policy ? NULL : setting_seg->policy_settings,
+					   policy_settings,
 					   seg->metadata_start,
 					   seg->metadata_len,
 					   seg->data_start,


