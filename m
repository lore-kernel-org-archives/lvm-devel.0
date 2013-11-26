From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 26 Nov 2013 13:59:59 +0000 (UTC)
Subject: master - lv/vgchange: do not try to connect to lvmetad if socket absent and --sysinit -aay used
Message-ID: <20131126135959.5F80F6022E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8d5cff5b9bb217942c009dca49d0bffb51e85004
Commit:        8d5cff5b9bb217942c009dca49d0bffb51e85004
Parent:        47110f7e27ce2a4bf329e860cf6eb339d107fde7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Nov 26 14:51:23 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Nov 26 14:51:23 2013 +0100

lv/vgchange: do not try to connect to lvmetad if socket absent and --sysinit -aay used

If using lv/vgchange --sysinit -aay and lvmetad is enabled, we'd like to
avoid the direct activation and rely on autoactivation instead so
it fits system initialization scripts.

But if we're calling lv/vgchange --sysinit -aay too early when even
lvmetad service is not started yet, we just need to do the direct
activation instead without printing any error messages (while
trying to connect to lvmetad and not finding its socket).

This patch adds two helper functions - "lvmetad_socket_present" and
"lvmetad_used" which can be used to check for this condition properly
and avoid these lvmetad connections when the socket is not present
(and hence lvmetad is not yet running).
---
 WHATS_NEW                        |    1 +
 daemons/lvmetad/lvmetad-client.h |    4 +++-
 daemons/lvmetad/lvmetad-core.c   |    4 +++-
 lib/cache/lvmetad.c              |   16 ++++++++++++++++
 lib/cache/lvmetad.h              |   15 +++++++++++++++
 tools/lvchange.c                 |   30 ++++++++++++++++++++++++++----
 tools/vgchange.c                 |   30 ++++++++++++++++++++++++++----
 7 files changed, 90 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9b18ef0..4148754 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Do not connect to lvmetad on vg/lvchange --sysinit -aay and socket absent.
   Use lv_check_not_in_use() when testing device in use before merging.
   Move test for target present from init_snapshot_merge() to lvconvert.
   Check for failure of lvmcache_add_mda() when writing pv.
diff --git a/daemons/lvmetad/lvmetad-client.h b/daemons/lvmetad/lvmetad-client.h
index fe8eedc..8d6ae0e 100644
--- a/daemons/lvmetad/lvmetad-client.h
+++ b/daemons/lvmetad/lvmetad-client.h
@@ -17,6 +17,8 @@
 
 #include "daemon-client.h"
 
+#define LVMETAD_SOCKET DEFAULT_RUN_DIR "/lvmetad.socket"
+
 struct volume_group;
 
 /* Different types of replies we may get from lvmetad. */
