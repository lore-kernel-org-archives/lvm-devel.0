From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Jun 2010 20:21:04 -0000
Subject: LVM2/tools args.h lvmcmdline.c tools.h
Message-ID: <20100630202104.24612.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-06-30 20:21:03

Modified files:
	tools          : args.h lvmcmdline.c tools.h 

Log message:
	Fix --[vg]metadatacopies arg processing

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.77&r2=1.78
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.125&r2=1.126
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.69&r2=1.70

--- LVM2/tools/args.h	2010/06/28 20:40:01	1.77
+++ LVM2/tools/args.h	2010/06/30 20:21:03	1.78
@@ -23,8 +23,8 @@
 arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", NULL, 0)
 arg(nolocking_ARG, '\0', "nolocking", NULL, 0)
 arg(pvmetadatacopies_ARG, '\0', "pvmetadatacopies", int_arg, 0)
-arg(vgmetadatacopies_ARG, '\0', "vgmetadatacopies", vgmetadatacopies_arg, 0)
-arg(metadatacopies_ARG, '\0', "metadatacopies", int_arg, 0)
+arg(vgmetadatacopies_ARG, '\0', "vgmetadatacopies", metadatacopies_arg, 0)
+arg(metadatacopies_ARG, '\0', "metadatacopies", metadatacopies_arg, 0)
 arg(metadatasize_ARG, '\0', "metadatasize", size_mb_arg, 0)
 arg(metadataignore_ARG, '\0', "metadataignore", yes_no_arg, 0)
 arg(restorefile_ARG, '\0', "restorefile", string_arg, 0)
--- LVM2/tools/lvmcmdline.c	2010/06/30 16:43:10	1.125
+++ LVM2/tools/lvmcmdline.c	2010/06/30 20:21:03	1.126
@@ -476,29 +476,22 @@
 /*
  * Non-zero, positive integer, "all", or "unmanaged"
  */
-int vgmetadatacopies_arg(struct cmd_context *cmd __attribute((unused)),
+int metadatacopies_arg(struct cmd_context *cmd __attribute((unused)),
 			 struct arg *a)
 {
-	if (!strcasecmp(a->value, "all")) {
-		a->ui_value = VGMETADATACOPIES_ALL;
-		return 1;
-	}
+	if (!strncmp(cmd->command->name, "vg", 2)) {
+		if (!strcasecmp(a->value, "all")) {
+			a->ui_value = VGMETADATACOPIES_ALL;
+			return 1;
+		}
 
-	if (!strcasecmp(a->value, "unmanaged")) {
-		a->ui_value = VGMETADATACOPIES_UNMANAGED;
-		return 1;
+		if (!strcasecmp(a->value, "unmanaged")) {
+			a->ui_value = VGMETADATACOPIES_UNMANAGED;
+			return 1;
+		}
 	}
 
-	if (!_size_arg(cmd, a, 1))
-		return 0;
-
-	if (a->sign == SIGN_MINUS)
-		return 0;
-
-	if (!a->ui_value)
-		return 0;
-
-	return 1;
+	return int_arg(cmd, a);
 }
 
 static void __alloc(int size)
--- LVM2/tools/tools.h	2010/06/28 20:40:01	1.69
+++ LVM2/tools/tools.h	2010/06/30 20:21:03	1.70
@@ -152,8 +152,7 @@
 int segtype_arg(struct cmd_context *cmd, struct arg *a);
 int alloc_arg(struct cmd_context *cmd, struct arg *a);
 int readahead_arg(struct cmd_context *cmd, struct arg *a);
-int vgmetadatacopies_arg(struct cmd_context *cmd __attribute((unused)),
-			 struct arg *a);
+int metadatacopies_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a);
 
 /* we use the enums to access the switches */
 unsigned arg_count(const struct cmd_context *cmd, int a);


