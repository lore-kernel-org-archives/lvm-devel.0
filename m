From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Oct 2010 17:09:25 -0000
Subject: LVM2/lib/metadata lv.c
Message-ID: <20101012170925.28579.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-10-12 17:09:23

Modified files:
	lib/metadata   : lv.c 

Log message:
	Fix lv_modules_dup segfault.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/lib/metadata/lv.c	2010/10/12 16:13:06	1.13
+++ LVM2/lib/metadata/lv.c	2010/10/12 17:09:23	1.14
@@ -31,7 +31,7 @@
 
 	if (!list_lv_modules(mem, lv, modules))
 		return_NULL;
-	return tags_format_and_copy(lv->vg->vgmem, modules);
+	return tags_format_and_copy(mem, modules);
 }
 
 char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv)


