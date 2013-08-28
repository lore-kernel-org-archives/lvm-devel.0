From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 28 Aug 2013 12:53:53 +0000 (UTC)
Subject: master - test: Make timeouts a little more robust & verbose.
Message-ID: <20130828125353.8386360FCD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c1217e6881f6d679c0589078c00350f00c6bee10
Commit:        c1217e6881f6d679c0589078c00350f00c6bee10
Parent:        9a1da7b262e6284422bedfb565ff46d2ac203027
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Aug 5 21:11:49 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Aug 28 14:53:23 2013 +0200

test: Make timeouts a little more robust & verbose.

---
 test/lib/harness.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index 043ca9b..586c5d3 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -381,13 +381,14 @@ static void run(int i, char *f) {
 		FD_SET(fds[1], &master_set);
 		while ((w = wait4(pid, &st, WNOHANG, &usage)) == 0) {
 			if ((fullbuffer && fullbuffer++ == 8000) ||
-			    time(NULL) - start > 120) // a 2 minute timeout
+			    time(NULL) - start > 5) // a 2 minute timeout
 			{
-				kill(-pid, SIGINT);
+				system("echo t > /proc/sysrq-trigger");
+				kill(pid, SIGINT);
 				sleep(5); /* wait a bit for a reaction */
 				if ((w = waitpid(pid, &st, WNOHANG)) == 0) {
 					kill(-pid, SIGKILL);
-					w = waitpid(pid, &st, NULL);
+					w = pid; // waitpid(pid, &st, NULL);
 				}
 				drain();
 				runaway = 1;


