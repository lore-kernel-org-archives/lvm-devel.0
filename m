From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 19 Dec 2008 14:43:03 -0000
Subject: LVM2 ./WHATS_NEW tools/lvmcmdline.c
Message-ID: <20081219144303.19227.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2008-12-19 14:43:03

Modified files:
	.              : WHATS_NEW 
	tools          : lvmcmdline.c 

Log message:
	Fix incorrect return value in help function.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1010&r2=1.1011
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91

--- LVM2/WHATS_NEW	2008/12/19 14:22:48	1.1010
+++ LVM2/WHATS_NEW	2008/12/19 14:43:02	1.1011
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Fix incorrect return value in help function.
   Fix vgrename using UUID in case there are VGs with the same name.
   Fix segfault when invalid field given in reporting commands.
   Refactor init_lvm() for lvmcmdline and clvmd.
--- LVM2/tools/lvmcmdline.c	2008/12/18 05:27:18	1.90
+++ LVM2/tools/lvmcmdline.c	2008/12/19 14:43:02	1.91
@@ -568,14 +568,17 @@
 	log_error("Run `%s --help' for more information.", name);
 }
 
-static void _usage(const char *name)
+static int _usage(const char *name)
 {
 	struct command *com = _find_command(name);
 
-	if (!com)
-		return;
+	if (!com) {
+		log_print("%s: no such command.", name);
+		return 0;
+	}
 
 	log_print("%s: %s\n\n%s", com->name, com->desc, com->usage);
+	return 1;
 }
 
 /*
@@ -852,15 +855,18 @@
 
 int help(struct cmd_context *cmd __attribute((unused)), int argc, char **argv)
 {
+	int ret = ECMD_PROCESSED;
+
 	if (!argc)
 		_display_help();
 	else {
 		int i;
 		for (i = 0; i < argc; i++)
-			_usage(argv[i]);
+			if (!_usage(argv[i]))
+				ret = EINVALID_CMD_LINE;
 	}
 
-	return 0;
+	return ret;
 }
 
 static int _override_settings(struct cmd_context *cmd)


