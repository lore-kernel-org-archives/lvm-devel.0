From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 5 Nov 2018 11:27:18 -0500
Subject: master - cov: explicit ignore if failures
Message-ID: <201811051627.wA5GRIm9005403@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bc1976011adb51951dc0280817b2c047ab22ac7c
Commit:        bc1976011adb51951dc0280817b2c047ab22ac7c
Parent:        79879bd201d4156312bb03fc0b7228ce34a3bf38
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 1 15:38:30 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 3 16:09:36 2018 +0100

cov: explicit ignore if failures

Here we can't do anything better than just ignore syscall failures
(with silence as there is no loging mechanism)
---
 scripts/generator-internals.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/scripts/generator-internals.c b/scripts/generator-internals.c
index 00a15e5..5acc969 100644
--- a/scripts/generator-internals.c
+++ b/scripts/generator-internals.c
@@ -42,18 +42,18 @@ static bool _open_child(struct child_process *child, const char *cmd, const char
 
 	child->pid = fork();
 	if (child->pid < 0) {
-		close(pipe_fd[0]);
-		close(pipe_fd[1]);
+		(void) close(pipe_fd[0]);
+		(void) close(pipe_fd[1]);
 		_error("call to fork() failed: %d\n", r);
 		return false;
 	}
 
 	if (child->pid == 0) {
 		// child
-		close(pipe_fd[0]);
+		(void) close(pipe_fd[0]);
 		if (pipe_fd[1] != STDOUT_FILENO) {
-			dup2(pipe_fd[1], STDOUT_FILENO);
-			close(pipe_fd[1]);
+			(void) dup2(pipe_fd[1], STDOUT_FILENO);
+			(void) close(pipe_fd[1]);
 		}
 
 		if (execv(cmd, (char *const *) argv) < 0)
@@ -62,7 +62,7 @@ static bool _open_child(struct child_process *child, const char *cmd, const char
 		exit(1);
 	} else {
 		// parent
-		close(pipe_fd[1]);
+		(void) close(pipe_fd[1]);
 		child->fp = fdopen(pipe_fd[0], "r");
 		if (!child->fp) {
 			_error("call to fdopen() failed\n");
@@ -78,7 +78,7 @@ static bool _close_child(struct child_process *child)
 {
 	int status;
 
-	fclose(child->fp);
+	(void) fclose(child->fp);
 
 	while (waitpid(child->pid, &status, 0) < 0)
 		if (errno != EINTR)


