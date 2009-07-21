From: agk@sourceware.org <agk@sourceware.org>
Date: 21 Jul 2009 11:10:50 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c
Message-ID: <20090721111050.25719.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-21 11:10:49

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c 

Log message:
	Return EINVALID_CMD_LINE not success when invalid VG name format is used.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1193&r2=1.1194
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.165&r2=1.166

--- LVM2/WHATS_NEW	2009/07/16 03:25:26	1.1193
+++ LVM2/WHATS_NEW	2009/07/21 11:10:49	1.1194
@@ -1,5 +1,6 @@
 Version 2.02.50 - 
 ================================
+  Return EINVALID_CMD_LINE not success when invalid VG name format is used.
   Remove unnecessary messages after vgcreate/vgsplit refactor (2.02.49).
   Add log_errno to set a specific errno and replace log_error in due course.
   Add lvm_errno and lvm_errmsg to liblvm to obtain failure information.
--- LVM2/tools/toollib.c	2009/07/15 20:02:48	1.165
+++ LVM2/tools/toollib.c	2009/07/21 11:10:49	1.166
@@ -482,6 +482,8 @@
 				if (!validate_name(vg_name + 1)) {
 					log_error("Skipping invalid tag %s",
 						  vg_name);
+					if (ret_max < EINVALID_CMD_LINE)
+						ret_max = EINVALID_CMD_LINE;
 					continue;
 				}
 				if (!str_list_add(cmd->mem, &tags,
@@ -497,6 +499,8 @@
 			if (strchr(vg_name, '/')) {
 				log_error("Invalid volume group name: %s",
 					  vg_name);
+				if (ret_max < EINVALID_CMD_LINE)
+					ret_max = EINVALID_CMD_LINE;
 				continue;
 			}
 			if (!str_list_add(cmd->mem, &arg_vgnames,


