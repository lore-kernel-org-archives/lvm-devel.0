From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 13 Aug 2008 12:44:24 -0000
Subject: LVM2 ./WHATS_NEW tools/vgcfgbackup.c
Message-ID: <20080813124424.6581.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-08-13 12:44:24

Modified files:
	.              : WHATS_NEW 
	tools          : vgcfgbackup.c 

Log message:
	Fix vgcfgbackup to properly check filename if template is used.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.945&r2=1.946
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgbackup.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/WHATS_NEW	2008/08/05 14:29:38	1.945
+++ LVM2/WHATS_NEW	2008/08/13 12:44:23	1.946
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Fix vgcfgbackup to properly check filename if template is used.
   configure aborts if lcov or genhtml are missing with --enable-profiling
   vgremove tries to remove lv snapshot first.
   Added function lv_remove_with_dependencies().
--- LVM2/tools/vgcfgbackup.c	2008/01/30 14:00:02	1.24
+++ LVM2/tools/vgcfgbackup.c	2008/08/13 12:44:24	1.25
@@ -34,8 +34,7 @@
 		dm_free(filename);	
 		return NULL;
 	}
-	if (*last_filename && !strncmp(*last_filename, filename,
-				      strlen(template))) {
+	if (*last_filename && !strncmp(*last_filename, filename, PATH_MAX)) {
 		log_error("VGs must be backed up into different files. "
 			  "Use %%s in filename for VG name.");
 		dm_free(filename);
@@ -70,7 +69,8 @@
 			return ECMD_FAILED;
 		}
 
-		backup_to_file(filename, vg->cmd->cmd_line, vg);
+		if (!backup_to_file(filename, vg->cmd->cmd_line, vg))
+			return ECMD_FAILED;
 	} else {
 		if (!consistent) {
 			log_error("No backup taken: specify filename with -f "


