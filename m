From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 27 Jun 2011 14:04:00 -0000
Subject: LVM2/daemons common/daemon-client.h common/dae ...
Message-ID: <20110627140400.2090.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-06-27 14:03:59

Modified files:
	daemons/common : daemon-client.h daemon-server.h 
	daemons/lvmetad: lvmetad-core.c testclient.c 

Log message:
	Add int/str lookup routines specific to the reply (in client) and request (in
	server) for nicer-looking code (thin wrapping around find_config_{int,str}).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/testclient.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/daemons/common/daemon-client.h	2011/06/27 13:58:11	1.5
+++ LVM2/daemons/common/daemon-client.h	2011/06/27 14:03:58	1.6
@@ -81,6 +81,15 @@
 
 void daemon_reply_destroy(daemon_reply r);
 
+static inline int daemon_reply_int(daemon_reply r, const char *path, int def) {
+	return find_config_int(r.cft->root, path, def);
+}
+
+static inline const char *daemon_reply_str(daemon_reply r, const char *path, const char *def) {
+	return find_config_str(r.cft->root, path, def);
+}
+
+
 /* Shut down the communication to the daemon. Compulsory. */
 void daemon_close(daemon_handle h);
 
--- LVM2/daemons/common/daemon-server.h	2011/06/27 13:58:11	1.7
+++ LVM2/daemons/common/daemon-server.h	2011/06/27 14:03:59	1.8
@@ -44,6 +44,14 @@
  */
 response daemon_reply_simple(char *id, ...);
 
+static inline int daemon_request_int(request r, const char *path, int def) {
+	return find_config_int(r.cft->root, path, def);
+}
+
+static inline const char *daemon_request_str(request r, const char *path, const char *def) {
+	return find_config_str(r.cft->root, path, def);
+}
+
 /*
  * The callback. Called once per request issued, in the respective client's
  * thread. It is presented by a parsed request (in the form of a config tree).
--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/06/27 13:58:11	1.4
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/06/27 14:03:59	1.5
@@ -6,8 +6,8 @@
 
 static response handler(daemon_state s, client_handle h, request r)
 {
-	fprintf(stderr, "[D] REQUEST: %s, param = %d\n", find_config_str(r.cft->root, "request", "NONE"),
-		                                         find_config_int(r.cft->root, "param", -1));
+	fprintf(stderr, "[D] REQUEST: %s, param = %d\n", daemon_request_str(r, "request", "NONE"),
+		                                         daemon_request_int(r, "param", -1));
 	return daemon_reply_simple("hey there", "param = %d", 42, NULL);
 }
 
--- LVM2/daemons/lvmetad/testclient.c	2011/06/27 13:58:11	1.5
+++ LVM2/daemons/lvmetad/testclient.c	2011/06/27 14:03:59	1.6
@@ -5,8 +5,8 @@
 	int i;
 	for (i = 0; i < 5; ++i ) {
 		daemon_reply reply = daemon_send_simple(h, "hello world", "param = %d", 3, NULL);
-		fprintf(stderr, "[C] REPLY: %s, param = %d\n", find_config_str(reply.cft->root, "request", "NONE"),
-			                                       find_config_int(reply.cft->root, "param", -1));
+		fprintf(stderr, "[C] REPLY: %s, param = %d\n", daemon_reply_str(reply, "request", "NONE"),
+			                                       daemon_reply_int(reply, "param", -1));
 		daemon_reply_destroy(reply);
 	}
 	daemon_close(h);


