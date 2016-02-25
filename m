From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 25 Feb 2016 15:15:44 +0000 (UTC)
Subject: master - vgcreate: use the common toollib pv create
Message-ID: <20160225151544.1885D61BB7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a9940bd3c928598d1f15a60503c146046e55a357
Commit:        a9940bd3c928598d1f15a60503c146046e55a357
Parent:        749a7cecf895264bb8b924e2cc091d13cb111965
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 26 11:34:59 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 25 09:14:09 2016 -0600

vgcreate: use the common toollib pv create

Use the new pvcreate_each_device() function from
toollib, previously added for pvcreate, in place
of the old pvcreate_vol().

This also requires shifting the location where the
lock is acquired for the new VG name.  The lock for
the new VG is supposed to be acquired before pvcreate.
This means splitting the vg_lock_newname() out of
vg_create(), and calling vg_lock_newname() directly
before pvcreate, and then calling the remainder of
vg_create() after pvcreate.

The new function vg_lock_and_create() now does
vg_lock_newname() + vg_create(), like the previous
version of vg_create().

The lock on the new VG name is released before the
pvcreate and reacquired after the pvcreate because
pvcreate needs to reset lvmcache, which doesn't work
when locks are held.  An exception could likely be
made for the new VG name lock, which would allow
vgcreate to hold the new VG name lock across the
pvcreate step.
---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   33 ++++++++-------
 liblvm/lvm_vg.c                  |    2 +-
 tools/vgcreate.c                 |   83 ++++++++++++++++++++++++++++---------
 tools/vgsplit.c                  |    6 +-
 5 files changed, 86 insertions(+), 39 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 87342d8..0a45397 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -752,6 +752,7 @@ uint32_t pv_list_extents_free(const struct dm_list *pvh);
 int validate_new_vg_name(struct cmd_context *cmd, const char *vg_name);
 int vg_validate(struct volume_group *vg);
 struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name);
+struct volume_group *vg_lock_and_create(struct cmd_context *cmd, const char *vg_name);
 int vg_remove_mdas(struct volume_group *vg);
 int vg_remove_check(struct volume_group *vg);
 void vg_remove_pvs(struct volume_group *vg);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 92a9e82..20caab9 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1087,6 +1087,24 @@ int vg_has_unknown_segments(const struct volume_group *vg)
 	return 0;
 }
 
+struct volume_group *vg_lock_and_create(struct cmd_context *cmd, const char *vg_name)
+{
+	uint32_t rc;
+
+	if (!validate_name(vg_name)) {
+		log_error("Invalid vg name %s", vg_name);
+		/* FIXME: use _vg_make_handle() w/proper error code */
+		return NULL;
+	}
+
+	rc = vg_lock_newname(cmd, vg_name);
+	if (rc != SUCCESS)
+		/* NOTE: let caller decide - this may be check for existence */
+		return _vg_make_handle(cmd, NULL, rc);
+
+	return vg_create(cmd, vg_name);
+}
+
 /*
  * Create a VG with default parameters.
  * Returns:
@@ -1103,21 +1121,6 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 		.context.vg_ref.vg_name = vg_name
 	};
 	struct format_instance *fid;
-	uint32_t rc;
-
-	if (!validate_name(vg_name)) {
-		log_error("Invalid vg name %s", vg_name);
-		/* FIXME: use _vg_make_handle() w/proper error code */
-		return NULL;
-	}
-
-	rc = vg_lock_newname(cmd, vg_name);
-	if (rc != SUCCESS)
-		/* NOTE: let caller decide - this may be check for existence */
-		return _vg_make_handle(cmd, NULL, rc);
-
-	/* Strip dev_dir if present */
-	vg_name = strip_dir(vg_name, cmd->dev_dir);
 
 	if (!(vg = alloc_vg("vg_create", cmd, vg_name)))
 		goto_bad;
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 80f51ad..7e48df0 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -54,7 +54,7 @@ vg_t lvm_vg_create(lvm_t libh, const char *vg_name)
 	struct volume_group *vg = NULL;
 	struct saved_env e = store_user_env((struct cmd_context *)libh);
 
