From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 02:33:36 -0000
Subject: LVM2 lib/metadata/lv_manip.c lib/metadata/meta ...
Message-ID: <20090726023336.16816.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 02:33:35

Modified files:
	lib/metadata   : lv_manip.c metadata-exported.h 
	tools          : lvcreate.c 

Log message:
	Move _lvcreate into the internal library and rename to lv_create_single.
	
	After some refactorings, we can now move the bulk of _lvcreate into the
	internal library, and we can call from liblvm.  In the future, we should
	refactor lv_create_single further, probably by segtype, to reduce the
	size of struct lvcreate_params.  For now this is a reasonable refactor
	and allows us to re-use the function from liblvm.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.182&r2=1.183
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.99&r2=1.100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.205&r2=1.206

--- LVM2/lib/metadata/lv_manip.c	2009/07/15 20:02:47	1.182
+++ LVM2/lib/metadata/lv_manip.c	2009/07/26 02:33:35	1.183
@@ -25,6 +25,7 @@
 #include "segtype.h"
 #include "archiver.h"
 #include "activate.h"
+#include "str_list.h"
 
 struct lv_names {
 	const char *old;
@@ -2772,3 +2773,384 @@
 
 	return 1;
 }
+
+
+static struct logical_volume *_create_virtual_origin(struct cmd_context *cmd,
+						     struct volume_group *vg,
+						     const char *lv_name,
+						     uint32_t permission,
+						     uint64_t voriginextents)
+{
+	const struct segment_type *segtype;
+	size_t len;
+	char *vorigin_name;
+	struct logical_volume *lv;
+
+	if (!(segtype = get_segtype_from_string(cmd, "zero"))) {
+		log_error("Zero segment type for virtual origin not found");
+		return NULL;
+	}
+
+	len = strlen(lv_name) + 32;
+	if (!(vorigin_name = alloca(len)) ||
+	    dm_snprintf(vorigin_name, len, "%s_vorigin", lv_name) < 0) {
+		log_error("Virtual origin name allocation failed.");
+		return NULL;
+	}
+
+	if (!(lv = lv_create_empty(vorigin_name, NULL, permission,
+				   ALLOC_INHERIT, vg)))
+		return_NULL;
+
+	if (!lv_extend(lv, segtype, 1, 0, 1, voriginextents, NULL, 0u, 0u,
+		       NULL, ALLOC_INHERIT))
+		return_NULL;
+
+	/* store vg on disk(s) */
+	if (!vg_write(vg) || !vg_commit(vg))
+		return_NULL;
+
+	backup(vg);
+
+	return lv;
+}
+
+int lv_create_single(struct volume_group *vg,
+		     struct lvcreate_params *lp)
+{
+	struct cmd_context *cmd = vg->cmd;
+	uint32_t size_rest;
+	uint32_t status = 0;
+	struct logical_volume *lv, *org = NULL;
+	int origin_active = 0;
+	char lv_name_buf[128];
+	const char *lv_name;
+	struct lvinfo info;
+
+	if (lp->lv_name && find_lv_in_vg(vg, lp->lv_name)) {
+		log_error("Logical volume \"%s\" already exists in "
+			  "volume group \"%s\"", lp->lv_name, lp->vg_name);
+		return 0;
+	}
+
+	if (vg_max_lv_reached(vg)) {
+		log_error("Maximum number of logical volumes (%u) reached "
+			  "in volume group %s", vg->max_lv, vg->name);
+		return 0;
+	}
+
+	if (lp->mirrors > 1 && !(vg->fid->fmt->features & FMT_SEGMENTS)) {
+		log_error("Metadata does not support mirroring.");
+		return 0;
+	}
+
+	if (lp->read_ahead != DM_READ_AHEAD_AUTO &&
+	    lp->read_ahead != DM_READ_AHEAD_NONE &&
+	    (vg->fid->fmt->features & FMT_RESTRICTED_READAHEAD) &&
+	    (lp->read_ahead < 2 || lp->read_ahead > 120)) {
+		log_error("Metadata only supports readahead values between 2 and 120.");
+		return 0;
+	}
+
+	if (lp->stripe_size > vg->extent_size) {
+		log_error("Reducing requested stripe size %s to maximum, "
+			  "physical extent size %s",
+			  display_size(cmd, (uint64_t) lp->stripe_size),
+			  display_size(cmd, (uint64_t) vg->extent_size));
+		lp->stripe_size = vg->extent_size;
+	}
+
+	/* Need to check the vg's format to verify this - the cmd format isn't setup properly yet */
+	if (lp->stripes > 1 &&
+	    !(vg->fid->fmt->features & FMT_UNLIMITED_STRIPESIZE) &&
+	    (lp->stripe_size > STRIPE_SIZE_MAX)) {
+		log_error("Stripe size may not exceed %s",
+			  display_size(cmd, (uint64_t) STRIPE_SIZE_MAX));
+		return 0;
+	}
+
+	if ((size_rest = lp->extents % lp->stripes)) {
+		log_print("Rounding size (%d extents) up to stripe boundary "
+			  "size (%d extents)", lp->extents,
+			  lp->extents - size_rest + lp->stripes);
+		lp->extents = lp->extents - size_rest + lp->stripes;
+	}
+
+	if (lp->zero && !activation()) {
+		log_error("Can't wipe start of new LV without using "
+			  "device-mapper kernel driver");
+		return 0;
+	}
+
+	status |= lp->permission | VISIBLE_LV;
+
+	if (lp->snapshot) {
+		if (!activation()) {
+			log_error("Can't create snapshot without using "
+				  "device-mapper kernel driver");
+			return 0;
+		}
+		/* FIXME Allow exclusive activation. */
+		if (vg_is_clustered(vg)) {
+			log_error("Clustered snapshots are not yet supported.");
+			return 0;
+		}
+
+		/* Must zero cow */
+		status |= LVM_WRITE;
+
+		if (lp->voriginsize)
+			origin_active = 1;
+		else {
+
+			if (!(org = find_lv(vg, lp->origin))) {
+				log_error("Couldn't find origin volume '%s'.",
+					  lp->origin);
+				return 0;
+			}
+			if (lv_is_virtual_origin(org)) {
+				log_error("Can't share virtual origins. "
+					  "Use --virtualsize.");
+				return 0;
+			}
+			if (lv_is_cow(org)) {
+				log_error("Snapshots of snapshots are not "
+					  "supported yet.");
+				return 0;
+			}
+			if (org->status & LOCKED) {
+				log_error("Snapshots of locked devices are not "
+					  "supported yet");
+				return 0;
+			}
+			if (org->status & MIRROR_IMAGE ||
+			    org->status & MIRROR_LOG ||
+			    org->status & MIRRORED) {
+				log_error("Snapshots and mirrors may not yet "
+					  "be mixed.");
+				return 0;
+			}
+
+			if (!lv_info(cmd, org, &info, 0, 0)) {
+				log_error("Check for existence of snapshot "
+					  "origin '%s' failed.", org->name);
+				return 0;
+			}
+			origin_active = info.exists;
+		}
+	}
+
+	if (!lp->extents) {
+		log_error("Unable to create new logical volume with no extents");
+		return 0;
+	}
+
+	if (!seg_is_virtual(lp) &&
+	    vg->free_count < lp->extents) {
+		log_error("Insufficient free extents (%u) in volume group %s: "
+			  "%u required", vg->free_count, vg->name, lp->extents);
+		return 0;
+	}
+
+	if (lp->stripes > dm_list_size(lp->pvh) && lp->alloc != ALLOC_ANYWHERE) {
+		log_error("Number of stripes (%u) must not exceed "
+			  "number of physical volumes (%d)", lp->stripes,
+			  dm_list_size(lp->pvh));
+		return 0;
+	}
+
+	if (lp->mirrors > 1 && !activation()) {
+		log_error("Can't create mirror without using "
+			  "device-mapper kernel driver.");
+		return 0;
+	}
+
+	/* The snapshot segment gets created later */
+	if (lp->snapshot &&
+	    !(lp->segtype = get_segtype_from_string(cmd, "striped")))
+		return_0;
+
+	if (!archive(vg))
+		return 0;
+
+	if (lp->lv_name)
+		lv_name = lp->lv_name;
+	else {
+		if (!generate_lv_name(vg, "lvol%d", lv_name_buf, sizeof(lv_name_buf))) {
+			log_error("Failed to generate LV name.");
+			return 0;
+		}
+		lv_name = &lv_name_buf[0];
+	}
+
+	if (lp->tag) {
+		if (!(vg->fid->fmt->features & FMT_TAGS)) {
+			log_error("Volume group %s does not support tags",
+				  vg->name);
+			return 0;
+		}
+	}
+
+	if (lp->mirrors > 1) {
+		init_mirror_in_sync(lp->nosync);
+
+		if (lp->nosync) {
+			log_warn("WARNING: New mirror won't be synchronised. "
+				  "Don't read what you didn't write!");
+			status |= MIRROR_NOTSYNCED;
+		}
+	}
+
+	if (!(lv = lv_create_empty(lv_name ? lv_name : "lvol%d", NULL,
+				   status, lp->alloc, vg)))
+		return_0;
+
+	if (lp->read_ahead) {
+		log_verbose("Setting read ahead sectors");
+		lv->read_ahead = lp->read_ahead;
+	}
+
+	if (lp->minor >= 0) {
+		lv->major = lp->major;
+		lv->minor = lp->minor;
+		lv->status |= FIXED_MINOR;
+		log_verbose("Setting device number to (%d, %d)", lv->major,
+			    lv->minor);
+	}
+
+	if (lp->tag && !str_list_add(cmd->mem, &lv->tags, lp->tag)) {
+		log_error("Failed to add tag %s to %s/%s",
+			  lp->tag, lv->vg->name, lv->name);
+		return 0;
+	}
+
+	if (!lv_extend(lv, lp->segtype, lp->stripes, lp->stripe_size,
+		       1, lp->extents, NULL, 0u, 0u, lp->pvh, lp->alloc))
+		return_0;
+
+	if (lp->mirrors > 1) {
+		if (!lv_add_mirrors(cmd, lv, lp->mirrors - 1, lp->stripes,
+				    adjusted_mirror_region_size(
+						vg->extent_size,
+						lv->le_count,
+						lp->region_size),
+				    lp->corelog ? 0U : 1U, lp->pvh, lp->alloc,
+				    MIRROR_BY_LV |
+				    (lp->nosync ? MIRROR_SKIP_INIT_SYNC : 0))) {
+			stack;
+			goto revert_new_lv;
+		}
+	}
+
+	/* store vg on disk(s) */
+	if (!vg_write(vg) || !vg_commit(vg))
+		return_0;
+
+	backup(vg);
+
+	if (lp->snapshot) {
+		if (!activate_lv_excl(cmd, lv)) {
+			log_error("Aborting. Failed to activate snapshot "
+				  "exception store.");
+			goto revert_new_lv;
+		}
+	} else if (!activate_lv(cmd, lv)) {
+		if (lp->zero) {
+			log_error("Aborting. Failed to activate new LV to wipe "
+				  "the start of it.");
+			goto deactivate_and_revert_new_lv;
+		}
+		log_error("Failed to activate new LV.");
+		return 0;
+	}
+
+	if (!lp->zero && !lp->snapshot)
+		log_error("WARNING: \"%s\" not zeroed", lv->name);
+	else if (!set_lv(cmd, lv, UINT64_C(0), 0)) {
+		log_error("Aborting. Failed to wipe %s.",
+			  lp->snapshot ? "snapshot exception store" :
+					 "start of new LV");
+		goto deactivate_and_revert_new_lv;
+	}
+
+	if (lp->snapshot) {
+		/* Reset permission after zeroing */
+		if (!(lp->permission & LVM_WRITE))
+			lv->status &= ~LVM_WRITE;
+
+		/* COW area must be deactivated if origin is not active */
+		if (!origin_active && !deactivate_lv(cmd, lv)) {
+			log_error("Aborting. Couldn't deactivate snapshot "
+				  "COW area. Manual intervention required.");
+			return 0;
+		}
+
+		/* A virtual origin must be activated explicitly. */
+		if (lp->voriginsize &&
+		    (!(org = _create_virtual_origin(cmd, vg, lv->name,
+						    lp->permission,
+						    lp->voriginextents)) ||
+		     !activate_lv(cmd, org))) {
+			log_error("Couldn't create virtual origin for LV %s",
+				  lv->name);
+			if (org && !lv_remove(org))
+				stack;
+			goto deactivate_and_revert_new_lv;
+		}
+
+		/* cow LV remains active and becomes snapshot LV */
+
+		if (!vg_add_snapshot(org, lv, NULL,
+				     org->le_count, lp->chunk_size)) {
+			log_error("Couldn't create snapshot.");
+			goto deactivate_and_revert_new_lv;
+		}
+
+		/* store vg on disk(s) */
+		if (!vg_write(vg))
+			return_0;
+
+		if (!suspend_lv(cmd, org)) {
+			log_error("Failed to suspend origin %s", org->name);
+			vg_revert(vg);
+			return 0;
+		}
+
+		if (!vg_commit(vg))
+			return_0;
+
+		if (!resume_lv(cmd, org)) {
+			log_error("Problem reactivating origin %s", org->name);
+			return 0;
+		}
+	}
+	/* FIXME out of sequence */
+	backup(vg);
+
+	log_print("Logical volume \"%s\" created", lv->name);
+
+	/*
+	 * FIXME: as a sanity check we could try reading the
+	 * last block of the device ?
+	 */
+
+	return 1;
+
+deactivate_and_revert_new_lv:
+	if (!deactivate_lv(cmd, lv)) {
+		log_error("Unable to deactivate failed new LV. "
+			  "Manual intervention required.");
+		return 0;
+	}
+
+revert_new_lv:
+	/* FIXME Better to revert to backup of metadata? */
+	if (!lv_remove(lv) || !vg_write(vg) || !vg_commit(vg))
+		log_error("Manual intervention may be required to remove "
+			  "abandoned LV(s) before retrying.");
+	else
+		backup(vg);
+
+	return 0;
+}
+
--- LVM2/lib/metadata/metadata-exported.h	2009/07/26 02:02:22	1.99
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/26 02:33:35	1.100
@@ -495,6 +495,45 @@
 int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 	      const char *new_name);
 
