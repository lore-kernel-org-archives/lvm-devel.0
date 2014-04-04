From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  4 Apr 2014 00:50:50 +0000 (UTC)
Subject: master - lvmetad: Update retry logic vars and comments.
Message-ID: <20140404005050.4DEF9608F0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b38a3d8c85a5ce96ccbac4e5be859d53a2ec4c35
Commit:        b38a3d8c85a5ce96ccbac4e5be859d53a2ec4c35
Parent:        d36f721bb984c16bd20733325be0d9fc73706709
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Apr 4 01:46:53 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Apr 4 01:46:53 2014 +0100

lvmetad: Update retry logic vars and comments.

Avoid using variables with same name as functions.
Use lvm_even_rand for random numbers.
---
 lib/cache/lvmetad.c |   53 ++++++++++++++++++++++++++++----------------------
 1 files changed, 30 insertions(+), 23 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 697660f..0dd2c81 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -22,6 +22,9 @@
 #include "format-text.h" // TODO for disk_locn, used as a DA representation
 #include "crc.h"
 
+#define SCAN_TIMEOUT_SECONDS	80
+#define MAX_RESCANS		10	/* Maximum number of times to scan all PVs and retry if the daemon returns a token mismatch error */
+
 static daemon_handle _lvmetad;
 static int _lvmetad_use = 0;
 static int _lvmetad_connected = 0;
@@ -141,8 +144,10 @@ static daemon_reply _lvmetad_send(const char *id, ...)
 	va_list ap;
 	daemon_reply repl;
 	daemon_request req;
-	int try = 0;
-	int time = 0, wait, sleep = 1;
+	unsigned num_rescans = 0;
+	unsigned total_usecs_waited = 0;
+	unsigned max_remaining_sleep_times = 1;
+	unsigned wait_usecs;
 
 retry:
 	req = daemon_request_make(id);
@@ -158,30 +163,32 @@ retry:
 
 	daemon_request_destroy(req);
 
+	/*
+	 * If another process is trying to scan, it might have the
+	 * same future token id and it's better to wait and avoid doing
+	 * the work multiple times. For the case where the future token is
+	 * different, the wait is randomized so that multiple waiting
+	 * processes do not start scanning all at once.
+	 *
+	 * If the token is mismatched because of global_filter changes,
+	 * we re-scan immediately, but if we lose the potential race for
+	 * the update, we back off for a short while (0.05-0.5 seconds) and
+	 * try again.
+	 */
 	if (!repl.error && !strcmp(daemon_reply_str(repl, "response", ""), "token_mismatch") &&
-	    try < 10 && time < 80000000 && !test_mode()) {
-		/*
-		 * If another process is trying to scan, they might have the
-		 * same future token id and it's better to wait and avoid doing
-		 * the work multiple times. For the case the future token is
-		 * different, the wait is randomized so that multiple waiting
-		 * processes do not start scanning all@once.
-		 *
-		 * If the token is mismatched because of global_filter changes,
-		 * we re-scan immediately, but if we lose the potential race for
-		 * the update, we back off for a short while (0.2-2 seconds) and
-		 * try again.
-		 */
-		if (!strcmp(daemon_reply_str(repl, "expected", ""), "update in progress") || sleep) {
-			wait = 50000 + random() % 450000; /* 0.05 - 0.5s */
-			time += wait;
-			usleep( wait );
-			-- sleep;
+	    num_rescans < MAX_RESCANS && total_usecs_waited < (SCAN_TIMEOUT_SECONDS * 1000000) && !test_mode()) {
+		if (!strcmp(daemon_reply_str(repl, "expected", ""), "update in progress") ||
+		    max_remaining_sleep_times) {
+			wait_usecs = 50000 + lvm_even_rand(&_lvmetad_cmd->rand_seed, 450000); /* between 0.05s and 0.5s */
+			(void) usleep(wait_usecs);
+			total_usecs_waited += wait_usecs;
+			if (max_remaining_sleep_times)
+				max_remaining_sleep_times--;	/* Sleep once before rescanning the first time, then 5 times each time after that. */
 		} else {
 			/* If the re-scan fails here, we try again later. */
-			lvmetad_pvscan_all_devs(_lvmetad_cmd, NULL);
-			++ try;
-			sleep = 5;
+			(void) lvmetad_pvscan_all_devs(_lvmetad_cmd, NULL);
+			num_rescans++;
+			max_remaining_sleep_times = 5;
 		}
 		daemon_reply_destroy(repl);
 		goto retry;


