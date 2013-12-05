From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 Dec 2013 11:41:17 +0000 (UTC)
Subject: master - tests: sysrq only when stuck with no output.
Message-ID: <20131205114117.8E40660F2E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b494881e685da3ada4a42a17a33d4fe67f3ca784
Commit:        b494881e685da3ada4a42a17a33d4fe67f3ca784
Parent:        c7b733cd6cbc69e4a681b17ca4e89eb9fcd6d31f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 5 12:32:27 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 5 12:40:47 2013 +0100

tests: sysrq only when stuck with no output.

If we are stuck in user for too long without output,
grab kernel stack traces.
If we just produce too many lines of output, it's
not probably kernel related bug.
---
 test/lib/harness.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index 5591f77..c4dd3da 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -406,11 +406,18 @@ static void run(int i, char *f) {
 			if ((fullbuffer && fullbuffer++ == 8000) ||
 			    (no_write > 180 * 2)) /* a 3 minute timeout */
 			{
-				system("echo t > /proc/sysrq-trigger");
 			timeout:
 				kill(pid, SIGINT);
 				sleep(5); /* wait a bit for a reaction */
 				if ((w = waitpid(pid, &st, WNOHANG)) == 0) {
+					if (no_write > 180 * 2)
+						/*
+						 * Kernel traces needed, when stuck for
+						 * too long in userspace without producing
+						 * any output, in other case it should be
+						 * user space problem
+						 */
+						system("echo t > /proc/sysrq-trigger");
 					collect_debug = 1;
 					kill(-pid, SIGKILL);
 					w = pid; // waitpid(pid, &st, NULL);


