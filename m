From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  4 Dec 2013 18:53:11 +0000 (UTC)
Subject: master - tests: reuse timeout code for too long debug.log
Message-ID: <20131204185311.56C746066D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e06cfd74373ae7928ef2a340b00e9bc3da8753ca
Commit:        e06cfd74373ae7928ef2a340b00e9bc3da8753ca
Parent:        c144305d3e6b68bc9f85641a5038013fdc07b5a2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 4 19:48:29 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 4 19:48:29 2013 +0100

tests: reuse timeout code for too long debug.log

Jump to the same code used for timeout when no output
is made for long time.

Increase the allowed debug.log size to 32MB.
---
 test/lib/harness.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index 47a331d..bcc6b97 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -401,6 +401,7 @@ static void run(int i, char *f) {
 			    (no_write > 180 * 2)) /* a 3 minute timeout */
 			{
 				system("echo t > /proc/sysrq-trigger");
+			timeout:
 				kill(pid, SIGINT);
 				sleep(5); /* wait a bit for a reaction */
 				if ((w = waitpid(pid, &st, WNOHANG)) == 0) {
@@ -418,10 +419,10 @@ static void run(int i, char *f) {
 			if (select(fds[0] + 1, &set, NULL, NULL, &selectwait) <= 0) {
 				/* Still checking debug log size if it's not growing too much */
 				if (testdirdebug[0] && (stat(testdirdebug, &statbuf) == 0) &&
-				    statbuf.st_size > 8 * 1024 * 1024) { /* 8MB command log size */
-					fprintf(stderr, "Killing test since debug.log has gone wild (size %ld)\n",
-						statbuf.st_size);
-					kill(-pid, SIGINT);
+				    statbuf.st_size > 32 * 1024 * 1024) { /* 32MB command log size */
+					printf("Killing test since debug.log has gone wild (size %ld)\n",
+					       statbuf.st_size);
+					goto timeout;
 				}
 
 				no_write++;


