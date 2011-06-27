From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 27 Jun 2011 13:58:12 -0000
Subject: LVM2/daemons common/daemon-client.c common/dae ...
Message-ID: <20110627135812.30006.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-06-27 13:58:11

Modified files:
	daemons/common : daemon-client.c daemon-client.h daemon-server.c 
	                 daemon-server.h 
	daemons/lvmetad: lvmetad-core.c testclient.c 

Log message:
	Also parse the config_tree on the client end (daemon-client.c).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/testclient.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/daemons/common/daemon-client.c	2011/06/27 13:46:45	1.3
+++ LVM2/daemons/common/daemon-client.c	2011/06/27 13:58:11	1.4
@@ -44,13 +44,18 @@
 	write_buffer(h.socket_fd, rq.buffer, strlen(rq.buffer));
 
 	if (read_buffer(h.socket_fd, &reply.buffer)) {
-		/* TODO: parse reply.buffer into reply.cft */
+		reply.cft = create_config_tree_from_string(reply.buffer);
 	} else
 		reply.error = 1;
 
 	return reply;
 }
 
+void daemon_reply_destroy(daemon_reply r) {
+	if (r.cft)
+		destroy_config_tree(r.cft);
+}
+
 daemon_reply daemon_send_simple(daemon_handle h, char *id, ...)
 {
 	va_list ap;
--- LVM2/daemons/common/daemon-client.h	2011/06/27 12:26:54	1.4
+++ LVM2/daemons/common/daemon-client.h	2011/06/27 13:58:11	1.5
@@ -41,13 +41,13 @@
 	 *        knobs = [ "twiddle", "tweak" ]
 	 *    }
 	 */
-	struct config_node *cft;
+	struct config_tree *cft;
 } daemon_request;
 
 typedef struct {
 	int error; /* 0 for success */
 	char *buffer; /* textual reply */
-	struct config_node *cft; /* parsed reply, if available */
+	struct config_tree *cft; /* parsed reply, if available */
 } daemon_reply;
 
 /*
@@ -79,6 +79,8 @@
  */
 daemon_reply daemon_send_simple(daemon_handle h, char *id, ...);
 
+void daemon_reply_destroy(daemon_reply r);
+
 /* Shut down the communication to the daemon. Compulsory. */
 void daemon_close(daemon_handle h);
 
--- LVM2/daemons/common/daemon-server.c	2011/06/27 13:46:45	1.5
+++ LVM2/daemons/common/daemon-server.c	2011/06/27 13:58:11	1.6
@@ -25,6 +25,7 @@
 
 #include <syslog.h>
 #include "daemon-server.h"
+#include "daemon-shared.h"
 #include "libdevmapper.h"
 
 #if 0
@@ -200,6 +201,18 @@
 	setsid();
 }
 
+response daemon_reply_simple(char *id, ...)
+{
+	va_list ap;
+	va_start(ap, id);
+	response res = { .buffer = format_buffer(id, ap), .cft = NULL };
+
+	if (!res.buffer)
+		res.error = ENOMEM;
+
+	return res;
+}
+
 struct thread_baton {
 	daemon_state s;
 	client_handle client;
--- LVM2/daemons/common/daemon-server.h	2011/06/27 13:46:45	1.6
+++ LVM2/daemons/common/daemon-server.h	2011/06/27 13:58:11	1.7
@@ -39,6 +39,12 @@
 struct daemon_state;
 
 /*
+ * Craft a simple reply, without the need to construct a config_tree. See
+ * daemon_send_simple in daemon-client.h for the description of the parameters.
+ */
+response daemon_reply_simple(char *id, ...);
+
+/*
  * The callback. Called once per request issued, in the respective client's
  * thread. It is presented by a parsed request (in the form of a config tree).
  * The output is a new config tree that is serialised and sent back to the
--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/06/27 13:46:45	1.3
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/06/27 13:58:11	1.4
@@ -6,11 +6,9 @@
 
 static response handler(daemon_state s, client_handle h, request r)
 {
-	response res;
-	fprintf(stderr, "[D] REQUEST: %s\n", find_config_str(r.cft->root, "request", "NONE"));
-	res.error = 1;
-	res.buffer = strdup("hey hey.\n\n");
-	return res;
+	fprintf(stderr, "[D] REQUEST: %s, param = %d\n", find_config_str(r.cft->root, "request", "NONE"),
+		                                         find_config_int(r.cft->root, "param", -1));
+	return daemon_reply_simple("hey there", "param = %d", 42, NULL);
 }
 
 static int setup_post(daemon_state *s)
--- LVM2/daemons/lvmetad/testclient.c	2011/06/27 13:46:45	1.4
+++ LVM2/daemons/lvmetad/testclient.c	2011/06/27 13:58:11	1.5
@@ -5,7 +5,9 @@
 	int i;
 	for (i = 0; i < 5; ++i ) {
 		daemon_reply reply = daemon_send_simple(h, "hello world", "param = %d", 3, NULL);
-		fprintf(stderr, "[C] obtained: %s\n", reply.buffer);
+		fprintf(stderr, "[C] REPLY: %s, param = %d\n", find_config_str(reply.cft->root, "request", "NONE"),
+			                                       find_config_int(reply.cft->root, "param", -1));
+		daemon_reply_destroy(reply);
 	}
 	daemon_close(h);
 	return 0;


