From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 28 Aug 2013 12:53:51 +0000 (UTC)
Subject: master - TEST: Add a timeout to the harness, killing tests after 2 minutes.
Message-ID: <20130828125351.6A90760FCD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9a1da7b262e6284422bedfb565ff46d2ac203027
Commit:        9a1da7b262e6284422bedfb565ff46d2ac203027
Parent:        e72b2d047dd64fca941cc6853c72dfe6b8e52399
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Jul 23 11:42:34 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Aug 28 14:53:23 2013 +0200

TEST: Add a timeout to the harness, killing tests after 2 minutes.

---
 test/lib/harness.c |   50 +++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 39 insertions(+), 11 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index cea9a15..043ca9b 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -71,11 +71,12 @@ enum {
 	WARNED,
 	KNOWNFAIL,
 	INTERRUPTED,
+	TIMEOUT,
 };
 
 static void handler( int sig ) {
 	signal( sig, SIG_DFL );
-	kill( pid, sig );
+	kill( -pid, sig );
 	die = sig;
 }
 
@@ -169,7 +170,7 @@ static void _append_buf(const char *buf, size_t len)
 		if ((readbuf_sz >= MAX_LOG_SIZE) &&
 		    !getenv("LVM_TEST_UNLIMITED")) {
 			if (fullbuffer++ ==  0)
-				kill(pid, SIGINT);
+				kill(-pid, SIGINT);
 			return;
 		}
 		readbuf_sz = readbuf_sz ? 2 * readbuf_sz : 4096;
@@ -293,6 +294,17 @@ static void interrupted(int i, char *f) {
 	}
 }
 
+static void timeout(int i, char *f) {
+	++ s.ninterrupted;
+	s.status[i] = TIMEOUT;
+	printf("timeout.\n");
+	if (!verbose && readbuf) {
+		printf("-- Timed out %s ------------------------------------\n", f);
+		dump();
+		printf("\n-- Timed out %s (end) ------------------------------\n", f);
+	}
+}
+
 static void skipped(int i, char *f) {
 	++ s.nskipped;
 	s.status[i] = SKIPPED;
@@ -341,6 +353,7 @@ static void run(int i, char *f) {
 		} else {
 			strcpy(script, f);
 		}
+		setpgid(0, 0);
 		execlp("bash", "bash", "-noprofile", "-norc", script, NULL);
 		perror("execlp");
 		fflush(stderr);
@@ -351,8 +364,9 @@ static void run(int i, char *f) {
 		char buf[128];
 		char outpath[PATH_MAX];
 		char *c = outpath + strlen(results) + 1;
-		struct timeval timeout;
+		struct timeval selectwait;
 		fd_set master_set, copy_set;
+		int runaway = 0;
 
 		snprintf(buf, sizeof(buf), "%s ...", f);
 		printf("Running %-60s ", buf);
@@ -366,13 +380,24 @@ static void run(int i, char *f) {
 		FD_ZERO(&master_set);
 		FD_SET(fds[1], &master_set);
 		while ((w = wait4(pid, &st, WNOHANG, &usage)) == 0) {
-			if (fullbuffer && fullbuffer++ == 8000)
-				/* Output doesn't won't to stop... */
-				kill(pid, SIGKILL);
+			if ((fullbuffer && fullbuffer++ == 8000) ||
+			    time(NULL) - start > 120) // a 2 minute timeout
+			{
+				kill(-pid, SIGINT);
+				sleep(5); /* wait a bit for a reaction */
+				if ((w = waitpid(pid, &st, WNOHANG)) == 0) {
+					kill(-pid, SIGKILL);
+					w = waitpid(pid, &st, NULL);
+				}
+				drain();
+				runaway = 1;
+				break;
+			}
+
 			memcpy(&copy_set, &master_set, sizeof(master_set));
-			timeout.tv_sec = 0;
-			timeout.tv_usec = 500000;
-			if (select(fds[1] + 1, &copy_set, NULL, NULL, &timeout) <= 0)
+			selectwait.tv_sec = 0;
+			selectwait.tv_usec = 500000;
+			if (select(fds[1] + 1, &copy_set, NULL, NULL, &selectwait) <= 0)
 				continue;
 			drain();
 		}
@@ -381,9 +406,11 @@ static void run(int i, char *f) {
 			exit(206);
 		}
 		drain();
-		if (fullbuffer || (die == 2))
+		if (die == 2)
 			interrupted(i, f);
-		else if (WIFEXITED(st)) {
+		else if (runaway) {
+			timeout(i, f);
+		} else if (WIFEXITED(st)) {
 			if (WEXITSTATUS(st) == 0)
 				passed(i, f, start, &usage);
 			else if (WEXITSTATUS(st) == 200)
@@ -467,6 +494,7 @@ int main(int argc, char **argv) {
 			case FAILED: result = "failed"; break;
 			case SKIPPED: result = "skipped"; break;
 			case WARNED: result = "warnings"; break;
+			case TIMEOUT: result = "timeout"; break;
 			case INTERRUPTED: result = "interrupted"; break;
 			default: result = "unknown"; break;
 			}


