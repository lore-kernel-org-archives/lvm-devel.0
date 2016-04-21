From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 21 Apr 2016 14:52:55 +0000 (UTC)
Subject: master - lvmetad: check pid for warning case
Message-ID: <20160421145255.C260E61ECB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e44c4806db2424c6e375ac06391f0bcd475e6ce7
Commit:        e44c4806db2424c6e375ac06391f0bcd475e6ce7
Parent:        d00b70c789cca1ca73b3d1311db9981d9ca5056b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 21 09:50:59 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 21 09:50:59 2016 -0500

lvmetad: check pid for warning case

When command is not using lvmetad because
use_lvmetad=0 in the config, but the lvmetad
pidfile exists, print a warning (previously
this checked for the socket existing instead
of the pidfile existing.)
---
 lib/cache/lvmetad.c        |    7 +++++++
 lib/cache/lvmetad.h        |    6 ++++++
 lib/commands/toolcontext.c |    2 +-
 3 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index e50234a..8d13a59 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -165,6 +165,13 @@ void lvmetad_make_unused(struct cmd_context *cmd)
 		stack;
 }
 
+int lvmetad_pidfile_present(void)
+{
+	const char *pidfile = getenv("LVM_LVMETAD_PIDFILE") ?: LVMETAD_PIDFILE;
+
+	return !access(pidfile, F_OK);
+}
+
 int lvmetad_socket_present(void)
 {
 	const char *socket = _lvmetad_socket ?: LVMETAD_SOCKET;
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 699c9a4..240610b 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -53,6 +53,12 @@ void lvmetad_set_socket(const char *);
 int lvmetad_socket_present(void);
 
 /*
+ * Check if lvmetad pidfile is present, indicating that the lvmetad
+ * process is running or not.
+ */
+int lvmetad_pidfile_present(void);
+
+/*
  * Set the "lvmetad validity token" (currently only consists of the lvmetad
  * filter. See lvm.conf.
  */
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 1f8ac4c..67d4f99 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1720,7 +1720,7 @@ static int _init_lvmetad(struct cmd_context *cmd)
 	}
 
 	if (!find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL)) {
-		if (lvmetad_socket_present())
+		if (lvmetad_pidfile_present())
 			log_warn("WARNING: Not using lvmetad because config setting use_lvmetad=0.");
 		return 1;
 	}


