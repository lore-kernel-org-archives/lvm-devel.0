From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:24:59 +0000 (UTC)
Subject: dev-mornfall-activate - cleanup: add printf attribute
Message-ID: <20130604192459.7A62B60F3D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=855175fa261c2c5de0e030615e2f274344e2d129
Commit:        855175fa261c2c5de0e030615e2f274344e2d129
Parent:        d38af2857fe86a5e0916d67aee7597e5a0dea6c8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 20 20:56:07 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:14:05 2013 +0200

cleanup: add printf attribute

Add gcc attribute for printf for daemon_logf().
---
 libdaemon/server/daemon-server.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/libdaemon/server/daemon-server.h b/libdaemon/server/daemon-server.h
index f184853..eb6df43 100644
--- a/libdaemon/server/daemon-server.h
+++ b/libdaemon/server/daemon-server.h
@@ -140,7 +140,8 @@ void daemon_log_cft(log_state *s, int type, const char *prefix,
 void daemon_log_multi(log_state *s, int type, const char *prefix, const char *message);
 
 /* Log a formatted message as "type". See also daemon-log.h. */
-void daemon_logf(log_state *s, int type, const char *format, ...);
+void daemon_logf(log_state *s, int type, const char *format, ...)
+	__attribute__ ((format(printf, 3, 4)));
 
 /*
  * Configure log_state to send messages of type "type" to the log outlet


