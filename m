From: David Teigland <teigland@sourceware.org>
Date: Mon, 10 Jun 2019 11:36:55 -0400
Subject: master - reset cmd wipe_outdated_pvs
Message-ID: <201906101536.x5AFatxl019420@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a07cc8dbefc26503b27331dcb1e7632c954fb8cb
Commit:        a07cc8dbefc26503b27331dcb1e7632c954fb8cb
Parent:        36cbc6db24f8aa01fb1c1be095b22a672434f754
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 10 10:33:41 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 10 10:34:58 2019 -0500

reset cmd wipe_outdated_pvs

at the start of a command, which is needed in case the cmd
struct is reused.
---
 lib/cache/lvmcache.c |    2 +-
 tools/lvmcmdline.c   |   10 +++++-----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 9a3a2e3..60dc848 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -2664,7 +2664,7 @@ void lvmcache_del_outdated_devs(struct cmd_context *cmd,
 	struct lvmcache_info *info, *info2;
 
 	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid))) {
-		log_error(INTERNAL_ERROR "lvmcache_get_outdated_devs no vginfo");
+		log_error(INTERNAL_ERROR "lvmcache_del_outdated_devs no vginfo");
 		return;
 	}
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 8091b39..94e527c 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2942,12 +2942,12 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	    !init_filters(cmd, !refresh_done))
 		return_ECMD_FAILED;
 
-	if (arg_is_set(cmd, readonly_ARG))
-		cmd->metadata_read_only = 1;
+	cmd->metadata_read_only = arg_is_set(cmd, readonly_ARG);
+
+	cmd->is_activating = (cmd->command->command_enum == vgchange_activate_CMD) ||
+			     (cmd->command->command_enum == lvchange_activate_CMD);
 
-	if ((cmd->command->command_enum == vgchange_activate_CMD) ||
-	    (cmd->command->command_enum == lvchange_activate_CMD))
-		cmd->is_activating = 1;
+	cmd->wipe_outdated_pvs = 0;
 
 	/*
 	 * Now that all configs, profiles and command lines args are available,


