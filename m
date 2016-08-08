From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  8 Aug 2016 10:02:59 +0000 (UTC)
Subject: master - lvmcmdline: do not refresh whole cmd context if profile dropped after processing LVM cmd
Message-ID: <20160808100259.E2E9060960@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=57fa5d4329e9152ff689b510f16a237e2f85c903
Commit:        57fa5d4329e9152ff689b510f16a237e2f85c903
Parent:        76ef2d15d839106adac4d82005d517be05a657eb
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 8 11:57:13 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Aug 8 11:57:13 2016 +0200

lvmcmdline: do not refresh whole cmd context if profile dropped after processing LVM cmd

We don't need to refresh whole cmd context if we drop profile after
processing LVM command - just like we don't refresh cmd context when
we're applying the profile. It's because profiles contain only safe
subset of settings which do not require complete cmd context refresh.

This patch calls process_profilable_config instead of
refresh_toolcontext if there was profile applied for the LVM
command only, not --config which requires toolcontext refresh.
The process_profilable_config just sets proper values based on
values of profilable settings, but it does not do complete
reinitialization of various parts (e.g. filters, logging etc.).
---
 WHATS_NEW          |    1 +
 tools/lvmcmdline.c |    5 ++++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3adc194..4ba8a0c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.163 - 
 =================================
+  Do not refresh whole cmd context if profile dropped after processing LVM cmd.
   Support straightforward lvconvert between striped and raid4 LVs.
   Support straightforward lvconvert between raid1 and mirror LVs.
   Report supported conversions when asked for unsupported raid lvconvert.
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 4ad2ea6..3c3498a 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1734,10 +1734,13 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	config_profile_metadata_cft = remove_config_tree_by_source(cmd, CONFIG_PROFILE_METADATA);
 	cmd->profile_params->global_metadata_profile = NULL;
 
-	if (config_string_cft || config_profile_command_cft || config_profile_metadata_cft) {
+	if (config_string_cft) {
 		/* Move this? */
 		if (!refresh_toolcontext(cmd))
 			stack;
+	} else if (config_profile_command_cft || config_profile_metadata_cft) {
+		if (!process_profilable_config(cmd))
+			stack;
 	}
 
 	if (ret == EINVALID_CMD_LINE && !cmd->is_interactive)


