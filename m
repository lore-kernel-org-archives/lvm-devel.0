From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 28 Aug 2013 22:58:00 +0000 (UTC)
Subject: master - toolcontext: Only reopen stdin if readable.
Message-ID: <20130828225800.3550B60E5D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=78647da1c66106e3e8f310cd37742d196e195c96
Commit:        78647da1c66106e3e8f310cd37742d196e195c96
Parent:        c0f987949b8a0bbbbe7f06694f59f710a73814da
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Aug 28 23:55:14 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Aug 28 23:55:14 2013 +0100

toolcontext: Only reopen stdin if readable.

Don't fail when running lvm commands under versions of nohup that set
up stdin as O_WRONLY!
---
 WHATS_NEW                  |    1 +
 lib/commands/toolcontext.c |   19 +++++++++++++++----
 2 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 71e9fa8..c56be6d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Don't assume stdin file descriptor is readable.
   Avoid unlimited recursion when creating dtree containing inactive pvmove LV.
   Require exactly 3 arguments for lvm2-activation-generator. Remove defaults.
   Disable pvmove of merging or converting logical volumes.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 702a2d8..4f53f0e 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1372,6 +1372,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 {
 	struct cmd_context *cmd;
 	FILE *new_stream;
+	int flags;
 
 #ifdef M_MMAP_MAX
 	mallopt(M_MMAP_MAX, 0);
@@ -1415,7 +1416,10 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 			goto out;
 		}
 
-		if (is_valid_fd(STDIN_FILENO)) {
+		/* nohup might set stdin O_WRONLY ! */
+		if (is_valid_fd(STDIN_FILENO) &&
+		    ((flags = fcntl(STDIN_FILENO, F_GETFL)) > 0) &&
+		    (flags & O_ACCMODE) != O_WRONLY) {
 			if (!_reopen_stream(stdin, STDIN_FILENO, "r", "stdin", &new_stream))
 				goto_out;
 			stdin = new_stream;
@@ -1425,7 +1429,9 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 			}
 		}
 
-		if (is_valid_fd(STDOUT_FILENO)) {
+		if (is_valid_fd(STDOUT_FILENO) &&
+		    ((flags = fcntl(STDOUT_FILENO, F_GETFL)) > 0) &&
+		    (flags & O_ACCMODE) != O_RDONLY) {
 			if (!_reopen_stream(stdout, STDOUT_FILENO, "w", "stdout", &new_stream))
 				goto_out;
 			stdout = new_stream;
@@ -1709,6 +1715,7 @@ void destroy_toolcontext(struct cmd_context *cmd)
 {
 	struct dm_config_tree *cft_cmdline;
 	FILE *new_stream;
+	int flags;
 
 	if (cmd->dump_filter && cmd->filter && cmd->filter->dump &&
 	    !cmd->filter->dump(cmd->filter, 1))
@@ -1741,7 +1748,9 @@ void destroy_toolcontext(struct cmd_context *cmd)
 #ifndef VALGRIND_POOL
 	if (cmd->linebuffer) {
 		/* Reset stream buffering to defaults */
-		if (is_valid_fd(STDIN_FILENO)) {
+		if (is_valid_fd(STDIN_FILENO) &&
+		    ((flags = fcntl(STDIN_FILENO, F_GETFL)) > 0) &&
+		    (flags & O_ACCMODE) != O_WRONLY) {
 			if (_reopen_stream(stdin, STDIN_FILENO, "r", "stdin", &new_stream)) {
 				stdin = new_stream;
 				setlinebuf(stdin);
@@ -1749,7 +1758,9 @@ void destroy_toolcontext(struct cmd_context *cmd)
 				cmd->linebuffer = NULL;	/* Leave buffer in place (deliberate leak) */
 		}
 
-		if (is_valid_fd(STDOUT_FILENO)) {
+		if (is_valid_fd(STDOUT_FILENO) &&
+		    ((flags = fcntl(STDOUT_FILENO, F_GETFL)) > 0) &&
+		    (flags & O_ACCMODE) != O_RDONLY) {
 			if (_reopen_stream(stdout, STDOUT_FILENO, "w", "stdout", &new_stream)) {
 				stdout = new_stream;
 				setlinebuf(stdout);