+/* FIXME: refactor and reduce the size of this struct! */
+struct lvcreate_params {
+	/* flags */
+	int snapshot; /* snap */
+	int zero; /* all */
+	int major; /* all */
+	int minor; /* all */
+	int corelog; /* mirror */
+	int nosync; /* mirror */
+
+	char *origin; /* snap */
+	const char *vg_name; /* all */
+	const char *lv_name; /* all */
+
+	uint32_t stripes; /* striped */
+	uint32_t stripe_size; /* striped */
+	uint32_t chunk_size; /* snapshot */
+	uint32_t region_size; /* mirror */
+
+	uint32_t mirrors; /* mirror */
+
+	const struct segment_type *segtype; /* all */
+
+	/* size */
+	uint32_t extents; /* all */
+	uint32_t voriginextents; /* snapshot */
+	uint64_t voriginsize; /* snapshot */
+	struct dm_list *pvh; /* all */
+
+	uint32_t permission; /* all */
+	uint32_t read_ahead; /* all */
+	alloc_policy_t alloc; /* all */
+
+	const char *tag; /* all */
+};
+
+int lv_create_single(struct volume_group *vg,
+		     struct lvcreate_params *lp);
+
 /*
  * Functions for layer manipulation
  */
--- LVM2/tools/lvcreate.c	2009/07/26 02:32:50	1.205
+++ LVM2/tools/lvcreate.c	2009/07/26 02:33:35	1.206
@@ -25,42 +25,6 @@
 	int pv_count;
 };
 
