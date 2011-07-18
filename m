From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 18 Jul 2011 14:46:55 -0000
Subject: LVM2/daemons/common daemon-client.h daemon-ser ...
Message-ID: <20110718144655.27439.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-18 14:46:54

Modified files:
	daemons/common : daemon-client.h daemon-server.c daemon-server.h 

Log message:
	Various improvements to the daemon-common code, including automated response
	formatting from config trees provided by the daemon implementation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/daemons/common/daemon-client.h	2011/06/27 14:03:58	1.6
+++ LVM2/daemons/common/daemon-client.h	2011/07/18 14:46:54	1.7
@@ -12,6 +12,7 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#include "libdevmapper.h" // for dm_list, needed by config.h
 #include "config.h" // should become part of libdevmapper later
 
 #ifndef _LVM_DAEMON_COMMON_CLIENT_H
--- LVM2/daemons/common/daemon-server.c	2011/06/29 22:20:14	1.7
+++ LVM2/daemons/common/daemon-server.c	2011/07/18 14:46:54	1.8
@@ -218,6 +218,22 @@
 	client_handle client;
 };
 
+int buffer_rewrite(char **buf, const char *format, const char *string) {
+	char *old = *buf;
+	dm_asprintf(buf, format, *buf, string);
+	dm_free(old);
+	return 0;
+}
+
+int buffer_line(const char *line, void *baton) {
+	response *r = baton;
+	if (r->buffer)
+		buffer_rewrite(&r->buffer, "%s\n%s", line);
+	else
+		dm_asprintf(&r->buffer, "%s\n", line);
+	return 0;
+}
+
 void *client_thread(void *baton)
 {
 	struct thread_baton *b = baton;
@@ -227,12 +243,16 @@
 			goto fail;
 
 		req.cft = create_config_tree_from_string(req.buffer);
+		if (!req.cft)
+			fprintf(stderr, "error parsing request:\n %s\n", req.buffer);
 		response res = b->s.handler(b->s, b->client, req);
-		destroy_config_tree(req.cft);
+		if (req.cft)
+			destroy_config_tree(req.cft);
 		dm_free(req.buffer);
 
 		if (!res.buffer) {
-			/* TODO fill in the buffer from res.cft */
+			write_config_node(res.cft->root, buffer_line, &res);
+			buffer_rewrite(&res.buffer, "%s\n\n", NULL);
 		}
 
 		write_buffer(b->client.socket_fd, res.buffer, strlen(res.buffer));
@@ -318,6 +338,9 @@
 	if (!s.foreground)
 		kill(getppid(), SIGTERM);
 
+	if (s.daemon_init)
+		s.daemon_init(&s);
+
 	while (!_shutdown_requested && !failed) {
 		int status;
 		fd_set in;
@@ -333,6 +356,9 @@
 	if (s.socket_fd >= 0)
 		unlink(s.socket_path);
 
+	if (s.daemon_fini)
+		s.daemon_fini(&s);
+
 	syslog(LOG_NOTICE, "%s shutting down", s.name);
 	closelog();
 	remove_lockfile(s.pidfile);
--- LVM2/daemons/common/daemon-server.h	2011/06/27 14:03:59	1.8
+++ LVM2/daemons/common/daemon-server.h	2011/07/18 14:46:54	1.9
@@ -45,10 +45,14 @@
 response daemon_reply_simple(char *id, ...);
 
 static inline int daemon_request_int(request r, const char *path, int def) {
+	if (!r.cft)
+		return def;
 	return find_config_int(r.cft->root, path, def);
 }
 
 static inline const char *daemon_request_str(request r, const char *path, const char *def) {
+	if (!r.cft)
+		return def;
 	return find_config_str(r.cft->root, path, def);
 }
 
@@ -77,7 +81,8 @@
 	const char *socket_path;
 	int log_level;
 	handle_request handler;
-	int (*setup_post)(struct daemon_state *st);
+	int (*daemon_init)(struct daemon_state *st);
+	int (*daemon_fini)(struct daemon_state *st);
 
 	/* Global runtime info maintained by the framework. */
 	int socket_fd;


