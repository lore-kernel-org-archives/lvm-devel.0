From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 14 Mar 2012 15:23:07 +0100
Subject: [PATCH] Remove fifos on dmeventd shutdown
Message-ID: <4F60A9CB.5050000@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I think we should clean these fifos properly (if not using systemd
activation where they are maintained by systemd itself).

Also, there's missing SIGTERM signal handler registration for the case
we run in foreground - it leaves the dmeventd.pid in filesystem then.
(..it would leave the fifos behind as well)

Peter
---
 daemons/dmeventd/dmeventd.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index b61fb8b..b28816e 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1735,10 +1735,18 @@ out:
 }
 #endif
 
-static void remove_lockfile(void)
+static void _remove_files_on_exit(void)
 {
 	if (unlink(DMEVENTD_PIDFILE))
 		perror(DMEVENTD_PIDFILE ": unlink failed");
+
+	if (!_systemd_activation) {
+		if (unlink(DM_EVENT_FIFO_CLIENT))
+			perror(DM_EVENT_FIFO_CLIENT " : unlink failed");
+
+		if (unlink(DM_EVENT_FIFO_SERVER))
+			perror(DM_EVENT_FIFO_SERVER " : unlink failed");
+	}
 }
 
 static void _daemonize(void)
@@ -1949,10 +1957,11 @@ int main(int argc, char *argv[])
 	if (dm_create_lockfile(DMEVENTD_PIDFILE) == 0)
 		exit(EXIT_FAILURE);
 
-	atexit(remove_lockfile);
+	atexit(_remove_files_on_exit);
 	(void) dm_prepare_selinux_context(NULL, 0);
 
 	/* Set the rest of the signals to cause '_exit_now' to be set */
+	signal(SIGTERM, &_exit_handler);
 	signal(SIGINT, &_exit_handler);
 	signal(SIGHUP, &_exit_handler);
 	signal(SIGQUIT, &_exit_handler);


