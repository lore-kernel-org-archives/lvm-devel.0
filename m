From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 19 Mar 2014 00:02:04 +0000 (UTC)
Subject: master - clvmd: avoid resending local sync commands
Message-ID: <20140319000204.3BD8361095@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6a8d3d781112acdddf8fbb671bf9b68837f11c63
Commit:        6a8d3d781112acdddf8fbb671bf9b68837f11c63
Parent:        a6b159e99c18905370c6cfed316f3fa1b189c7ae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 19 00:25:51 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 19 00:47:58 2014 +0100

clvmd: avoid resending local sync commands

Instead of sending repeatedly  LOCAL_SYNC commands to clvmds
like 'lvs', rememeber the last sent commmand, and if there was no other
clvmd command, drop this redundant SYNC call message.

The problem has started with commit:
56cab8cc037fc4d31085705987b3a4c04d5e5938

This introduced correct synchronisation of name, when user requests to know
open_count (needs to wait for udev), however it is also executed for
read-only cases like 'lvs' command.

For now implement very simple solution, which is only monitoring
outgoing clvmd command, and when sequence of LOCAL sync names are
recognized, they are skipped automatically.

TODO:
Future solution might move this variable info 'cmd_context' and
use  'needs_sync' flag also i.e. in file locking code.
---
 WHATS_NEW                     |    1 +
 lib/locking/cluster_locking.c |   10 +++++++++-
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bbc2298..08d5b1d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Skip redundant synchronization calls on local clvmd.
   Use correct PATH_MAX for locking dir path.
   Do not check for backups when when its creation is disabled.
   Don't allow --mergedconfig without --type current in dumpconfig. Fix memleak.
diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index 7cbb8f1..86e6c77 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -301,6 +301,8 @@ static int _cluster_free_request(lvm_response_t * response, int num)
 static int _lock_for_cluster(struct cmd_context *cmd, unsigned char clvmd_cmd,
 			     uint32_t flags, const char *name)
 {
+	/* TODO: convert to global usable solution and move static into cmd */
+	static unsigned char last_clvmd_cmd = 0;
 	int status;
 	int i;
 	char *args;
@@ -360,8 +362,13 @@ static int _lock_for_cluster(struct cmd_context *cmd, unsigned char clvmd_cmd,
 	 * SYNC_NAMES and VG_BACKUP use the VG name directly without prefix.
 	 */
 	if (clvmd_cmd == CLVMD_CMD_SYNC_NAMES) {
-		if (flags & LCK_LOCAL)
+		if (flags & LCK_LOCAL) {
 			node = NODE_LOCAL;
+			if (clvmd_cmd == last_clvmd_cmd) {
+				log_debug("Skipping redundant local sync command.");
+				return 1;
+			}
+		}
 	} else if (clvmd_cmd != CLVMD_CMD_VG_BACKUP) {
 		if (strncmp(name, "P_", 2) &&
 		    (clvmd_cmd == CLVMD_CMD_LOCK_VG ||
@@ -372,6 +379,7 @@ static int _lock_for_cluster(struct cmd_context *cmd, unsigned char clvmd_cmd,
 			node = NODE_REMOTE;
 	}
 
+	last_clvmd_cmd = clvmd_cmd;
 	status = _cluster_request(clvmd_cmd, node, args, len,
 				  &response, &num_responses);
 


