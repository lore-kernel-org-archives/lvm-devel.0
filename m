From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  4 Jun 2013 13:58:38 +0000 (UTC)
Subject: master - tests: compilation updates
Message-ID: <20130604135838.9772061043@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c8dda314666437852ffcd515e60433c66702a36e
Commit:        c8dda314666437852ffcd515e60433c66702a36e
Parent:        325ca748bb1abf1ff41cbd83f96b27ee020b4304
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 3 12:09:21 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 4 15:57:18 2013 +0200

tests: compilation updates

---
 test/api/thin_percent.c |    2 +-
 test/lib/harness.c      |   25 +++++++++++++++----------
 2 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/test/api/thin_percent.c b/test/api/thin_percent.c
index ae511df..0df896c 100644
--- a/test/api/thin_percent.c
+++ b/test/api/thin_percent.c
@@ -65,7 +65,7 @@ int main(int argc, char *argv[])
 
 	v = lvm_lv_get_property(lv, "snap_percent");
 	assert(v.is_valid);
-	assert(v.value.integer == PERCENT_INVALID);
+	assert(v.value.integer == (uint64_t) PERCENT_INVALID);
 
 	v = lvm_lv_get_property(lv, "origin");
 	assert(v.is_valid);
diff --git a/test/lib/harness.c b/test/lib/harness.c
index ece36ec..2377116 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -41,7 +41,7 @@ struct stats {
 static struct stats s;
 
 static char *readbuf = NULL;
-static int readbuf_sz = 0, readbuf_used = 0;
+static size_t readbuf_sz = 0, readbuf_used = 0;
 
 static int die = 0;
 static int verbose = 0; /* >1 with timestamps */
@@ -57,11 +57,14 @@ struct subst {
 
 static struct subst subst[2];
 
-#define PASSED 0
-#define SKIPPED 1
-#define FAILED 2
-#define WARNED 3
-#define KNOWNFAIL 4
+enum {
+	UNKNOWN,
+	PASSED,
+	SKIPPED,
+	FAILED,
+	WARNED,
+	KNOWNFAIL,
+};
 
 static void handler( int sig ) {
 	signal( sig, SIG_DFL );
@@ -121,18 +124,18 @@ static int outline(FILE *out, char *buf, int start, int force) {
 static void dump(void) {
 	int counter_last = -1, counter = 0;
 
-	while ( counter < readbuf_used && counter != counter_last ) {
+	while ((counter < (int) readbuf_used) && (counter != counter_last)) {
 		counter_last = counter;
 		counter = outline( stdout, readbuf, counter, 1 );
 	}
 }
 
 static void trickle(FILE *out, int *last, int *counter) {
-	if (*last > readbuf_used) {
+	if (*last > (int) readbuf_used) {
 		*last = -1;
 		*counter = 0;
 	}
-	while ( *counter < readbuf_used && *counter != *last ) {
+	while ((*counter < (int) readbuf_used) && (*counter != *last)) {
 		*last = *counter;
 		*counter = outline( out, readbuf, *counter, 1 );
 	}
@@ -281,6 +284,8 @@ static void failed(int i, char *f, int st) {
 }
 
 static void run(int i, char *f) {
+	char flavour[512], script[512];
+
 	pid = fork();
 	if (pid < 0) {
 		perror("Fork failed.");
@@ -293,7 +298,6 @@ static void run(int i, char *f) {
 			close(fds[0]);
 			close(fds[1]);
 		}
-		char flavour[512], script[512];
 		if (strchr(f, ':')) {
 			strcpy(flavour, f);
 			*strchr(flavour, ':') = 0;
@@ -426,6 +430,7 @@ int main(int argc, char **argv) {
 			case SKIPPED:
 				printf("skipped: %s\n", argv[i]);
 				break;
+			default: /* do nothing */ ;
 			}
 		}
 		printf("\n");


