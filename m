From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 Jul 2016 19:56:12 +0000 (UTC)
Subject: master - lvresize: fix zero size extension
Message-ID: <20160713195612.E6C2260370@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e1112227d19cc252e1404eb4bf44d03e3867e463
Commit:        e1112227d19cc252e1404eb4bf44d03e3867e463
Parent:        3928c96a37941d765bf467d82502cd2aec7fd809
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 13 16:23:25 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 13 21:52:04 2016 +0200

lvresize: fix zero size extension

Commit ca878a3426197b629c76e98cfc049948da470cd7 changed behavior
or resize operation. Later the code has been futher changed
to skip fs resize completely when size of LV is already matching
and finaly at the most recent resize changeset for resize the
check for matching size has been eliminated as well so we ended
with a request call to resize fs to 0 size in some cases.

This commit reoders some test so the prompt happens just once before
resize of possibly 2 related volumes.

Also extra test for having LV already given size is added, and
whole metadata update is skipped for this case as the only
result would be an increment of seqno.

However the filesystem is still resized when requested,
so if the LV has some size and the resize is resolved to
the same size, the filesystem resize is called so in case FS
would not match, the resize will happen.
---
 WHATS_NEW                        |    1 +
 lib/metadata/lv_manip.c          |   88 ++++++++++++++++++++++----------------
 lib/metadata/metadata-exported.h |    1 +
 3 files changed, 53 insertions(+), 37 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5653b13..3ed398c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.161 - 
 ================================
