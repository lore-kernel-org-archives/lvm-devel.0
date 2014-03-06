From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  6 Mar 2014 11:21:12 +0000 (UTC)
Subject: master - config: add default for allocation/cache_pool_chunk_size
Message-ID: <20140306112112.769986114B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=74a3fc4e853de50b0e5ccafcd2c9c5328dc10ad1
Commit:        74a3fc4e853de50b0e5ccafcd2c9c5328dc10ad1
Parent:        d27868e94fb953c7e61da1e0d356f816e4567933
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 4 11:15:54 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 6 11:34:02 2014 +0100

config: add default for allocation/cache_pool_chunk_size

The same as for allocation/thin_pool_chunk_size - the default value
used is just a starting point. The calculation continues using the
properties of the devices actually used.
---
 lib/config/config.c          |    5 +++++
 lib/config/config.h          |    1 +
 lib/config/config_settings.h |    4 +---
 lib/metadata/lv_manip.c      |    2 +-
 4 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 3cc091c..1717343 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1711,3 +1711,8 @@ int get_default_allocation_thin_pool_chunk_size_CFG(struct cmd_context *cmd, str
 
 	return (int) chunk_size;
 }
+
+int get_default_allocation_cache_pool_chunk_size_CFG(struct cmd_context *cmd, struct profile *profile)
+{
+	return DEFAULT_CACHE_POOL_CHUNK_SIZE;
+}
diff --git a/lib/config/config.h b/lib/config/config.h
index 7d7d4b2..9a8209d 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -237,5 +237,6 @@ const char *get_default_backup_archive_dir_CFG(struct cmd_context *cmd, struct p
 const char *get_default_config_profile_dir_CFG(struct cmd_context *cmd, struct profile *profile);
 const char *get_default_activation_mirror_image_fault_policy_CFG(struct cmd_context *cmd, struct profile *profile);
 int get_default_allocation_thin_pool_chunk_size_CFG(struct cmd_context *cmd, struct profile *profile);
+int get_default_allocation_cache_pool_chunk_size_CFG(struct cmd_context *cmd, struct profile *profile);
 
 #endif
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 6231b79..e631de6 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -117,10 +117,8 @@ cfg(allocation_maximise_cling_CFG, "maximise_cling", allocation_CFG_SECTION, 0,
 cfg(allocation_use_blkid_wiping_CFG, "use_blkid_wiping", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL)
 cfg(allocation_wipe_signatures_when_zeroing_new_lvs_CFG, "wipe_signatures_when_zeroing_new_lvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL)
 cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS, vsn(2, 2, 85), NULL)
-
 cfg(allocation_cache_pool_metadata_require_separate_pvs_CFG, "cache_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 106), NULL)
-cfg(allocation_cache_pool_chunk_size_CFG, "cache_pool_chunk_size", allocation_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(2, 2, 106), NULL)
-
+cfg_runtime(allocation_cache_pool_chunk_size_CFG, "cache_pool_chunk_size", allocation_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 106), NULL)
 cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL)
 cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL)
 cfg(allocation_thin_pool_discards_CFG, "thin_pool_discards", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_THIN_POOL_DISCARDS, vsn(2, 2, 99), NULL)
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 51342a3..1264de7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5777,7 +5777,7 @@ static int _recalculate_pool_chunk_size_with_dev_hints(struct lvcreate_params *l
 			goto out;
 		min_chunk_size = DM_CACHE_MIN_DATA_BLOCK_SIZE;
 		max_chunk_size = DM_CACHE_MAX_DATA_BLOCK_SIZE;
-		default_chunk_size = DEFAULT_CACHE_POOL_CHUNK_SIZE*2;
+		default_chunk_size = get_default_allocation_cache_pool_chunk_size_CFG(cmd, NULL) * 2;
 	} else {
 		log_error(INTERNAL_ERROR "%s is not a thin pool or cache pool",
 			  pool_lv->name);


