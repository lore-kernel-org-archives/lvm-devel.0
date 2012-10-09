From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  9 Oct 2012 05:52:57 +0000 (UTC)
Subject: master - TEST: When INTERACTIVE=1, allow scripts to control a TTY.
Message-ID: <20121009055257.64BF9241E@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d5f2e6223f90b56fb173997bc2932bc361f54475
Commit:        d5f2e6223f90b56fb173997bc2932bc361f54475
Parent:        138b4e1719324139426d894f666d00b8f5b86965
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Oct 8 20:15:55 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Oct 8 20:35:29 2012 +0200

TEST: When INTERACTIVE=1, allow scripts to control a TTY.

---
 test/lib/harness.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index c1d6774..929bfc8 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -44,6 +44,7 @@ static int readbuf_sz = 0, readbuf_used = 0;
 
 static int die = 0;
 static int verbose = 0; /* >1 with timestamps */
+static int interactive = 0; /* disable all redirections */
 
 struct subst {
 	const char *key;
@@ -278,11 +279,13 @@ static void run(int i, char *f) {
 		perror("Fork failed.");
 		exit(201);
 	} else if (pid == 0) {
-		close(0);
-		dup2(fds[0], 1);
-		dup2(fds[0], 2);
-		close(fds[0]);
-		close(fds[1]);
+		if (!interactive) {
+			close(0);
+			dup2(fds[0], 1);
+			dup2(fds[0], 2);
+			close(fds[0]);
+			close(fds[1]);
+		}
 		execlp("bash", "bash", f, NULL);
 		perror("execlp");
 		fflush(stderr);
@@ -320,7 +323,8 @@ static void run(int i, char *f) {
 }
 
 int main(int argc, char **argv) {
-	const char *be_verbose = getenv("VERBOSE");
+	const char *be_verbose = getenv("VERBOSE"),
+		   *be_interactive = getenv("INTERACTIVE");
 	time_t start = time(NULL);
 	int i;
 
@@ -332,6 +336,9 @@ int main(int argc, char **argv) {
 	if (be_verbose)
 		verbose = atoi(be_verbose);
 
+	if (be_interactive)
+		interactive = atoi(be_interactive);
+
 	if (socketpair(PF_UNIX, SOCK_STREAM, 0, fds)) {
 		perror("socketpair");
 		return 201;


