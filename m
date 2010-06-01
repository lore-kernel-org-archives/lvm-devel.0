From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 1 Jun 2010 12:08:51 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c
Message-ID: <20100601120851.6570.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-06-01 12:08:51

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 

Log message:
	Fix incorrect memory pool deallocation while using vg_read for files.
	
	We create a separate pool "lvm2 vg_read" for vg_read and we don't use
	cmd->mem anymore.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1600&r2=1.1601
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.121&r2=1.122

--- LVM2/WHATS_NEW	2010/05/28 03:50:15	1.1600
+++ LVM2/WHATS_NEW	2010/06/01 12:08:50	1.1601
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Fix incorrect memory pool deallocation while using vg_read for files.
   Add --type parameter description to the lvcreate man page.
   Replace strncmp kernel version number checks with proper ones.
   Avoid selecting names under /dev/block if there is an alternative.
--- LVM2/lib/format_text/format-text.c	2010/04/14 13:09:16	1.121
+++ LVM2/lib/format_text/format-text.c	2010/06/01 12:08:50	1.122
@@ -814,7 +814,7 @@
 	 * check that it contains the correct volume group.
 	 */
 	if (vgname && strcmp(vgname, vg->name)) {
-		dm_pool_free(fid->fmt->cmd->mem, vg);
+		dm_pool_destroy(vg->vgmem);
 		log_error("'%s' does not contain volume group '%s'.",
 			  read_path, vgname);
 		return NULL;


