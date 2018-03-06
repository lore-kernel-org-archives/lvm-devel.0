From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 6 Mar 2018 09:46:33 -0500
Subject: master - activation: support activation of component LVs
Message-ID: <201803061446.w26EkXNh027154@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=112846ce0b01e5353dfa81979a2d8ccb3e25a900
Commit:        112846ce0b01e5353dfa81979a2d8ccb3e25a900
Parent:        6134a71a906744dec2d602f83915f0adb05e77f7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 28 17:16:17 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 6 15:42:46 2018 +0100

activation: support activation of component LVs

Occasionaly users may need to peek into 'component devices.
Normally lvm2 does not let users activation component.

This patch adds special mode where user can activate
component LV in a 'read-only' mode i.e.:

lvchange -ay vg/pool_tdata

All devices can be deactivated with:

lvchange -an vg  |  vgchange -an....
---
 WHATS_NEW                  |    1 +
 lib/activate/activate.c    |    6 +++++-
 lib/commands/toolcontext.h |    2 ++
 lib/locking/locking.c      |   11 +++++++++++
 tools/lvchange.c           |   27 ++++++++++++++++++++++++++-
 tools/toollib.c            |    3 ++-
 tools/vgchange.c           |    4 +++-
 7 files changed, 50 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9656da7..69345c6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Support activation of component LVs in read-only mode.
   Extend internal library to recognize and work with component LV.
   Skip duplicate check for active LV when prompting for its removal.
   Activate correct lock holding LV when it is cached.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index aa230fe..6333ba9 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2673,7 +2673,11 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 		goto out;
 	}
 
-	if (filter)
+	/* Component LV activation is enforced to be 'read-only' */
+	/* TODO: should not apply for LVs in maintenance mode */
+	if (!lv_is_visible(lv) && lv_is_component(lv)) {
+		laopts->read_only = 1;
+	} else if (filter)
 		laopts->read_only = _passes_readonly_filter(cmd, lv);
 
 	log_debug_activation("Activating %s%s%s%s%s.", display_lvname(lv),
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 3921167..4225c57 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -166,6 +166,8 @@ struct cmd_context {
 	unsigned lv_notify:1;
 	unsigned pv_notify:1;
 	unsigned use_aio:1;
+	unsigned activate_component:1;		/* command activates component LV */
+	unsigned process_component_lvs:1;	/* command processes also component LVs */
 
 	/*
 	 * Filtering.
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 1e1be56..f90bd2d 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -252,6 +252,7 @@ static int _lock_vol(struct cmd_context *cmd, const char *resource,
 	uint32_t lck_type = flags & LCK_TYPE_MASK;
 	uint32_t lck_scope = flags & LCK_SCOPE_MASK;
 	int ret = 0;
+	const struct logical_volume *active_lv;
 
 	block_signals(flags);
 	_lock_memory(cmd, lv_op);
@@ -268,6 +269,16 @@ static int _lock_vol(struct cmd_context *cmd, const char *resource,
 		goto out;
 	}
 
+	/* When trying activating component LV, make sure none of
+	 * sub component LV or  LVs that are using it are active */
+	if (lv && ((lck_type == LCK_READ) || (lck_type == LCK_EXCL)) &&
+	    ((!lv_is_visible(lv) && (active_lv = lv_holder_is_active(lv))) ||
+	     (active_lv = lv_component_is_active(lv)))) {
+		log_error("Activation of logical volume %s is prohibited while logical volume %s is active.",
+			  display_lvname(lv), display_lvname(active_lv));
+		goto out;
+	}
+
 	if (cmd->metadata_read_only && lck_type == LCK_WRITE &&
 	    strcmp(resource, VG_GLOBAL)) {
 		log_error("Operation prohibited while global/metadata_read_only is set.");
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 288b04c..0aac5ac 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1266,6 +1266,11 @@ int lvchange_properties_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
 	int ret;
 
+	if (cmd->activate_component) {
+		log_error("Cannot change LV properties when activating component LVs.");
+		return 0;
+	}
+
 	/*
 	 * A command def rule allows only some options when LV is partial,
 	 * so handles_missing_pvs will only affect those.
@@ -1362,7 +1367,10 @@ static int _lvchange_activate_check(struct cmd_context *cmd,
 				     struct processing_handle *handle,
 				     int lv_is_named_arg)
 {
-	if (!lv_is_visible(lv)) {
+	if (!lv_is_visible(lv) &&
+	    !cmd->activate_component && /* activation of named component LV */
+	    ((first_seg(lv)->status & MERGING) || /* merging already started */
+	     !cmd->process_component_lvs)) { /* deactivation of a component LV */
 		if (lv_is_named_arg)
 			log_error("Operation not permitted on hidden LV %s.", display_lvname(lv));
 		return 0;
@@ -1391,6 +1399,23 @@ int lvchange_activate_cmd(struct cmd_context *cmd, int argc, char **argv)
 	if (do_activate)
 		cmd->lockd_vg_enforce_sh = 1;
 
+	/* When activating, check if given LV is a component LV */
+	if (do_activate) {
+		if ((argc == 1) && is_component_lvname(argv[0])) {
+			/* With single arg with reserved name prompt for component activation */
+			if (arg_is_set(cmd, yes_ARG) ||
+			    (yes_no_prompt("Do you want to activate component LV "
+					   "in read-only mode? [y/n]: ") == 'y')) {
+				log_print_unless_silent("Allowing activation of component LV.");
+				cmd->activate_component = 1;
+			}
+
+			if (sigint_caught())
+				return_ECMD_FAILED;
+		}
+	} else /* Component LVs might be active, support easy deactivation */
+		cmd->process_component_lvs = 1;
+
 	ret = process_each_lv(cmd, argc, argv, NULL, NULL, 0,
 			      NULL, &_lvchange_activate_check, &_lvchange_activate_single);
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 0958f2f..eab6223 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3058,7 +3058,8 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		 * Only let hidden LVs through if --all was used or the LVs 
 		 * were specifically named on the command line.
 		 */
-		if (!lvargs_supplied && !lv_is_visible(lvl->lv) && !arg_is_set(cmd, all_ARG))
+		if (!lvargs_supplied && !lv_is_visible(lvl->lv) && !arg_is_set(cmd, all_ARG) &&
+		    (!cmd->process_component_lvs || !lv_is_component(lvl->lv)))
 			continue;
 
 		/*
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 616a9d3..6d739fe 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -92,7 +92,7 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 
 		lv = lvl->lv;
 
-		if (!lv_is_visible(lv))
+		if (!lv_is_visible(lv) && (!cmd->process_component_lvs || !lv_is_component(lv)))
 			continue;
 
 		/* If LV is sparse, activate origin instead */
@@ -222,6 +222,8 @@ int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 	/* FIXME Move into library where clvmd can use it */
 	if (do_activate)
 		check_current_backup(vg);
+	else /* Component LVs might be active, support easy deactivation */
+		cmd->process_component_lvs = 1;
 
 	if (do_activate && (active = lvs_in_vg_activated(vg))) {
 		log_verbose("%d logical volume(s) in volume group \"%s\" "


