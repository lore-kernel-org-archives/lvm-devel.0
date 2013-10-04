From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  4 Oct 2013 13:40:33 +0000 (UTC)
Subject: master - release 2.02.103
Message-ID: <20131004134033.A468E60D88@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=04d9a526843dcb93fc0110e6e9dfbb12143a3930
Commit:        04d9a526843dcb93fc0110e6e9dfbb12143a3930
Parent:        0d03503a453f91cee09fb3a1664d2136d58ac751
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Oct 4 14:32:23 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Oct 4 14:32:23 2013 +0100

release 2.02.103

52 files changed, 598 insertions(+), 264 deletions(-)
---
 VERSION                          |    2 +-
 VERSION_DM                       |    2 +-
 WHATS_NEW                        |   12 +++++++-----
 WHATS_NEW_DM                     |    4 ++--
 conf/example.conf.in             |    2 +-
 conf/thin-performance.profile    |    2 +-
 lib/config/defaults.h            |    6 +++---
 lib/metadata/lv_manip.c          |    4 ++--
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/thin_manip.c        |    2 +-
 tools/lvconvert.c                |    8 ++++----
 tools/lvcreate.c                 |    4 ++--
 12 files changed, 26 insertions(+), 24 deletions(-)

diff --git a/VERSION b/VERSION
index d1e7c0e..f4bbdb9 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.103(2)-git (2013-09-23)
+2.02.103(2)-git (2013-10-04)
diff --git a/VERSION_DM b/VERSION_DM
index 6c755b8..f4e8c0b 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.82-git (2013-09-23)
+1.02.82-git (2013-10-04)
diff --git a/WHATS_NEW b/WHATS_NEW
index 0b71786..d69e74e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,14 +1,16 @@
-Version 2.02.103 - 
-======================================
+Version 2.02.103 - 4th October 2013
+===================================
+  Ensure vgid matches before removing vgname entry from lvmetad cache.
   Add --ignoreskippedcluster for exit status success when clustered VGs skipped.
-  Fix 3min udev timeout so that it is applied for all LVM volumes.
+  Fix 3 minute udev timeout so that it is applied for all LVM volumes.
+  Fix thin/raid & activation config defaults with configure --disable-devmapper.
   Fix RAID calculation for sufficient allocatable space.
-  Conversion from linear to mirror or RAID1 now honors mirror_segtype_default.
+  lvconvert from linear to mirror or RAID1 now honors mirror_segtype_default.
   Add thin-performance configuration profile.
   Add lvm.conf allocation/thin_pool_chunk_size_policy option.
   Fix contiguous & cling allocation policies for parity RAID.  (2.02.100)
   Have lvmconf --enable/disable-cluster reset/set use_lvmetad.
-  Don't install separate command symlink in binary directory for 'lvm devtypes'.
+  Don't install separate command symlink for 'lvm devtypes'. (2.02.101)
   Add seg_size_pe field to reports.
   Support start+length notation with command line PE ranges.
   Exit cleanly with message when pvmove cannot restart because LV is inactive.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index dfc2d89..9dfd9bf 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.82 - 
-=====================================
+Version 1.02.82 - 4th October 2013
+==================================
   Define symbolic names for subsystem udev flags in libdevmapper for easier use.
   Make subsystem udev rules responsible for importing DM_SUBSYSTEM_UDEV_FLAG*.
 
