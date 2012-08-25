From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 25 Aug 2012 23:28:51 +0000 (UTC)
Subject: master - buffering: use unbuffered silent mode for liblvm
Message-ID: <20120825232851.3604DA1503@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3acc85caa8d313b8c21e4bef7f84601731e74b2b
Commit:        3acc85caa8d313b8c21e4bef7f84601731e74b2b
Parent:        438e0050dfed1f8f2d74670a5f7c5e8c8819c777
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sun Aug 26 00:15:45 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sun Aug 26 00:15:45 2012 +0100

buffering: use unbuffered silent mode for liblvm

Disable private buffering when using liblvm.
When private stdin/stdout buffering is not used always use silent
mode.
---
 WHATS_NEW                  |    2 ++
 doc/example.conf.in        |    2 ++
 lib/commands/toolcontext.c |   12 +++++++++---
 lib/display/display.c      |    9 ++++++++-
 lib/metadata/lv_manip.c    |    1 +
 liblvm/lvm_base.c          |    2 +-
 6 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7d070f9..acb158b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.98 -
 =================================
+  Disable private buffering when using liblvm.
+  When private stdin/stdout buffering is not used always use silent mode.
   Add log/silent to lvm.conf equivalent to -qq.
   Suppress non-essential stdout with -qq.
   Switch non-essential log_print messages to log_print_unless_silent.
diff --git a/doc/example.conf.in b/doc/example.conf.in
index 479b74b..8cec63c 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -241,6 +241,8 @@ log {
     # pvs, version, vgcfgrestore -l, vgdisplay, vgs.
     # Non-essential messages are shifted from log level 4 to log level 5
     # for syslog and lvm2_log_fn purposes.
+    # Any 'yes' or 'no' questions not overridden by other arguments
+    # are suppressed and default to 'no'.
     silent = 0
 
     # Should we send log messages through syslog?
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 57667b6..4230624 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -144,8 +144,12 @@ static void _init_logging(struct cmd_context *cmd)
 	    find_config_tree_int(cmd, "log/level", DEFAULT_LOGLEVEL);
 	init_debug(cmd->default_settings.debug);
 
-	/* Suppress all non-essential stdout? */
-	cmd->default_settings.silent = 
+	/*
+	 * Suppress all non-essential stdout?
+	 * -qq can override the default of 0 to 1 later.
+	 * Once set to 1, there is no facility to change it back to 0.
+	 */
+	cmd->default_settings.silent = silent_mode() ? :
 	    find_config_tree_int(cmd, "log/silent", DEFAULT_SILENT);
 	init_silent(cmd->default_settings.silent);
 
@@ -1296,7 +1300,9 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 			goto out;
 		}
 		/* Buffers are used for lines without '\n' */
-	}
+	} else
+		/* Without buffering, must not use stdin/stdout */
+		init_silent(1);
 
 	/*
 	 * Environment variable LVM_SYSTEM_DIR overrides this below.
diff --git a/lib/display/display.c b/lib/display/display.c
index 2422b51..b15ff71 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -902,11 +902,19 @@ void display_segtypes(const struct cmd_context *cmd)
 	}
 }
 
+/*
+ * Prompt for y or n from stdin.
+ * Defaults to 'no' in silent mode.
+ * All callers should support --yes and/or --force to override this.
+ */
 char yes_no_prompt(const char *prompt, ...)
 {
 	int c = 0, ret = 0;
 	va_list ap;
 
+	if (silent_mode())
+		return 'n';
+
 	sigint_allow();
 	do {
 		if (c == '\n' || !c) {
@@ -939,4 +947,3 @@ char yes_no_prompt(const char *prompt, ...)
 
 	return ret;
 }
-
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d591b7b..617d4b7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2741,6 +2741,7 @@ int lv_extend(struct logical_volume *lv,
 				log_error("%s/%s is not active."
 					  "  Unable to get sync percent.",
 					  lv->vg->name, lv->name);
+				/* FIXME Support --force */
 				if (yes_no_prompt("Do full resync of extended "
 						  "portion of %s/%s?  [y/n]: ",
 						  lv->vg->name, lv->name) == 'y')
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 2f39b46..815151e 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -37,7 +37,7 @@ lvm_t lvm_init(const char *system_dir)
 	/* create context */
 	/* FIXME: split create_toolcontext */
 	/* FIXME: make all globals configurable */
-	cmd = create_toolcontext(0, system_dir, 1, 0);
+	cmd = create_toolcontext(0, system_dir, 0, 0);
 	if (!cmd)
 		return NULL;
 


