From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Mar 2014 10:46:00 +0000 (UTC)
Subject: master - lvmetad: Fix an endless wait loop introduced in c13f5dbb.
Message-ID: <20140326104600.B84636104F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a3615f314993f4f898fb3bdc4e53f1548069698f
Commit:        a3615f314993f4f898fb3bdc4e53f1548069698f
Parent:        a2614c686670559b75b01ad9893fbd9338690d9f
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Mar 26 11:42:42 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Mar 26 11:45:28 2014 +0100

lvmetad: Fix an endless wait loop introduced in c13f5dbb.

---
 lib/cache/lvmetad.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 3ee850c..697660f 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -142,7 +142,7 @@ static daemon_reply _lvmetad_send(const char *id, ...)
 	daemon_reply repl;
 	daemon_request req;
 	int try = 0;
-	int time = 0, wait;
+	int time = 0, wait, sleep = 1;
 
 retry:
 	req = daemon_request_make(id);
@@ -172,14 +172,16 @@ retry:
 		 * the update, we back off for a short while (0.2-2 seconds) and
 		 * try again.
 		 */
-		if (!strcmp(daemon_reply_str(repl, "expected", ""), "update in progress") || try % 5) {
+		if (!strcmp(daemon_reply_str(repl, "expected", ""), "update in progress") || sleep) {
 			wait = 50000 + random() % 450000; /* 0.05 - 0.5s */
 			time += wait;
 			usleep( wait );
+			-- sleep;
 		} else {
 			/* If the re-scan fails here, we try again later. */
 			lvmetad_pvscan_all_devs(_lvmetad_cmd, NULL);
 			++ try;
+			sleep = 5;
 		}
 		daemon_reply_destroy(repl);
 		goto retry;