diff --git a/conf/example.conf.in b/conf/example.conf.in
index e0f8be8..ae571b6 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -255,7 +255,7 @@ allocation {
     # Specify chunk size calculation policy for thin pool volumes.
     # Possible options are:
     # "generic"        - if thin_pool_chunk_size is defined, use it.
-    #                    Otherwise, calcucate the chunk size based on
+    #                    Otherwise, calculate the chunk size based on
     #                    estimation and device hints exposed in sysfs:
     #                    the minimum_io_size. The chunk size is always
     #                    at least 64KiB.
diff --git a/conf/thin-performance.profile b/conf/thin-performance.profile
index fbd46aa..2914de2 100644
--- a/conf/thin-performance.profile
+++ b/conf/thin-performance.profile
@@ -1,4 +1,4 @@
 allocation {
-	thin_pool_chunk_size_calculation = "performance"
+	thin_pool_chunk_size_policy = "performance"
 	thin_pool_zero = 0
 }
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index fc2d4dc..bd7a40a 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -141,9 +141,9 @@
 #  define DEFAULT_ACTIVATION 0
 #endif
 
-# define DEFAULT_RESERVED_MEMORY 8192
-#  define DEFAULT_RESERVED_STACK 64 /* KB */
-#  define DEFAULT_PROCESS_PRIORITY -18
+#define DEFAULT_RESERVED_MEMORY 8192
+#define DEFAULT_RESERVED_STACK 64 /* KB */
+#define DEFAULT_PROCESS_PRIORITY -18
 
 #define DEFAULT_AUTO_SET_ACTIVATION_SKIP 1
 #define DEFAULT_USE_LINEAR_TARGET 1
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 71b5278..f42db1d 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5541,7 +5541,7 @@ static int _recalculate_thin_pool_chunk_size_with_dev_hints(struct lvcreate_para
 	struct cmd_context *cmd = pool_lv->vg->cmd;
 	unsigned long previous_hint = 0, hint = 0;
 	uint32_t chunk_size = lp->chunk_size;
-	uint32_t default_chunk_size = lp->thin_chunk_size_calc_method == THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE ?
+	uint32_t default_chunk_size = lp->thin_chunk_size_calc_policy == THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE ?
 					DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE*2 : DEFAULT_THIN_POOL_CHUNK_SIZE*2;
 
 	if (lp->passed_args & PASS_ARG_CHUNK_SIZE ||
@@ -5552,7 +5552,7 @@ static int _recalculate_thin_pool_chunk_size_with_dev_hints(struct lvcreate_para
 
 	dm_list_iterate_items(seg, &pool_data_lv->segments) {
 		pv = seg_pv(seg, 0);
-		if (lp->thin_chunk_size_calc_method == THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE)
+		if (lp->thin_chunk_size_calc_policy == THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE)
 			hint = dev_optimal_io_size(cmd->dev_types, pv_dev(pv));
 		else
 			hint = dev_minimum_io_size(cmd->dev_types, pv_dev(pv));
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 971f677..308dcfe 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -728,7 +728,7 @@ struct lvcreate_params {
 	thin_discards_t discards;     /* thin */
 #define THIN_CHUNK_SIZE_CALC_METHOD_GENERIC 0x01
 #define THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE 0x02
-	int thin_chunk_size_calc_method;
+	int thin_chunk_size_calc_policy;
 
 	const char *origin; /* snap */
 	const char *pool;   /* thin */
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index f85696c..a6e0fc2 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -582,7 +582,7 @@ static int _get_pool_chunk_size_calc(const char *str,
 		*chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE * 2;
 	}
 	else {
-		log_error("Thin pool chunk size calculation method \"%s\" is unknown.", str);
+		log_error("Thin pool chunk size calculation policy \"%s\" is unrecognised.", str);
 		return 0;
 	}
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ebb5138..49881fa 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -34,7 +34,7 @@ struct lvconvert_params {
 	int wait_completion;
 	int need_polling;
 
-	int thin_chunk_size_calc_method;
+	int thin_chunk_size_calc_policy;
 	uint32_t chunk_size;
 	uint32_t region_size;
 
@@ -2329,7 +2329,7 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 	if (!lp->pool_metadata_lv_name) {
 		if (!update_pool_params(pool_lv->vg, lp->target_attr, lp->passed_args,
 					pool_lv->le_count, pool_lv->vg->extent_size,
-					&lp->thin_chunk_size_calc_method, &lp->chunk_size,
+					&lp->thin_chunk_size_calc_policy, &lp->chunk_size,
 					&lp->discards, &lp->poolmetadata_size, &lp->zero))
 			return_0;
 
@@ -2441,7 +2441,7 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		}
 		if (!update_pool_params(pool_lv->vg, lp->target_attr, lp->passed_args,
 					pool_lv->le_count, pool_lv->vg->extent_size,
-					&lp->thin_chunk_size_calc_method, &lp->chunk_size,
+					&lp->thin_chunk_size_calc_policy, &lp->chunk_size,
 					&lp->discards, &lp->poolmetadata_size, &lp->zero))
 			return_0;
 	}
@@ -2723,7 +2723,7 @@ static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp
 
 	if (arg_count(cmd, thinpool_ARG) &&
 	    !get_pool_params(cmd, lv_config_profile(lv),
-			     &lp->passed_args, &lp->thin_chunk_size_calc_method,
+			     &lp->passed_args, &lp->thin_chunk_size_calc_policy,
 			     &lp->chunk_size, &lp->discards,
 			     &lp->poolmetadata_size, &lp->zero))
 		goto_bad;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index c5a2e20..4850872 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -336,7 +336,7 @@ static int _update_extents_params(struct volume_group *vg,
 	if (lp->create_thin_pool) {
 		if (!update_pool_params(vg, lp->target_attr, lp->passed_args,
 					lp->extents, vg->extent_size,
-					&lp->thin_chunk_size_calc_method,
+					&lp->thin_chunk_size_calc_policy,
 					&lp->chunk_size, &lp->discards,
 					&lp->poolmetadatasize, &lp->zero))
 			return_0;
@@ -877,7 +877,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
 	    (lp->create_thin_pool &&
 	     !get_pool_params(cmd, NULL, &lp->passed_args,
-			      &lp->thin_chunk_size_calc_method,
+			      &lp->thin_chunk_size_calc_policy,
 			      &lp->chunk_size, &lp->discards,
 			      &lp->poolmetadatasize, &lp->zero)) ||
 	    !_read_mirror_params(lp, cmd) ||


