From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 7 May 2009 12:01:22 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20090507120122.15326.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-07 12:01:22

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Use zalloc in initialization of device manager (to zero pvmove mirror count).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.146&r2=1.147

--- LVM2/lib/activate/dev_manager.c	2009/02/28 20:04:24	1.146
+++ LVM2/lib/activate/dev_manager.c	2009/05/07 12:01:21	1.147
@@ -445,7 +445,7 @@
 	if (!(mem = dm_pool_create("dev_manager", 16 * 1024)))
 		return_NULL;
 
-	if (!(dm = dm_pool_alloc(mem, sizeof(*dm))))
+	if (!(dm = dm_pool_zalloc(mem, sizeof(*dm))))
 		goto_bad;
 
 	dm->cmd = cmd;


