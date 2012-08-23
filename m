From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:05 +0000 (UTC)
Subject: master - lvmetad: fix memleaks
Message-ID: <20120823124205.6FB39A0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8edc0e450da2c0959c44da4811901782cc399649
Commit:        8edc0e450da2c0959c44da4811901782cc399649
Parent:        00877fe47b99458e22f6e1c928505fc75aad0752
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 16 20:10:35 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:33:23 2012 +0200

lvmetad: fix memleaks

Release allocated buffers in daemon_logf, daemon_log_parse
---
 WHATS_NEW                     |    1 +
 libdaemon/server/daemon-log.c |    7 ++++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dcd51ff..dc3b29e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98
 =================================
+  Fix buffer memory leak in lvmetad logging.
   Use 'ignore' discards for thin metadata created with older versions.
   Use proper condition to check for unsupported discards settings.
   Update lvs manpage with discards (2.02.97).
diff --git a/libdaemon/server/daemon-log.c b/libdaemon/server/daemon-log.c
index caa40cb..21068bc 100644
--- a/libdaemon/server/daemon-log.c
+++ b/libdaemon/server/daemon-log.c
@@ -59,6 +59,7 @@ void daemon_logf(log_state *s, int type, const char *fmt, ...) {
 	if (dm_vasprintf(&buf, fmt, ap) < 0)
 		return; /* _0 */
 	daemon_log(s, type, buf);
+	dm_free(buf);
 }
 
 struct log_line_baton {
@@ -134,10 +135,14 @@ int daemon_log_parse(log_state *s, int outlet, const char *types, int enable)
 		char *next = strchr(pos, ',');
 		if (next)
 			*next = 0;
-		if (!_parse_one(s, outlet, pos, enable))
+		if (!_parse_one(s, outlet, pos, enable)) {
+			dm_free(buf);
 			return 0;
+		}
 		pos = next ? next + 1 : 0;
 	}
 
+	dm_free(buf);
+
 	return 1;
 }


