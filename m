From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Apr 2010 12:23:13 -0000
Subject: LVM2/tools toollib.c
Message-ID: <20100428122313.24392.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-04-28 12:23:12

Modified files:
	tools          : toollib.c 

Log message:
	Small indent change

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.195&r2=1.196

--- LVM2/tools/toollib.c	2010/04/23 14:16:33	1.195
+++ LVM2/tools/toollib.c	2010/04/28 12:23:11	1.196
@@ -316,7 +316,7 @@
 				   strlen(vgname) == (size_t) (lv_name - vg_name)) {
 				if (!str_list_add(cmd->mem, &lvnames,
 						  dm_pool_strdup(cmd->mem,
-							      lv_name + 1))) {
+								 lv_name + 1))) {
 					log_error("strlist allocation failed");
 					unlock_and_release_vg(cmd, vg, vgname);
 					return ECMD_FAILED;


