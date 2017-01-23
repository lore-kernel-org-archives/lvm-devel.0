From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 23 Jan 2017 13:56:42 +0000 (UTC)
Subject: master - clean: move code to lib part
Message-ID: <20170123135642.81B8F60727@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4a7f2155c1d6bd5df1226632c5c5d5631c5abc97
Commit:        4a7f2155c1d6bd5df1226632c5c5d5631c5abc97
Parent:        2d48317d3aa2283e606c9a200b68bd3eac67f0a4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 23 14:21:56 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 23 14:55:28 2017 +0100

clean: move code to lib part

Move actual processing part of the lvm2_disable_dmeventd_monitoring()
into a /lib part so we can reuse the code later for other cases.
---
 lib/commands/toolcontext.c |    9 +++++++++
 lib/commands/toolcontext.h |    1 +
 tools/lvmcmdlib.c          |    7 +++----
 3 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 394aa4b..2843bf8 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1755,6 +1755,15 @@ bad:
 	return 0;
 }
 
+int init_run_by_dmeventd(struct cmd_context *cmd)
+{
+	init_dmeventd_monitor(DMEVENTD_MONITOR_IGNORE);
+	init_ignore_suspended_devices(1);
+	init_disable_dmeventd_monitoring(1); /* Lock settings */
+
+	return 0;
+}
+
 void destroy_config_context(struct cmd_context *cmd)
 {
 	_destroy_config(cmd);
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index c6d938d..bb962dc 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -233,6 +233,7 @@ int config_files_changed(struct cmd_context *cmd);
 int init_lvmcache_orphans(struct cmd_context *cmd);
 int init_filters(struct cmd_context *cmd, unsigned load_persistent_cache);
 int init_connections(struct cmd_context *cmd);
+int init_run_by_dmeventd(struct cmd_context *cmd);
 
 /*
  * A config context is a very light weight cmd struct that
diff --git a/tools/lvmcmdlib.c b/tools/lvmcmdlib.c
index 0243768..64c0d8b 100644
--- a/tools/lvmcmdlib.c
+++ b/tools/lvmcmdlib.c
@@ -98,10 +98,9 @@ int lvm2_run(void *handle, const char *cmdline)
 	return ret;
 }
 
-void lvm2_disable_dmeventd_monitoring(void *handle) {
-	init_dmeventd_monitor(DMEVENTD_MONITOR_IGNORE);
-	init_ignore_suspended_devices(1);
-	init_disable_dmeventd_monitoring(1); /* Lock settings */
+void lvm2_disable_dmeventd_monitoring(void *handle)
+{
+	init_run_by_dmeventd((struct cmd_context *) handle);
 }
 
 void lvm2_log_level(void *handle, int level)


