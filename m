From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 24 Jun 2020 13:02:42 +0000 (GMT)
Subject: master - pool: zero metadata
Message-ID: <20200624130242.A3B6B3938C10@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bc39d5bec6fea787a8d8d16fa484084b7d2a7c29
Commit:        bc39d5bec6fea787a8d8d16fa484084b7d2a7c29
Parent:        edbc5a62b26806e5c4de59b5292609e955303576
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 24 12:11:21 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 24 15:01:03 2020 +0200

pool: zero metadata

To avoid polution of metadata with some 'garbage' content or eventualy
some leak of stale data in case user want to upload metadata somewhere,
ensure upon allocation the metadata device is fully zeroed.

Behaviour may slow down allocation of thin-pool or cache-pool a bit
so the old behaviour can be restored with lvm.conf setting:
allocation/zero_metadata=0

TODO: add zeroing for extension of metadata volume.
---
 WHATS_NEW                        |  1 +
 lib/config/config_settings.h     |  5 ++++-
 lib/config/defaults.h            |  1 +
 lib/metadata/lv_manip.c          | 29 ++++++++++++++++++++++-------
 lib/metadata/metadata-exported.h |  2 ++
 lib/metadata/pool_manip.c        |  6 ++++--
 6 files changed, 34 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b770455fb..2e2e6d919 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.10 - 
 =================================
+  Zero pool metadata on allocation (disable with allocation/zero_metadata=0).
   Failure in zeroing or wiping will fail command (bypass with -Zn, -Wn).
   Fix running out of free buffers for async writing for larger writes.
   Add integrity with raid capability.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 2bb72ba71..531fb139d 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -626,7 +626,7 @@ cfg(allocation_cache_pool_max_chunks_CFG, "cache_pool_max_chunks", allocation_CF
 	"Using cache pool with more chunks may degrade cache performance.\n")
 
 cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL, 0, NULL,
-	"Thin pool metdata and data will always use different PVs.\n")
+	"Thin pool metadata and data will always use different PVs.\n")
 
 cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL, 0, NULL,
 	"Thin pool data chunks are zeroed before they are first used.\n"
@@ -657,6 +657,9 @@ cfg(allocation_thin_pool_chunk_size_policy_CFG, "thin_pool_chunk_size_policy", a
 	"    512KiB.\n"
 	"#\n")
 
+cfg(allocation_zero_metadata_CFG, "zero_metadata", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ZERO_METADATA, vsn(2, 3, 10), NULL, 0, NULL,
+	"Zero whole metadata area before use with thin or cache pool.\n")
+
 cfg_runtime(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 99), 0, NULL,
 	"The minimal chunk size in KiB for thin pool volumes.\n"
 	"Larger chunk sizes may improve performance for plain thin volumes,\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index be4f5ff7f..708a57554 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -129,6 +129,7 @@
 #define DEFAULT_THIN_POOL_DISCARDS "passdown"
 #define DEFAULT_THIN_POOL_ZERO 1
 #define DEFAULT_POOL_METADATA_SPARE 1 /* thin + cache */
+#define DEFAULT_ZERO_METADATA 1		/* thin + cache */
 
 #ifdef CACHE_CHECK_NEEDS_CHECK
 #  define DEFAULT_CACHE_CHECK_OPTION1 "-q"
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8250819da..d96137aff 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7576,8 +7576,10 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 	struct device *dev;
 	char name[PATH_MAX];
 	uint64_t zero_sectors;
+	int zero_metadata = wp.is_metadata ?
+		find_config_tree_bool(lv->vg->cmd, allocation_zero_metadata_CFG, NULL) : 0;
 
-	if (!wp.do_zero && !wp.do_wipe_signatures)
+	if (!wp.do_zero && !wp.do_wipe_signatures && !wp.is_metadata)
 		/* nothing to do */
 		return 1;
 
@@ -7629,17 +7631,29 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 		}
 	}
 
