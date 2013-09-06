From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  6 Sep 2013 00:53:23 +0000 (UTC)
Subject: master - toollib: tweak background forking
Message-ID: <20130906005323.CF0EE610D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=10a5838a600bbadfe9e20f686f86ffcd9d0c473e
Commit:        10a5838a600bbadfe9e20f686f86ffcd9d0c473e
Parent:        96880102a3b792cadbfc97e44c09c5714a96ca9e
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Sep 6 01:49:43 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Sep 6 01:49:43 2013 +0100

toollib: tweak background forking

Log what is forked and replace #if 1 with DEBUG_CHILD.
---
 tools/toollib.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 50c43d9..5868ac0 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -44,7 +44,7 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm)
 		.sa_flags = SA_NOCLDSTOP,
 	};
 
-	log_verbose("Forking background process");
+	log_verbose("Forking background process: %s", cmd->cmd_line);
 
 	sigaction(SIGCHLD, &act, NULL);
 
@@ -65,8 +65,10 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm)
 		log_error("Background process failed to setsid: %s",
 			  strerror(errno));
 
-	/* For poll debugging it's best to disable for compilation */
-#if 1
+/* Set this to avoid discarding output from background process */
+/* #define DEBUG_CHILD /* */
+
+#ifndef DEBUG_CHILD
 	if ((null_fd = open(devnull, O_RDWR)) == -1) {
 		log_sys_error("open", devnull);
 		_exit(ECMD_FAILED);
@@ -84,7 +86,8 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm)
 		(void) close(null_fd);
 
 	init_verbose(VERBOSE_BASE_LEVEL);
-#endif
+#endif	/* DEBUG_CHILD */
+
 	strncpy(*cmd->argv, "(lvm2)", strlen(*cmd->argv));
 
 	if (!skip_lvm) {


