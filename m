From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  4 Jan 2013 23:48:27 +0000 (UTC)
Subject: master - lvmetad: improve client logging when connecting
Message-ID: <20130104234827.AE69E231A@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d760b2c63f463364b71fa8d0679ac9b5242cae1
Commit:        6d760b2c63f463364b71fa8d0679ac9b5242cae1
Parent:        a527a3b8c25200284824cd43ec7693d5543741a4
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jan 4 23:22:30 2013 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jan 4 23:22:30 2013 +0000

lvmetad: improve client logging when connecting

Rename lvmetad_warning() to lvmetad_connect_or_warn().

Log all connection attempts on the client side, whether successful or not.

Reduce some nesting and remove a redundant assertion.
---
 lib/cache/lvmetad.c |   27 +++++++++++++++++++--------
 lib/cache/lvmetad.h |    9 ++++++---
 tools/lvmcmdline.c  |    2 +-
 3 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 67e083b..0862f0a 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -20,7 +20,6 @@
 #include "lvmcache.h"
 #include "lvmetad-client.h"
 #include "format-text.h" // TODO for disk_locn, used as a DA representation
-#include "assert.h"
 #include "crc.h"
 
 static daemon_handle _lvmetad;
@@ -49,19 +48,26 @@ void lvmetad_init(struct cmd_context *cmd)
 
 static void _lvmetad_connect()
 {
-	if (_lvmetad_use && _lvmetad_socket && !_lvmetad_connected) {
-		assert(_lvmetad_socket);
-		_lvmetad = lvmetad_open(_lvmetad_socket);
-		if (_lvmetad.socket_fd >= 0 && !_lvmetad.error)
-			_lvmetad_connected = 1;
+	if (!_lvmetad_use || !_lvmetad_socket || _lvmetad_connected)
+		return;
+
+	_lvmetad = lvmetad_open(_lvmetad_socket);
+	if (_lvmetad.socket_fd >= 0 && !_lvmetad.error) {
+		log_debug("Successfully connected to lvmetad on fd %d.",
+			  _lvmetad.socket_fd);
+		_lvmetad_connected = 1;
 	}
 }
 
-void lvmetad_warning(void)
+void lvmetad_connect_or_warn(void)
 {
+	if (!_lvmetad_use)
+		return;
+
 	if (!_lvmetad_connected)
 		_lvmetad_connect();
-	if (_lvmetad_use && (_lvmetad.socket_fd < 0 || _lvmetad.error))
+
+	if ((_lvmetad.socket_fd < 0 || _lvmetad.error))
 		log_warn("WARNING: Failed to connect to lvmetad: %s. Falling back to internal scanning.",
 			 strerror(_lvmetad.error));
 }
@@ -70,8 +76,13 @@ int lvmetad_active(void)
 {
 	if (!_lvmetad_use)
 		return 0;
+
 	if (!_lvmetad_connected)
 		_lvmetad_connect();
+
+	if ((_lvmetad.socket_fd < 0 || _lvmetad.error))
+		log_debug("Failed to connect to lvmetad: %s.", strerror(_lvmetad.error));
+
 	return _lvmetad_connected;
 }
 
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index c644069..7886965 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -49,8 +49,11 @@ void lvmetad_set_socket(const char *);
  */
 int lvmetad_active(void);
 
-/* Print a warning if lvmetad is enabled but we failed to connect. */
-void lvmetad_warning(void);
+/* 
+ * Connect to lvmetad unless the connection is already open or lvmetad is
+ * not configured to be used.  If we fail to connect, print a warning.
+ */
+void lvmetad_connect_or_warn(void);
 
 /*
  * Drop connection to lvmetad. A subsequent lvmetad_init() will re-establish
@@ -146,7 +149,7 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 #    define lvmetad_set_active(a)	do { } while (0)
 #    define lvmetad_set_socket(a)	do { } while (0)
 #    define lvmetad_active()	(0)
-#    define lvmetad_warning()	do { } while (0)
+#    define lvmetad_connect_or_warn()	do { } while (0)
 #    define lvmetad_set_token@	do { } while (0)
 #    define lvmetad_release_token()	do { } while (0)
 #    define lvmetad_vg_update(vg)	(1)
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 34d324f..6d6537b 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -877,7 +877,7 @@ static int _get_settings(struct cmd_context *cmd)
 		init_ignorelockingfailure(0);
 
 	if (!arg_count(cmd, sysinit_ARG))
-		lvmetad_warning();
+		lvmetad_connect_or_warn();
 
 	if (arg_count(cmd, nosuffix_ARG))
 		cmd->current_settings.suffix = 0;


