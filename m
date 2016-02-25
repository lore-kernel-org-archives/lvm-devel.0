From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 25 Feb 2016 15:15:40 +0000 (UTC)
Subject: master - vgextend: use the common toollib pv create
Message-ID: <20160225151540.DEE6B61BB7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=749a7cecf895264bb8b924e2cc091d13cb111965
Commit:        749a7cecf895264bb8b924e2cc091d13cb111965
Parent:        6a1c22aadf26bfa60782537968d1a03b535cd555
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 15 14:28:09 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 25 09:14:09 2016 -0600

vgextend: use the common toollib pv create

---
 tools/vgextend.c |   89 +++++++++++++++++++++++++++++++++--------------------
 1 files changed, 55 insertions(+), 34 deletions(-)

diff --git a/tools/vgextend.c b/tools/vgextend.c
index d22f426..2780755 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -16,9 +16,7 @@
 #include "tools.h"
 
 struct vgextend_params {
-	struct pvcreate_params pp;
-	int pv_count;
-	const char *const *pv_names;
+	struct pvcreate_each_params pp;
 };
 
 static int _restore_pv(struct volume_group *vg, const char *pv_name)
@@ -49,14 +47,15 @@ static int _vgextend_restoremissing(struct cmd_context *cmd __attribute__((unuse
 				    struct processing_handle *handle)
 {
 	struct vgextend_params *vp = (struct vgextend_params *) handle->custom_handle;
+	struct pvcreate_each_params *pp = &vp->pp;
 	int fixed = 0;
 	int i;
 
 	if (!archive(vg))
 		return_0;
 
-	for (i = 0; i < vp->pv_count; i++)
-		if (_restore_pv(vg, vp->pv_names[i]))
+	for (i = 0; i < pp->pv_count; i++)
+		if (_restore_pv(vg, pp->pv_names[i]))
 			fixed++;
 
 	if (!fixed) {
@@ -78,7 +77,7 @@ static int _vgextend_single(struct cmd_context *cmd, const char *vg_name,
 			    struct volume_group *vg, struct processing_handle *handle)
 {
 	struct vgextend_params *vp = (struct vgextend_params *) handle->custom_handle;
-	struct pvcreate_params *pp = &vp->pp;
+	struct pvcreate_each_params *pp = &vp->pp;
 	uint32_t mda_copies;
 	uint32_t mda_used;
 	int ret = ECMD_FAILED;
@@ -94,12 +93,7 @@ static int _vgextend_single(struct cmd_context *cmd, const char *vg_name,
 	if (!archive(vg))
 		return_ECMD_FAILED;
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
-		log_error("Can't get lock for orphan PVs");
-		return ECMD_FAILED;
-	}
-
-	if (!vg_extend(vg, vp->pv_count, vp->pv_names, pp))
+	if (!vg_extend_each_pv(vg, pp))
 		goto_out;
 
 	if (arg_count(cmd, metadataignore_ARG)) {
@@ -114,7 +108,7 @@ static int _vgextend_single(struct cmd_context *cmd, const char *vg_name,
 		}
 	}
 
-	log_verbose("Volume group \"%s\" will be extended by %d new physical volumes", vg_name, vp->pv_count);
+	log_verbose("Volume group \"%s\" will be extended by %d new physical volumes", vg_name, pp->pv_count);
 
 	if (!vg_write(vg) || !vg_commit(vg))
 		goto_out;
@@ -123,19 +117,17 @@ static int _vgextend_single(struct cmd_context *cmd, const char *vg_name,
 
 	log_print_unless_silent("Volume group \"%s\" successfully extended", vg_name);
 	ret = ECMD_PROCESSED;
-
 out:
-	unlock_vg(cmd, VG_ORPHANS);
-
 	return ret;
 }
 
 int vgextend(struct cmd_context *cmd, int argc, char **argv)
 {
+	struct processing_handle *handle;
 	struct vgextend_params vp;
+	struct pvcreate_each_params *pp = &vp.pp;
 	unsigned restoremissing = arg_is_set(cmd, restoremissing_ARG);
-	struct processing_handle *handle;
-	const char *one_vgname;
+	const char *vg_name;
 	int ret;
 
 	if (!argc) {
@@ -144,27 +136,56 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	one_vgname = skip_dev_dir(cmd, argv[0], NULL);
-
 	if (arg_count(cmd, metadatacopies_ARG)) {
 		log_error("Invalid option --metadatacopies, "
 			  "use --pvmetadatacopies instead.");
 		return EINVALID_CMD_LINE;
 	}
 
-	pvcreate_params_set_defaults(&vp.pp);
-	vp.pv_count = argc - 1;
-	vp.pv_names = (const char* const*)(argv + 1);
+	vg_name = skip_dev_dir(cmd, argv[0], NULL);
+	argc--;
+	argv++;
 
-	if (!pvcreate_params_validate(cmd, vp.pv_count, &vp.pp))
-		return_EINVALID_CMD_LINE;
+	pvcreate_each_params_set_defaults(pp);
 
-        if (!(handle = init_processing_handle(cmd))) {
-                log_error("Failed to initialize processing handle.");
-                return ECMD_FAILED;
-        }
+	if (!pvcreate_each_params_from_args(cmd, pp))
+		return EINVALID_CMD_LINE;
 
-	handle->custom_handle = &vp;
+	pp->pv_count = argc;
+	pp->pv_names = argv;
+
+	/* Don't create a new PV on top of an existing PV like pvcreate does. */
+	pp->preserve_existing = 1;
+
+	/* pvcreate within vgextend cannot be forced. */
+	pp->force = 0;
+
+	/*
+	 * Needed to change the set of orphan PVs.
+	 * (disable afterward to prevent process_each_pv from doing
+	 * a shared global lock since it's already acquired it ex.)
+	 */
+	if (!lockd_gl(cmd, "ex", 0))
+		return_ECMD_FAILED;
+	cmd->lockd_gl_disable = 1;
+
+	if (!(handle = init_processing_handle(cmd))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	if (!restoremissing) {
+		if (!pvcreate_each_device(cmd, handle, pp)) {
+			destroy_processing_handle(cmd, handle);
+			return_ECMD_FAILED;
+		}
+	}
+
+	/*
+	 * pvcreate_each_device returns with the VG_ORPHANS write lock held,
+	 * which was used to do pvcreate.  Now to create the VG using those
+	 * PVs, the VG lock will be taken (with the orphan lock already held.)
+	 */
 
 	/*
 	 * It is always ok to add new PVs to a VG - even if there are
@@ -174,15 +195,15 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	 */
 	cmd->handles_missing_pvs = 1;
 
-	/* Needed to change the set of orphan PVs. */
-	if (!lockd_gl(cmd, "ex", 0))
-		return_ECMD_FAILED;
+	handle->custom_handle = &vp;
 
-	ret = process_each_vg(cmd, 0, NULL, one_vgname,
+	ret = process_each_vg(cmd, 0, NULL, vg_name,
 			      READ_FOR_UPDATE, handle,
 			      restoremissing ? &_vgextend_restoremissing : &_vgextend_single);
 
 	destroy_processing_handle(cmd, handle);
 
+	if (!restoremissing)
+		unlock_vg(cmd, VG_ORPHANS);
 	return ret;
 }


