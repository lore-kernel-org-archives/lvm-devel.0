From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Feb 2018 16:20:44 -0500
Subject: master - cleanup: detect dmeventd_executable just once
Message-ID: <201802122120.w1CLKih9023715@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=12fba201be314dd16ea01fc756e39c04c8ba50c3
Commit:        12fba201be314dd16ea01fc756e39c04c8ba50c3
Parent:        4f278324c76c339b59f4c613303573bc64a16272
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 9 23:38:02 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 12 22:14:25 2018 +0100

cleanup: detect  dmeventd_executable just once

Avoid repeating debug messages about dmeventd executable
and just remember it once for whole cmd lifetime.
---
 lib/activate/activate.c    |    5 ++++-
 lib/commands/toolcontext.h |    1 +
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 2328abe..58e6873 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1662,7 +1662,10 @@ static struct dm_event_handler *_create_dm_event_handler(struct cmd_context *cmd
 	if (!(dmevh = dm_event_handler_create()))
 		return_NULL;
 
-	if (dm_event_handler_set_dmeventd_path(dmevh, find_config_tree_str(cmd, dmeventd_executable_CFG, NULL)))
+	if (!cmd->default_settings.dmeventd_executable)
+		cmd->default_settings.dmeventd_executable = find_config_tree_str(cmd, dmeventd_executable_CFG, NULL);
+
+	if (dm_event_handler_set_dmeventd_path(dmevh, cmd->default_settings.dmeventd_executable))
 		goto_bad;
 
 	if (dso && dm_event_handler_set_dso(dmevh, dso))
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 4419daa..3921167 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -42,6 +42,7 @@ struct config_info {
 	int cache_vgmetadata;
 	const char *msg_prefix;
 	const char *fmt_name;
+	const char *dmeventd_executable;
 	uint64_t unit_factor;
 	int cmd_name;		/* Show command name? */
 	mode_t umask;


