From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 31 Jul 2015 19:14:16 +0000 (UTC)
Subject: master - vgchange/lvchange: allow deactivation without locking
Message-ID: <20150731191416.0972F60354@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=439a579aa2aaf13c2e420b6e7888dbd71d7021c0
Commit:        439a579aa2aaf13c2e420b6e7888dbd71d7021c0
Parent:        649c9d47199feddf7f5b65b5dbe12918ba2b383b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 31 14:11:24 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 31 14:11:24 2015 -0500

vgchange/lvchange: allow deactivation without locking

If locking with lvmlockd has failed, allow LVs to be deactivated.
---
 tools/lvchange.c |    4 +++-
 tools/vgchange.c |    6 ++++--
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 823c36a..22a407a 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1296,7 +1296,9 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 	 */
 	if (arg_count(cmd, activate_ARG) || arg_count(cmd, refresh_ARG)) {
 		cmd->lockd_vg_default_sh = 1;
-		cmd->lockd_vg_enforce_sh = 1;
+		/* Allow deactivating if locks fail. */
+		if (is_change_activating((activation_change_t)arg_uint_value(cmd, activate_ARG, CHANGE_AY)))
+			cmd->lockd_vg_enforce_sh = 1;
 	}
 
 	return process_each_lv(cmd, argc, argv,
diff --git a/tools/vgchange.c b/tools/vgchange.c
index a163cf5..7aecd98 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -204,7 +204,7 @@ int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 	if (vg->system_id && vg->system_id[0] &&
 	    cmd->system_id && cmd->system_id[0] &&
 	    strcmp(vg->system_id, cmd->system_id) &&
-	    is_change_activating(activate)) {
+	    do_activate) {
 		log_error("Cannot activate LVs in a foreign VG.");
 		return ECMD_FAILED;
 	}
@@ -1026,7 +1026,9 @@ static int _lockd_vgchange(struct cmd_context *cmd, int argc, char **argv)
 
 	if (arg_is_set(cmd, activate_ARG) || arg_is_set(cmd, refresh_ARG)) {
 		cmd->lockd_vg_default_sh = 1;
-		cmd->lockd_vg_enforce_sh = 1;
+		/* Allow deactivating if locks fail. */
+		if (is_change_activating((activation_change_t)arg_uint_value(cmd, activate_ARG, CHANGE_AY)))
+			cmd->lockd_vg_enforce_sh = 1;
 	}
 
 	/* Starting a vg lockspace means there are no locks available yet. */


