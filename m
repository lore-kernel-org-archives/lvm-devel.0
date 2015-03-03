From: David Teigland <teigland@fedoraproject.org>
Date: Tue,  3 Mar 2015 19:22:59 +0000 (UTC)
Subject: master - vgchange: deactivate LVs in foreign VG
Message-ID: <20150303192259.07F69610DA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cccc2b2980f8321e5f8c8b553f50966f7e1b5abc
Commit:        cccc2b2980f8321e5f8c8b553f50966f7e1b5abc
Parent:        926b38c0d73d958e5774082ff17fb2a48e20d32e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 3 13:23:13 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 3 13:23:13 2015 -0600

vgchange: deactivate LVs in foreign VG

Apply the same logic as lvchange, which allows
deactivating LVs in a foreign VG.
---
 tools/vgchange.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 199ee82..38a129f 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -197,6 +197,18 @@ int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 	int do_activate = is_change_activating(activate);
 
 	/*
+	 * We can get here in the odd case where an LV is already active in
+	 * a foreign VG, which allows the VG to be accessed by vgchange -a
+	 * so the LV can be deactivated.
+	 */
+	if (vg->system_id && cmd->system_id &&
+	    strcmp(vg->system_id, cmd->system_id) &&
+	    is_change_activating(activate)) {
+		log_error("Cannot activate LVs in a foreign VG.");
+		return ECMD_FAILED;
+	}
+
+	/*
 	 * Safe, since we never write out new metadata here. Required for
 	 * partial activation to work.
 	 */
@@ -795,6 +807,9 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	if (!update || !update_partial_unsafe)
 		cmd->handles_missing_pvs = 1;
 
+	if (arg_is_set(cmd, activate_ARG))
+		cmd->include_active_foreign_vgs = 1;
+
 	return process_each_vg(cmd, argc, argv, update ? READ_FOR_UPDATE : 0,
 			       NULL, &vgchange_single);
 }


