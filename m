From: David Teigland <teigland@sourceware.org>
Date: Mon, 11 Oct 2021 22:15:03 +0000 (GMT)
Subject: main - fix syslog setting
Message-ID: <20211011221503.EDAE03858C3A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=062ea3c4181ef158620556bbab2358bc76eeab90
Commit:        062ea3c4181ef158620556bbab2358bc76eeab90
Parent:        ca38251b1043c49f5453c2c571876b12aad6b450
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 11 17:08:05 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 11 17:11:01 2021 -0500

fix syslog setting

Just setting lvm.conf level=N should not send messages to
syslog (now the journal by default.)

Sending messages to syslog should require setting lvm.conf
log { syslog=1 level=N }.
---
 lib/commands/toolcontext.c | 9 +++------
 lib/config/defaults.h      | 2 +-
 lib/log/log.c              | 7 ++++++-
 lib/log/lvm-logging.h      | 2 +-
 4 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index f939c3e76..5144a9a6e 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -377,12 +377,11 @@ static void _init_logging(struct cmd_context *cmd)
 
 	/* Syslog */
 	cmd->default_settings.syslog = find_config_tree_bool(cmd, log_syslog_CFG, NULL);
-	if (cmd->default_settings.syslog != 1)
+	if (cmd->default_settings.syslog)
+		init_syslog(1, DEFAULT_LOG_FACILITY);
+	else
 		fin_syslog();
 
-	if (cmd->default_settings.syslog > 1)
-		init_syslog(cmd->default_settings.syslog);
-
 	/* Debug level for log file output */
 	cmd->default_settings.debug = find_config_tree_int(cmd, log_level_CFG, NULL);
 	init_debug(cmd->default_settings.debug);
@@ -1653,8 +1652,6 @@ struct cmd_context *create_toolcontext(unsigned is_clvmd,
 	bindtextdomain(INTL_PACKAGE, LOCALEDIR);
 #endif
 
-	init_syslog(DEFAULT_LOG_FACILITY);
-
 	if (!(cmd = zalloc(sizeof(*cmd)))) {
 		log_error("Failed to allocate command context");
 		return NULL;
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index a7a2a06df..54eba3723 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -221,7 +221,7 @@
 #endif
 
 #define DEFAULT_COMMAND_LOG_REPORT 0
-#define DEFAULT_SYSLOG 1
+#define DEFAULT_SYSLOG 0
 #define DEFAULT_VERBOSE 0
 #define DEFAULT_SILENT 0
 #define DEFAULT_LOGLEVEL 0
diff --git a/lib/log/log.c b/lib/log/log.c
index 8ebbf947a..f9568792f 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -312,8 +312,13 @@ void init_log_while_suspended(int log_while_suspended)
 	_log_while_suspended = log_while_suspended;
 }
 
-void init_syslog(int facility)
+void init_syslog(int enable, int facility)
 {
+	if (!enable) {
+		_syslog = 0;
+		return;
+	}
+
 	if (getenv("LVM_SUPPRESS_SYSLOG"))
 		return;
 
diff --git a/lib/log/lvm-logging.h b/lib/log/lvm-logging.h
index fb18a4159..5b975a6b8 100644
--- a/lib/log/lvm-logging.h
+++ b/lib/log/lvm-logging.h
@@ -59,7 +59,7 @@ void init_abort_on_internal_errors(int fatal);
 void fin_log(void);
 void reset_log_duplicated(void);
 
-void init_syslog(int facility);
+void init_syslog(int enable, int facility);
 void fin_syslog(void);
 
 void init_log_journal(uint32_t fields);


