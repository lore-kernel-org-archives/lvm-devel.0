From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:54:49 -0400
Subject: master - cov: warn about failing sigaction
Message-ID: <201810151554.w9FFsnoh020454@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1bb30a8c27ce73433748b49b5478e6ce2b7d4703
Commit:        1bb30a8c27ce73433748b49b5478e6ce2b7d4703
Parent:        5811fa33bbdb2065966489f334ba9fb1174369ca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 14:15:58 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 14:24:28 2018 +0200

cov: warn about failing sigaction

---
 tools/toollib.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 85d44b3..c2ffa42 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -59,7 +59,8 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm)
 
 	log_verbose("Forking background process from command: %s", cmd->cmd_line);
 
-	sigaction(SIGCHLD, &act, NULL);
+	if (sigaction(SIGCHLD, &act, NULL))
+		log_warn("WARNING: Failed to set SIGCHLD action.");
 
 	if (!skip_lvm)
 		if (!sync_local_dev_names(cmd)) { /* Flush ops and reset dm cookie */