+  Fix lvresize of filesystem when LV has already right size (2.02.141).
   New LVM_LOG_FILE_MAX_LINES env var to limit max size of created logs.
 
 Version 2.02.160 - 6th July 2016
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d11b125..022bb1f 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5130,38 +5130,8 @@ static int _lvresize_volume(struct logical_volume *lv,
 	struct volume_group *vg = lv->vg;
 	struct cmd_context *cmd = vg->cmd;
 	uint32_t old_extents;
-	int status;
 	alloc_policy_t alloc = lp->alloc ? : lv->alloc;
 
-	if ((lp->resize == LV_REDUCE) && (pvh != &vg->pvs))
-		log_print_unless_silent("Ignoring PVs on command line when reducing.");
-
-	/* Request confirmation before operations that are often mistakes. */
-	if ((lp->resizefs || (lp->resize == LV_REDUCE)) &&
-	    !_request_confirmation(lv, lp))
-		return_0;
-
-	if (lp->resizefs) {
-		if (!lp->nofsck &&
-		    !_fsadm_cmd(FSADM_CMD_CHECK, lv, 0, lp->force, &status)) {
-			if (status != FSADM_CHECK_FAILS_FOR_MOUNTED) {
-				log_error("Filesystem check failed.");
-				return 0;
-			}
-			/* some filesystems support online resize */
-		}
-
-		/* FIXME forks here */
-		if ((lp->resize == LV_REDUCE) &&
-		    !_fsadm_cmd(FSADM_CMD_RESIZE, lv, lp->extents, lp->force, NULL)) {
-			log_error("Filesystem resize failed.");
-			return 0;
-		}
-	}
-
-	if (!archive(vg))
-		return_0;
-
 	old_extents = lv->le_count;
 	log_verbose("%sing logical volume %s to %s%s",
 		    (lp->resize == LV_REDUCE) ? "Reduc" : "Extend",
@@ -5187,11 +5157,13 @@ static int _lvresize_volume(struct logical_volume *lv,
 		log_print_unless_silent("Size of logical volume %s unchanged from %s (%" PRIu32 " extents).",
 					display_lvname(lv),
 					display_size(cmd, (uint64_t) old_extents * vg->extent_size), old_extents);
-	else
+	else {
+		lp->size_changed = 1;
 		log_print_unless_silent("Size of logical volume %s changed from %s (%" PRIu32 " extents) to %s (%" PRIu32 " extents).",
 					display_lvname(lv),
 					display_size(cmd, (uint64_t) old_extents * vg->extent_size), old_extents,
 					display_size(cmd, (uint64_t) lv->le_count * vg->extent_size), lv->le_count);
+	}
 
 	return 1;
 }
@@ -5211,10 +5183,10 @@ static int _lvresize_prepare(struct logical_volume **lv,
 	else if (lp->extents && !_lvresize_extents_from_percent(*lv, lp, pvh))
 		return_0;
 
-	if (lp->extents && !_lvresize_adjust_extents(*lv, lp, pvh))
+	if (!_lvresize_adjust_extents(*lv, lp, pvh))
 		return_0;
 
-	if (lp->extents && !_lvresize_check_type(*lv, lp))
+	if (!_lvresize_check_type(*lv, lp))
 		return_0;
 
 	return 1;
@@ -5246,6 +5218,7 @@ int lv_resize(struct logical_volume *lv,
 	struct lvresize_params aux_lp;
 	int activated = 0;
 	int ret = 0;
+	int status;
 
 	if (!_lvresize_check(lv, lp))
 		return_0;
@@ -5271,8 +5244,8 @@ int lv_resize(struct logical_volume *lv,
 		}
 	} else if (lp->poolmetadata_size) {
 		if (!lp->extents && !lp->size) {
-			/* When only --poolmetadatasize give and not --size
-			 * swith directly to resize metadata LV */
+			/* When only --poolmetadatasize given and not --size
+			 * switch directly to resize metadata LV */
 			lv = first_seg(lv)->metadata_lv;
 			lp->size = lp->poolmetadata_size;
 			lp->sign = lp->poolmetadata_sign;
@@ -5287,9 +5260,44 @@ int lv_resize(struct logical_volume *lv,
 	if (aux_lv && !_lvresize_prepare(&aux_lv, &aux_lp, pvh))
 		return_0;
 
+	/* Always should have lp->size or lp->extents */
 	if (!_lvresize_prepare(&lv, lp, pvh))
 		return_0;
 
+	if (((lp->resize == LV_REDUCE) ||
+	     (aux_lv && aux_lp.resize == LV_REDUCE)) &&
+	    (pvh != &vg->pvs))
+		log_print_unless_silent("Ignoring PVs on command line when reducing.");
+
+	/* Request confirmation before operations that are often mistakes. */
+	/* aux_lv never resize fs */
+	if ((lp->resizefs || (lp->resize == LV_REDUCE)) &&
+	    !_request_confirmation(lv, lp))
+		return_0;
+
+	if (lp->resizefs) {
+		if (!lp->nofsck &&
+		    !_fsadm_cmd(FSADM_CMD_CHECK, lv, 0, lp->force, &status)) {
+			if (status != FSADM_CHECK_FAILS_FOR_MOUNTED) {
+				log_error("Filesystem check failed.");
+				return 0;
+			}
+			/* some filesystems support online resize */
+		}
+
+		/* FIXME forks here */
+		if ((lp->resize == LV_REDUCE) &&
+		    !_fsadm_cmd(FSADM_CMD_RESIZE, lv, lp->extents, lp->force, NULL)) {
+			log_error("Filesystem resize failed.");
+			return 0;
+		}
+	}
+
+	if (!lp->extents && (!aux_lv || !aux_lp.extents)) {
+		lp->extents = lv->le_count;
+		goto out; /* Nothing to do */
+	}
+
 	if (lv_is_thin_pool(lock_lv) &&  /* Lock holder is thin-pool */
 	    !lv_is_active(lock_lv)) {
 
@@ -5322,12 +5330,15 @@ int lv_resize(struct logical_volume *lv,
 	if (!lockd_lv(cmd, lock_lv, "ex", 0))
 		return_0;
 
+	if (!archive(vg))
+		return_0;
+
 	if (aux_lv) {
 		if (!_lvresize_volume(aux_lv, &aux_lp, pvh))
 			goto_bad;
 
 		/* store vg on disk(s) */
-		if (!lv_update_and_reload(lock_lv))
+		if (aux_lp.size_changed && !lv_update_and_reload(lock_lv))
 			goto_bad;
 	}
 
@@ -5335,6 +5346,9 @@ int lv_resize(struct logical_volume *lv,
 		goto_bad;
 
 	/* store vg on disk(s) */
+	if (!lp->size_changed)
+		goto out; /* No table reload needed */
+
 	if (!lv_update_and_reload(lock_lv))
 		goto_bad;
 
@@ -5349,7 +5363,7 @@ int lv_resize(struct logical_volume *lv,
 
 		backup(vg);
 	}
-
+out:
 	log_print_unless_silent("Logical volume %s successfully resized.",
 				display_lvname(lv));
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 7765d23..84b510b 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -637,6 +637,7 @@ struct lvresize_params {
 
 	int approx_alloc;
 	int extents_are_pes;	/* Is 'extents' counting PEs or LEs? */
+	int size_changed;	/* Was there actually a size change */
 };
 
 void pvcreate_params_set_defaults(struct pvcreate_params *pp);


