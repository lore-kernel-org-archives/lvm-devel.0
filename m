From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  6 Feb 2014 17:10:58 +0000 (UTC)
Subject: master - dmeventd: check pidfile for exit instead of polling via protocol
Message-ID: <20140206171058.A8C69612FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=73f30ed6a4b85c3b70aa39efa14ce78be5bf8a3a
Commit:        73f30ed6a4b85c3b70aa39efa14ce78be5bf8a3a
Parent:        90286fa0e96dde8f79c1d06eff4a878cb3024283
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 6 17:53:03 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Feb 6 17:53:03 2014 +0100

dmeventd: check pidfile for exit instead of polling via protocol

Since we use unlink + _exit now on dmeventd DIE message, we can
check the pidfile existence to see whether the dmeventd has finished.
---
 daemons/dmeventd/dmeventd.c |   39 +++++++++------------------------------
 1 files changed, 9 insertions(+), 30 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 04ed71e..1d979fa 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1535,8 +1535,11 @@ static void _process_request(struct dm_event_fifos *fifos)
 
 	dm_free(msg.data);
 
-	if (die)
+	if (die) {
+		if (unlink(DMEVENTD_PIDFILE))
+			perror(DMEVENTD_PIDFILE ": unlink failed");
 		_exit(0);
+	}
 }
 
 static void _process_initial_registrations(void)
@@ -2001,41 +2004,17 @@ static void restart(void)
 	    ((e = getenv(SD_ACTIVATION_ENV_VAR_NAME)) && strcmp(e, "1")))
 		_systemd_activation = 1;
 
-	/*
-	 * If we're under systemd management, just send the initial
-	 * registrations to the fifo - this will instantiate new dmeventd.
-	 * If not under systemd management, continue with this process
-	 * to take over the old dmeventd.
-	 */
-	if (!_systemd_activation) {
-		/*
-		 * Non-systemd environment.
-		 * Wait for daemon to die, detected by sending further DIE messages
-		 * until one fails. This is really silly, but since nobody cleans up
-		 * the pidfile after SIGKILL is received in old dmeventd, we have to
-		 * do it this way.
-		*/
-	        for (i = 0; i < 10; ++i) {
-			if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_DIE, "-", "-", 0, 0))
-				break; /* yep, it's dead probably */
-	                usleep(10);
-		}
-		fini_fifos(&fifos);
-		return;
-	}
-
-	/*
-	 * Systemd environment.
-	 * Wait for daemon to die, detected by checking the pidfile.
-	 * We can do this - systemd cleans up the pidfile automatically
-	 * for us even if we don't do that when SIGKILL is received in old dmeventd.
-	 */
 	for (i = 0; i < 10; ++i) {
 		if ((access(DMEVENTD_PIDFILE, F_OK) == -1) && (errno == ENOENT))
 			break;
 		usleep(10);
 	}
 
+	if (!_systemd_activation) {
+		fini_fifos(&fifos);
+		return;
+	}
+
 	/* Reopen fifos. */
 	fini_fifos(&fifos);
 	if (!init_fifos(&fifos)) {


