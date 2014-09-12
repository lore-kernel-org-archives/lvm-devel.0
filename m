From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 12 Sep 2014 08:09:47 +0000 (UTC)
Subject: master - conf: add allocation/physical_extent_size config option for default PE size of VGs.
Message-ID: <20140912080947.A440B609E8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f0cafc92812e285e5120241da04b5d119b27060b
Commit:        f0cafc92812e285e5120241da04b5d119b27060b
Parent:        80ac8f37d6ac5f8c5228678d4ee07187b5d4db7b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Sep 12 10:03:12 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Sep 12 10:09:21 2014 +0200

conf: add allocation/physical_extent_size config option for default PE size of VGs.

Removes a need to use "vgcreate -s <desired PE size>" all the
time time just to override hardcoded default which is 4096KiB.
---
 WHATS_NEW                    |    1 +
 conf/example.conf.in         |    3 +++
 lib/config/config_settings.h |    2 +-
 tools/toollib.c              |   21 +++++++++++++++++----
 tools/toollib.h              |    3 ++-
 tools/vgcreate.c             |    3 ++-
 tools/vgsplit.c              |    5 ++++-
 7 files changed, 30 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2175d29..983bc1a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Add allocation/physical_extent_size config option for default PE size of VGs.
   Introduce common code to modify metadate and reload updated LV.
   Fix rename of active snapshot volume in cluster.
   Make sure shared libraries are built with RELRO option.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 21c553a..511ca0b 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -370,6 +370,9 @@ allocation {
     # first use.
     # N.B. zeroing larger thin pool chunk size degrades performance.
     # thin_pool_zero = 1
+
+    # Default physical extent size to use for newly created VGs (in KB).
+    # physical_extent_size = 4096
 }
 
 # This section that allows you to configure the nature of the
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index c6be2e3..7724c57 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -126,7 +126,7 @@ cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG
 cfg(allocation_thin_pool_discards_CFG, "thin_pool_discards", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_STRING, DEFAULT_THIN_POOL_DISCARDS, vsn(2, 2, 99), NULL)
 cfg(allocation_thin_pool_chunk_size_policy_CFG, "thin_pool_chunk_size_policy", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_STRING, DEFAULT_THIN_POOL_CHUNK_SIZE_POLICY, vsn(2, 2, 101), NULL)
 cfg_runtime(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 99), NULL)
-
+cfg(allocation_physical_extent_size_CFG, "physical_extent_size", allocation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_EXTENT_SIZE, vsn(2, 2, 112), NULL)
 
 cfg(log_verbose_CFG, "verbose", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_VERBOSE, vsn(1, 0, 0), NULL)
 cfg(log_silent_CFG, "silent", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SILENT, vsn(2, 2, 98), NULL)
diff --git a/tools/toollib.c b/tools/toollib.c
index 25ff21d..b160ead 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1305,9 +1305,14 @@ struct dm_list *clone_pv_list(struct dm_pool *mem, struct dm_list *pvsl)
 	return r;
 }
 
-void vgcreate_params_set_defaults(struct vgcreate_params *vp_def,
-				  struct volume_group *vg)
+const char _pe_size_may_not_be_negative_msg[] = "Physical extent size may not be negative";
+
+int vgcreate_params_set_defaults(struct cmd_context *cmd,
+				 struct vgcreate_params *vp_def,
+				 struct volume_group *vg)
 {
+	int64_t extent_size;
+
 	if (vg) {
 		vp_def->vg_name = NULL;
 		vp_def->extent_size = vg->extent_size;
@@ -1318,13 +1323,21 @@ void vgcreate_params_set_defaults(struct vgcreate_params *vp_def,
 		vp_def->vgmetadatacopies = vg->mda_copies;
 	} else {
 		vp_def->vg_name = NULL;
-		vp_def->extent_size = DEFAULT_EXTENT_SIZE * 2;
+		extent_size = find_config_tree_int64(cmd,
+				allocation_physical_extent_size_CFG, NULL) * 2;
+		if (extent_size < 0) {
+			log_error(_pe_size_may_not_be_negative_msg);
+			return 0;
+		}
+		vp_def->extent_size = (uint32_t) extent_size;
 		vp_def->max_pv = DEFAULT_MAX_PV;
 		vp_def->max_lv = DEFAULT_MAX_LV;
 		vp_def->alloc = DEFAULT_ALLOC_POLICY;
 		vp_def->clustered = DEFAULT_CLUSTERED;
 		vp_def->vgmetadatacopies = DEFAULT_VGMETADATACOPIES;
 	}
+
+	return 1;
 }
 
 /*
@@ -1357,7 +1370,7 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 		vp_new->clustered = locking_is_clustered();
 
 	if (arg_sign_value(cmd, physicalextentsize_ARG, SIGN_NONE) == SIGN_MINUS) {
-		log_error("Physical extent size may not be negative");
+		log_error(_pe_size_may_not_be_negative_msg);
 		return 0;
 	}
 
diff --git a/tools/toollib.h b/tools/toollib.h
index b51c637..c605aed 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -106,7 +106,8 @@ struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int
 
 struct dm_list *clone_pv_list(struct dm_pool *mem, struct dm_list *pvs);
 
-void vgcreate_params_set_defaults(struct vgcreate_params *vp_def,
+int vgcreate_params_set_defaults(struct cmd_context *cmd,
+				 struct vgcreate_params *vp_def,
 				 struct volume_group *vg);
 int vgcreate_params_set_from_args(struct cmd_context *cmd,
 				  struct vgcreate_params *vp_new,
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 9d701c8..01bf421 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -41,7 +41,8 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	vgcreate_params_set_defaults(&vp_def, NULL);
+	if (!vgcreate_params_set_defaults(cmd, &vp_def, NULL))
+		return EINVALID_CMD_LINE;
 	vp_def.vg_name = vg_name;
 	if (!vgcreate_params_set_from_args(cmd, &vp_new, &vp_def))
 		return EINVALID_CMD_LINE;
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 5478e78..1a8e237 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -551,7 +551,10 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		if (!vgs_are_compatible(cmd, vg_from,vg_to))
 			goto_bad;
 	} else {
-		vgcreate_params_set_defaults(&vp_def, vg_from);
+		if (!vgcreate_params_set_defaults(cmd, &vp_def, vg_from)) {
+			r = EINVALID_CMD_LINE;
+			goto_bad;
+		}
 		vp_def.vg_name = vg_name_to;
 		if (!vgcreate_params_set_from_args(cmd, &vp_new, &vp_def)) {
 			r = EINVALID_CMD_LINE;


