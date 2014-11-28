From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 28 Nov 2014 21:38:12 +0000 (UTC)
Subject: master - libdaemon: Fix some client leaks.
Message-ID: <20141128213812.65285607A3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6521c4b2156597a36a986def85449be734336c72
Commit:        6521c4b2156597a36a986def85449be734336c72
Parent:        530ebd8976bc08fdbaac7c132301fdde1e66ed8f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Nov 28 21:31:51 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Nov 28 21:31:51 2014 +0000

libdaemon: Fix some client leaks.

Free (and clear) h.protocol string on daemon_open() error paths
so it's OK for caller to skip calling daemon_close() if returned
h.socket_fd is -1.

Close h.socket_fd in daemon_close() to avoid possible leak.

https://bugzilla.redhat.com/1164234
---
 WHATS_NEW                        |    1 +
 daemons/lvmetad/testclient.c     |    4 +++-
 libdaemon/client/daemon-client.c |   30 +++++++++++++++++++++++-------
 libdaemon/client/daemon-client.h |    7 ++++---
 4 files changed, 31 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 89f0ebb..b1cce84 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.114 - 
 =====================================
+  Release socket in daemon_close and protocol string in a daemon_open error path.
   Add --cachepolicy and --cachesettings to lvcreate.
   Fix regression when parsing /dev/mapper dir (2.02.112).
   Fix missing rounding to 64KB when estimating optimal thin pool chunk size.
diff --git a/daemons/lvmetad/testclient.c b/daemons/lvmetad/testclient.c
index c4cf7c5..8ea068d 100644
--- a/daemons/lvmetad/testclient.c
+++ b/daemons/lvmetad/testclient.c
@@ -105,6 +105,7 @@ void _dump_vg(daemon_handle h, const char *uuid)
 
 int main(int argc, char **argv) {
 	daemon_handle h = lvmetad_open();
+	/* FIXME Missing error path */
 
 	if (argc > 1) {
 		int i;
@@ -114,6 +115,7 @@ int main(int argc, char **argv) {
 			scan(h, argv[i]);
 		}
 		destroy_toolcontext(cmd);
+		/* FIXME Missing lvmetad_close() */
 		return 0;
 	}
 
@@ -122,6 +124,6 @@ int main(int argc, char **argv) {
 	_dump_vg(h, vgid);
 	_pv_add(h, uuid3, NULL);
 
-	daemon_close(h);
+	daemon_close(h);	/* FIXME lvmetad_close? */
 	return 0;
 }
diff --git a/libdaemon/client/daemon-client.c b/libdaemon/client/daemon-client.c
index d0b8951..d37b966 100644
--- a/libdaemon/client/daemon-client.c
+++ b/libdaemon/client/daemon-client.c
@@ -26,7 +26,11 @@
 
 daemon_handle daemon_open(daemon_info i)
 {
-	daemon_handle h = { .protocol_version = 0, .error = 0 };
+	daemon_handle h = {
+		.protocol = NULL,
+		.protocol_version = 0,
+		.error = 0
+	};
 	daemon_reply r = { 0 };
 	struct sockaddr_un sockaddr = { .sun_family = AF_UNIX };
 
@@ -79,12 +83,16 @@ daemon_handle daemon_open(daemon_info i)
 	return h;
 
 error:
-	if (h.socket_fd >= 0)
-		if (close(h.socket_fd))
-			log_sys_error("close", "daemon_open");
+	if (h.socket_fd >= 0 && close(h.socket_fd))
+		log_sys_error("close", "daemon_open");
+	h.socket_fd = -1;
+
 	if (r.cft)
 		daemon_reply_destroy(r);
-	h.socket_fd = -1;
+
+	dm_free((char *)h.protocol);
+	h.protocol = NULL;
+
 	return h;
 }
 
@@ -118,7 +126,8 @@ daemon_reply daemon_send(daemon_handle h, daemon_request rq)
 	return reply;
 }
 
-void daemon_reply_destroy(daemon_reply r) {
+void daemon_reply_destroy(daemon_reply r)
+{
 	if (r.cft)
 		dm_config_destroy(r.cft);
 	buffer_destroy(&r.buffer);
@@ -160,6 +169,12 @@ daemon_reply daemon_send_simple(daemon_handle h, const char *id, ...)
 
 void daemon_close(daemon_handle h)
 {
+	if (h.socket_fd >= 0) {
+		log_debug("Closing daemon socket (fd %d).", h.socket_fd);
+ 		if (close(h.socket_fd))
+			log_sys_error("close", "daemon_close");
+	}
+
 	dm_free((char *)h.protocol);
 }
 
@@ -210,7 +225,8 @@ int daemon_request_extend(daemon_request r, ...)
 	return res;
 }
 
-void daemon_request_destroy(daemon_request r) {
+void daemon_request_destroy(daemon_request r)
+{
 	if (r.cft)
 		dm_config_destroy(r.cft);
 	buffer_destroy(&r.buffer);
diff --git a/libdaemon/client/daemon-client.h b/libdaemon/client/daemon-client.h
index ae3be91..e1445c1 100644
--- a/libdaemon/client/daemon-client.h
+++ b/libdaemon/client/daemon-client.h
@@ -97,15 +97,16 @@ void daemon_request_destroy(daemon_request r);
 
 void daemon_reply_destroy(daemon_reply r);
 
-static inline int64_t daemon_reply_int(daemon_reply r, const char *path, int64_t def) {
+static inline int64_t daemon_reply_int(daemon_reply r, const char *path, int64_t def)
+{
 	return dm_config_find_int64(r.cft->root, path, def);
 }
 
-static inline const char *daemon_reply_str(daemon_reply r, const char *path, const char *def) {
+static inline const char *daemon_reply_str(daemon_reply r, const char *path, const char *def)
+{
 	return dm_config_find_str_allow_empty(r.cft->root, path, def);
 }
 
-
 /* Shut down the communication to the daemon. Compulsory. */
 void daemon_close(daemon_handle h);
 


