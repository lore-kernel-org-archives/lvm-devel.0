From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 17 Dec 2013 10:08:00 +0000 (UTC)
Subject: dev-dct-process-v5 - test: Make the harness optionally less verbose (QUIET=1).
Message-ID: <20131217100800.684A160A36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=612a615fa641dfbc786dfeeb09637ba8c30aca93
Commit:        612a615fa641dfbc786dfeeb09637ba8c30aca93
Parent:        c418f942050674b97094e1ab9f38585b93daac29
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Dec 15 16:36:24 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Dec 17 11:07:25 2013 +0100

test: Make the harness optionally less verbose (QUIET=1).

---
 test/lib/harness.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index 9f93717..19859a0 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -54,6 +54,7 @@ static size_t readbuf_sz = 0, readbuf_used = 0;
 static int die = 0;
 static int verbose = 0; /* >1 with timestamps */
 static int interactive = 0; /* disable all redirections */
+static int quiet = 0;
 static const char *results;
 static unsigned fullbuffer = 0;
 static int unlimited = 0;
@@ -316,7 +317,7 @@ static void interrupted(int i, char *f) {
 	++ s.ninterrupted;
 	s.status[i] = INTERRUPTED;
 	printf("\ninterrupted.\n");
-	if (!verbose && fullbuffer) {
+	if (!quiet && !verbose && fullbuffer) {
 		printf("-- Interrupted %s ------------------------------------\n", f);
 		dump();
 		printf("\n-- Interrupted %s (end) ------------------------------\n", f);
@@ -327,7 +328,7 @@ static void timeout(int i, char *f) {
 	++ s.ninterrupted;
 	s.status[i] = TIMEOUT;
 	printf("timeout.\n");
-	if (!verbose && readbuf) {
+	if (!quiet && !verbose && readbuf) {
 		printf("-- Timed out %s ------------------------------------\n", f);
 		dump();
 		printf("\n-- Timed out %s (end) ------------------------------\n", f);
@@ -351,7 +352,7 @@ static void failed(int i, char *f, int st) {
 	++ s.nfailed;
 	s.status[i] = FAILED;
 	printf("FAILED  (status %d).\n", WEXITSTATUS(st));
-	if (!verbose && readbuf) {
+	if (!quiet && !verbose && readbuf) {
 		printf("-- FAILED %s ------------------------------------\n", f);
 		dump();
 		printf("-- FAILED %s (end) ------------------------------\n", f);
@@ -500,7 +501,8 @@ int main(int argc, char **argv) {
 	char results_list[PATH_MAX];
 	const char *result;
 	const char *be_verbose = getenv("VERBOSE"),
-		   *be_interactive = getenv("INTERACTIVE");
+		   *be_interactive = getenv("INTERACTIVE"),
+		   *be_quiet = getenv("QUIET");;
 	time_t start = time(NULL);
 	int i;
 	FILE *list;
@@ -516,6 +518,9 @@ int main(int argc, char **argv) {
 	if (be_interactive)
 		interactive = atoi(be_interactive);
 
+	if (be_quiet)
+		quiet = atoi(be_quiet);
+
 	results = getenv("LVM_TEST_RESULTS") ? : "results";
 	unlimited = getenv("LVM_TEST_UNLIMITED") ? 1 : 0;
 	(void) snprintf(results_list, sizeof(results_list), "%s/list", results);


