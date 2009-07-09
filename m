From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Jul 2009 10:09:33 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20090709100933.12116.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-09 10:09:33

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : vgcreate.c vgsplit.c 

Log message:
	Change vg_create() to take only minimal parameters and obtain a lock.
	
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

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.240&r2=1.241
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83

--- LVM2/lib/metadata/metadata-exported.h	2009/07/09 10:08:54	1.86
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/09 10:09:33	1.87
@@ -423,10 +423,7 @@
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
--- LVM2/lib/metadata/metadata.c	2009/07/09 10:08:54	1.240
+++ LVM2/lib/metadata/metadata.c	2009/07/09 10:09:33	1.241
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -67,6 +67,10 @@
 static struct physical_volume *_find_pv_in_vg_by_uuid(const struct volume_group *vg,
 						      const struct id *id);
 
+static vg_t *_vg_make_handle(struct cmd_context *cmd,
+			     struct volume_group *vg,
+			     uint32_t failure);
+
 unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignment)
 {
 	if (pv->pe_align)
@@ -515,24 +519,43 @@
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
@@ -559,14 +582,14 @@
 
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
@@ -587,15 +610,11 @@
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
 
--- LVM2/tools/vgcreate.c	2009/07/09 10:00:36	1.62
+++ LVM2/tools/vgcreate.c	2009/07/09 10:09:33	1.63
@@ -46,22 +46,26 @@
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
--- LVM2/tools/vgsplit.c	2009/07/09 10:00:36	1.82
+++ LVM2/tools/vgsplit.c	2009/07/09 10:09:33	1.83
@@ -284,7 +284,6 @@
 	int existing_vg = 0;
 	int r = ECMD_FAILED;
 	const char *lv_name;
-	uint32_t rc;
 
 	if ((arg_count(cmd, name_ARG) + argc) < 3) {
 		log_error("Existing VG, new VG and either physical volumes "
@@ -322,24 +321,34 @@
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
 
@@ -356,13 +365,9 @@
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
@@ -380,9 +385,10 @@
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


