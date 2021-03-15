From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:09 +0000 (GMT)
Subject: main - config: keep issue_discards in config struct
Message-ID: <20210315101409.3B25D3858D29@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b4dfe026dd38a3d84de48664f357828f05b36da2
Commit:        b4dfe026dd38a3d84de48664f357828f05b36da2
Parent:        fab9987ad73d1de55f21f71fed065525aa4cf4d5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 13 18:33:55 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 14 16:59:24 2021 +0100

config: keep issue_discards in config struct

Avoid quering for this config option and keep it for removing in struct.
Also drop unused cache_vgmetadata variable.
---
 lib/commands/toolcontext.c | 2 ++
 lib/commands/toolcontext.h | 2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index c3de18d7f..92008a641 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -661,6 +661,8 @@ static int _process_config(struct cmd_context *cmd)
 	 */
 	cmd->default_settings.udev_fallback = udev_disabled ? 1 : -1;
 
+	cmd->default_settings.issue_discards = find_config_tree_bool(cmd, devices_issue_discards_CFG, NULL);
+
 	init_retry_deactivation(find_config_tree_bool(cmd, activation_retry_deactivation_CFG, NULL));
 
 	init_activation_checks(find_config_tree_bool(cmd, activation_checks_CFG, NULL));
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 977b31412..a47b7d760 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -39,7 +39,7 @@ struct config_info {
 	int udev_rules;
 	int udev_sync;
 	int udev_fallback;
-	int cache_vgmetadata;
+	int issue_discards;
 	const char *msg_prefix;
 	const char *fmt_name;
 	const char *dmeventd_executable;


