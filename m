From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Dec 2010 12:22:50 -0000
Subject: LVM2/tools toollib.c
Message-ID: <20101201122250.5538.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-01 12:22:49

Modified files:
	tools          : toollib.c 

Log message:
	Test lv_name is not NULL
	
	Patch adds extra check for lv_name not being NULL.
	Test avoids unneeded strlen call for this case.
	Otherwise there is no functional change as test would fail on
	size_t comparation even for NULL lv_name (thus there is no risk
	of NULL dereference when taking 'true' if branch.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.215&r2=1.216

--- LVM2/tools/toollib.c	2010/12/01 10:36:25	1.215
+++ LVM2/tools/toollib.c	2010/12/01 12:22:49	1.216
@@ -331,7 +331,7 @@
 				tags_arg = NULL;
 				dm_list_init(&lvnames);
 				break;
-			} else if (!strncmp(vg_name, vgname, strlen(vgname)) &&
+			} else if (!strncmp(vg_name, vgname, strlen(vgname)) && lv_name &&
 				   strlen(vgname) == (size_t) (lv_name - vg_name)) {
 				if (!str_list_add(cmd->mem, &lvnames,
 						  dm_pool_strdup(cmd->mem,


