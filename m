From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 12 Oct 2012 08:58:35 +0000 (UTC)
Subject: master - lvmetad: Make --sysinit suppress connection failure warnings.
Message-ID: <20121012085835.E1A99A0D9C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=28776b9526784fc3dd2ab94a4151613771c4dfda
Commit:        28776b9526784fc3dd2ab94a4151613771c4dfda
Parent:        9ee071705b2c35e1132f39f5731861c831a1bb6b
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Oct 12 02:48:39 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Fri Oct 12 10:58:04 2012 +0200

lvmetad: Make --sysinit suppress connection failure warnings.

---
 lib/cache/lvmetad.c |    9 +++++++--
 lib/cache/lvmetad.h |    4 ++++
 tools/lvmcmdline.c  |    3 +++
 3 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 5d211c6..b1c799a 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -49,11 +49,16 @@ void lvmetad_init(struct cmd_context *cmd)
 		if (_lvmetad.socket_fd >= 0 && !_lvmetad.error) {
 			_lvmetad_connected = 1;
 			_lvmetad_cmd = cmd;
-		} else
-			log_warn("WARNING: Failed to connect to lvmetad: %s. Falling back to internal scanning.", strerror(_lvmetad.error));
+		}
 	}
 }
 
+void lvmetad_warning()
+{
+	log_warn("WARNING: Failed to connect to lvmetad: %s. Falling back to internal scanning.",
+		 strerror(_lvmetad.error));
+}
+
 int lvmetad_active(void)
 {
 	return _lvmetad_use && _lvmetad_connected;
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 10c4b13..f6e7b67 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -48,6 +48,9 @@ void lvmetad_set_socket(const char *);
  */
 int lvmetad_active(void);
 
+/* Print a warning if lvmetad is enabled but we failed to connect. */
+void lvmetad_warning(void);
+
 /*
  * Drop connection to lvmetad. A subsequent lvmetad_init() will re-establish
  * the connection (possibly at a different socket path).
@@ -137,6 +140,7 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 #    define lvmetad_set_active(a)	do { } while (0)
 #    define lvmetad_set_socket(a)	do { } while (0)
 #    define lvmetad_active()	(0)
+#    define lvmetad_warning()	do { } while (0)
 #    define lvmetad_set_token(a)	do { } while (0)
 #    define lvmetad_vg_update(vg)	(1)
 #    define lvmetad_vg_remove(vg)	(1)
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index bccf7a6..efcefe3 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -876,6 +876,9 @@ static int _get_settings(struct cmd_context *cmd)
 	else
 		init_ignorelockingfailure(0);
 
+	if (!arg_count(cmd, sysinit_ARG))
+		lvmetad_warning();
+
 	if (arg_count(cmd, nosuffix_ARG))
 		cmd->current_settings.suffix = 0;
 


