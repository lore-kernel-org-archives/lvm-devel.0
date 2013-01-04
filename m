From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  4 Jan 2013 23:48:30 +0000 (UTC)
Subject: master - libdaemon: add logging to daemon_open
Message-ID: <20130104234830.7663C231A@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=981962b339123338335da5a3cda822117808c591
Commit:        981962b339123338335da5a3cda822117808c591
Parent:        6d760b2c63f463364b71fa8d0679ac9b5242cae1
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jan 4 23:29:59 2013 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jan 4 23:29:59 2013 +0000

libdaemon: add logging to daemon_open

Log all conditions encountered in daemon_open().

Only store errno when known to be set.
---
 libdaemon/client/daemon-client.c |   36 ++++++++++++++++++++++++++++--------
 1 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/libdaemon/client/daemon-client.c b/libdaemon/client/daemon-client.c
index 371dc5c..a821cf3 100644
--- a/libdaemon/client/daemon-client.c
+++ b/libdaemon/client/daemon-client.c
@@ -25,41 +25,61 @@
 #include <assert.h>
 #include <errno.h> // ENOMEM
 
-daemon_handle daemon_open(daemon_info i) {
+daemon_handle daemon_open(daemon_info i)
+{
 	daemon_handle h = { .protocol_version = 0, .error = 0 };
 	daemon_reply r = { 0 };
 	struct sockaddr_un sockaddr = { .sun_family = AF_UNIX };
 
-	if ((h.socket_fd = socket(PF_UNIX, SOCK_STREAM /* | SOCK_NONBLOCK */, 0)) < 0)
+	log_debug("%s: Opening daemon socket to %s for protocol %s version %d.",
+		  i.socket, i.path, i.protocol, i.protocol_version);
+
+	if ((h.socket_fd = socket(PF_UNIX, SOCK_STREAM /* | SOCK_NONBLOCK */, 0)) < 0) {
+		h.error = errno;
+		log_sys_error("socket", i.socket);
 		goto error;
+	}
 
 	if (!dm_strncpy(sockaddr.sun_path, i.socket, sizeof(sockaddr.sun_path))) {
-		fprintf(stderr, "%s: daemon socket path too long.\n", i.socket);
+		log_error("%s: Daemon socket path too long.", i.socket);
 		goto error;
 	}
 
-	if (connect(h.socket_fd,(struct sockaddr *) &sockaddr, sizeof(sockaddr)))
+	if (connect(h.socket_fd,(struct sockaddr *) &sockaddr, sizeof(sockaddr))) {
+		h.error = errno;
+		log_sys_error("connect", i.socket);
 		goto error;
+	}
 
+	log_debug("Sending daemon %s: hello", i.path);
 	r = daemon_send_simple(h, "hello", NULL);
-	if (r.error || strcmp(daemon_reply_str(r, "response", "unknown"), "OK"))
+	if (r.error || strcmp(daemon_reply_str(r, "response", "unknown"), "OK")) {
+		h.error = r.error;
+		log_error("Daemon %s returned error %d", i.path, r.error);
 		goto error;
+	}
 
+	/* Check protocol and version matches */
 	h.protocol = daemon_reply_str(r, "protocol", NULL);
 	if (h.protocol)
 		h.protocol = dm_strdup(h.protocol); /* keep around */
 	h.protocol_version = daemon_reply_int(r, "version", 0);
 
-	if (i.protocol && (!h.protocol || strcmp(h.protocol, i.protocol)))
+	if (i.protocol && (!h.protocol || strcmp(h.protocol, i.protocol))) {
+		log_error("Daemon %s: requested protocol %s != %s",
+			i.path, i.protocol, h.protocol ? : "");
 		goto error;
-	if (i.protocol_version && h.protocol_version != i.protocol_version)
+	}
+	if (i.protocol_version && h.protocol_version != i.protocol_version) {
+		log_error("Daemon %s: requested protocol version %d != %d",
+			  i.path, i.protocol_version, h.protocol_version);
 		goto error;
+	}
 
 	daemon_reply_destroy(r);
 	return h;
 
 error:
-	h.error = errno;
 	if (h.socket_fd >= 0)
 		if (close(h.socket_fd))
 			log_sys_error("close", "daemon_open");


