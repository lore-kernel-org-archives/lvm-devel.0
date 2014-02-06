From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  6 Feb 2014 16:46:13 +0000 (UTC)
Subject: master - dmeventd: add DM_EVENT_GET_PARAMETERS request to dmeventd protocol
Message-ID: <20140206164613.B2C08600D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fbeb08f320414cf0b5ae22096504bc4293fe939a
Commit:        fbeb08f320414cf0b5ae22096504bc4293fe939a
Parent:        8a8abc5ed9358f45b127927a20f844a7ef122466
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Feb 4 17:01:54 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Feb 6 17:41:12 2014 +0100

dmeventd: add DM_EVENT_GET_PARAMETERS request to dmeventd protocol

The DM_EVENT_GET_PARAMETERS requests the parameters under which
the running dmeventd is run and the it sends them to caller.

The parameters sent:
  - the pid of the running dmeventd
  - foreground state
  - exec_method (currently either "direct" or "systemd")

The exact message sent back:
  pid=<pid> daemon=<no/yes> exec_method=<direct/systemd>
---
 daemons/dmeventd/dmeventd.c           |   59 ++++++++++++++++++++++++++++++++-
 daemons/dmeventd/dmeventd.h           |    1 +
 daemons/dmeventd/libdevmapper-event.h |    2 +-
 3 files changed, 60 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index e6b269c..b456ce6 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -514,6 +514,29 @@ static int _get_status(struct message_data *message_data)
 
 }
 
+static int _get_parameters(struct message_data *message_data) {
+	struct dm_event_daemon_message *msg = message_data->msg;
+	char buf[128];
+	int r = -1;
+
+	dm_free(msg->data);
+
+	if (!(dm_snprintf(buf, sizeof(buf), "%s pid=%d daemon=%s exec_method=%s",
+			  message_data->id,
+			  getpid(),
+			  _foreground ? "no" : "yes",
+			  _systemd_activation ? "systemd" : "direct")))
+		goto_out;
+
+	msg->size = strlen(buf) + 1;
+	if (!(msg->data = dm_malloc(msg->size)))
+		goto_out;
+	dm_strncpy(msg->data, buf, msg->size);
+	r = 0;
+out:
+	return r;
+}
+
 /* Cleanup at exit. */
 static void _exit_dm_lib(void)
 {
@@ -1437,6 +1460,14 @@ static int _handle_request(struct dm_event_daemon_message *msg,
 		{ DM_EVENT_CMD_GET_TIMEOUT, _get_timeout},
 		{ DM_EVENT_CMD_ACTIVE, _active},
 		{ DM_EVENT_CMD_GET_STATUS, _get_status},
+		/* dmeventd parameters of running dmeventd,
+		 * returns 'pid=<pid> daemon=<no/yes> exec_method=<direct/systemd>'
+		 * 	pid - pidfile of running dmeventd
+		 * 	daemon - running as a daemon or not (foreground)?
+		 * 	exec_method - "direct" if executed directly or
+		 * 		      "systemd" if executed via systemd
+		 */
+		{ DM_EVENT_CMD_GET_PARAMETERS, _get_parameters},
 	}, *req;
 
 	for (req = requests; req < requests + sizeof(requests) / sizeof(struct request); req++)
@@ -1732,6 +1763,7 @@ out:
 	unsetenv(SD_LISTEN_FDS_ENV_VAR_NAME);
 	return r;
 }
+
 #endif
 
 static void _remove_files_on_exit(void)
@@ -1938,18 +1970,43 @@ static void restart(void)
 	}
 	_initial_registrations[count] = 0;
 
+	if (version >= 2) {
+		if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_GET_PARAMETERS, "-", "-", 0, 0)) {
+			fprintf(stderr, "Failed to acquire parameters from old dmeventd.\n");
+			goto bad;
+		}
+		if (strstr(msg.data, "exec_method=systemd"))
+			_systemd_activation = 1;
+	}
+#ifdef __linux__
+	/*
+	* If the protocol version is old, just assume that if systemd is running,
+	* the dmeventd is also run as a systemd service via fifo activation.
+	*/
+	if (version < 2) {
+		/* This check is copied from sd-daemon.c. */
+		struct stat st;
+		if (!lstat("/run/systemd/system/", &st) && !!S_ISDIR(st.st_mode))
+			_systemd_activation = 1;
+	}
+#endif
+
 	if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_DIE, "-", "-", 0, 0)) {
 		fprintf(stderr, "Old dmeventd refused to die.\n");
 		goto bad;
 	}
 
+	if (!_systemd_activation &&
+	    ((e = getenv(SD_ACTIVATION_ENV_VAR_NAME)) && strcmp(e, "1")))
+		_systemd_activation = 1;
+
 	/*
 	 * If we're under systemd management, just send the initial
 	 * registrations to the fifo - this will instantiate new dmeventd.
 	 * If not under systemd management, continue with this process
 	 * to take over the old dmeventd.
 	 */
-	if (!(e = getenv(SD_ACTIVATION_ENV_VAR_NAME)) || strcmp(e, "1")) {
+	if (!_systemd_activation) {
 		/*
 		 * Non-systemd environment.
 		 * Wait for daemon to die, detected by sending further DIE messages
diff --git a/daemons/dmeventd/dmeventd.h b/daemons/dmeventd/dmeventd.h
index e21cf45..25a4bbb 100644
--- a/daemons/dmeventd/dmeventd.h
+++ b/daemons/dmeventd/dmeventd.h
@@ -34,6 +34,7 @@ enum dm_event_command {
 	DM_EVENT_CMD_HELLO,
 	DM_EVENT_CMD_DIE,
 	DM_EVENT_CMD_GET_STATUS,
+	DM_EVENT_CMD_GET_PARAMETERS,
 };
 
 /* Message passed between client and daemon. */
diff --git a/daemons/dmeventd/libdevmapper-event.h b/daemons/dmeventd/libdevmapper-event.h
index 9c1cc6f..532bebf 100644
--- a/daemons/dmeventd/libdevmapper-event.h
+++ b/daemons/dmeventd/libdevmapper-event.h
@@ -46,7 +46,7 @@ enum dm_event_mask {
 };
 
 #define DM_EVENT_ALL_ERRORS DM_EVENT_ERROR_MASK
-#define DM_EVENT_PROTOCOL_VERSION 1
+#define DM_EVENT_PROTOCOL_VERSION 2
 
 struct dm_task;
 struct dm_event_handler;


