From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Sep 2013 10:21:52 +0000 (UTC)
Subject: master - test: timeout when no write happens since last written line
Message-ID: <20130909102152.B49B660DD9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ac2de55d69605d058bbc7622638331549a0ba5c8
Commit:        ac2de55d69605d058bbc7622638331549a0ba5c8
Parent:        f5832d8c49bfe96d0162d1b59125a169117c52b2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 9 12:14:00 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 9 12:17:11 2013 +0200

test: timeout when no write happens since last written line

Change current test abort after 3 minutes, to abort after 3 minutes
without written output line.
---
 test/lib/harness.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index 53814dc..415093d 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -365,8 +365,9 @@ static void run(int i, char *f) {
 		char outpath[PATH_MAX];
 		char *c = outpath + strlen(results) + 1;
 		struct timeval selectwait;
-		fd_set master_set, copy_set;
+		fd_set set;
 		int runaway = 0;
+		int no_write = 0;
 
 		snprintf(buf, sizeof(buf), "%s ...", f);
 		printf("Running %-60s ", buf);
@@ -377,11 +378,9 @@ static void run(int i, char *f) {
 		if (!(outfile = fopen(outpath, "w")))
 			perror("fopen");
 
-		FD_ZERO(&master_set);
-		FD_SET(fds[1], &master_set);
 		while ((w = wait4(pid, &st, WNOHANG, &usage)) == 0) {
 			if ((fullbuffer && fullbuffer++ == 8000) ||
-			    time(NULL) - start > 180) // a 3 minute timeout
+			    (no_write > 180 * 2)) /* a 3 minute timeout */
 			{
 				system("echo t > /proc/sysrq-trigger");
 				kill(pid, SIGINT);
@@ -394,12 +393,16 @@ static void run(int i, char *f) {
 				break;
 			}
 
-			memcpy(&copy_set, &master_set, sizeof(master_set));
+			FD_ZERO(&set);
+			FD_SET(fds[1], &set);
 			selectwait.tv_sec = 0;
-			selectwait.tv_usec = 500000;
-			if (select(fds[1] + 1, &copy_set, NULL, NULL, &selectwait) <= 0)
+			selectwait.tv_usec = 500000; /* timeout 0.5s */
+			if (select(fds[1] + 1, &set, NULL, NULL, &selectwait) <= 0) {
+				no_write++;
 				continue;
+			}
 			drain();
+			no_write = 0;
 		}
 		if (w != pid) {
 			perror("waitpid");


