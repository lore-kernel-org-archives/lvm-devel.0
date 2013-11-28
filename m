From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 28 Nov 2013 11:48:44 +0000 (UTC)
Subject: master - dmeventd: fifo init and close cleanup
Message-ID: <20131128114844.E270560F37@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6dae2373034ce3fc11f226c963d81a670043191a
Commit:        6dae2373034ce3fc11f226c963d81a670043191a
Parent:        fc9d4dd11f2331e056f0b56274877c8a4b4b1570
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 28 12:21:06 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 28 12:43:14 2013 +0100

dmeventd: fifo init and close cleanup

Use structure initialization for easier to read code.
Close only descriptors >= 0.
---
 daemons/dmeventd/dmeventd.c           |    8 +++++-
 daemons/dmeventd/libdevmapper-event.c |   48 ++++++++++++++++----------------
 2 files changed, 31 insertions(+), 25 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 189d1b6..301c5f5 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1826,7 +1826,13 @@ static void _daemonize(void)
 
 static void restart(void)
 {
-	struct dm_event_fifos fifos = { 0 };
+	struct dm_event_fifos fifos = {
+		.server = -1,
+		.client = -1,
+		/* FIXME Make these either configurable or depend directly on dmeventd_path */
+		.client_path = DM_EVENT_FIFO_CLIENT,
+		.server_path = DM_EVENT_FIFO_SERVER
+	};
 	struct dm_event_daemon_message msg = { 0 };
 	int i, count = 0;
 	char *message;
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 92e9c1d..9e8911e 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -468,10 +468,6 @@ int init_fifos(struct dm_event_fifos *fifos)
 	/* FIXME? Is fifo the most suitable method? Why not share
 	   comms/daemon code with something else e.g. multipath? */
 
-	/* FIXME Make these either configurable or depend directly on dmeventd_path */
-	fifos->client_path = DM_EVENT_FIFO_CLIENT;
-	fifos->server_path = DM_EVENT_FIFO_SERVER;
-
 	/* Open the fifo used to read from the daemon. */
 	if ((fifos->server = open(fifos->server_path, O_RDWR)) < 0) {
 		log_sys_error("open", fifos->server_path);
@@ -481,32 +477,27 @@ int init_fifos(struct dm_event_fifos *fifos)
 	/* Lock out anyone else trying to do communication with the daemon. */
 	if (flock(fifos->server, LOCK_EX) < 0) {
 		log_sys_error("flock", fifos->server_path);
-		if (close(fifos->server))
-			log_sys_error("close", fifos->server_path);
-		return 0;
+		goto bad;
 	}
 
 /*	if ((fifos->client = open(fifos->client_path, O_WRONLY | O_NONBLOCK)) < 0) {*/
 	if ((fifos->client = open(fifos->client_path, O_RDWR | O_NONBLOCK)) < 0) {
 		log_sys_error("open", fifos->client_path);
-		if (close(fifos->server))
-			log_sys_error("close", fifos->server_path);
-		return 0;
+		goto bad;
 	}
 
 	return 1;
+bad:
+	if (close(fifos->server))
+		log_sys_debug("close", fifos->server_path);
+	fifos->server = -1;
+
+	return 0;
 }
 
 /* Initialize client. */
 static int _init_client(char *dmeventd_path, struct dm_event_fifos *fifos)
 {
-	/* init fifos */
-	memset(fifos, 0, sizeof(*fifos));
-
-	/* FIXME Make these either configurable or depend directly on dmeventd_path */
-	fifos->client_path = DM_EVENT_FIFO_CLIENT;
-	fifos->server_path = DM_EVENT_FIFO_SERVER;
-
 	if (!_start_daemon(dmeventd_path, fifos))
 		return_0;
 
@@ -515,13 +506,16 @@ static int _init_client(char *dmeventd_path, struct dm_event_fifos *fifos)
 
 void fini_fifos(struct dm_event_fifos *fifos)
 {
-	if (flock(fifos->server, LOCK_UN))
-		log_error("flock unlock %s", fifos->server_path);
-
-	if (close(fifos->client))
+	if (fifos->client >= 0 && close(fifos->client))
 		log_sys_error("close", fifos->client_path);
-	if (close(fifos->server))
-		log_sys_error("close", fifos->server_path);
+
+	if (fifos->server >= 0) {
+		if (flock(fifos->server, LOCK_UN))
+			log_sys_error("flock unlock", fifos->server_path);
+
+		if (close(fifos->server))
+			log_sys_error("close", fifos->server_path);
+	}
 }
 
 /* Get uuid of a device */
@@ -585,7 +579,13 @@ static int _do_event(int cmd, char *dmeventd_path, struct dm_event_daemon_messag
 		     enum dm_event_mask evmask, uint32_t timeout)
 {
 	int ret;
-	struct dm_event_fifos fifos;
+	struct dm_event_fifos fifos = {
+		.server = -1,
+		.client = -1,
+		/* FIXME Make these either configurable or depend directly on dmeventd_path */
+		.client_path = DM_EVENT_FIFO_CLIENT,
+		.server_path = DM_EVENT_FIFO_SERVER
+	};
 
 	if (!_init_client(dmeventd_path, &fifos)) {
 		stack;


