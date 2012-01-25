From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 09:00:18 -0000
Subject: LVM2/lib/activate activate.c
Message-ID: <20120125090018.28233.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 09:00:18

Modified files:
	lib/activate   : activate.c 

Log message:
	lv_info using -real layer only for origin_only LV
	
	If the origin_only flag is passed for non lv_is_origin LVs,
	the extension is not added.
	
	Thin volumes may also use origin_only flag.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.235&r2=1.236

--- LVM2/lib/activate/activate.c	2012/01/25 08:51:29	1.235
+++ LVM2/lib/activate/activate.c	2012/01/25 09:00:18	1.236
@@ -552,7 +552,7 @@
 			fs_unlock(); /* For non clustered - wait if there are non-delete ops */
 	}
 
-	if (!dev_manager_info(lv->vg->cmd->mem, lv, origin_only ? "real" : NULL, with_open_count,
+	if (!dev_manager_info(lv->vg->cmd->mem, lv, (lv_is_origin(lv) && origin_only) ? "real" : NULL, with_open_count,
 			      with_read_ahead, &dminfo, &info->read_ahead))
 		return_0;
 


