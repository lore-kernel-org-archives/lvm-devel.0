From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 13 Oct 2013 22:31:02 +0000 (UTC)
Subject: master - tests: harness updates
Message-ID: <20131013223102.40F0D60CFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f8f6bfefe0636880a1d70c8f7c99ff9938eb5eb
Commit:        9f8f6bfefe0636880a1d70c8f7c99ff9938eb5eb
Parent:        851bba258cc6989db78d547b9983c523caae9026
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 11 22:31:57 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 14 00:26:59 2013 +0200

tests: harness updates

Reshape code a bit to make sockepair 'swappable' with plain old pipe
call.

Display status for FAILED error.

Increase buffer to hold always at least 1 page size.

Print error results with capitals.
---
 test/lib/harness.c |   30 ++++++++++++++++--------------
 1 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index 0036502..8c9f4a7 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -173,7 +173,7 @@ static void _append_buf(const char *buf, size_t len)
 				kill(-pid, SIGINT);
 			return;
 		}
-		readbuf_sz = readbuf_sz ? 2 * readbuf_sz : 4096;
+		readbuf_sz = readbuf_sz ? 2 * readbuf_sz : 16384;
 		readbuf = realloc(readbuf, readbuf_sz);
 	}
 
@@ -221,7 +221,7 @@ static const char *_append_with_stamp(const char *buf, int stamp)
 
 static void drain(int fd)
 {
-	char buf[4096];
+	char buf[4096 + 1];
 	const char *bp;
 	int stamp = 0;
 	int sz;
@@ -322,7 +322,7 @@ static void failed(int i, char *f, int st) {
 
 	++ s.nfailed;
 	s.status[i] = FAILED;
-	printf("FAILED.\n");
+	printf("FAILED  (status %d).\n", WEXITSTATUS(st));
 	if (!verbose && readbuf) {
 		printf("-- FAILED %s ------------------------------------\n", f);
 		dump();
@@ -340,12 +340,12 @@ static void run(int i, char *f) {
 		exit(201);
 	} else if (pid == 0) {
 		if (!interactive) {
-			close(0);
-			dup2(fds[0], 1);
-			dup2(fds[0], 2);
-			close(fds[0]);
+			close(STDIN_FILENO);
+			dup2(fds[1], STDOUT_FILENO);
+			dup2(fds[1], STDERR_FILENO);
 			close(fds[1]);
 		}
+		close(fds[0]);
 		if (strchr(f, ':')) {
 			strcpy(flavour, f);
 			*strchr(flavour, ':') = 0;
@@ -372,6 +372,7 @@ static void run(int i, char *f) {
 		FILE *varlogmsg;
 		int fd_vlm = -1;
 
+		//close(fds[1]);
 		snprintf(buf, sizeof(buf), "%s ...", f);
 		printf("Running %-60s ", buf);
 		fflush(stdout);
@@ -404,14 +405,14 @@ static void run(int i, char *f) {
 			}
 
 			FD_ZERO(&set);
-			FD_SET(fds[1], &set);
+			FD_SET(fds[0], &set);
 			selectwait.tv_sec = 0;
 			selectwait.tv_usec = 500000; /* timeout 0.5s */
-			if (select(fds[1] + 1, &set, NULL, NULL, &selectwait) <= 0) {
+			if (select(fds[0] + 1, &set, NULL, NULL, &selectwait) <= 0) {
 				no_write++;
 				continue;
 			}
-			drain(fds[1]);
+			drain(fds[0]);
 			no_write = 0;
 			if (fd_vlm >= 0)
 				drain(fd_vlm);
@@ -420,7 +421,7 @@ static void run(int i, char *f) {
 			perror("waitpid");
 			exit(206);
 		}
-		drain(fds[1]);
+		drain(fds[0]);
 		if (fd_vlm >= 0)
 			drain(fd_vlm);
 		if (die == 2)
@@ -472,12 +473,13 @@ int main(int argc, char **argv) {
 	results = getenv("LVM_TEST_RESULTS") ? : "results";
 	(void) snprintf(results_list, sizeof(results_list), "%s/list", results);
 
+	//if (pipe(fds)) {
 	if (socketpair(PF_UNIX, SOCK_STREAM, 0, fds)) {
 		perror("socketpair");
 		return 201;
 	}
 
-	if (fcntl(fds[1], F_SETFL, O_NONBLOCK ) == -1) {
+	if (fcntl(fds[0], F_SETFL, O_NONBLOCK ) == -1) {
 		perror("fcntl on socket");
 		return 202;
 	}
@@ -537,10 +539,10 @@ int main(int argc, char **argv) {
 				printf("skipped: %s\n", argv[i]);
 				break;
 			case INTERRUPTED:
-				printf("interrupted: %s\n", argv[i]);
+				printf("INTERRUPTED: %s\n", argv[i]);
 				break;
 			case TIMEOUT:
-				printf("timeout: %s\n", argv[i]);
+				printf("TIMEOUT: %s\n", argv[i]);
 				break;
 			default: /* do nothing */ ;
 			}


