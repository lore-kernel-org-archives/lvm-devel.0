From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  9 Jul 2009 03:08:47 -0400
Subject: [PATCH 9/9] Change vg_create() to take only minimal parameters and obtain a lock.
In-Reply-To: <1247123327-26141-9-git-send-email-dwysocha@redhat.com>
References: <1247123327-26141-1-git-send-email-dwysocha@redhat.com>
	<1247123327-26141-2-git-send-email-dwysocha@redhat.com>
	<1247123327-26141-3-git-send-email-dwysocha@redhat.com>
	<1247123327-26141-4-git-send-email-dwysocha@redhat.com>
	<1247123327-26141-5-git-send-email-dwysocha@redhat.com>
	<1247123327-26141-6-git-send-email-dwysocha@redhat.com>
	<1247123327-26141-7-git-send-email-dwysocha@redhat.com>
	<1247123327-26141-8-git-send-email-dwysocha@redhat.com>
	<1247123327-26141-9-git-send-email-dwysocha@redhat.com>
Message-ID: <1247123327-26141-10-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

vg_t *vg_create(struct cmd_context *cmd, const char *vg_name);
This is the first step towards the API called to create a VG.
Call vg_lock_newname() inside this function.  Use _vg_make_handle()
where possible.
Now we have 2 ways to construct a volume group:
1) vg_read: Used when constructing an existing VG from disks
2) vg_create: Used when constructing a new VG
Both of these interfaces obtain a lock, and return a vg_t *.
The usage of _vg_make_handle() inside vg_create() doesn't fit
perfectly but it's ok for now.  Needs some cleanup though and I've
noted "FIXME" in the code.

Add the new vg_create() plus vg 'set' functions for non-default
VG parameters in the following tools:
- vgcreate: Fairly straightforward refactoring.  We just moved
vg_lock_newname inside vg_create so we check the return via
vg_read_error.
- vgsplit: The refactoring here is a bit more tricky.  Originally
we called vg_lock_newname and depending on the error code, we either
read the existing vg or created the new one.  Now vg_create()
calls vg_lock_newname, so we first try to create the VG.  If this
fails with FAILED_EXIST, we can then do the vg_read.  If the
create succeeds, we check the input parameters and set any new
values on the VG.

