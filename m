From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Dec 2010 15:32:16 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20101222153216.28144.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-22 15:32:16

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Hide unused code into if 0
	
	Make it obvious for lcov coverage and static analyzis we
	are not interested in this piece of code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.209&r2=1.210

--- LVM2/lib/activate/dev_manager.c	2010/12/20 14:04:43	1.209
+++ LVM2/lib/activate/dev_manager.c	2010/12/22 15:32:15	1.210
@@ -306,6 +306,7 @@
 	return dinfo;
 }
 
+#if 0
 /* FIXME Interface must cope with multiple targets */
 static int _status_run(const char *name, const char *uuid,
 		       unsigned long long *s, unsigned long long *l,
@@ -383,6 +384,7 @@
 
 	return 0;
 }
+#endif
 
 int lv_has_target_type(struct dm_pool *mem, struct logical_volume *lv,
 		       const char *layer, const char *target_type)


