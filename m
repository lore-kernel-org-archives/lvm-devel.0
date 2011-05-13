From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 13 May 2011 08:07:30 -0000
Subject: LVM2/daemons/common daemon-client.h daemon-ser ...
Message-ID: <20110513080730.541.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-05-13 08:07:29

Added files:
	daemons/common : daemon-client.h daemon-server.h 

Log message:
	First stab at the prototypes of the daemon-common functionality (to be
	eventually shared by dmeventd, lvmetad and clvmd).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/daemons/common/daemon-client.h,v  -->  standard output
revision 1.1
--- LVM2/daemons/common/daemon-client.h
+++ -	2011-05-13 08:07:30.026952000 +0000
@@ -0,0 +1,59 @@
+/*
+ * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_DAEMON_COMMON_CLIENT_H
+#define _LVM_DAEMON_COMMON_CLIENT_H
+
+typedef struct {
+	int socket_fd; /* the fd we use to talk to the daemon */
+	int protocol;  /* version of the protocol the daemon uses */
+	char *read_buf;
+} daemon_handle;
+
+typedef struct {
+	const char *path; /* the binary of the daemon */
+	const char *socket; /* path to the comms socket */
+	unsigned autostart:1; /* start the daemon if not running? */
+} daemon_info;
+
+typedef struct {
+	char *request;
+} daemon_request;
+
+typedef struct {
+	int errno; /* 0 for success */
+	char *reply; /* textual reply */
+	struct config_tree *cft; /* parsed reply, if available */
+} daemon_reply;
+
+/*
+ * Open the communication channel to the daemon. If the daemon is not running,
+ * it may be autostarted based on the binary path provided in the info (this
+ * will only happen if autostart is set to true). If the call fails for any
+ * reason, daemon_handle_valid(h) for the response will return false. Otherwise,
+ * the connection is good to start serving requests.
+ */
+daemon_handle daemon_open(daemon_info i);
+
+/*
+ * Send a request to the daemon, waiting for the reply. All communication with
+ * the daemon is synchronous. The function handles the IO details and parses the
+ * response, handling common error conditions. See "daemon_reply" for details.
+ */
+daemon_reply daemon_request(daemon_handle h, daemon_request r);
+
+/* Shut down the communication to the daemon. Compulsory. */
+void daemon_close(daemon_handle h);
+
+#endif
/cvs/lvm2/LVM2/daemons/common/daemon-server.h,v  -->  standard output
revision 1.1
--- LVM2/daemons/common/daemon-server.h
+++ -	2011-05-13 08:07:30.411524000 +0000
@@ -0,0 +1,72 @@
+/*
+ * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_DAEMON_COMMON_CLIENT_H
+#define _LVM_DAEMON_COMMON_CLIENT_H
+
+typedef struct {
+	int socket_fd; /* the fd we use to talk to the client */
+	pthread_t thread_id;
+	char *read_buf;
+	void *private; /* this holds per-client state */
+} client_handle;
+
+typedef struct {
+	void *private; /* the global daemon state */
+} daemon_state;
+
+typedef struct {
+	struct config_tree *cft;
+} request;
+
+typedef struct {
+	struct config_tree *cft;
+} response;
+
+/*
+ * The callback. Called once per request issued, in the respective client's
+ * thread. It is presented by a parsed request (in the form of a config tree).
+ * The output is a new config tree that is serialised and sent back to the
+ * client. The client blocks until the request processing is done and reply is
+ * sent.
+ */
+typedef response (*handle_request)(daemon_state s, client_handle h, request r);
+
+/*
+ * Start serving the requests. This does all the daemonisation, socket setup
+ * work and so on.
+ */
+void daemon_start(daemon_state s, handle_request r);
+
+/*
+ * Take over from an already running daemon. This function handles connecting
+ * to the running daemon and telling it we are going to take over. The takeover
+ * request may be customised by passing in a non-NULL request.
+ *
+ * The takeover sequence: the old daemon stops accepting new clients, then it
+ * waits until all current client connections are closed. When that happens, it
+ * serializes its current state and sends that as a reply, which is then
+ * returned by this function (therefore, this function won't return until the
+ * previous instance has shut down).
+ *
+ * The daemon, after calling daemon_takeover is expected to set up its
+ * daemon_state using the reply from this function and call daemon_start as
+ * usual.
+ */
+daemon_reply daemon_takeover(daemon_info i, daemon_request r);
+
+/* Call this to request a clean shutdown of the daemon. Async safe. */
+void daemon_stop();
+
+#endif


