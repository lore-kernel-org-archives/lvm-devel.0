From: David Teigland <teigland@sourceware.org>
Date: Mon, 8 Apr 2019 11:39:38 -0400
Subject: master - pvscan: don't print warning about lvmlockd not running
Message-ID: <201904081539.x38FdchG023012@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f58a70c168f8ac225b0e4e40c2f0e1d1c98357fa
Commit:        f58a70c168f8ac225b0e4e40c2f0e1d1c98357fa
Parent:        0ba316f102ac3fcea48a6e60dfb8c0ddef8d197e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 14 16:25:55 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 5 14:04:42 2019 -0500

pvscan: don't print warning about lvmlockd not running

pvscan --cache ignores shared VGs, so it doesn't need to
consider lvmlockd, and shouldn't include a warning about it.
---
 tools/lvmcmdline.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 44b7724..1e3b1e3 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2714,6 +2714,13 @@ static int _init_lvmlockd(struct cmd_context *cmd)
 	const char *lvmlockd_socket;
 	int use_lvmlockd = find_config_tree_bool(cmd, global_use_lvmlockd_CFG, NULL);
 
+	if (cmd->command->command_enum == pvscan_cache_CMD) {
+		/* pvscan cache ignores shared vgs, it only activates local vgs. */
+		if (use_lvmlockd)
+			log_debug("Ignore lvmlockd for pvscan cache.");
+		return 1;
+	}
+
 	/*
 	 * Think about when/how to enable hints with lvmlockd.
 	 */