-/* FIXME: refactor and reduce the size of this struct! */
-struct lvcreate_params {
-	/* flags */
-	int snapshot; /* snap */
-	int zero; /* all */
-	int major; /* all */
-	int minor; /* all */
-	int corelog; /* mirror */
-	int nosync; /* mirror */
-
-	char *origin; /* snap */
-	const char *vg_name; /* all */
-	const char *lv_name; /* all */
-
-	uint32_t stripes; /* striped */
-	uint32_t stripe_size; /* striped */
-	uint32_t chunk_size; /* snapshot */
-	uint32_t region_size; /* mirror */
-
-	uint32_t mirrors; /* mirror */
-
-	const struct segment_type *segtype; /* all */
-
-	/* size */
-	uint32_t extents; /* all */
-	uint32_t voriginextents; /* snapshot */
-	uint64_t voriginsize; /* snapshot */
-	struct dm_list *pvh; /* all */
-
-	uint32_t permission; /* all */
-	uint32_t read_ahead; /* all */
-	alloc_policy_t alloc; /* all */
-
-	const char *tag; /* all */
-};
-
 static uint64_t _extents_from_size(struct cmd_context *cmd, uint64_t size,
 				   uint32_t extent_size);
 
@@ -631,385 +595,6 @@
 	return (uint64_t) size / extent_size;
 }
 
