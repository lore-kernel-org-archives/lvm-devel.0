From: David Teigland <teigland@sourceware.org>
Date: Wed, 13 Feb 2019 16:26:41 -0500
Subject: master - hints: fix recreating hints from pvscan
Message-ID: <201902132126.x1DLQfZd031202@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0aa51a2f6129bf05d9897894a7abae627f05ce45
Commit:        0aa51a2f6129bf05d9897894a7abae627f05ce45
Parent:        3ebce8dbd2d9afc031e0737f8feed796ec7a8df9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 13 15:23:43 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 13 15:23:43 2019 -0600

hints: fix recreating hints from pvscan

When aay was included in the pvscan --cache command,
the activation part was complaining about the unusual
state of the hint file since it had been recreated
just prior.
---
 lib/label/hints.c |   30 +++++++++++++++++++++++++++++-
 lib/label/hints.h |    2 ++
 tools/pvscan.c    |   11 +++++++----
 3 files changed, 38 insertions(+), 5 deletions(-)

diff --git a/lib/label/hints.c b/lib/label/hints.c
index 4fe44b0..a2e7646 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -1026,6 +1026,34 @@ void clear_hint_file(struct cmd_context *cmd)
 }
 
 /*
+ * This is only used at the start of pvscan --cache [-aay] to
+ * set up for recreating the hint file.
+ */
+void pvscan_recreate_hints_begin(struct cmd_context *cmd)
+{
+	/* No commands are using hints. */
+	if (!cmd->enable_hints)
+		return;
+
+	log_debug("pvscan_recreate_hints_begin");
+
+	if (!_touch_hints())
+		return;
+
+	/* limit potential delay blocking on hints lock next */
+	if (!_touch_nohints())
+		stack;
+
+	if (!_lock_hints(LOCK_EX, 0))
+		stack;
+
+	_unlink_nohints();
+
+	if (!_clear_hints(cmd))
+		stack;
+}
+
+/*
  * This is used when pvscan --cache sees a new PV, which
  * means we should refresh hints.  It could catch some case
  * which the other methods of detecting stale hints may miss.
@@ -1136,7 +1164,7 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints, int *newhints,
 	 * so this has to be checked before the cmd->use_hints check.
 	 */
 	if (cmd->pvscan_recreate_hints) {
-		/* clear_hint_file already locked hints ex */
+		/* pvscan_recreate_hints_begin already locked hints ex */
 		/* create new hints after scan */
 		log_debug("get_hints: pvscan recreate");
 		*newhints = NEWHINTS_FILE;
diff --git a/lib/label/hints.h b/lib/label/hints.h
index 469e8c4..0134f1e 100644
--- a/lib/label/hints.h
+++ b/lib/label/hints.h
@@ -37,5 +37,7 @@ int validate_hints(struct cmd_context *cmd, struct dm_list *hints);
 
 void hints_exit(void);
 
+void pvscan_recreate_hints_begin(struct cmd_context *cmd);
+
 #endif
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 098c502..55b6f5f 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -660,17 +660,20 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	if (!argc && !devno_args) {
 		/*
 		 * pvscan --cache removes existing hints and recreates new ones.
-		 * We begin by clearing hints at the start of the command like
-		 * vgcreate would do.  The pvscan_recreate_hints flag is used
-		 * to enable the special case hint recreation in label_scan.
+		 * We begin by clearing hints at the start of the command.
+		 * The pvscan_recreate_hints flag is used to enable the
+		 * special case hint recreation in label_scan.
 		 */
 		cmd->pvscan_recreate_hints = 1;
-		clear_hint_file(cmd);
+		pvscan_recreate_hints_begin(cmd);
 
 		log_verbose("pvscan all devices.");
 		_online_pvid_files_remove();
 		_online_pvscan_all_devs(cmd, NULL, NULL);
 		all_vgs = 1;
+
+		cmd->pvscan_recreate_hints = 0;
+		cmd->use_hints = 0;
 		goto activate;
 	}
 


