From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  9 Oct 2012 23:49:06 +0000 (UTC)
Subject: master - libdaemon-server: Do not create pidfile if NULL.
Message-ID: <20121009234906.44D84246B@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=329d10268cf64f6d2ddb801f0191f3112c76ef66
Commit:        329d10268cf64f6d2ddb801f0191f3112c76ef66
Parent:        ff752c60dfde5f40e400746b98b17e511c9f1e34
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Oct 9 20:22:30 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Oct 9 20:37:34 2012 +0200

libdaemon-server: Do not create pidfile if NULL.

---
 libdaemon/server/daemon-server.c |   21 ++++++++++++---------
 1 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index b15a7cc..9dd911f 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -466,16 +466,18 @@ void daemon_start(daemon_state s)
 	daemon_log_enable(s.log, DAEMON_LOG_OUTLET_SYSLOG, DAEMON_LOG_FATAL, 1);
 	daemon_log_enable(s.log, DAEMON_LOG_OUTLET_SYSLOG, DAEMON_LOG_ERROR, 1);
 
-	(void) dm_prepare_selinux_context(s.pidfile, S_IFREG);
+	if (s.pidfile) {
+		(void) dm_prepare_selinux_context(s.pidfile, S_IFREG);
 
-	/*
-	 * NB. Take care to not keep stale locks around. Best not exit(...)
-	 * after this point.
-	 */
-	if (dm_create_lockfile(s.pidfile) == 0)
-		exit(1);
+		/*
+		 * NB. Take care to not keep stale locks around. Best not exit(...)
+		 * after this point.
+		 */
+		if (dm_create_lockfile(s.pidfile) == 0)
+			exit(1);
 
-	(void) dm_prepare_selinux_context(NULL, 0);
+		(void) dm_prepare_selinux_context(NULL, 0);
+	}
 
 	/* Set normal exit signals to request shutdown instead of dying. */
 	signal(SIGINT, &_exit_handler);
@@ -526,7 +528,8 @@ void daemon_start(daemon_state s)
 	INFO(&s, "%s shutting down", s.name);
 
 	closelog(); /* FIXME */
-	remove_lockfile(s.pidfile);
+	if (s.pidfile)
+		remove_lockfile(s.pidfile);
 	if (failed)
 		exit(1);
 }


