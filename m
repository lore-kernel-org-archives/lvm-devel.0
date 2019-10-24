From: David Teigland <teigland@sourceware.org>
Date: Thu, 24 Oct 2019 11:27:30 -0400
Subject: stable-2.02 - Revert "Revert "vgcreate/vgextend: restrict PVs with mixed block sizes""
Message-ID: <201910241527.x9OFRUXi001354@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c2853147639ca31f16539a4e6316ef3320811497
Commit:        c2853147639ca31f16539a4e6316ef3320811497
Parent:        4e99308b7cab21fd79d1290a5aa47aee4ee4a76e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 24 10:01:12 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 24 10:01:12 2019 -0500

Revert "Revert "vgcreate/vgextend: restrict PVs with mixed block sizes""

This reverts commit c37aa7881d840c429b858ee0068f0151e46ce0d9.

Put back the setting again, but the next commit will just
turn off the new behavior by default.
---
 lib/commands/toolcontext.h       |    1 +
 lib/config/config_settings.h     |    5 ++++
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   44 +++++++++++++++++++++++++++++++++++
 tools/lvmcmdline.c               |    2 +
 tools/toollib.c                  |   47 ++++++++++++++++++++++++++++++++++++++
 tools/vgcreate.c                 |    2 +
 7 files changed, 102 insertions(+), 0 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 4b2a079..497f4bd 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -155,6 +155,7 @@ struct cmd_context {
 	unsigned include_shared_vgs:1;		/* report/display cmds can reveal lockd VGs */
 	unsigned include_active_foreign_vgs:1;	/* cmd should process foreign VGs with active LVs */
 	unsigned vg_read_print_access_error:1;	/* print access errors from vg_read */
+	unsigned allow_mixed_block_sizes:1;
 	unsigned force_access_clustered:1;
 	unsigned lockd_gl_disable:1;
 	unsigned lockd_vg_disable:1;
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 0e81252..7981d5d 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -470,6 +470,11 @@ cfg(devices_allow_changes_with_duplicate_pvs_CFG, "allow_changes_with_duplicate_
 	"Enabling this setting allows the VG to be used as usual even with\n"
 	"uncertain devices.\n")
 
+cfg(devices_allow_mixed_block_sizes_CFG, "allow_mixed_block_sizes", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 3, 6), NULL, 0, NULL,
+	"Allow PVs in the same VG with different logical block sizes.\n"
+	"When allowed, the user is responsible to ensure that an LV is\n"
+	"using PVs with matching block sizes when necessary.\n")
+
 cfg_array(allocation_cling_tag_list_CFG, "cling_tag_list", allocation_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 77), NULL, 0, NULL,
 	"Advise LVM which PVs to use when searching for new space.\n"
 	"When searching for free space to extend an LV, the 'cling' allocation\n"
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 75caba1..9c24132 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -591,6 +591,7 @@ struct pvcreate_params {
 	unsigned is_remove : 1;         /* is removing PVs, not creating */
 	unsigned preserve_existing : 1;
 	unsigned check_failed : 1;
+	unsigned check_consistent_block_size : 1;
 };
 
 struct lvresize_params {
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index cb38f66..81a6029 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -699,12 +699,40 @@ int vg_extend_each_pv(struct volume_group *vg, struct pvcreate_params *pp)
 {
 	struct pv_list *pvl;
 	unsigned int max_phys_block_size = 0;
+	unsigned int physical_block_size, logical_block_size;
+	unsigned int prev_lbs = 0;
+	int inconsistent_existing_lbs = 0;
 
 	log_debug_metadata("Adding PVs to VG %s.", vg->name);
 
 	if (vg_bad_status_bits(vg, RESIZEABLE_VG))
 		return_0;
 
+	/*
+	 * Check if existing PVs have inconsistent block sizes.
+	 * If so, do not enforce new devices to be consistent.
+	 */
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		logical_block_size = 0;
+		physical_block_size = 0;
+
+		if (!dev_get_direct_block_sizes(pvl->pv->dev, &physical_block_size, &logical_block_size))
+			continue;
+
+		if (!logical_block_size)
+			continue;
+
+		if (!prev_lbs) {
+			prev_lbs = logical_block_size;
+			continue;
+		}
+		
+		if (prev_lbs != logical_block_size) {
+			inconsistent_existing_lbs = 1;
+			break;
+		}
+	}
+
 	dm_list_iterate_items(pvl, &pp->pvs) {
 		log_debug_metadata("Adding PV %s to VG %s.", pv_dev_name(pvl->pv), vg->name);
 
@@ -715,6 +743,22 @@ int vg_extend_each_pv(struct volume_group *vg, struct pvcreate_params *pp)
 			return 0;
 		}
 
+		logical_block_size = 0;
+		physical_block_size = 0;
+
+		if (!dev_get_direct_block_sizes(pvl->pv->dev, &physical_block_size, &logical_block_size))
+			log_warn("WARNING: PV %s has unknown block size.", pv_dev_name(pvl->pv));
+
+		else if (prev_lbs && logical_block_size && (logical_block_size != prev_lbs)) {
+			if (vg->cmd->allow_mixed_block_sizes || inconsistent_existing_lbs)
+				log_debug("Devices have inconsistent block sizes (%u and %u)", prev_lbs, logical_block_size);
+			else {
+				log_error("Devices have inconsistent logical block sizes (%u and %u).",
+					  prev_lbs, logical_block_size);
+				return 0;
+			}
+		}
+
 		if (!add_pv_to_vg(vg, pv_dev_name(pvl->pv), pvl->pv, 0)) {
 			log_error("PV %s cannot be added to VG %s.",
 				  pv_dev_name(pvl->pv), vg->name);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 6a1ab11..9c39f48 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2306,6 +2306,8 @@ static int _get_current_settings(struct cmd_context *cmd)
 	if (cmd->cname->flags & CAN_USE_ONE_SCAN)
 		cmd->can_use_one_scan = 1;
 
+	cmd->allow_mixed_block_sizes = find_config_tree_bool(cmd, devices_allow_mixed_block_sizes_CFG, NULL);
+
 	cmd->partial_activation = 0;
 	cmd->degraded_activation = 0;
 	activation_mode = find_config_tree_str(cmd, activation_mode_CFG, NULL);
diff --git a/tools/toollib.c b/tools/toollib.c
index 1b01ccc..42179d9 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5481,6 +5481,8 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	struct device_list *devl;
 	const char *pv_name;
 	int consistent = 0;
+	unsigned int physical_block_size, logical_block_size;
+	unsigned int prev_pbs = 0, prev_lbs = 0;
 	int must_use_all = (cmd->cname->flags & MUST_USE_ALL_ARGS);
 	int found;
 	unsigned i;
@@ -5559,6 +5561,51 @@ int pvcreate_each_device(struct cmd_context *cmd,
 		pd->dev = dev_cache_get(pd->name, cmd->full_filter);
 
 	/*
+	 * Check for consistent block sizes.
+	 */
+	if (pp->check_consistent_block_size) {
+		dm_list_iterate_items(pd, &pp->arg_devices) {
+			if (!pd->dev)
+				continue;
+
+			logical_block_size = 0;
+			physical_block_size = 0;
+
+			if (!dev_get_direct_block_sizes(pd->dev, &physical_block_size, &logical_block_size)) {
+				log_warn("WARNING: Unknown block size for device %s.", dev_name(pd->dev));
+				continue;
+			}
+
+			if (!logical_block_size) {
+				log_warn("WARNING: Unknown logical_block_size for device %s.", dev_name(pd->dev));
+				continue;
+			}
+
+			if (!prev_lbs) {
+				prev_lbs = logical_block_size;
+				prev_pbs = physical_block_size;
+				continue;
+			}
+
+			if (prev_lbs == logical_block_size) {
+				/* Require lbs to match, just warn about unmatching pbs. */
+				if (!cmd->allow_mixed_block_sizes && prev_pbs && physical_block_size &&
+				    (prev_pbs != physical_block_size))
+					log_warn("WARNING: Devices have inconsistent physical block sizes (%u and %u).",
+						  prev_pbs, physical_block_size);
+				continue;
+			}
+
+			if (!cmd->allow_mixed_block_sizes) {
+				log_error("Devices have inconsistent logical block sizes (%u and %u).",
+					  prev_lbs, logical_block_size);
+				log_print("See lvm.conf allow_mixed_block_sizes.");
+				return 0;
+			}
+		}
+	}
+
+	/*
 	 * Use process_each_pv to search all existing PVs and devices.
 	 *
 	 * This is a slightly different way to use process_each_pv, because the
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 4356d99..7add53b 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -48,6 +48,8 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	/* Don't create a new PV on top of an existing PV like pvcreate does. */
 	pp.preserve_existing = 1;
 
+	pp.check_consistent_block_size = 1;
+
 	if (!vgcreate_params_set_defaults(cmd, &vp_def, NULL))
 		return EINVALID_CMD_LINE;
 	vp_def.vg_name = vg_name;


