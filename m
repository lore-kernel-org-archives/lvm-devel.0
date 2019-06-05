From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 5 Jun 2019 09:49:26 -0400
Subject: master - cache: support no_discard_passdown
Message-ID: <201906051349.x55DnQBR026256@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e3c4ab0cc788b0190ab58446189c2d6b07a27b98
Commit:        e3c4ab0cc788b0190ab58446189c2d6b07a27b98
Parent:        d18e491f6890e15a677e8189de0699ccc7412f16
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 5 14:31:34 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 5 15:48:41 2019 +0200

cache: support no_discard_passdown

Recent kernel version from kernel commit:
de7180ff908b2bc0342e832dbdaa9a5f1ecaa33a
started to report in cache status line new flag:
no_discard_passdown

Whenever lvm spots unknown status it reports:
Unknown feature in status:

So add reconginzing this feature flag and also report this with

'lvs -o+kernel_discards'

When no_discard_passdown is found in status 'nopassdown' gets reported
for this field  (roughly matching what we report for thin-pools).
---
 WHATS_NEW                     |    1 +
 WHATS_NEW_DM                  |    1 +
 device_mapper/all.h           |    1 +
 device_mapper/libdm-targets.c |    2 ++
 lib/metadata/lv.c             |    5 +++++
 libdm/libdevmapper.h          |    1 +
 libdm/libdm-targets.c         |    2 ++
 7 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fd27c33..b5deceb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Report no_discard_passdown for cache LVs with lvs -o+kernel_discards.
   Add pvck --dump option to extract metadata.
   Fix signal delivery checking race in libdaemon (lvmetad).
   Add missing Before=shutdown.target to LVM2 services to fix shutdown ordering.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 7c8b853..8a2146d 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.155 - 
 ====================================
+  Parsing of cache status understand no_discard_passdown.
   Ensure migration_threshold for cache is at least 8 chunks.
   Include correct internal header inside libdm list.c.
   Enhance ioctl flattening and add parameters only when needed.
diff --git a/device_mapper/all.h b/device_mapper/all.h
index 05cd83b..bdb69e1 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -903,6 +903,7 @@ int dm_tree_node_add_raid_target_with_params_v2(struct dm_tree_node *node,
 #define DM_CACHE_FEATURE_WRITETHROUGH 0x00000002
 #define DM_CACHE_FEATURE_PASSTHROUGH  0x00000004
 #define DM_CACHE_FEATURE_METADATA2    0x00000008 /* cache v1.10 */
+#define DM_CACHE_FEATURE_NO_DISCARD_PASSDOWN 0x00000010
 
 struct dm_config_node;
 /*
diff --git a/device_mapper/libdm-targets.c b/device_mapper/libdm-targets.c
index 607f429..d82e28b 100644
--- a/device_mapper/libdm-targets.c
+++ b/device_mapper/libdm-targets.c
@@ -296,6 +296,8 @@ int dm_get_status_cache(struct dm_pool *mem, const char *params,
 			s->feature_flags |= DM_CACHE_FEATURE_PASSTHROUGH;
 		else if (!strncmp(p, "metadata2 ", 10))
 			s->feature_flags |= DM_CACHE_FEATURE_METADATA2;
+		else if (!strncmp(p, "no_discard_passdown ", 20))
+			s->feature_flags |= DM_CACHE_FEATURE_NO_DISCARD_PASSDOWN;
 		else
 			log_error("Unknown feature in status: %s", params);
 
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index e8f1fab..b4ed712 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -245,6 +245,11 @@ char *lvseg_kernel_discards_dup_with_info_and_seg_status(struct dm_pool *mem, co
 			return 0;
 		}
 		s = get_pool_discards_name(d);
+	} else if (lvdm->seg_status.type == SEG_STATUS_CACHE) {
+		if (lvdm->seg_status.cache->feature_flags &
+		    DM_CACHE_FEATURE_NO_DISCARD_PASSDOWN) {
+			s = "nopassdown";
+		}
 	}
 
 	if (!(ret = dm_pool_strdup(mem, s))) {
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 19032d7..e885f52 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1893,6 +1893,7 @@ int dm_tree_node_add_raid_target_with_params_v2(struct dm_tree_node *node,
 #define DM_CACHE_FEATURE_WRITETHROUGH 0x00000002
 #define DM_CACHE_FEATURE_PASSTHROUGH  0x00000004
 #define DM_CACHE_FEATURE_METADATA2    0x00000008 /* cache v1.10 */
+#define DM_CACHE_FEATURE_NO_DISCARD_PASSDOWN 0x00000010
 
 struct dm_config_node;
 /*
diff --git a/libdm/libdm-targets.c b/libdm/libdm-targets.c
index f2bac51..164d515 100644
--- a/libdm/libdm-targets.c
+++ b/libdm/libdm-targets.c
@@ -296,6 +296,8 @@ int dm_get_status_cache(struct dm_pool *mem, const char *params,
 			s->feature_flags |= DM_CACHE_FEATURE_PASSTHROUGH;
 		else if (!strncmp(p, "metadata2 ", 10))
 			s->feature_flags |= DM_CACHE_FEATURE_METADATA2;
+		else if (!strncmp(p, "no_discard_passdown ", 20))
+			s->feature_flags |= DM_CACHE_FEATURE_NO_DISCARD_PASSDOWN;
 		else
 			log_error("Unknown feature in status: %s", params);
 