-	if (wp.do_zero) {
-		zero_sectors = wp.zero_sectors ? : UINT64_C(4096) >> SECTOR_SHIFT;
-
-		if (zero_sectors > lv->size)
+	if (wp.do_zero || wp.is_metadata) {
+		zero_metadata = !wp.is_metadata ? 0 :
+			find_config_tree_bool(lv->vg->cmd, allocation_zero_metadata_CFG, NULL);
+		if (zero_metadata) {
+			log_debug("Metadata logical volume %s will be fully zeroed.",
+				  display_lvname(lv));
 			zero_sectors = lv->size;
+		} else {
+			if (wp.is_metadata) /* Verbosely notify metadata will not be fully zeroed */
+				log_verbose("Metadata logical volume %s not fully zeroed and may contain stale data.",
+					    display_lvname(lv));
+			zero_sectors = wp.zero_sectors ? : UINT64_C(4096) >> SECTOR_SHIFT;
+
+			if (zero_sectors > lv->size)
+				zero_sectors = lv->size;
+		}
 
 		log_verbose("Initializing %s of logical volume %s with value %d.",
 			    display_size(lv->vg->cmd, zero_sectors),
 			    display_lvname(lv), wp.zero_value);
 
-		if ((wp.zero_value && !dev_set_bytes(dev, UINT64_C(0),
+		if ((!wp.is_metadata &&
+		     wp.zero_value && !dev_set_bytes(dev, UINT64_C(0),
 						     (size_t) zero_sectors << SECTOR_SHIFT,
 						     (uint8_t)wp.zero_value)) ||
 		    !dev_write_zeros(dev, UINT64_C(0), (size_t) zero_sectors << SECTOR_SHIFT)) {
@@ -8465,7 +8479,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				     .do_zero = lp->zero,
 				     .do_wipe_signatures = lp->wipe_signatures,
 				     .yes = lp->yes,
-				     .force = lp->force
+				     .force = lp->force,
+				     .is_metadata = lp->is_metadata,
 			     })) {
 			log_error("Aborting. Failed to wipe %s.", lp->snapshot
 				  ? "snapshot exception store" : "start of new LV");
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0cc5f37a0..06ea757b8 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -803,6 +803,7 @@ struct wipe_params {
 	int do_wipe_signatures;	/* should we wipe known signatures found on LV? */
 	int yes;		/* answer yes automatically to all questions */
 	force_t force;		/* force mode */
+	int is_metadata;	/* wipe volume is metadata LV */
 };
 
 /* Zero out LV and/or wipe signatures */
@@ -955,6 +956,7 @@ struct lvcreate_params {
 	unsigned suppress_zero_warn : 1;
 	unsigned needs_lockd_init : 1;
 	unsigned ignore_type : 1;
+	unsigned is_metadata : 1; /* created LV will be used as metadata LV (and can be zeroed) */
 
 	const char *vg_name; /* only-used when VG is not yet opened (in /tools) */
 	const char *lv_name; /* all */
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index bed51f12a..23b5b63ba 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -545,8 +545,8 @@ int create_pool(struct logical_volume *pool_lv,
 				  display_lvname(pool_lv));
 			goto bad;
 		}
-		/* Clear 4KB of pool metadata device. */
-		if (!(r = wipe_lv(pool_lv, (struct wipe_params) { .do_zero = 1 }))) {
+		/* Clear pool metadata device. */
+		if (!(r = wipe_lv(pool_lv, (struct wipe_params) { .is_metadata = 1 }))) {
 			log_error("Aborting. Failed to wipe pool metadata %s.",
 				  display_lvname(pool_lv));
 		}
@@ -627,6 +627,7 @@ struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 		.tags = DM_LIST_HEAD_INIT(lvc.tags),
 		.temporary = 1,
 		.zero = 1,
+		.is_metadata = 1,
 	};
 
 	if (!(lvc.segtype = get_segtype_from_string(pool_lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
@@ -663,6 +664,7 @@ static struct logical_volume *_alloc_pool_metadata_spare(struct volume_group *vg
 		.tags = DM_LIST_HEAD_INIT(lp.tags),
 		.temporary = 1,
 		.zero = 1,
+		.is_metadata = 1,
 	};
 
 	if (!(lp.segtype = get_segtype_from_string(vg->cmd, SEG_TYPE_NAME_STRIPED)))


