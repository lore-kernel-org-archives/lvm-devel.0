From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jun 2009 11:29:06 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20090626112906.1420.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-06-26 11:29:06

Modified files:
	tools          : lvconvert.c 

Log message:
	Fix incomplete revert for lvconvert.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86

--- LVM2/tools/lvconvert.c	2009/06/26 10:55:58	1.85
+++ LVM2/tools/lvconvert.c	2009/06/26 11:29:06	1.86
@@ -242,8 +242,10 @@
 	/*
 	 * uuid is here LV uuid, but vg_read will use only first part.
 	 */
-	return vg_read_for_update(cmd, extract_vgname(cmd, lv_name),
-				  NULL, 0);
+        return vg_lock_and_read(cmd, extract_vgname(cmd, lv_name),
+                               uuid, LCK_VG_WRITE,
+                               CLUSTERED | EXPORTED_VG | LVM_WRITE,
+                               CORRECT_INCONSISTENT | FAIL_INCONSISTENT);
 }
 
 static struct logical_volume *_get_lvconvert_lv(struct cmd_context *cmd __attribute((unused)),


