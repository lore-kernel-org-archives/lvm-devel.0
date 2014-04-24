From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 24 Apr 2014 21:45:29 +0000 (UTC)
Subject: master - test: configurable write timeout
Message-ID: <20140424214529.BD07660C8E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0ee9d59b48b7b5eb844f6857977641e7a95f7ccb
Commit:        0ee9d59b48b7b5eb844f6857977641e7a95f7ccb
Parent:        448af9ff0ba04bfaeb45c15819f577fef089fd95
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 24 22:44:22 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 24 22:44:22 2014 +0100

test: configurable write timeout

Hard-coded 3 minutes is far too short when investigating problems.
---
 test/lib/harness.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index 7ee45c8..d7e51ee 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -36,6 +36,7 @@ static int fds[2];
 
 #define MAX 1024
 #define MAX_LOG_SIZE (32*1024*1024) /* Default max size of test log */
+#define WRITE_TIMEOUT (180 * 2)	/* 3 minutes */
 
 struct stats {
 	int nfailed;
@@ -59,6 +60,7 @@ static int quiet = 0;
 static const char *results;
 static unsigned fullbuffer = 0;
 static int unlimited = 0;
+static int write_timeout = WRITE_TIMEOUT;
 
 static time_t harness_start;
 
@@ -433,13 +435,13 @@ static void run(int i, char *f) {
 			struct timeval selectwait = { .tv_usec = 500000 }; /* 0.5s */
 
 			if ((fullbuffer && fullbuffer++ == 8000) ||
-			    (no_write > 180 * 2)) /* a 3 minute timeout */
+			    (write_timeout > 0 && no_write > write_timeout)) 
 			{
 			timeout:
 				kill(pid, SIGINT);
 				sleep(5); /* wait a bit for a reaction */
 				if ((w = waitpid(pid, &st, WNOHANG)) == 0) {
-					if (no_write > 180 * 2)
+					if (write_timeout > 0 && no_write > write_timeout)
 						/*
 						 * Kernel traces needed, when stuck for
 						 * too long in userspace without producing
@@ -533,7 +535,8 @@ int main(int argc, char **argv) {
 	const char *result;
 	const char *be_verbose = getenv("VERBOSE"),
 		   *be_interactive = getenv("INTERACTIVE"),
-		   *be_quiet = getenv("QUIET");;
+		   *be_quiet = getenv("QUIET"),
+		   *be_write_timeout = getenv("WRITE_TIMEOUT");
 	time_t start = time(NULL);
 	int i;
 	FILE *list;
@@ -552,6 +555,9 @@ int main(int argc, char **argv) {
 	if (be_quiet)
 		quiet = atoi(be_quiet);
 
+	if (be_write_timeout)
+		write_timeout = atoi(be_write_timeout) * 2;
+
 	results = getenv("LVM_TEST_RESULTS") ? : "results";
 	unlimited = getenv("LVM_TEST_UNLIMITED") ? 1 : 0;
 	(void) snprintf(results_list, sizeof(results_list), "%s/list", results);


