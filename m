From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 25 Mar 2014 15:39:12 +0000 (UTC)
Subject: master - lvmetad: Wait at least 80s for the initial scan.
Message-ID: <20140325153912.1E68F60DAA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c13f5dbb2521901f723d4c40fd5992ee0b992d8d
Commit:        c13f5dbb2521901f723d4c40fd5992ee0b992d8d
Parent:        65bbfdf74ddbb16579c4fa5fc76e1f51aee0da22
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Mar 25 15:53:36 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Mar 25 16:38:35 2014 +0100

lvmetad: Wait at least 80s for the initial scan.

---
 lib/cache/lvmetad.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 040a790..3ee850c 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -142,6 +142,7 @@ static daemon_reply _lvmetad_send(const char *id, ...)
 	daemon_reply repl;
 	daemon_request req;
 	int try = 0;
+	int time = 0, wait;
 
 retry:
 	req = daemon_request_make(id);
@@ -158,7 +159,7 @@ retry:
 	daemon_request_destroy(req);
 
 	if (!repl.error && !strcmp(daemon_reply_str(repl, "response", ""), "token_mismatch") &&
-	    try < 60 && !test_mode()) {
+	    try < 10 && time < 80000000 && !test_mode()) {
 		/*
 		 * If another process is trying to scan, they might have the
 		 * same future token id and it's better to wait and avoid doing
@@ -171,12 +172,15 @@ retry:
 		 * the update, we back off for a short while (0.2-2 seconds) and
 		 * try again.
 		 */
-		if (!strcmp(daemon_reply_str(repl, "expected", ""), "update in progress") || try % 5)
-			usleep( 50000 + random() % 450000 ); /* 0.05 - 0.5s */
-		else
+		if (!strcmp(daemon_reply_str(repl, "expected", ""), "update in progress") || try % 5) {
+			wait = 50000 + random() % 450000; /* 0.05 - 0.5s */
+			time += wait;
+			usleep( wait );
+		} else {
 			/* If the re-scan fails here, we try again later. */
 			lvmetad_pvscan_all_devs(_lvmetad_cmd, NULL);
-		++ try;
+			++ try;
+		}
 		daemon_reply_destroy(repl);
 		goto retry;
 	}


