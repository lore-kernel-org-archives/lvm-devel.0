From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 5 Jun 2019 09:57:40 -0400
Subject: stable-2.02 - cache: support no_discard_passdown
Message-ID: <201906051357.x55DveXj028624@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=adf9bf80a32500b45b37eb24b98fa7c2c933019e
Commit:        adf9bf80a32500b45b37eb24b98fa7c2c933019e
Parent:        f633d68c542e62fe68b6df8ec03b9851fd6e74d9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 5 14:31:34 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 5 15:54:58 2019 +0200

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
 WHATS_NEW             |    1 +
 WHATS_NEW_DM          |    1 +
 lib/metadata/lv.c     |    5 +++++
 libdm/libdevmapper.h  |    1 +
 libdm/libdm-targets.c |    2 ++
 5 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 106661f..d3da403 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.186 - 
 ================================
+  Report no_discard_passdown for cache LVs with lvs -o+kernel_discards.
   Prevent shared active mirror LVs with lvmlockd.
 
 Version 2.02.185 - 13th May 2019
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 15e5b8b..8c78724 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.160 - 
 ================================
+  Parsing of cache status understand no_discard_passdown.
 
 Version 1.02.158 - 13th May 2019
 ================================
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 2abe42d..538b292 100644
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
index 8766789..d0a8b43 100644
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
 


