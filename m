From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:36 +0000 (UTC)
Subject: master - cleanup: add va_end
Message-ID: <20120823124236.C0C01A33BE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=93f36fb77f595f67602cd9b39bb696e802545546
Commit:        93f36fb77f595f67602cd9b39bb696e802545546
Parent:        bd67a3151aa3a3202d52fcc9ffac781b96dca04a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 17 00:46:00 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:37:21 2012 +0200

cleanup: add va_end

Pair va_start with va_end.
---
 libdaemon/server/daemon-log.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/libdaemon/server/daemon-log.c b/libdaemon/server/daemon-log.c
index 8eab917..b18e70c 100644
--- a/libdaemon/server/daemon-log.c
+++ b/libdaemon/server/daemon-log.c
@@ -53,13 +53,15 @@ void daemon_log(log_state *s, int type, const char *message) {
 }
 
 void daemon_logf(log_state *s, int type, const char *fmt, ...) {
+	char *buf;
 	va_list ap;
+
 	va_start(ap, fmt);
-	char *buf;
-	if (dm_vasprintf(&buf, fmt, ap) < 0)
-		return; /* _0 */
-	daemon_log(s, type, buf);
-	dm_free(buf);
+	if (dm_vasprintf(&buf, fmt, ap) >= 0) {
+		daemon_log(s, type, buf);
+		dm_free(buf);
+	} /* else return_0 */
+	va_end(ap);
 }
 
 struct log_line_baton {