TODO in future patches:
1. The VG_ORPHAN lock needs some thought.  We may want to treat
this as any other VG, and require the application to obtain a handle
and pass it to other API calls (for example, vg_extend).  Or,
we may find that hiding the VG_ORPHAN lock inside other APIs is
the way to go.  I thought of placing the VG_ORPHAN lock inside
vg_create() and tying it to the vg handle, but was not certain
this was the right approach.
2. Cleanup error paths. Integrate vg_read_error() with vg_create and
vg_read* error codes and/or the new error APIs.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    5 +--
 lib/metadata/metadata.c          |   63 ++++++++++++++++++++++++-------------
 tools/vgcreate.c                 |   24 ++++++++------
 tools/vgsplit.c                  |   36 ++++++++++++---------
 4 files changed, 77 insertions(+), 51 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 474b3a7..5aa0d56 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -423,10 +423,7 @@ int pv_analyze(struct cmd_context *cmd, const char *pv_name,
 /* FIXME: move internal to library */
 uint32_t pv_list_extents_free(const struct dm_list *pvh);
 
-struct volume_group *vg_create(struct cmd_context *cmd, const char *name,
-			       uint32_t extent_size, uint32_t max_pv,
-			       uint32_t max_lv, alloc_policy_t alloc,
-			       int pv_count, char **pv_names);
+vg_t *vg_create(struct cmd_context *cmd, const char *vg_name);
 int vg_remove(struct volume_group *vg);
 int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
 		     struct volume_group *vg,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index da09de5..4465332 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -67,6 +67,10 @@ static struct pv_list *_find_pv_in_vg(const struct volume_group *vg,
 static struct physical_volume *_find_pv_in_vg_by_uuid(const struct volume_group *vg,
 						      const struct id *id);
 
+static vg_t *_vg_make_handle(struct cmd_context *cmd,
+			     struct volume_group *vg,
+			     uint32_t failure);
+
 unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignment)
 {
 	if (pv->pe_align)
@@ -510,24 +514,43 @@ int validate_vg_create_params(struct cmd_context *cmd,
 	return 0;
 }
 
-struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name,
-			       uint32_t extent_size, uint32_t max_pv,
-			       uint32_t max_lv, alloc_policy_t alloc,
-			       int pv_count, char **pv_names)
+/*
+ * Create a VG with default parameters.
+ * Returns:
+ * - vg_t* with SUCCESS code: VG structure created
+ * - NULL or vg_t* with FAILED_* code: error creating VG structure
+ * Use vg_read_error() to determine success or failure.
+ * FIXME: cleanup usage of _vg_make_handle()
+ */
+vg_t *vg_create(struct cmd_context *cmd, const char *vg_name)
 {
-	struct volume_group *vg;
+	vg_t *vg;
 	int consistent = 0;
 	struct dm_pool *mem;
+	uint32_t rc;
 
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
+	/* FIXME: Is this vg_read_internal necessary? Move it inside
+	   vg_lock_newname? */
 	/* is this vg name already in use ? */
 	if ((vg = vg_read_internal(cmd, vg_name, NULL, &consistent))) {
-		log_err("A volume group called '%s' already exists.", vg_name);
-		vg_release(vg);
-		return NULL;
+		log_error("A volume group called '%s' already exists.", vg_name);
+		unlock_and_release_vg(cmd, vg, vg_name);
+		return _vg_make_handle(cmd, NULL, FAILED_EXIST);
 	}
 
 	if (!(mem = dm_pool_create("lvm2 vg_create", VG_MEMPOOL_CHUNK)))
-		return_NULL;
+		goto_bad;
 
 	if (!(vg = dm_pool_zalloc(mem, sizeof(*vg))))
 		goto_bad;
@@ -554,14 +577,14 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name,
 
 	*vg->system_id = '\0';
 
-	vg->extent_size = extent_size;
+	vg->extent_size = DEFAULT_EXTENT_SIZE * 2;
 	vg->extent_count = 0;
 	vg->free_count = 0;
 
-	vg->max_lv = max_lv;
-	vg->max_pv = max_pv;
+	vg->max_lv = DEFAULT_MAX_LV;
+	vg->max_pv = DEFAULT_MAX_PV;
 
-	vg->alloc = alloc;
+	vg->alloc = DEFAULT_ALLOC_POLICY;
 
 	vg->pv_count = 0;
 	dm_list_init(&vg->pvs);
@@ -582,15 +605,11 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name,
 			  vg_name);
 		goto bad;
 	}
+	return _vg_make_handle(cmd, vg, SUCCESS);
 
-	/* attach the pv's */
-	if (!vg_extend(vg, pv_count, pv_names))
-		goto_bad;
-
-	return vg;
-
-      bad:
-	dm_pool_destroy(mem);
+bad:
+	unlock_and_release_vg(cmd, vg, vg_name);
+	/* FIXME: use _vg_make_handle() w/proper error code */
 	return NULL;
 }
 
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 353611b..7cfd0f2 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -46,22 +46,26 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	if (validate_vg_create_params(cmd, &vp_new))
 	    return EINVALID_CMD_LINE;
 
+	/* FIXME: orphan lock needs tied to vg handle or inside library call */
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Can't get lock for orphan PVs");
 		return ECMD_FAILED;
 	}
 
-	if (vg_lock_newname(cmd, vp_new.vg_name) != SUCCESS) {
-		log_error("Can't get lock for %s", vp_new.vg_name);
-		unlock_vg(cmd, VG_ORPHANS);
-		return ECMD_FAILED;
-	}
-
 	/* Create the new VG */
