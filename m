From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  6 Feb 2014 16:46:11 +0000 (UTC)
Subject: master - dmeventd: fix dmeventd -R to work properly with systemd
Message-ID: <20140206164611.94179600D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8a8abc5ed9358f45b127927a20f844a7ef122466
Commit:        8a8abc5ed9358f45b127927a20f844a7ef122466
Parent:        36f9fadcb4be4091ba5fd505016d79a91037b19d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Feb 3 16:07:06 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Feb 6 17:15:19 2014 +0100

dmeventd: fix dmeventd -R to work properly with systemd

Trying to restart dmeventd as a reload action is causing problems
under systemd environment. The systemd loses track of new dmeventd
this way. See also https://bugzilla.redhat.com/show_bug.cgi?id=1060134
for more info.

We need to call dmeventd -R directly instead of "systemctl reload dm-event.service"
that was used before (the reload is aimed at configuration reload anyway,
not stateful restart of the daemon - we did this before just because
there's no ExecRestart in systemd and there's only ExecStart and
ExecStop with which we'd lose the state).

Also, use ExecStart="dmeventd -f" to run dmeventd in foreground
(and let's rely on systemd to daemonize it) and change the
service type from "forking" to "simple".
---
 daemons/dmeventd/dmeventd.c                 |  101 +++++++++++++++++++++++++--
 scripts/dm_event_systemd_red_hat.service.in |    5 +-
 2 files changed, 97 insertions(+), 9 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 179775a..e6b269c 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1823,6 +1823,59 @@ static void _daemonize(void)
 	setsid();
 }
 
+static int _reinstate_registrations(struct dm_event_fifos *fifos)
+{
+	static const char _failed_parsing_msg[] = "Failed to parse existing event registration.\n";
+	static const char *_delim = " ";
+	struct dm_event_daemon_message msg = { 0 };
+	char *endp, *dso_name, *dev_name, *mask, *timeout;
+	unsigned long mask_value, timeout_value;
+	int i, ret;
+
+	ret = daemon_talk(fifos, &msg, DM_EVENT_CMD_HELLO, NULL, NULL, 0, 0);
+	dm_free(msg.data);
+	msg.data = NULL;
+
+	if (ret) {
+		fprintf(stderr, "Failed to communicate with new instance of dmeventd.\n");
+		return 0;
+	}
+
+	for (i = 0; _initial_registrations[i]; ++i) {
+		if (!(strtok(_initial_registrations[i], _delim)) ||
+		    !(dso_name = strtok(NULL, _delim)) ||
+		    !(dev_name = strtok(NULL, _delim)) ||
+		    !(mask = strtok(NULL, _delim)) ||
+		    !(timeout = strtok(NULL, _delim))) {
+			fprintf(stderr, _failed_parsing_msg);
+			continue;
+		}
+
+		errno = 0;
+		mask_value = strtoul(mask, &endp, 10);
+		if (errno || !endp || *endp) {
+			fprintf(stderr, _failed_parsing_msg);
+			continue;
+		}
+
+		errno = 0;
+		timeout_value = strtoul(timeout, &endp, 10);
+		if (errno || !endp || *endp) {
+			fprintf(stderr, _failed_parsing_msg);
+			continue;
+		}
+
+		if (daemon_talk(fifos, &msg, DM_EVENT_CMD_REGISTER_FOR_EVENT,
+				dso_name,
+				dev_name,
+				(enum dm_event_mask) mask_value,
+				timeout_value))
+			fprintf(stderr, "Failed to reinstate monitoring for device %s.\n", dev_name);
+	}
+
+	return 1;
+}
+
 static void restart(void)
 {
 	struct dm_event_fifos fifos = {
@@ -1837,9 +1890,9 @@ static void restart(void)
 	char *message;
 	int length;
 	int version;
+	const char *e;
 
 	/* Get the list of registrations from the running daemon. */
-
 	if (!init_fifos(&fifos)) {
 		fprintf(stderr, "WARNING: Could not initiate communication with existing dmeventd.\n");
 		exit(EXIT_FAILURE);
@@ -1891,18 +1944,54 @@ static void restart(void)
 	}
 
 	/*
-	 * Wait for daemon to die, detected by sending further DIE messages
-	 * until one fails.
+	 * If we're under systemd management, just send the initial
+	 * registrations to the fifo - this will instantiate new dmeventd.
+	 * If not under systemd management, continue with this process
+	 * to take over the old dmeventd.
+	 */
+	if (!(e = getenv(SD_ACTIVATION_ENV_VAR_NAME)) || strcmp(e, "1")) {
+		/*
+		 * Non-systemd environment.
+		 * Wait for daemon to die, detected by sending further DIE messages
+		 * until one fails. This is really silly, but since nobody cleans up
+		 * the pidfile after SIGKILL is received in old dmeventd, we have to
+		 * do it this way.
+		*/
+	        for (i = 0; i < 10; ++i) {
+			if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_DIE, "-", "-", 0, 0))
+				break; /* yep, it's dead probably */
+	                usleep(10);
+		}
+		fini_fifos(&fifos);
+		return;
+	}
+
+	/*
+	 * Systemd environment.
+	 * Wait for daemon to die, detected by checking the pidfile.
+	 * We can do this - systemd cleans up the pidfile automatically
+	 * for us even if we don't do that when SIGKILL is received in old dmeventd.
 	 */
 	for (i = 0; i < 10; ++i) {
-		if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_DIE, "-", "-", 0, 0))
-			break; /* yep, it's dead probably */
+		if ((access(DMEVENTD_PIDFILE, F_OK) == -1) && (errno == ENOENT))
+			break;
 		usleep(10);
 	}
 
+	/* Reopen fifos. */
 	fini_fifos(&fifos);
+	if (!init_fifos(&fifos)) {
+		fprintf(stderr, "Could not initiate communication with new instance of dmeventd.\n");
+		exit(EXIT_FAILURE);
+	}
 
-	return;
+	if (!_reinstate_registrations(&fifos)) {
+		fprintf(stderr, "Failed to reinstate monitoring with new instance of dmeventd.\n");
+		goto bad;
+	}
+
+	fini_fifos(&fifos);
+	exit(EXIT_SUCCESS);
 bad:
 	fini_fifos(&fifos);
 	exit(EXIT_FAILURE);
diff --git a/scripts/dm_event_systemd_red_hat.service.in b/scripts/dm_event_systemd_red_hat.service.in
index 96c5225..3791618 100644
--- a/scripts/dm_event_systemd_red_hat.service.in
+++ b/scripts/dm_event_systemd_red_hat.service.in
@@ -7,9 +7,8 @@ Before=local-fs.target
 DefaultDependencies=no
 
 [Service]
-Type=forking
-ExecStart=@sbindir@/dmeventd
-ExecReload=@sbindir@/dmeventd -R
+Type=simple
+ExecStart=@sbindir@/dmeventd -f
 Environment=SD_ACTIVATION=1
 PIDFile=@DMEVENTD_PIDFILE@
 OOMScoreAdjust=-1000


