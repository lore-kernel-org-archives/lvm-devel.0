From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 31 Jan 2022 13:57:29 +0000 (GMT)
Subject: main - tools: missing sync after deactivation
Message-ID: <20220131135729.23FB0385840B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f8d12913e78e25120ca41d8d6938ec3a423274f5
Commit:        f8d12913e78e25120ca41d8d6938ec3a423274f5
Parent:        e10f67e91728f1e576803df884049ecbd92874d0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 28 17:42:04 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 31 14:55:42 2022 +0100

tools: missing sync after deactivation

Caching of DM states optimisation revealed some missing
synchronisation points.
---
 tools/lvchange.c | 2 ++
 tools/toollib.c  | 4 ++++
 2 files changed, 6 insertions(+)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 0525bc53c..879999766 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -358,6 +358,8 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 	if (monitored != DMEVENTD_MONITOR_IGNORE)
 		init_dmeventd_monitor(monitored);
 	init_mirror_in_sync(0);
+	if (!sync_local_dev_names(cmd))
+		log_warn("Failed to sync local dev names.");
 
 	log_very_verbose("Starting resync of %s%s%s%s %s.",
 			 (active) ? "active " : "",
diff --git a/tools/toollib.c b/tools/toollib.c
index e8873adee..4a131aea8 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -900,6 +900,10 @@ void lv_spawn_background_polling(struct cmd_context *cmd,
 	const char *pvname;
 	const struct logical_volume *lv_mirr = NULL;
 
+	/* Ensure there is nothing waiting on cookie */
+	if (!sync_local_dev_names(cmd))
+		log_warn("Failed to sync local dev names.");
+
 	if (lv_is_pvmove(lv))
 		lv_mirr = lv;
 	else if (lv_is_locked(lv))