-	if (!(vg = vg_create(cmd, vp_new.vg_name, vp_new.extent_size,
-			     vp_new.max_pv, vp_new.max_lv, vp_new.alloc,
-			     argc - 1, argv + 1)))
-		goto bad;
+	vg = vg_create(cmd, vp_new.vg_name);
+	if (vg_read_error(vg))
+		goto_bad;
+
+	if (!vg_set_extent_size(vg, vp_new.extent_size) ||
+	    !vg_set_max_lv(vg, vp_new.max_lv) ||
+	    !vg_set_max_pv(vg, vp_new.max_pv) ||
+	    !vg_set_alloc_policy(vg, vp_new.alloc))
+		goto_bad;
+
+	/* attach the pv's */
+	if (!vg_extend(vg, argc - 1, argv + 1))
+		goto_bad;
 
 	if (vp_new.max_lv != vg->max_lv)
 		log_warn("WARNING: Setting maxlogicalvolumes to %d "
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 573dfb6..ec12720 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -284,7 +284,6 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	int existing_vg = 0;
 	int r = ECMD_FAILED;
 	const char *lv_name;
-	uint32_t rc;
 
 	if ((arg_count(cmd, name_ARG) + argc) < 3) {
 		log_error("Existing VG, new VG and either physical volumes "
@@ -322,24 +321,34 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
+	/*
+	 * Set metadata format of original VG.
+	 * NOTE: We must set the format before calling vg_create()
+	 * since vg_create() calls the per-format constructor.
+	 */
+	cmd->fmt = vg_from->fid->fmt;
+
 	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
 	/*
-	 * Try to lock the name of the new VG.  If we cannot reserve it,
-	 * then we assume it exists, and we will not be holding a lock.
-	 * We then try to read it - the vgsplit will be into an existing VG.
+	 * First try to create a new VG.  If we cannot create it,
+	 * and we get FAILED_EXIST (we will not be holding a lock),
+	 * a VG must already exist with this name.  We then try to
+	 * read the existing VG - the vgsplit will be into an existing VG.
 	 *
 	 * Otherwise, if the lock was successful, it must be the case that
 	 * we obtained a WRITE lock and could not find the vgname in the
 	 * system.  Thus, the split will be into a new VG.
 	 */
-	rc = vg_lock_newname(cmd, vg_name_to);
-	if (rc == FAILED_LOCKING) {
+	vg_to = vg_create(cmd, vg_name_to);
+	if (vg_read_error(vg_to) == FAILED_LOCKING) {
 		log_error("Can't get lock for %s", vg_name_to);
+		vg_release(vg_to);
 		unlock_and_release_vg(cmd, vg_from, vg_name_from);
 		return ECMD_FAILED;
 	}
-	if (rc == FAILED_EXIST) {
+	if (vg_read_error(vg_to) == FAILED_EXIST) {
 		existing_vg = 1;
+		vg_release(vg_to);
 		vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
 					   READ_REQUIRE_RESIZEABLE);
 
@@ -356,13 +365,9 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		}
 		if (!vgs_are_compatible(cmd, vg_from,vg_to))
 			goto_bad;
-	} else if (rc == SUCCESS) {
+	} else if (vg_read_error(vg_to) == SUCCESS) {
 		existing_vg = 0;
 
-		/* Set metadata format of original VG */
-		/* FIXME: need some common logic */
-		cmd->fmt = vg_from->fid->fmt;
-
 		vp_def.vg_name = NULL;
 		vp_def.extent_size = vg_from->extent_size;
 		vp_def.max_pv = vg_from->max_pv;
@@ -380,9 +385,10 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 			goto bad;
 		}
 
-		if (!(vg_to = vg_create(cmd, vg_name_to, vp_new.extent_size,
-					vp_new.max_pv, vp_new.max_lv,
-					vp_new.alloc, 0, NULL)))
+		if (!vg_set_extent_size(vg_to, vp_new.extent_size) ||
+		    !vg_set_max_lv(vg_to, vp_new.max_lv) ||
+		    !vg_set_max_pv(vg_to, vp_new.max_pv) ||
+		    !vg_set_alloc_policy(vg_to, vp_new.alloc))
 			goto_bad;
 
 		if (vg_is_clustered(vg_from))
-- 
1.6.0.6


