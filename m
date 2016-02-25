From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 25 Feb 2016 15:15:56 +0000 (UTC)
Subject: master - replace pvcreate_params with pvcreate_each_params
Message-ID: <20160225151556.9996E60E97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a77ded3001ad584e75bb3b315a8c99c56951e530
Commit:        a77ded3001ad584e75bb3b315a8c99c56951e530
Parent:        4de6caf5b5a1b7eef80fc9ed56ac0cf8b7776ac4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 18 15:38:23 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 25 09:14:10 2016 -0600

replace pvcreate_params with pvcreate_each_params

"pvcreate_each_params" was a temporary name used
to transition from the old "pvcreate_params".

Remove the old pvcreate_params struct and rename the
new pvcreate_each_params struct to pvcreate_params.
Rename various pvcreate_each_params terms to simply
pvcreate_params.
---
 lib/metadata/metadata-exported.h |   14 +--------
 lib/metadata/metadata.c          |   57 ++++++++++++++++++++++---------------
 tools/pvcreate.c                 |   20 ++++++------
 tools/pvremove.c                 |    4 +-
 tools/toollib.c                  |   45 ++++--------------------------
 tools/toollib.h                  |    5 +--
 tools/vgcreate.c                 |    6 ++--
 tools/vgextend.c                 |   12 ++++----
 8 files changed, 64 insertions(+), 99 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index c5dee05..03e8572 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -540,18 +540,6 @@ struct pv_create_args {
 };
 
 struct pvcreate_params {
-	int zero;
-	force_t force;
-	unsigned yes;
-	const char *restorefile; /* 0 if no --restorefile option */
-	struct pv_create_args pva;
-};
-
-/*
- * FIXME: rename this pvcreate_params once the old pvcreate_params is unused.
- * This can probably be put in toollib.h.
- */
-struct pvcreate_each_params {
 	/*
 	 * From argc and argv.
 	 */
@@ -747,7 +735,7 @@ int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
 int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names,
 	      struct pvcreate_params *pp);
-int vg_extend_each_pv(struct volume_group *vg, struct pvcreate_each_params *pp);
+int vg_extend_each_pv(struct volume_group *vg, struct pvcreate_params *pp);
 int vg_reduce(struct volume_group *vg, const char *pv_name);
 
 int vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index aafc4ce..acdfdec 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -809,7 +809,7 @@ int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names
 	return 1;
 }
 