-static struct logical_volume *_create_virtual_origin(struct cmd_context *cmd,
-						     struct volume_group *vg,
-						     const char *lv_name,
-						     uint32_t permission,
-						     uint64_t voriginextents)
-{
-	const struct segment_type *segtype;
-	size_t len;
-	char *vorigin_name;
-	struct logical_volume *lv;
-
-	if (!(segtype = get_segtype_from_string(cmd, "zero"))) {
-		log_error("Zero segment type for virtual origin not found");
-		return NULL;
-	}
-
-	len = strlen(lv_name) + 32;
-	if (!(vorigin_name = alloca(len)) ||
-	    dm_snprintf(vorigin_name, len, "%s_vorigin", lv_name) < 0) {
-		log_error("Virtual origin name allocation failed.");
-		return NULL;
-	}
-
-	if (!(lv = lv_create_empty(vorigin_name, NULL, permission,
-				   ALLOC_INHERIT, vg)))
-		return_NULL;
-
-	if (!lv_extend(lv, segtype, 1, 0, 1, voriginextents, NULL, 0u, 0u,
-		       NULL, ALLOC_INHERIT))
-		return_NULL;
-
-	/* store vg on disk(s) */
-	if (!vg_write(vg) || !vg_commit(vg))
-		return_NULL;
-
-	backup(vg);
-
-	return lv;
-}
-
-static int _lvcreate(struct volume_group *vg,
-		     struct lvcreate_params *lp)
-{
-	struct cmd_context *cmd = vg->cmd;
-	uint32_t size_rest;
-	uint32_t status = 0;
-	struct logical_volume *lv, *org = NULL;
-	int origin_active = 0;
-	char lv_name_buf[128];
-	const char *lv_name;
-	struct lvinfo info;
-
-	if (lp->lv_name && find_lv_in_vg(vg, lp->lv_name)) {
-		log_error("Logical volume \"%s\" already exists in "
-			  "volume group \"%s\"", lp->lv_name, lp->vg_name);
-		return 0;
-	}
-
-	if (vg_max_lv_reached(vg)) {
-		log_error("Maximum number of logical volumes (%u) reached "
-			  "in volume group %s", vg->max_lv, vg->name);
-		return 0;
-	}
-
-	if (lp->mirrors > 1 && !(vg->fid->fmt->features & FMT_SEGMENTS)) {
-		log_error("Metadata does not support mirroring.");
-		return 0;
-	}
-
-	if (lp->read_ahead != DM_READ_AHEAD_AUTO &&
-	    lp->read_ahead != DM_READ_AHEAD_NONE &&
-	    (vg->fid->fmt->features & FMT_RESTRICTED_READAHEAD) &&
-	    (lp->read_ahead < 2 || lp->read_ahead > 120)) {
-		log_error("Metadata only supports readahead values between 2 and 120.");
-		return 0;
-	}
-
-	if (lp->stripe_size > vg->extent_size) {
-		log_error("Reducing requested stripe size %s to maximum, "
-			  "physical extent size %s",
-			  display_size(cmd, (uint64_t) lp->stripe_size),
-			  display_size(cmd, (uint64_t) vg->extent_size));
-		lp->stripe_size = vg->extent_size;
-	}
-
-	/* Need to check the vg's format to verify this - the cmd format isn't setup properly yet */
-	if (lp->stripes > 1 &&
-	    !(vg->fid->fmt->features & FMT_UNLIMITED_STRIPESIZE) &&
-	    (lp->stripe_size > STRIPE_SIZE_MAX)) {
-		log_error("Stripe size may not exceed %s",
-			  display_size(cmd, (uint64_t) STRIPE_SIZE_MAX));
-		return 0;
-	}
-
-	if ((size_rest = lp->extents % lp->stripes)) {
-		log_print("Rounding size (%d extents) up to stripe boundary "
-			  "size (%d extents)", lp->extents,
-			  lp->extents - size_rest + lp->stripes);
-		lp->extents = lp->extents - size_rest + lp->stripes;
-	}
-
-	if (lp->zero && !activation()) {
-		log_error("Can't wipe start of new LV without using "
-			  "device-mapper kernel driver");
-		return 0;
-	}
-
-	status |= lp->permission | VISIBLE_LV;
-
-	if (lp->snapshot) {
-		if (!activation()) {
-			log_error("Can't create snapshot without using "
-				  "device-mapper kernel driver");
-			return 0;
-		}
-		/* FIXME Allow exclusive activation. */
-		if (vg_is_clustered(vg)) {
-			log_error("Clustered snapshots are not yet supported.");
-			return 0;
-		}
-
-		/* Must zero cow */
-		status |= LVM_WRITE;
-
-		if (lp->voriginsize)
-			origin_active = 1;
-		else {
-
-			if (!(org = find_lv(vg, lp->origin))) {
-				log_error("Couldn't find origin volume '%s'.",
-					  lp->origin);
-				return 0;
-			}
-			if (lv_is_virtual_origin(org)) {
-				log_error("Can't share virtual origins. "
-					  "Use --virtualsize.");
-				return 0;
-			}
-			if (lv_is_cow(org)) {
-				log_error("Snapshots of snapshots are not "
-					  "supported yet.");
-				return 0;
-			}
-			if (org->status & LOCKED) {
-				log_error("Snapshots of locked devices are not "
-					  "supported yet");
-				return 0;
-			}
-			if (org->status & MIRROR_IMAGE ||
-			    org->status & MIRROR_LOG ||
-			    org->status & MIRRORED) {
-				log_error("Snapshots and mirrors may not yet "
-					  "be mixed.");
-				return 0;
-			}
-
-			if (!lv_info(cmd, org, &info, 0, 0)) {
-				log_error("Check for existence of snapshot "
-					  "origin '%s' failed.", org->name);
-				return 0;
-			}
-			origin_active = info.exists;
-		}
-	}
-
-	if (!lp->extents) {
-		log_error("Unable to create new logical volume with no extents");
-		return 0;
-	}
-
-	if (!seg_is_virtual(lp) &&
-	    vg->free_count < lp->extents) {
-		log_error("Insufficient free extents (%u) in volume group %s: "
-			  "%u required", vg->free_count, vg->name, lp->extents);
-		return 0;
-	}
-
-	if (lp->stripes > dm_list_size(lp->pvh) && lp->alloc != ALLOC_ANYWHERE) {
-		log_error("Number of stripes (%u) must not exceed "
-			  "number of physical volumes (%d)", lp->stripes,
-			  dm_list_size(lp->pvh));
-		return 0;
-	}
-
-	if (lp->mirrors > 1 && !activation()) {
-		log_error("Can't create mirror without using "
-			  "device-mapper kernel driver.");
-		return 0;
-	}
-
-	/* The snapshot segment gets created later */
-	if (lp->snapshot &&
-	    !(lp->segtype = get_segtype_from_string(cmd, "striped")))
-		return_0;
-
-	if (!archive(vg))
-		return 0;
-
-	if (lp->lv_name)
-		lv_name = lp->lv_name;
-	else {
-		if (!generate_lv_name(vg, "lvol%d", lv_name_buf, sizeof(lv_name_buf))) {
-			log_error("Failed to generate LV name.");
-			return 0;
-		}
-		lv_name = &lv_name_buf[0];
-	}
-
-	if (lp->tag) {
-		if (!(vg->fid->fmt->features & FMT_TAGS)) {
-			log_error("Volume group %s does not support tags",
-				  vg->name);
-			return 0;
-		}
-	}
-
-	if (lp->mirrors > 1) {
-		init_mirror_in_sync(lp->nosync);
-
-		if (lp->nosync) {
-			log_warn("WARNING: New mirror won't be synchronised. "
-				  "Don't read what you didn't write!");
-			status |= MIRROR_NOTSYNCED;
-		}
-	}
-
-	if (!(lv = lv_create_empty(lv_name ? lv_name : "lvol%d", NULL,
-				   status, lp->alloc, vg)))
-		return_0;
-
-	if (lp->read_ahead) {
-		log_verbose("Setting read ahead sectors");
-		lv->read_ahead = lp->read_ahead;
-	}
-
-	if (lp->minor >= 0) {
-		lv->major = lp->major;
-		lv->minor = lp->minor;
-		lv->status |= FIXED_MINOR;
-		log_verbose("Setting device number to (%d, %d)", lv->major,
-			    lv->minor);
-	}
-
-	if (lp->tag && !str_list_add(cmd->mem, &lv->tags, lp->tag)) {
-		log_error("Failed to add tag %s to %s/%s",
-			  lp->tag, lv->vg->name, lv->name);
-		return 0;
-	}
-
-	if (!lv_extend(lv, lp->segtype, lp->stripes, lp->stripe_size,
-		       1, lp->extents, NULL, 0u, 0u, lp->pvh, lp->alloc))
-		return_0;
-
-	if (lp->mirrors > 1) {
-		if (!lv_add_mirrors(cmd, lv, lp->mirrors - 1, lp->stripes,
-				    adjusted_mirror_region_size(
-						vg->extent_size,
-						lv->le_count,
-						lp->region_size),
-				    lp->corelog ? 0U : 1U, lp->pvh, lp->alloc,
-				    MIRROR_BY_LV |
-				    (lp->nosync ? MIRROR_SKIP_INIT_SYNC : 0))) {
-			stack;
-			goto revert_new_lv;
-		}
-	}
-
-	/* store vg on disk(s) */
-	if (!vg_write(vg) || !vg_commit(vg))
-		return_0;
-
-	backup(vg);
-
-	if (lp->snapshot) {
-		if (!activate_lv_excl(cmd, lv)) {
-			log_error("Aborting. Failed to activate snapshot "
-				  "exception store.");
-			goto revert_new_lv;
-		}
-	} else if (!activate_lv(cmd, lv)) {
-		if (lp->zero) {
-			log_error("Aborting. Failed to activate new LV to wipe "
-				  "the start of it.");
-			goto deactivate_and_revert_new_lv;
-		}
-		log_error("Failed to activate new LV.");
-		return 0;
-	}
-
-	if (!lp->zero && !lp->snapshot)
-		log_error("WARNING: \"%s\" not zeroed", lv->name);
-	else if (!set_lv(cmd, lv, UINT64_C(0), 0)) {
-		log_error("Aborting. Failed to wipe %s.",
-			  lp->snapshot ? "snapshot exception store" :
-					 "start of new LV");
-		goto deactivate_and_revert_new_lv;
-	}
-
-	if (lp->snapshot) {
-		/* Reset permission after zeroing */
-		if (!(lp->permission & LVM_WRITE))
-			lv->status &= ~LVM_WRITE;
-
-		/* COW area must be deactivated if origin is not active */
-		if (!origin_active && !deactivate_lv(cmd, lv)) {
-			log_error("Aborting. Couldn't deactivate snapshot "
-				  "COW area. Manual intervention required.");
-			return 0;
-		}
-
-		/* A virtual origin must be activated explicitly. */
-		if (lp->voriginsize &&
-		    (!(org = _create_virtual_origin(cmd, vg, lv->name,
-						    lp->permission,
-						    lp->voriginextents)) ||
-		     !activate_lv(cmd, org))) {
-			log_error("Couldn't create virtual origin for LV %s",
-				  lv->name);
-			if (org && !lv_remove(org))
-				stack;
-			goto deactivate_and_revert_new_lv;
-		}
-
-		/* cow LV remains active and becomes snapshot LV */
-
-		if (!vg_add_snapshot(org, lv, NULL,
-				     org->le_count, lp->chunk_size)) {
-			log_error("Couldn't create snapshot.");
-			goto deactivate_and_revert_new_lv;
-		}
-
-		/* store vg on disk(s) */
-		if (!vg_write(vg))
-			return_0;
-
-		if (!suspend_lv(cmd, org)) {
-			log_error("Failed to suspend origin %s", org->name);
-			vg_revert(vg);
-			return 0;
-		}
-
-		if (!vg_commit(vg))
-			return_0;
-
-		if (!resume_lv(cmd, org)) {
-			log_error("Problem reactivating origin %s", org->name);
-			return 0;
-		}
-	}
-	/* FIXME out of sequence */
-	backup(vg);
-
-	log_print("Logical volume \"%s\" created", lv->name);
-
-	/*
-	 * FIXME: as a sanity check we could try reading the
-	 * last block of the device ?
-	 */
-
-	return 1;
-
-deactivate_and_revert_new_lv:
-	if (!deactivate_lv(cmd, lv)) {
-		log_error("Unable to deactivate failed new LV. "
-			  "Manual intervention required.");
-		return 0;
-	}
-
-revert_new_lv:
-	/* FIXME Better to revert to backup of metadata? */
-	if (!lv_remove(lv) || !vg_write(vg) || !vg_commit(vg))
-		log_error("Manual intervention may be required to remove "
-			  "abandoned LV(s) before retrying.");
-	else
-		backup(vg);
-
-	return 0;
-}
-
 int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 {
 	int r = ECMD_PROCESSED;
@@ -1032,7 +617,7 @@
 	if (!_update_extents_params(vg, &lp, &lcp))
 		return ECMD_FAILED;
 
-	if (!_lvcreate(vg, &lp))
+	if (!lv_create_single(vg, &lp))
 		r = ECMD_FAILED;
 
 	unlock_and_release_vg(cmd, vg, lp.vg_name);


