From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Feb 2014 14:13:26 +0000 (UTC)
Subject: master - lvmetad: Make token_mismatch handling more robust in the clients.
Message-ID: <20140226141326.97A6560DF3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1769eddde7dcdd16716d646e14487cc1df6a3efc
Commit:        1769eddde7dcdd16716d646e14487cc1df6a3efc
Parent:        4143b284f8871b57b416eeab795489fcc66ed017
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Wed Feb 26 15:11:00 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Wed Feb 26 15:11:00 2014 +0100

lvmetad: Make token_mismatch handling more robust in the clients.

---
 lib/cache/lvmetad.c |   27 +++++++++++++++++++++------
 1 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 61361ed..c994874 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -159,12 +159,27 @@ retry:
 	daemon_request_destroy(req);
 
 	if (!repl.error && !strcmp(daemon_reply_str(repl, "response", ""), "token_mismatch") &&
-	    try < 2 && !test_mode()) {
-		if (lvmetad_pvscan_all_devs(_lvmetad_cmd, NULL)) {
-			++ try;
-			daemon_reply_destroy(repl);
-			goto retry;
-		}
+	    try < 60 && !test_mode()) {
+		/*
+		 * If another process is trying to scan, they might have the
+		 * same future token id and it's better to wait and avoid doing
+		 * the work multiple times. For the case the future token is
+		 * different, the wait is randomized so that multiple waiting
+		 * processes do not start scanning all@once.
+		 *
+		 * If the token is mismatched because of global_filter changes,
+		 * we re-scan immediately, but if we lose the potential race for
+		 * the update, we back off for a short while (0.2-2 seconds) and
+		 * try again.
+		 */
+		if (!strcmp(daemon_reply_str(repl, "expected", ""), "update in progress") || try % 5)
+			usleep( 50000 + random() % 450000 ); /* 0.05 - 0.5s */
+		else
+			/* If the re-scan fails here, we try again later. */
+			lvmetad_pvscan_all_devs(_lvmetad_cmd, NULL);
+		++ try;
+		daemon_reply_destroy(repl);
+		goto retry;
 	}
 
 	return repl;