@@ -64,7 +66,7 @@ static inline daemon_handle lvmetad_open(const char *socket)
 {
 	daemon_info lvmetad_info = {
 		.path = "lvmetad",
-		.socket = socket ?: DEFAULT_RUN_DIR "/lvmetad.socket",
+		.socket = socket ?: LVMETAD_SOCKET,
 		.protocol = "lvmetad",
 		.protocol_version = 1,
 		.autostart = 0
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 03d89c9..87374e8 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -29,6 +29,8 @@
 #include <math.h>  /* fabs() */
 #include <float.h> /* DBL_EPSILON */
 
+#define LVMETAD_SOCKET DEFAULT_RUN_DIR "/lvmetad.socket"
+
 typedef struct {
 	log_state *log; /* convenience */
 	const char *log_config;
@@ -1209,7 +1211,7 @@ int main(int argc, char *argv[])
 
 	if (!s.socket_path) {
 		_socket_override = 0;
-		s.socket_path = DEFAULT_RUN_DIR "/lvmetad.socket";
+		s.socket_path = LVMETAD_SOCKET;
 	}
 	ls.log_config = "";
 
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 5119ab1..1ead9f8 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -72,6 +72,22 @@ void lvmetad_connect_or_warn(void)
 			 strerror(_lvmetad.error));
 }
 
+int lvmetad_used(void)
+{
+	return _lvmetad_use;
+}
+
+int lvmetad_socket_present(void)
+{
+	const char *socket = _lvmetad_socket ?: LVMETAD_SOCKET;
+	int r;
+
+	if ((r = access(socket, F_OK)) && errno != ENOENT)
+		log_sys_error("lvmetad_socket_present", "");
+
+	return !r;
+}
+
 int lvmetad_active(void)
 {
 	if (!_lvmetad_use)
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index ff4cd0a..85b71c2 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -44,6 +44,19 @@ void lvmetad_set_active(int);
 void lvmetad_set_socket(const char *);
 
 /*
+ * Check whether lvmetad is used.
+ */
+int lvmetad_used(void);
+
+/*
+ * Check if lvmetad socket is present (either the one set by lvmetad_set_socket
+ * or the default one if not set). For example, this may be used before calling
+ * lvmetad_active() check that does connect to the socket - this would produce
+ * various connection errors if the socket is not present.
+ */
+int lvmetad_socket_present(void);
+
+/*
  * Check whether lvmetad is active (where active means both that it is running
  * and that we have a working connection with it).
  */
@@ -149,6 +162,8 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 #    define lvmetad_disconnect()	do { } while (0)
 #    define lvmetad_set_active(a)	do { } while (0)
 #    define lvmetad_set_socket(a)	do { } while (0)
+#    define lvmetad_used()	(0)
+#    define lvmetad_socket_present()	(0)
 #    define lvmetad_active()	(0)
 #    define lvmetad_connect_or_warn()	do { } while (0)
 #    define lvmetad_set_token(a)	do { } while (0)
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 1931c03..897ffb2 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1235,11 +1235,33 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, sysinit_ARG) && lvmetad_active() &&
+	/*
+	 * If --sysinit -aay is used and at the same time lvmetad is used,
+	 * we want to rely on autoactivation to take place. Also, we
+	 * need to take special care here as lvmetad service does
+	 * not neet to be running at this moment yet - it could be
+	 * just too early during system initialization time.
+	*/
+	if (arg_count(cmd, sysinit_ARG) && lvmetad_used() &&
 	    arg_uint_value(cmd, activate_ARG, 0) == CHANGE_AAY) {
-		log_warn("lvmetad is active while using --sysinit -a ay, "
-			 "skipping manual activation");
-		return ECMD_PROCESSED;
+		if (!lvmetad_socket_present()) {
+			/*
+			 * If lvmetad socket is not present yet,
+			 * the service is just not started. It'll
+			 * be started a bit later so we need to do
+			 * the activation without lvmetad which means
+			 * direct activation instead of autoactivation.
+			*/
+			log_warn("lvmetad is not active yet, using direct activation during sysinit");
+			lvmetad_set_active(0);
+		} else if (lvmetad_active()) {
+			/*
+			 * If lvmetad is active already, we want
+			 * to make use of the autoactivation.
+			*/
+			log_warn("lvmetad is active, skipping direct activation during sysinit");
+			return ECMD_PROCESSED;
+		}
 	}
 
 	return process_each_lv(cmd, argc, argv,
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 4087fab..b50b444 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -616,11 +616,33 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, sysinit_ARG) && lvmetad_active() &&
+	/*
+	 * If --sysinit -aay is used and at the same time lvmetad is used,
+	 * we want to rely on autoactivation to take place. Also, we
+	 * need to take special care here as lvmetad service does
+	 * not neet to be running at this moment yet - it could be
+	 * just too early during system initialization time.
+	 */
+	if (arg_count(cmd, sysinit_ARG) && lvmetad_used() &&
 	    arg_uint_value(cmd, activate_ARG, 0) == CHANGE_AAY) {
-		log_warn("lvmetad is active while using --sysinit -a ay, "
-			 "skipping manual activation");
-		return ECMD_PROCESSED;
+		if (!lvmetad_socket_present()) {
+			/*
+			 * If lvmetad socket is not present yet,
+			 * the service is just not started. It'll
+			 * be started a bit later so we need to do
+			 * the activation without lvmetad which means
+			 * direct activation instead of autoactivation.
+			 */
+			log_warn("lvmetad is not active yet, using direct activation during sysinit");
+			lvmetad_set_active(0);
+		} else if (lvmetad_active()) {
+			/*
+			 * If lvmetad is active already, we want
+			 * to make use of the autoactivation.
+			 */
+			log_warn("lvmetad is active, skipping direct activation during sysinit");
+			return ECMD_PROCESSED;
+		}
 	}
 
 	if (arg_count(cmd, clustered_ARG) && !argc && !arg_count(cmd, yes_ARG) &&


