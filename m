From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 21 Oct 2015 16:20:44 +0000 (UTC)
Subject: master - libdaemon: allow all debug levels for stderr
Message-ID: <20151021162044.3C00D6017F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0aee04288e221de91de022d84d19424d4698a05c
Commit:        0aee04288e221de91de022d84d19424d4698a05c
Parent:        ef4d69f456b22b4e58afb9fe5ff0b09603944f35
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 21 11:16:59 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 21 11:19:18 2015 -0500

libdaemon: allow all debug levels for stderr

The parsing code for log levels was missing
some levels.  Also ignore an unrecognized
level name rather than failing.
---
 libdaemon/server/daemon-log.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/libdaemon/server/daemon-log.c b/libdaemon/server/daemon-log.c
index 5ea5cdc..abe602b 100644
--- a/libdaemon/server/daemon-log.c
+++ b/libdaemon/server/daemon-log.c
@@ -160,12 +160,18 @@ static int _parse_one(log_state *s, int outlet, const char *type, int enable)
 	if (!strcmp(type, "all"))
 		for (i = 0; i < 32; ++i)
 			daemon_log_enable(s, outlet, i, enable);
+	else if (!strcmp(type, "fatal"))
+		daemon_log_enable(s, outlet, DAEMON_LOG_FATAL, enable);
+	else if (!strcmp(type, "error"))
+		daemon_log_enable(s, outlet, DAEMON_LOG_ERROR, enable);
+	else if (!strcmp(type, "warn"))
+		daemon_log_enable(s, outlet, DAEMON_LOG_WARN, enable);
+	else if (!strcmp(type, "warn"))
+		daemon_log_enable(s, outlet, DAEMON_LOG_INFO, enable);
 	else if (!strcmp(type, "wire"))
 		daemon_log_enable(s, outlet, DAEMON_LOG_WIRE, enable);
 	else if (!strcmp(type, "debug"))
 		daemon_log_enable(s, outlet, DAEMON_LOG_DEBUG, enable);
-	else
-		return 0;
 
 	return 1;
 }


