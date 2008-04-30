From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Apr 2008 14:34:03 -0000
Subject: LVM2 ./WHATS_NEW tools/vgrename.c
Message-ID: <20080430143403.32707.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-30 14:34:02

Modified files:
	.              : WHATS_NEW 
	tools          : vgrename.c 

Log message:
	Don't touch /dev in vgrename if activation is disabled.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.866&r2=1.867
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52

--- LVM2/WHATS_NEW	2008/04/29 16:11:26	1.866
+++ LVM2/WHATS_NEW	2008/04/30 14:34:02	1.867
@@ -1,5 +1,6 @@
 Version 2.02.37 - 
 =================================
+  Don't touch /dev in vgrename if activation is disabled.
   Check lv_count in vg_validate.
   Add --prefixes to reporting tools for field name prefix output format.
 
--- LVM2/tools/vgrename.c	2008/04/08 12:49:21	1.51
+++ LVM2/tools/vgrename.c	2008/04/30 14:34:02	1.52
@@ -122,7 +122,7 @@
 	sprintf(old_path, "%s%s", dev_dir, vg_name_old);
 	sprintf(new_path, "%s%s", dev_dir, vg_name_new);
 
-	if (dir_exists(old_path)) {
+	if (activation() && dir_exists(old_path)) {
 		log_verbose("Renaming \"%s\" to \"%s\"", old_path, new_path);
 		if (test_mode())
 			log_verbose("Test mode: Skipping rename.");