-	vg = vg_create((struct cmd_context *)libh, vg_name);
+	vg = vg_lock_and_create((struct cmd_context *)libh, vg_name);
 	/* FIXME: error handling is still TBD */
 	if (vg_read_error(vg)) {
 		release_vg(vg);
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index ac53538..456e207 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -17,14 +17,16 @@
 
 int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 {
+	struct processing_handle *handle;
+	struct pvcreate_each_params pp;
 	struct vgcreate_params vp_new;
 	struct vgcreate_params vp_def;
 	struct volume_group *vg;
 	const char *tag;
 	const char *clustered_message = "";
 	char *vg_name;
-	struct pvcreate_params pp;
 	struct arg_value_group_list *current_group;
+	uint32_t rc;
 
 	if (!argc) {
 		log_error("Please provide volume group name and "
@@ -36,10 +38,19 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	argc--;
 	argv++;
 
-	pvcreate_params_set_defaults(&pp);
-	if (!pvcreate_params_validate(cmd, argc, &pp)) {
+	pvcreate_each_params_set_defaults(&pp);
+
+	if (!pvcreate_each_params_from_args(cmd, &pp))
 		return EINVALID_CMD_LINE;
-	}
+
+	pp.pv_count = argc;
+	pp.pv_names = argv;
+
+	/* Don't create a new PV on top of an existing PV like pvcreate does. */
+	pp.preserve_existing = 1;
+
+	/* pvcreate within vgcreate cannot be forced. */
+	pp.force = 0;
 
 	if (!vgcreate_params_set_defaults(cmd, &vp_def, NULL))
 		return EINVALID_CMD_LINE;
@@ -48,28 +59,64 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 
 	if (!vgcreate_params_validate(cmd, &vp_new))
-	    return EINVALID_CMD_LINE;
+		return EINVALID_CMD_LINE;
 
 	/*
 	 * Needed to change the global VG namespace,
 	 * and to change the set of orphan PVs.
 	 */
 	if (!lockd_gl_create(cmd, "ex", vp_new.lock_type))
-		return ECMD_FAILED;
+		return_ECMD_FAILED;
+	cmd->lockd_gl_disable = 1;
 
 	lvmcache_seed_infos_from_lvmetad(cmd);
 
-	/* Create the new VG */
-	vg = vg_create(cmd, vp_new.vg_name);
-	if (vg_read_error(vg)) {
-		if (vg_read_error(vg) == FAILED_EXIST)
+	/*
+	 * Check if the VG name already exists.  This should be done before
+	 * creating PVs on any of the devices.
+	 */
+	if ((rc = vg_lock_newname(cmd, vp_new.vg_name)) != SUCCESS) {
+		if (rc == FAILED_EXIST)
 			log_error("A volume group called %s already exists.", vp_new.vg_name);
 		else
 			log_error("Can't get lock for %s.", vp_new.vg_name);
-		release_vg(vg);
 		return ECMD_FAILED;
 	}
 
+	/*
+	 * FIXME: we have to unlock/relock the new VG name around the pvcreate
+	 * step because pvcreate needs to destroy lvmcache, which doesn't allow
+	 * any locks to be held.  There shouldn't be any reason to require this
+	 * VG lock to be released, so the lvmcache destroy rule about locks
+	 * seems to be unwarranted here.
+	 */
+	unlock_vg(cmd, vp_new.vg_name);
+
+	if (!(handle = init_processing_handle(cmd))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	if (!pvcreate_each_device(cmd, handle, &pp)) {
+		destroy_processing_handle(cmd, handle);
+		return_ECMD_FAILED;
+	}
+
+	/* Relock the new VG name, see comment above. */
+	if (!lock_vol(cmd, vp_new.vg_name, LCK_VG_WRITE, NULL)) {
+		destroy_processing_handle(cmd, handle);
+		return_ECMD_FAILED;
+	}
+
+	/*
+	 * pvcreate_each_device returns with the VG_ORPHANS write lock held,
+	 * which was used to do pvcreate.  Now to create the VG using those
+	 * PVs, the VG lock will be taken (with the orphan lock already held.)
+	 */
+
+	if (!(vg = vg_create(cmd, vp_new.vg_name)))
+		goto_bad;
+
 	if (vg->fid->fmt->features & FMT_CONFIG_PROFILE)
 		vg->profile = vg->cmd->profile_params->global_metadata_profile;
 
@@ -80,15 +127,10 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	    !vg_set_clustered(vg, vp_new.clustered) ||
 	    !vg_set_system_id(vg, vp_new.system_id) ||
 	    !vg_set_mda_copies(vg, vp_new.vgmetadatacopies))
-		goto bad_orphan;
-
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
-		log_error("Can't get lock for orphan PVs");
-		goto bad_orphan;
-	}
+		goto_bad;
 
 	/* attach the pv's */
-	if (!vg_extend(vg, argc, (const char* const*)argv, &pp))
+	if (!vg_extend_each_pv(vg, &pp))
 		goto_bad;
 
 	if (vp_new.max_lv != vg->max_lv)
@@ -176,12 +218,13 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	}
 out:
 	release_vg(vg);
+	destroy_processing_handle(cmd, handle);
 	return ECMD_PROCESSED;
 
 bad:
+	unlock_vg(cmd, vp_new.vg_name);
 	unlock_vg(cmd, VG_ORPHANS);
-bad_orphan:
 	release_vg(vg);
-	unlock_vg(cmd, vp_new.vg_name);
+	destroy_processing_handle(cmd, handle);
 	return ECMD_FAILED;
 }
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 540fd1a..8335570 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -413,7 +413,7 @@ static struct volume_group *_vgsplit_to(struct cmd_context *cmd,
 	 * we obtained a WRITE lock and could not find the vgname in the
 	 * system.  Thus, the split will be into a new VG.
 	 */
-	vg_to = vg_create(cmd, vg_name_to);
+	vg_to = vg_lock_and_create(cmd, vg_name_to);
 	if (vg_read_error(vg_to) == FAILED_LOCKING) {
 		log_error("Can't get lock for %s", vg_name_to);
 		release_vg(vg_to);
@@ -526,8 +526,8 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 			return_ECMD_FAILED;
 		/*
 		 * Set metadata format of original VG.
-		 * NOTE: We must set the format before calling vg_create()
-		 * since vg_create() calls the per-format constructor.
+		 * NOTE: We must set the format before calling vg_lock_and_create()
+		 * since vg_lock_and_create() calls the per-format constructor.
 		 */
 		cmd->fmt = vg_from->fid->fmt;
 


