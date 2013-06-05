From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:00:54 +0000 (UTC)
Subject: dev-mornfall-lvmcache - tools: add common lv_change_activate
Message-ID: <20130605120054.0B75160EBD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a81a2406f18c6ad0802a02892214f56b1bb99c13
Commit:        a81a2406f18c6ad0802a02892214f56b1bb99c13
Parent:        698137ec38a3582954543685bffb1e937ab61c34
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 11 13:51:08 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 12 11:30:07 2013 +0200

tools: add common lv_change_activate

Move common code for changing activation state from
vgchange and lvchange to one function.

Fix the order of checks - so we always implicitelly
activate snapshots and thin volumes in exclusive mode,
and we do not allow local deactivation for them.
---
 WHATS_NEW        |    1 +
 tools/lvchange.c |   42 +++++-------------------------------------
 tools/toollib.c  |   45 +++++++++++++++++++++++++++++++++++++++++++++
 tools/toollib.h  |    2 ++
 tools/vgchange.c |   33 +++------------------------------
 5 files changed, 56 insertions(+), 67 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 11e838e..31c33fe 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add lv_change_activate() for common activation code in vg/lvchange.
   Revert change that allowed identical table reload for RAID.
   New lvchange arg, '--syncaction' allows scrubbing of RAID LVs.
   Improve RAID kernel status retrieval to include sync_action/mismatch_cnt.
diff --git a/tools/lvchange.c b/tools/lvchange.c
index e19e2e7..834ae0f 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -219,44 +219,12 @@ static int _lvchange_activate(struct cmd_context *cmd, struct logical_volume *lv
 	if (lv_is_cow(lv) && !lv_is_virtual_origin(origin_from_cow(lv)))
 		lv = origin_from_cow(lv);
 
-	if (activate == CHANGE_AAY) {
-		if (!lv_passes_auto_activation_filter(cmd, lv))
-			return 1;
-		activate = CHANGE_ALY;
-	}
-
-	if (activate == CHANGE_ALN) {
-		log_verbose("Deactivating logical volume \"%s\" locally",
-			    lv->name);
-		if (!deactivate_lv_local(cmd, lv))
-			return_0;
-	} else if (activate == CHANGE_AN) {
-		log_verbose("Deactivating logical volume \"%s\"", lv->name);
-		if (!deactivate_lv(cmd, lv))
-			return_0;
-	} else {
-		if ((activate == CHANGE_AE) ||
-		    lv_is_origin(lv) ||
-		    lv_is_thin_type(lv)) {
-			log_verbose("Activating logical volume \"%s\" "
-				    "exclusively", lv->name);
-			if (!activate_lv_excl(cmd, lv))
-				return_0;
-		} else if (activate == CHANGE_ALY) {
-			log_verbose("Activating logical volume \"%s\" locally",
-				    lv->name);
-			if (!activate_lv_local(cmd, lv))
-				return_0;
-		} else {
-			log_verbose("Activating logical volume \"%s\"",
-				    lv->name);
-			if (!activate_lv(cmd, lv))
-				return_0;
-		}
+	if ((activate == CHANGE_AAY) &&
+	    !lv_passes_auto_activation_filter(cmd, lv))
+		return 1;
 
-		if (background_polling())
-			lv_spawn_background_polling(cmd, lv);
-	}
+	if (!lv_change_activate(cmd, lv, activate))
+		return_0;
 
 	return 1;
 }
diff --git a/tools/toollib.c b/tools/toollib.c
index f00988a..950ca33 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1296,6 +1296,51 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 	return 1;
 }
 
+/* Shared code for changing activation state for vgchange/lvchange */
+int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
+		       activation_change_t activate)
+{
+	if (activate == CHANGE_AN) {
+		log_verbose("Deactivating logical volume \"%s\"", lv->name);
+		if (!deactivate_lv(cmd, lv))
+			return_0;
+		return 1;
+	} else if ((activate == CHANGE_AE) ||
+		   lv_is_origin(lv) ||
+		   lv_is_thin_type(lv)) {
+		if (activate == CHANGE_ALN) {
+			/* origin or thin, all others have _AE */
+			/* other types of activation are implicitly exclusive */
+			/* Note: the order of tests is mandatory */
+			log_error("Cannot deactivate \"%s\" locally.", lv->name);
+			return 0;
+		}
+		log_verbose("Activating logical volume \"%s\" exclusively.", lv->name);
+		if (!activate_lv_excl(cmd, lv))
+			return_0;
+	} else if (activate == CHANGE_ALN) {
+		log_verbose("Deactivating logical volume \"%s\" locally.", lv->name);
+		if (!deactivate_lv_local(cmd, lv))
+			return_0;
+		return 1;
+	} else if ((activate == CHANGE_ALY) || (activate == CHANGE_AAY)) {
+		log_verbose("Activating logical volume \"%s\" locally.", lv->name);
+		if (!activate_lv_local(cmd, lv))
+			return_0;
+	} else { /* CHANGE_AY */
+		log_verbose("Activating logical volume \"%s\".", lv->name);
+		if (!activate_lv(cmd, lv))
+			return_0;
+	}
+
+	/* CHANGE_AN/ALN is not getting here */
+	if (background_polling() &&
+	    (lv->status & (PVMOVE|CONVERTING|MERGING)))
+		lv_spawn_background_polling(cmd, lv);
+
+	return 1;
+}
+
 int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	int r = 0;
diff --git a/tools/toollib.h b/tools/toollib.h
index 2ca7951..d2fd9ac 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -101,6 +101,8 @@ void vgcreate_params_set_defaults(struct vgcreate_params *vp_def,
 int vgcreate_params_set_from_args(struct cmd_context *cmd,
 				  struct vgcreate_params *vp_new,
 				  struct vgcreate_params *vp_def);
+int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
+		       activation_change_t activate);
 int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv);
 int vg_refresh_visible(struct cmd_context *cmd, struct volume_group *vg);
 void lv_spawn_background_polling(struct cmd_context *cmd,
diff --git a/tools/vgchange.c b/tools/vgchange.c
index ccf31da..5c0a6fc 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -131,44 +131,17 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			continue;
 		}
 
-		if (activate == CHANGE_AAY && !lv_passes_auto_activation_filter(cmd, lv))
+		if ((activate == CHANGE_AAY) &&
+		    !lv_passes_auto_activation_filter(cmd, lv))
 			continue;
 
 		expected_count++;
 
-		if (activate == CHANGE_AN) {
-			if (!deactivate_lv(cmd, lv)) {
-				stack;
-				continue;
-			}
-		} else if (activate == CHANGE_ALN) {
-			if (!deactivate_lv_local(cmd, lv)) {
-				stack;
-				continue;
-			}
-		} else if ((activate == CHANGE_AE) ||
-			   lv_is_origin(lv) ||
-			   lv_is_thin_type(lv)) {
-			/* FIXME: duplicated test code with lvchange */
-			if (!activate_lv_excl(cmd, lv)) {
-				stack;
-				continue;
-			}
-		} else if (activate == CHANGE_AAY || activate == CHANGE_ALY) {
-			if (!activate_lv_local(cmd, lv)) {
-				stack;
-				continue;
-			}
-		} else if (!activate_lv(cmd, lv)) {
+		if (!lv_change_activate(cmd, lv, activate)) {
 			stack;
 			continue;
 		}
 
-		if (background_polling() &&
-		    activate != CHANGE_AN && activate != CHANGE_ALN &&
-		    (lv->status & (PVMOVE|CONVERTING|MERGING)))
-			lv_spawn_background_polling(cmd, lv);
-
 		count++;
 	}
 


