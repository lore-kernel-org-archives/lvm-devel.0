From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Nov 2013 20:09:32 +0000 (UTC)
Subject: master - tests: add WARNED test to final list
Message-ID: <20131122200932.40F6060E20@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=47110f7e27ce2a4bf329e860cf6eb339d107fde7
Commit:        47110f7e27ce2a4bf329e860cf6eb339d107fde7
Parent:        b8f72c0f2c41fa76bdd3f4c0d73cf31dc9ce9b88
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 21 10:41:08 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 22 21:00:56 2013 +0100

tests: add WARNED test to final list

WARNED result should not be forgotten - it's supposed
to be fixed...

keep enum alphabetically sorted
---
 test/lib/harness.c |   25 ++++++++++++++-----------
 1 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index 8c9f4a7..dca0198 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -65,13 +65,13 @@ static struct subst subst[2];
 
 enum {
 	UNKNOWN,
-	PASSED,
-	SKIPPED,
 	FAILED,
-	WARNED,
-	KNOWNFAIL,
 	INTERRUPTED,
+	KNOWNFAIL,
+	PASSED,
+	SKIPPED,
 	TIMEOUT,
+	WARNED,
 };
 
 static void handler( int sig ) {
@@ -511,12 +511,12 @@ int main(int argc, char **argv) {
 	if ((list = fopen(results_list, "w"))) {
 		for (i = 1; i < argc; ++ i) {
 			switch (s.status[i]) {
-			case PASSED: result = "passed"; break;
 			case FAILED: result = "failed"; break;
+			case INTERRUPTED: result = "interrupted"; break;
+			case PASSED: result = "passed"; break;
 			case SKIPPED: result = "skipped"; break;
-			case WARNED: result = "warnings"; break;
 			case TIMEOUT: result = "timeout"; break;
-			case INTERRUPTED: result = "interrupted"; break;
+			case WARNED: result = "warnings"; break;
 			default: result = "unknown"; break;
 			}
 			fprintf(list, "%s %s\n", argv[i], result);
@@ -526,24 +526,27 @@ int main(int argc, char **argv) {
 		perror("fopen result");
 
 	/* print out a summary */
-	if (s.nfailed || s.nskipped || s.nknownfail || s.ninterrupted) {
+	if (s.nfailed || s.nskipped || s.nknownfail || s.ninterrupted || s.nwarned) {
 		for (i = 1; i < argc; ++ i) {
 			switch (s.status[i]) {
 			case FAILED:
 				printf("FAILED: %s\n", argv[i]);
 				break;
+			case INTERRUPTED:
+				printf("INTERRUPTED: %s\n", argv[i]);
+				break;
 			case KNOWNFAIL:
 				printf("FAILED (expected): %s\n", argv[i]);
 				break;
 			case SKIPPED:
 				printf("skipped: %s\n", argv[i]);
 				break;
-			case INTERRUPTED:
-				printf("INTERRUPTED: %s\n", argv[i]);
-				break;
 			case TIMEOUT:
 				printf("TIMEOUT: %s\n", argv[i]);
 				break;
+			case WARNED:
+				printf("WARNED: %s\n", argv[i]);
+				break;
 			default: /* do nothing */ ;
 			}
 		}


