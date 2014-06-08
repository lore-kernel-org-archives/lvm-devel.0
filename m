From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun,  8 Jun 2014 20:12:01 +0000 (UTC)
Subject: master - lvmetad: Avoid "connect failed" spamming when lvmetad is not available.
Message-ID: <20140608201201.B839A60C26@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=02e1bf406b2fc9731b2f67c273acd8f21df64714
Commit:        02e1bf406b2fc9731b2f67c273acd8f21df64714
Parent:        150165591f36e0ba16d9dfdca70c569b3ae03a83
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Jun 8 22:09:29 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Jun 8 22:09:29 2014 +0200

lvmetad: Avoid "connect failed" spamming when lvmetad is not available.

---
 lib/cache/lvmetad.c |   20 ++++++--------------
 1 files changed, 6 insertions(+), 14 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 3470c66..c03590e 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -26,7 +26,7 @@
 #define SCAN_TIMEOUT_SECONDS	80
 #define MAX_RESCANS		10	/* Maximum number of times to scan all PVs and retry if the daemon returns a token mismatch error */
 
-static daemon_handle _lvmetad;
+static daemon_handle _lvmetad = { .error = 0 };
 static int _lvmetad_use = 0;
 static int _lvmetad_connected = 0;
 
@@ -68,12 +68,12 @@ void lvmetad_connect_or_warn(void)
 	if (!_lvmetad_use)
 		return;
 
-	if (!_lvmetad_connected)
+	if (!_lvmetad_connected && !_lvmetad.error) {
 		_lvmetad_connect();
 
-	if ((_lvmetad.socket_fd < 0 || _lvmetad.error))
-		log_warn("WARNING: Failed to connect to lvmetad: %s. Falling back to internal scanning.",
-			 strerror(_lvmetad.error));
+		if ((_lvmetad.socket_fd < 0 || _lvmetad.error))
+			log_warn("WARNING: Failed to connect to lvmetad. Falling back to internal scanning.");
+	}
 }
 
 int lvmetad_used(void)
@@ -94,15 +94,7 @@ int lvmetad_socket_present(void)
 
 int lvmetad_active(void)
 {
-	if (!_lvmetad_use)
-		return 0;
-
-	if (!_lvmetad_connected)
-		_lvmetad_connect();
-
-	if ((_lvmetad.socket_fd < 0 || _lvmetad.error))
-		log_debug_lvmetad("Failed to connect to lvmetad: %s.", strerror(_lvmetad.error));
-
+	lvmetad_connect_or_warn();
 	return _lvmetad_connected;
 }
 


