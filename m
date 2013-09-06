From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  6 Sep 2013 00:53:21 +0000 (UTC)
Subject: master - logging: Write Completed message before resetting.
Message-ID: <20130906005321.B9456610D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=96880102a3b792cadbfc97e44c09c5714a96ca9e
Commit:        96880102a3b792cadbfc97e44c09c5714a96ca9e
Parent:        5face2010dfb4e9fef43b867b4736a90abe51c00
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Sep 6 01:47:41 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Sep 6 01:47:41 2013 +0100

logging: Write Completed message before resetting.

---
 WHATS_NEW          |    1 +
 tools/lvmcmdline.c |    7 +++----
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index abfe0e1..212f4bb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Write Completed debug message before reinstating log defaults after command.
   Skip pvmove of RAID, thin, snapshot, origin, or mirror LVs in a cluster.
   Refresh existing VG before autoactivation (event retrigger/device reappeared).
   Use pvscan -b in udev rules to avoid a deadlock on udev process count limit.
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index c7917ea..116e963 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1190,15 +1190,14 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 			stack;
 	}
 
-	/* FIXME Move this? */
-	cmd->current_settings = cmd->default_settings;
-	_apply_settings(cmd);
-
 	if (ret == EINVALID_CMD_LINE && !_cmdline.interactive)
 		_short_usage(cmd->command->name);
 
 	log_debug("Completed: %s", cmd->cmd_line);
 
+	cmd->current_settings = cmd->default_settings;
+	_apply_settings(cmd);
+
 	/*
 	 * free off any memory the command used.
 	 */


