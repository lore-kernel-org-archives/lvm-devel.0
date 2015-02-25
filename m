From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 25 Feb 2015 20:59:14 +0000 (UTC)
Subject: master - lvchange: deactivate is always possible in foreign vgs
Message-ID: <20150225205914.5747860D6F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dd6a2028316febc4a44785c1cacacea0e53f8f76
Commit:        dd6a2028316febc4a44785c1cacacea0e53f8f76
Parent:        dd0ee35378cc2ff405183fea9a3d970aab96ac63
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 25 11:33:11 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 25 14:58:49 2015 -0600

lvchange: deactivate is always possible in foreign vgs

The only realistic way for a host to have active LVs in a
foreign VG is if the host's system_id (or system_id_source)
is changed while LVs are active.

In this case, the active LVs produce an warning, and access
to the VG is implicitly allowed (without requiring --foreign.)
This allows the active LVs to be deactivated.

In this case, rescanning PVs for the VG offers no benefit.
It is not possible that rescanning would reveal an LV that
is active but wasn't previously in the VG metadata.
---
 lib/commands/toolcontext.h |    1 +
 lib/metadata/metadata.c    |    4 +++-
 tools/lvchange.c           |   20 +++++++++++++++-----
 tools/lvmcmdline.c         |    1 +
 4 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index f491d1c..28f5a2c 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -98,6 +98,7 @@ struct cmd_context {
 	unsigned independent_metadata_areas:1;	/* Active formats have MDAs outside PVs */
 	unsigned unknown_system_id:1;
 	unsigned include_foreign_vgs:1;
+	unsigned include_active_foreign_vgs:1;
 	unsigned error_foreign_vgs:1;
 
 	struct dev_types *dev_types;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index f011af8..5ae3780 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4418,7 +4418,9 @@ static int _access_vg_systemid(struct cmd_context *cmd, struct volume_group *vg)
 	if (lvs_in_vg_activated(vg)) {
 		log_warn("WARNING: Found LVs active in VG %s with foreign system ID \"%s\".  Possible data corruption.",
 			  vg->name, vg->system_id);
-		return 1;
+		if (cmd->include_active_foreign_vgs)
+			return 1;
+		return 0;
 	}
 
 	/*
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 1ed0dd5..b44ef33 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -170,6 +170,18 @@ static int _lvchange_activate(struct cmd_context *cmd, struct logical_volume *lv
 
 	activate = (activation_change_t) arg_uint_value(cmd, activate_ARG, CHANGE_AY);
 
+	/*
+	 * We can get here in the odd case where an LV is already active in
+	 * a foreign VG, which allows the VG to be accessed by lvchange -a
+	 * so the LV can be deactivated.
+	 */
+	if (lv->vg->system_id && cmd->system_id &&
+	    strcmp(lv->vg->system_id, cmd->system_id) &&
+	    is_change_activating(activate)) {
+		log_error("Cannot activate LVs in a foreign VG.");
+		return ECMD_FAILED;
+	}
+
 	if (lv_activation_skip(lv, activate, arg_count(cmd, ignoreactivationskip_ARG)))
 		return 1;
 
@@ -1178,11 +1190,6 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (!update && !arg_count(cmd, refresh_ARG) && !arg_count(cmd, monitor_ARG) && !arg_count(cmd, poll_ARG) &&
-	     arg_count(cmd, activate_ARG) &&
-	     !is_change_activating((activation_change_t) arg_uint_value(cmd, activate_ARG, CHANGE_AY)))
-		cmd->include_foreign_vgs = 1;
-
 	/*
 	 * If --sysinit -aay is used and at the same time lvmetad is used,
 	 * we want to rely on autoactivation to take place. Also, we
@@ -1212,6 +1219,9 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
+	if (arg_is_set(cmd, activate_ARG))
+		cmd->include_active_foreign_vgs = 1;
+
 	return process_each_lv(cmd, argc, argv,
 			       update ? READ_FOR_UPDATE : 0, NULL,
 			       &_lvchange_single);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 7a11183..255fa41 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1077,6 +1077,7 @@ static int _get_settings(struct cmd_context *cmd)
 	cmd->ignore_clustered_vgs = arg_is_set(cmd, ignoreskippedcluster_ARG);
 	cmd->error_foreign_vgs = cmd->command->flags & ENABLE_FOREIGN_VGS ? 0 : 1;
 	cmd->include_foreign_vgs = arg_is_set(cmd, foreign_ARG) ? 1 : 0;
+	cmd->include_active_foreign_vgs = cmd->command->flags & ENABLE_FOREIGN_VGS ? 1 : 0;
 		
 	if (!arg_count(cmd, sysinit_ARG))
 		lvmetad_connect_or_warn();


