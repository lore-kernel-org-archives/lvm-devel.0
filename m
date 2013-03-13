From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 Mar 2013 14:15:56 +0000 (UTC)
Subject: master - thin: mark passed args
Message-ID: <20130313141556.E465AA0D6D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f06dd8725a85d344820eda91835c58f489097563
Commit:        f06dd8725a85d344820eda91835c58f489097563
Parent:        b9fe52e811eba446813292e230502ac41040cdae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 6 11:58:09 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 13 15:13:54 2013 +0100

thin: mark passed args

Keep the flag whether given thin pool argument has been given on command
line or it's been 'estimated'

Call of update_pool_params() must not change cmdline given args and
needs to know this info.

Since there is a need to move this update function into /lib, we cannot
use arg_count().

FIXME: we need some generic mechanism here.
---
 lib/metadata/metadata-exported.h |    8 ++++++++
 tools/lvconvert.c                |    7 ++++---
 tools/lvcreate.c                 |    5 +++--
 tools/toollib.c                  |   17 ++++++++++++-----
 tools/toollib.h                  |    5 +++--
 5 files changed, 30 insertions(+), 12 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0ce5ad5..5ed8f3e 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -610,6 +610,14 @@ struct lvcreate_params {
 	const char *vg_name; /* all */
 	const char *lv_name; /* all */
 
+	/* Keep args given by the user on command line */
+	/* FIXME: create some more universal solution here */
+#define PASS_ARG_CHUNK_SIZE		0x01
+#define PASS_ARG_DISCARDS		0x02
+#define PASS_ARG_POOL_METADATA_SIZE	0x04
+#define PASS_ARG_ZERO			0x08
+	int passed_args;
+
 	uint32_t stripes; /* striped */
 	uint32_t stripe_size; /* striped */
 	uint32_t chunk_size; /* snapshot */
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index fcfcddb..88ad719 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -56,6 +56,7 @@ struct lvconvert_params {
 
 	struct logical_volume *lv_to_poll;
 
+	int passed_args;
 	uint64_t poolmetadata_size;
 	const char *origin_lv_name;
 	const char *pool_data_lv_name;
@@ -377,7 +378,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			return 0;
 		}
 
-		if (!get_pool_params(cmd,
+		if (!get_pool_params(cmd, &lp->passed_args,
 				     &lp->chunk_size,
 				     &lp->discards,
 				     &lp->poolmetadata_size,
@@ -2125,13 +2126,13 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 				  display_size(cmd, 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE));
 			return 0;
 		}
-		if (!update_pool_params(cmd, lp->target_attr,
+		if (!update_pool_params(cmd, lp->target_attr, lp->passed_args,
 					pool_lv->le_count, pool_lv->vg->extent_size,
 					&lp->chunk_size, &lp->discards,
 					&lp->poolmetadata_size))
 			return_0;
 	} else {
-		if (!update_pool_params(cmd, lp->target_attr,
+		if (!update_pool_params(cmd, lp->target_attr, lp->passed_args,
 					pool_lv->le_count, pool_lv->vg->extent_size,
 					&lp->chunk_size, &lp->discards,
 					&lp->poolmetadata_size))
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 4618321..aa75636 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -307,7 +307,7 @@ static int _update_extents_params(struct volume_group *vg,
 	}
 
 	if (lp->create_thin_pool) {
-		if (!update_pool_params(vg->cmd, lp->target_attr,
+		if (!update_pool_params(vg->cmd, lp->target_attr, lp->passed_args,
 					lp->extents, vg->extent_size,
 					&lp->chunk_size, &lp->discards,
 					&lp->poolmetadatasize))
@@ -795,7 +795,8 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	    !_read_size_params(lp, lcp, cmd) ||
 	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
 	    (lp->create_thin_pool &&
-	     !get_pool_params(cmd, &lp->chunk_size, &lp->discards,
+	     !get_pool_params(cmd, &lp->passed_args,
+			      &lp->chunk_size, &lp->discards,
 			      &lp->poolmetadatasize, &lp->zero)) ||
 	    !_read_mirror_params(lp, cmd) ||
 	    !_read_raid_params(lp, cmd))
diff --git a/tools/toollib.c b/tools/toollib.c
index 6b00155..10ada7c 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1523,7 +1523,7 @@ int get_activation_monitoring_mode(struct cmd_context *cmd,
 	return 1;
 }
 
-int get_pool_params(struct cmd_context *cmd,
+int get_pool_params(struct cmd_context *cmd, int *passed_args,
 		    uint32_t *chunk_size,
 		    thin_discards_t *discards,
 		    uint64_t *pool_metadata_size,
@@ -1531,13 +1531,16 @@ int get_pool_params(struct cmd_context *cmd,
 {
 	const char *dstr;
 
+	*passed_args = 0;
 	if (arg_count(cmd, zero_ARG)) {
+		*passed_args |= PASS_ARG_ZERO;
 		*zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
 		log_very_verbose("Setting pool zeroing: %u", *zero);
 	} else
 		*zero = find_config_tree_bool(cmd, allocation_thin_pool_zero_CFG);
 
 	if (arg_count(cmd, discards_ARG)) {
+		*passed_args |= PASS_ARG_DISCARDS;
 		*discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, 0);
 		log_very_verbose("Setting pool discards: %s",
 				 get_pool_discards_name(*discards));
@@ -1552,6 +1555,7 @@ int get_pool_params(struct cmd_context *cmd,
 			log_error("Negative chunk size is invalid.");
 			return 0;
 		}
+		*passed_args |= PASS_ARG_CHUNK_SIZE;
 		*chunk_size = arg_uint_value(cmd, chunksize_ARG,
 					     DM_THIN_MIN_DATA_BLOCK_SIZE);
 		log_very_verbose("Setting pool chunk size: %s",
@@ -1567,16 +1571,19 @@ int get_pool_params(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
-		log_error("Negative pool metadata size is invalid.");
-		return 0;
+	if (arg_count(cmd, poolmetadatasize_ARG)) {
+		if (arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
+			log_error("Negative pool metadata size is invalid.");
+			return 0;
+		}
+		*passed_args |= PASS_ARG_POOL_METADATA_SIZE;
 	}
 	*pool_metadata_size = arg_uint64_value(cmd, poolmetadatasize_ARG, UINT64_C(0));
 
 	return 1;
 }
 
-int update_pool_params(struct cmd_context *cmd, unsigned attr,
+int update_pool_params(struct cmd_context *cmd, unsigned attr, int passed_args,
 		       uint32_t data_extents, uint32_t extent_size,
 		       uint32_t *chunk_size, thin_discards_t *discards,
 		       uint64_t *pool_metadata_size)
diff --git a/tools/toollib.h b/tools/toollib.h
index 80c01fd..9a4743d 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -111,12 +111,13 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 
 int get_activation_monitoring_mode(struct cmd_context *cmd,
 				   int *monitoring_mode);
-int get_pool_params(struct cmd_context *cmd,
+
+int get_pool_params(struct cmd_context *cmd, int *passed_args,
 		    uint32_t *chunk_size,
 		    thin_discards_t *discards,
 		    uint64_t *pool_metadata_size,
 		    int *zero);
-int update_pool_params(struct cmd_context *cmd, unsigned attr,
+int update_pool_params(struct cmd_context *cmd, unsigned attr, int passed_args,
 		       uint32_t data_extents, uint32_t extent_size,
 		       uint32_t *chunk_size, thin_discards_t *discards,
 		       uint64_t *pool_metadata_size);


