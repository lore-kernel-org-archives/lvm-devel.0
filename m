From: bmr@sourceware.org <bmr@sourceware.org>
Date: 8 Jun 2007 22:38:49 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/archive.c lib ...
Message-ID: <20070608223849.1607.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	bmr at sourceware.org	2007-06-08 22:38:48

Modified files:
	.              : WHATS_NEW 
	lib/format_text: archive.c archiver.c archiver.h format-text.h 
	tools          : vgcfgrestore.c 

Log message:
	Allow vgcfgrestore to list metadata backup files using -f

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.624&r2=1.625
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archive.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.h.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgrestore.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/WHATS_NEW	2007/06/06 19:40:27	1.624
+++ LVM2/WHATS_NEW	2007/06/08 22:38:48	1.625
@@ -1,5 +1,6 @@
 Version 2.02.26 -
 =================================
+  Allow vgcfgrestore to list metadata backup files using -f
   Add vg_check_status to consolidate vg status checks and error messages.
   Add pvdisplay --maps implementation.
   Fix vgcfgrestore man pg to show mandatory VG name and remove LVM1 options.
--- LVM2/lib/format_text/archive.c	2007/01/25 14:37:48	1.25
+++ LVM2/lib/format_text/archive.c	2007/06/08 22:38:48	1.26
@@ -362,6 +362,22 @@
 	return 1;
 }
 
+int archive_list_file(struct cmd_context *cmd, const char *file)
+{
+	struct archive_file af;
+
+	af.path = (char *)file;
+
+	if (!path_exists(af.path)) {
+		log_err("Archive file %s not found.", af.path);
+		return 0;
+	}
+
+	_display_archive(cmd, &af);
+
+	return 1;
+}
+
 int backup_list(struct cmd_context *cmd, const char *dir, const char *vgname)
 {
 	struct archive_file af;
--- LVM2/lib/format_text/archiver.c	2006/08/21 12:54:52	1.5
+++ LVM2/lib/format_text/archiver.c	2007/06/08 22:38:48	1.6
@@ -148,6 +148,17 @@
 	return r1 && r2;
 }
 
+int archive_display_file(struct cmd_context *cmd, const char *file)
+{
+	int r;
+
+	init_partial(1);
+	r = archive_list_file(cmd, file);
+	init_partial(0);
+
+	return r;
+}
+
 int backup_init(struct cmd_context *cmd, const char *dir)
 {
 	if (!(cmd->backup_params = dm_pool_zalloc(cmd->libmem,
--- LVM2/lib/format_text/archiver.h	2005/05/17 13:46:37	1.1
+++ LVM2/lib/format_text/archiver.h	2007/06/08 22:38:48	1.2
@@ -38,6 +38,7 @@
 void archive_enable(struct cmd_context *cmd, int flag);
 int archive(struct volume_group *vg);
 int archive_display(struct cmd_context *cmd, const char *vg_name);
+int archive_display_file(struct cmd_context *cmd, const char *file);
 
 int backup_init(struct cmd_context *cmd, const char *dir);
 void backup_exit(struct cmd_context *cmd);
--- LVM2/lib/format_text/format-text.h	2006/05/11 17:58:58	1.20
+++ LVM2/lib/format_text/format-text.h	2007/06/08 22:38:48	1.21
@@ -33,6 +33,7 @@
  * Displays a list of vg backups in a particular archive directory.
  */
 int archive_list(struct cmd_context *cmd, const char *dir, const char *vgname);
+int archive_list_file(struct cmd_context *cmd, const char *file);
 int backup_list(struct cmd_context *cmd, const char *dir, const char *vgname);
 
 /*
--- LVM2/tools/vgcfgrestore.c	2007/03/09 20:47:41	1.13
+++ LVM2/tools/vgcfgrestore.c	2007/06/08 22:38:48	1.14
@@ -19,26 +19,27 @@
 {
 	char *vg_name;
 
-	if (argc != 1) {
+	if (argc == 1) {
+		vg_name = skip_dev_dir(cmd, argv[0], NULL);
+		if (!validate_name(vg_name)) {
+			log_error("Volume group name \"%s\" is invalid", vg_name);
+			return ECMD_FAILED;
+		}
+	} else if (!(arg_count(cmd, list_ARG) && arg_count(cmd, file_ARG))) {
 		log_err("Please specify a *single* volume group to restore.");
 		return ECMD_FAILED;
 	}
 
-	vg_name = skip_dev_dir(cmd, argv[0], NULL);
-
-	if (!validate_name(vg_name)) {
-		log_error("Volume group name \"%s\" is invalid", vg_name);
-		return ECMD_FAILED;
-	}
-
 	/*
 	 * FIXME: overloading the -l arg for now to display a
 	 * list of archive files for a particular vg
 	 */
 	if (arg_count(cmd, list_ARG)) {
-		if (!archive_display(cmd, vg_name))
+		if (!(arg_count(cmd,file_ARG) ?
+			archive_display_file(cmd,
+					arg_str_value(cmd, file_ARG, "")) :
+			archive_display(cmd, vg_name)))
 			return ECMD_FAILED;
-
 		return ECMD_PROCESSED;
 	}
 


