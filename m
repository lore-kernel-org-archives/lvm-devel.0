From: Thomas Woerner <twoerner@redhat.com>
Date: Fri, 20 Feb 2009 17:41:49 +0100
Subject: [PATCH 1/3] New parameter system_dir for create_toolcontext.
In-Reply-To: <1235148111-10652-1-git-send-email-twoerner@redhat.com>
References: <1235148111-10652-1-git-send-email-twoerner@redhat.com>
Message-ID: <1235148111-10652-2-git-send-email-twoerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

cmd->sys_dir, which defaults to DEFAULT_SYS_DIR, will be set to system_dir i
the parameter is not NULL. If the environment variable LVM_SYSTEM_DIR is set
it will overwrite any value of cmd->sys_dir.

Signed-off-by: Thomas Woerner <twoerner@redhat.com>
---
 daemons/clvmd/lvm-functions.c |    4 ++--
 lib/commands/toolcontext.c    |   16 ++++++++++++++--
 lib/commands/toolcontext.h    |    9 +++++++--
 tools/lvmcmdline.c            |    4 ++--
 4 files changed, 25 insertions(+), 8 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 5cf7eff..d720802 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -724,7 +724,7 @@ void lvm_do_backup(const char *vgname)
 /* Called to initialise the LVM context of the daemon */
 int init_lvm(int using_gulm)
 {
-	if (!(cmd = create_toolcontext(1))) {
+	if (!(cmd = create_toolcontext(1, NULL))) {
 		log_error("Failed to allocate command context");
 		return 0;
 	}
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 0a98325..39c644c 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -998,7 +998,8 @@ static void _init_globals(struct cmd_context *cmd)
 }
 
 /* Entry point */
-struct cmd_context *create_toolcontext(unsigned is_long_lived)
+struct cmd_context *create_toolcontext(unsigned is_long_lived,
+				       const char *system_dir)
 {
 	struct cmd_context *cmd;
 
@@ -1030,6 +1031,17 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived)
 
 	strcpy(cmd->sys_dir, DEFAULT_SYS_DIR);
 
+	/*
+	 * cmd->sys_dir, which defaults to DEFAULT_SYS_DIR, will be set to 
+	 * system_dir if the parameter is not NULL. If the environment 
+	 * variable LVM_SYSTEM_DIR is set, it will overwrite any value of 
+	 * cmd->sys_dir.
+	 */
+        if (system_dir) {
+		strncpy(cmd->sys_dir, system_dir, sizeof(cmd->sys_dir));
+		cmd->sys_dir[sizeof(cmd->sys_dir) - 1] = '\0';
+	}
+
 	if (!_get_env_vars(cmd))
 		goto error;
 
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 7d2aef9..eb2b6ef 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -94,7 +94,12 @@ struct cmd_context {
 	char sysfs_dir[PATH_MAX];
 };
 
-struct cmd_context *create_toolcontext(unsigned is_long_lived);
+/*
+ * cmd->sys_dir, which defaults to DEFAULT_SYS_DIR, will be set to system_dir 
+ * if the parameter is not NULL. If the environment variable LVM_SYSTEM_DIR is 
+ * set, it will overwrite any value of cmd->sys_dir.
+ */
+struct cmd_context *create_toolcontext(unsigned is_long_lived, const char *system_dir);
 void destroy_toolcontext(struct cmd_context *cmd);
 int refresh_toolcontext(struct cmd_context *cmd);
 int config_files_changed(struct cmd_context *cmd);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 880f31e..cb1bfc6 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -1158,7 +1158,7 @@ struct cmd_context *init_lvm(void)
 
 	_cmdline.the_args = &_the_args[0];
 
-	if (!(cmd = create_toolcontext(0)))
+	if (!(cmd = create_toolcontext(0, NULL)))
 		return_NULL;
 
 	return cmd;
-- 
1.6.1.3