-int vg_extend_each_pv(struct volume_group *vg, struct pvcreate_each_params *pp)
+int vg_extend_each_pv(struct volume_group *vg, struct pvcreate_params *pp)
 {
 	struct pv_list *pvl;
 	unsigned int max_phys_block_size = 0;
@@ -1516,6 +1516,39 @@ int vg_split_mdas(struct cmd_context *cmd __attribute__((unused)),
 	return 1;
 }
 
+void pvcreate_params_set_defaults(struct pvcreate_params *pp)
+{
+	memset(pp, 0, sizeof(*pp));
+
+	pp->zero = 1;
+	pp->force = PROMPT;
+	pp->yes = 0;
+	pp->restorefile = NULL;
+	pp->uuid_str = NULL;
+
+	pp->pva.size = 0;
+	pp->pva.data_alignment = UINT64_C(0);
+	pp->pva.data_alignment_offset = UINT64_C(0);
+	pp->pva.pvmetadatacopies = DEFAULT_PVMETADATACOPIES;
+	pp->pva.pvmetadatasize = DEFAULT_PVMETADATASIZE;
+	pp->pva.label_sector = DEFAULT_LABELSECTOR;
+	pp->pva.metadataignore = DEFAULT_PVMETADATAIGNORE;
+	pp->pva.ba_start = 0;
+	pp->pva.ba_size = 0;
+	pp->pva.pe_start = PV_PE_START_CALC;
+	pp->pva.extent_count = 0;
+	pp->pva.extent_size = 0;
+
+	dm_list_init(&pp->prompts);
+	dm_list_init(&pp->arg_devices);
+	dm_list_init(&pp->arg_process);
+	dm_list_init(&pp->arg_confirm);
+	dm_list_init(&pp->arg_create);
+	dm_list_init(&pp->arg_remove);
+	dm_list_init(&pp->arg_fail);
+	dm_list_init(&pp->pvs);
+}
+
 /*
  * See if we may pvcreate on this device.
  * 0 indicates we may not.
@@ -1678,28 +1711,6 @@ out:
 	return r;
 }
 
-void pvcreate_params_set_defaults(struct pvcreate_params *pp)
-{
-	memset(pp, 0, sizeof(*pp));
-	pp->zero = 1;
-	pp->force = PROMPT;
-	pp->yes = 0;
-	pp->restorefile = 0;
-	pp->pva.size = 0;
-	pp->pva.data_alignment = UINT64_C(0);
-	pp->pva.data_alignment_offset = UINT64_C(0);
-	pp->pva.pvmetadatacopies = DEFAULT_PVMETADATACOPIES;
-	pp->pva.pvmetadatasize = DEFAULT_PVMETADATASIZE;
-	pp->pva.label_sector = DEFAULT_LABELSECTOR;
-	pp->pva.metadataignore = DEFAULT_PVMETADATAIGNORE;
-	pp->pva.idp = 0;
-	pp->pva.ba_start = 0;
-	pp->pva.ba_size = 0;
-	pp->pva.pe_start = PV_PE_START_CALC;
-	pp->pva.extent_count = 0;
-	pp->pva.extent_size = 0;
-}
-
 static int _pvcreate_write(struct cmd_context *cmd, struct pv_to_write *pvw)
 {
 	struct physical_volume *pv = pvw->pv;
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 92356b3..85fed09 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -22,8 +22,8 @@
  * Output arguments:
  * pp: structure allocated by caller, fields written / validated here
  */
-static int pvcreate_each_restore_params_from_args(struct cmd_context *cmd, int argc,
-					          struct pvcreate_each_params *pp)
+static int pvcreate_restore_params_from_args(struct cmd_context *cmd, int argc,
+					     struct pvcreate_params *pp)
 {
 	pp->restorefile = arg_str_value(cmd, restorefile_ARG, NULL);
 
@@ -62,8 +62,8 @@ static int pvcreate_each_restore_params_from_args(struct cmd_context *cmd, int a
 	return 1;
 }
 
-static int pvcreate_each_restore_params_from_backup(struct cmd_context *cmd,
-					            struct pvcreate_each_params *pp)
+static int pvcreate_restore_params_from_backup(struct cmd_context *cmd,
+					       struct pvcreate_params *pp)
 {
 	struct volume_group *vg;
 	struct pv_list *existing_pvl;
@@ -99,7 +99,7 @@ static int pvcreate_each_restore_params_from_backup(struct cmd_context *cmd,
 int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct processing_handle *handle;
-	struct pvcreate_each_params pp;
+	struct pvcreate_params pp;
 	int ret;
 
 	if (!argc) {
@@ -109,7 +109,7 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 
 	/*
 	 * Device info needs to be available for reading the VG backup file in
-	 * pvcreate_each_restore_params_from_backup.
+	 * pvcreate_restore_params_from_backup.
 	 */
 	lvmcache_seed_infos_from_lvmetad(cmd);
 
@@ -123,15 +123,15 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 	 * 5. argc/argv free args specifying devices
 	 */
 
-	pvcreate_each_params_set_defaults(&pp);
+	pvcreate_params_set_defaults(&pp);
 
-	if (!pvcreate_each_restore_params_from_args(cmd, argc, &pp))
+	if (!pvcreate_restore_params_from_args(cmd, argc, &pp))
 		return EINVALID_CMD_LINE;
 
-	if (!pvcreate_each_restore_params_from_backup(cmd, &pp))
+	if (!pvcreate_restore_params_from_backup(cmd, &pp))
 		return EINVALID_CMD_LINE;
 
-	if (!pvcreate_each_params_from_args(cmd, &pp))
+	if (!pvcreate_params_from_args(cmd, &pp))
 		return EINVALID_CMD_LINE;
 
 	pp.pv_count = argc;
diff --git a/tools/pvremove.c b/tools/pvremove.c
index 1628ecc..dd9a4e8 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -18,7 +18,7 @@
 int pvremove(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct processing_handle *handle;
-	struct pvcreate_each_params pp;
+	struct pvcreate_params pp;
 	int ret;
 
 	if (!argc) {
@@ -26,7 +26,7 @@ int pvremove(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	pvcreate_each_params_set_defaults(&pp);
+	pvcreate_params_set_defaults(&pp);
 
 	pp.is_remove = 1;
 	pp.force = arg_count(cmd, force_ARG);
diff --git a/tools/toollib.c b/tools/toollib.c
index b640285..3e48139 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3425,40 +3425,7 @@ int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	return ECMD_PROCESSED;
 }
 
-void pvcreate_each_params_set_defaults(struct pvcreate_each_params *pp)
-{
-	memset(pp, 0, sizeof(*pp));
-
-	pp->zero = 1;
-	pp->force = PROMPT;
-	pp->yes = 0;
-	pp->restorefile = NULL;
-	pp->uuid_str = NULL;
-
-	pp->pva.size = 0;
-	pp->pva.data_alignment = UINT64_C(0);
-	pp->pva.data_alignment_offset = UINT64_C(0);
-	pp->pva.pvmetadatacopies = DEFAULT_PVMETADATACOPIES;
-	pp->pva.pvmetadatasize = DEFAULT_PVMETADATASIZE;
-	pp->pva.label_sector = DEFAULT_LABELSECTOR;
-	pp->pva.metadataignore = DEFAULT_PVMETADATAIGNORE;
-	pp->pva.ba_start = 0;
-	pp->pva.ba_size = 0;
-	pp->pva.pe_start = PV_PE_START_CALC;
-	pp->pva.extent_count = 0;
-	pp->pva.extent_size = 0;
-
-	dm_list_init(&pp->prompts);
-	dm_list_init(&pp->arg_devices);
-	dm_list_init(&pp->arg_process);
-	dm_list_init(&pp->arg_confirm);
-	dm_list_init(&pp->arg_create);
-	dm_list_init(&pp->arg_remove);
-	dm_list_init(&pp->arg_fail);
-	dm_list_init(&pp->pvs);
-}
-
-int pvcreate_each_params_from_args(struct cmd_context *cmd, struct pvcreate_each_params *pp)
+int pvcreate_params_from_args(struct cmd_context *cmd, struct pvcreate_params *pp)
 {
 	pp->yes = arg_count(cmd, yes_ARG);
 	pp->force = (force_t) arg_count(cmd, force_ARG);
@@ -3620,7 +3587,7 @@ struct pvcreate_device {
  */
 
 static void _check_pvcreate_prompt(struct cmd_context *cmd,
-				   struct pvcreate_each_params *pp,
+				   struct pvcreate_params *pp,
 				   struct pvcreate_prompt *prompt,
 				   int ask)
 {
@@ -3728,7 +3695,7 @@ static int _pvcreate_check_single(struct cmd_context *cmd,
 				  struct physical_volume *pv,
 				  struct processing_handle *handle)
 {
-	struct pvcreate_each_params *pp = (struct pvcreate_each_params *) handle->custom_handle;
+	struct pvcreate_params *pp = (struct pvcreate_params *) handle->custom_handle;
 	struct pvcreate_device *pd;
 	struct pvcreate_prompt *prompt;
 	struct device *dev;
@@ -3871,7 +3838,7 @@ static int _pv_confirm_single(struct cmd_context *cmd,
 			      struct physical_volume *pv,
 			      struct processing_handle *handle)
 {
-	struct pvcreate_each_params *pp = (struct pvcreate_each_params *) handle->custom_handle;
+	struct pvcreate_params *pp = (struct pvcreate_params *) handle->custom_handle;
 	struct pvcreate_device *pd;
 	int found = 0;
 
@@ -3958,7 +3925,7 @@ static int _pvremove_check_single(struct cmd_context *cmd,
 				  struct physical_volume *pv,
 				  struct processing_handle *handle)
 {
-	struct pvcreate_each_params *pp = (struct pvcreate_each_params *) handle->custom_handle;
+	struct pvcreate_params *pp = (struct pvcreate_params *) handle->custom_handle;
 	struct pvcreate_device *pd;
 	struct pvcreate_prompt *prompt;
 	struct label *label;
@@ -4113,7 +4080,7 @@ static int _pvremove_check_single(struct cmd_context *cmd,
 
 int pvcreate_each_device(struct cmd_context *cmd,
 			 struct processing_handle *handle,
-			 struct pvcreate_each_params *pp)
+			 struct pvcreate_params *pp)
 {
 	struct pvcreate_device *pd, *pd2;
 	struct pvcreate_prompt *prompt, *prompt2;
diff --git a/tools/toollib.h b/tools/toollib.h
index c092c74..a67b3e6 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -152,9 +152,8 @@ const char *extract_vgname(struct cmd_context *cmd, const char *lv_name);
 const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
 			 unsigned *dev_dir_found);
 
-void pvcreate_each_params_set_defaults(struct pvcreate_each_params *pp);
-int pvcreate_each_params_from_args(struct cmd_context *cmd, struct pvcreate_each_params *pp);
-int pvcreate_each_device(struct cmd_context *cmd, struct processing_handle *handle, struct pvcreate_each_params *pp);
+int pvcreate_params_from_args(struct cmd_context *cmd, struct pvcreate_params *pp);
+int pvcreate_each_device(struct cmd_context *cmd, struct processing_handle *handle, struct pvcreate_params *pp);
 
 /*
  * Builds a list of pv's from the names in argv.  Used in
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 456e207..3811583 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -18,7 +18,7 @@
 int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct processing_handle *handle;
-	struct pvcreate_each_params pp;
+	struct pvcreate_params pp;
 	struct vgcreate_params vp_new;
 	struct vgcreate_params vp_def;
 	struct volume_group *vg;
@@ -38,9 +38,9 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	argc--;
 	argv++;
 
-	pvcreate_each_params_set_defaults(&pp);
+	pvcreate_params_set_defaults(&pp);
 
-	if (!pvcreate_each_params_from_args(cmd, &pp))
+	if (!pvcreate_params_from_args(cmd, &pp))
 		return EINVALID_CMD_LINE;
 
 	pp.pv_count = argc;
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 2780755..9cfd3a7 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -16,7 +16,7 @@
 #include "tools.h"
 
 struct vgextend_params {
-	struct pvcreate_each_params pp;
+	struct pvcreate_params pp;
 };
 
 static int _restore_pv(struct volume_group *vg, const char *pv_name)
@@ -47,7 +47,7 @@ static int _vgextend_restoremissing(struct cmd_context *cmd __attribute__((unuse
 				    struct processing_handle *handle)
 {
 	struct vgextend_params *vp = (struct vgextend_params *) handle->custom_handle;
-	struct pvcreate_each_params *pp = &vp->pp;
+	struct pvcreate_params *pp = &vp->pp;
 	int fixed = 0;
 	int i;
 
@@ -77,7 +77,7 @@ static int _vgextend_single(struct cmd_context *cmd, const char *vg_name,
 			    struct volume_group *vg, struct processing_handle *handle)
 {
 	struct vgextend_params *vp = (struct vgextend_params *) handle->custom_handle;
-	struct pvcreate_each_params *pp = &vp->pp;
+	struct pvcreate_params *pp = &vp->pp;
 	uint32_t mda_copies;
 	uint32_t mda_used;
 	int ret = ECMD_FAILED;
@@ -125,7 +125,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct processing_handle *handle;
 	struct vgextend_params vp;
-	struct pvcreate_each_params *pp = &vp.pp;
+	struct pvcreate_params *pp = &vp.pp;
 	unsigned restoremissing = arg_is_set(cmd, restoremissing_ARG);
 	const char *vg_name;
 	int ret;
@@ -146,9 +146,9 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	argc--;
 	argv++;
 
-	pvcreate_each_params_set_defaults(pp);
+	pvcreate_params_set_defaults(pp);
 
-	if (!pvcreate_each_params_from_args(cmd, pp))
+	if (!pvcreate_params_from_args(cmd, pp))
 		return EINVALID_CMD_LINE;
 
 	pp->pv_count = argc;


