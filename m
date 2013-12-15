From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 15 Dec 2013 16:19:13 +0000 (UTC)
Subject: master - test: Make the harness optionally less verbose (QUIET=1).
Message-ID: <20131215161913.ACCBF6104B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=97fbbbc150cdaea359370912a7b5a9a546490e98
Commit:        97fbbbc150cdaea359370912a7b5a9a546490e98
Parent:        d443bfac216a3eedcd752d532f6f90a339681b44
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Dec 15 16:36:24 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Dec 15 16:44:47 2013 +0100

test: Make the harness optionally less verbose (QUIET=1).

---
 test/lib/harness.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index fa174bb..f27fbeb 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -53,6 +53,7 @@ static size_t readbuf_sz = 0, readbuf_used = 0;
 static int die = 0;
 static int verbose = 0; /* >1 with timestamps */
 static int interactive = 0; /* disable all redirections */
+static int quiet = 0;
 static const char *results;
 static unsigned fullbuffer = 0;
 static int unlimited = 0;
@@ -298,7 +299,7 @@ static void interrupted(int i, char *f) {
 	++ s.ninterrupted;
 	s.status[i] = INTERRUPTED;
 	printf("\ninterrupted.\n");
-	if (!verbose && fullbuffer) {
+	if (!quiet && !verbose && fullbuffer) {
 		printf("-- Interrupted %s ------------------------------------\n", f);
 		dump();
 		printf("\n-- Interrupted %s (end) ------------------------------\n", f);
@@ -309,7 +310,7 @@ static void timeout(int i, char *f) {
 	++ s.ninterrupted;
 	s.status[i] = TIMEOUT;
 	printf("timeout.\n");
-	if (!verbose && readbuf) {
+	if (!quiet && !verbose && readbuf) {
 		printf("-- Timed out %s ------------------------------------\n", f);
 		dump();
 		printf("\n-- Timed out %s (end) ------------------------------\n", f);
@@ -333,7 +334,7 @@ static void failed(int i, char *f, int st) {
 	++ s.nfailed;
 	s.status[i] = FAILED;
 	printf("FAILED  (status %d).\n", WEXITSTATUS(st));
-	if (!verbose && readbuf) {
+	if (!quiet && !verbose && readbuf) {
 		printf("-- FAILED %s ------------------------------------\n", f);
 		dump();
 		printf("-- FAILED %s (end) ------------------------------\n", f);
@@ -491,7 +492,8 @@ int main(int argc, char **argv) {
 	char results_list[PATH_MAX];
 	const char *result;
 	const char *be_verbose = getenv("VERBOSE"),
-		   *be_interactive = getenv("INTERACTIVE");
+		   *be_interactive = getenv("INTERACTIVE"),
+		   *be_quiet = getenv("QUIET");;
 	time_t start = time(NULL);
 	int i;
 	FILE *list;
@@ -507,6 +509,9 @@ int main(int argc, char **argv) {
 	if (be_interactive)
 		interactive = atoi(be_interactive);
 
+	if (be_quiet)
+		quiet = atoi(be_quiet);
+
 	results = getenv("LVM_TEST_RESULTS") ? : "results";
 	unlimited = getenv("LVM_TEST_UNLIMITED") ? 1 : 0;
 	(void) snprintf(results_list, sizeof(results_list), "%s/list", results);


