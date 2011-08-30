From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Aug 2011 15:42:58 -0000
Subject: LVM2/daemons/common daemon-client.c daemon-cli ...
Message-ID: <20110830154258.30672.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-08-30 15:42:57

Modified files:
	daemons/common : daemon-client.c daemon-client.h daemon-server.c 
	                 daemon-server.h 

Log message:
	Adapt the daemon/common code to use the new dm_config interface.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/daemons/common/daemon-client.c	2011/06/29 22:20:14	1.5
+++ LVM2/daemons/common/daemon-client.c	2011/08/30 15:42:56	1.6
@@ -44,7 +44,7 @@
 	write_buffer(h.socket_fd, rq.buffer, strlen(rq.buffer));
 
 	if (read_buffer(h.socket_fd, &reply.buffer)) {
-		reply.cft = create_config_tree_from_string(reply.buffer);
+		reply.cft = dm_config_from_string(reply.buffer);
 	} else
 		reply.error = 1;
 
--- LVM2/daemons/common/daemon-client.h	2011/07/18 14:46:54	1.7
+++ LVM2/daemons/common/daemon-client.h	2011/08/30 15:42:57	1.8
@@ -13,7 +13,6 @@
  */
 
 #include "libdevmapper.h" // for dm_list, needed by config.h
-#include "config.h" // should become part of libdevmapper later
 
 #ifndef _LVM_DAEMON_COMMON_CLIENT_H
 #define _LVM_DAEMON_COMMON_CLIENT_H
@@ -42,13 +41,13 @@
 	 *        knobs = [ "twiddle", "tweak" ]
 	 *    }
 	 */
-	struct config_tree *cft;
+	struct dm_config_tree *cft;
 } daemon_request;
 
 typedef struct {
 	int error; /* 0 for success */
 	char *buffer; /* textual reply */
-	struct config_tree *cft; /* parsed reply, if available */
+	struct dm_config_tree *cft; /* parsed reply, if available */
 } daemon_reply;
 
 /*
@@ -83,11 +82,11 @@
 void daemon_reply_destroy(daemon_reply r);
 
 static inline int daemon_reply_int(daemon_reply r, const char *path, int def) {
-	return find_config_int(r.cft->root, path, def);
+	return dm_config_find_int(r.cft->root, path, def);
 }
 
 static inline const char *daemon_reply_str(daemon_reply r, const char *path, const char *def) {
-	return find_config_str(r.cft->root, path, def);
+	return dm_config_find_str(r.cft->root, path, def);
 }
 
 
--- LVM2/daemons/common/daemon-server.c	2011/07/20 18:23:33	1.9
+++ LVM2/daemons/common/daemon-server.c	2011/08/30 15:42:57	1.10
@@ -242,7 +242,7 @@
 		if (!read_buffer(b->client.socket_fd, &req.buffer))
 			goto fail;
 
-		req.cft = create_config_tree_from_string(req.buffer);
+		req.cft = dm_config_from_string(req.buffer);
 		if (!req.cft)
 			fprintf(stderr, "error parsing request:\n %s\n", req.buffer);
 		response res = b->s.handler(b->s, b->client, req);
@@ -251,7 +251,7 @@
 		dm_free(req.buffer);
 
 		if (!res.buffer) {
-			write_config_node(res.cft->root, buffer_line, &res);
+			dm_config_write_node(res.cft->root, buffer_line, &res);
 			buffer_rewrite(&res.buffer, "%s\n\n", NULL);
 			destroy_config_tree(res.cft);
 		}
@@ -323,6 +323,7 @@
 	signal(SIGHUP, &_exit_handler);
 	signal(SIGQUIT, &_exit_handler);
 	signal(SIGTERM, &_exit_handler);
+	signal(SIGALRM, &_exit_handler);
 	signal(SIGPIPE, SIG_IGN);
 
 #ifdef linux
--- LVM2/daemons/common/daemon-server.h	2011/07/18 14:46:54	1.9
+++ LVM2/daemons/common/daemon-server.h	2011/08/30 15:42:57	1.10
@@ -13,7 +13,6 @@
  */
 
 #include "daemon-client.h"
-#include "config.h" // XXX will be in libdevmapper.h later
 
 #ifndef _LVM_DAEMON_COMMON_SERVER_H
 #define _LVM_DAEMON_COMMON_SERVER_H
@@ -26,13 +25,13 @@
 } client_handle;
 
 typedef struct {
-	struct config_tree *cft;
+	struct dm_config_tree *cft;
 	char *buffer;
 } request;
 
 typedef struct {
 	int error;
-	struct config_tree *cft;
+	struct dm_config_tree *cft;
 	char *buffer;
 } response;
 
@@ -47,13 +46,13 @@
 static inline int daemon_request_int(request r, const char *path, int def) {
 	if (!r.cft)
 		return def;
-	return find_config_int(r.cft->root, path, def);
+	return dm_config_find_int(r.cft->root, path, def);
 }
 
 static inline const char *daemon_request_str(request r, const char *path, const char *def) {
 	if (!r.cft)
 		return def;
-	return find_config_str(r.cft->root, path, def);
+	return dm_config_find_str(r.cft->root, path, def);
 }
 
 /*


