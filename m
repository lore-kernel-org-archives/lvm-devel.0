From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 6 Jun 2009 16:37:15 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20090606163715.4917.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-06 16:37:15

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Suspend virtual origin before real snapshot.
	
	Because preload of table for snapshot can produce snapshot
	metadata (in kernel cow header) read.
	
	Code should suspend origin first to avoid possible deadlock
	when preloading (thus calling snapshot in-kernel constructor)
	for origin with suspended cow device.
	
	(fixes previous commit)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.180&r2=1.181

--- LVM2/lib/metadata/lv_manip.c	2009/06/01 15:55:07	1.180
+++ LVM2/lib/metadata/lv_manip.c	2009/06/06 16:37:15	1.181
@@ -1806,7 +1806,7 @@
 
 	/* rename active virtual origin too */
 	if (lv_is_cow(lv) && lv_is_virtual_origin(lvl2.lv = origin_from_cow(lv)))
-		dm_list_add(&lvs_changed, &lvl2.list);
+		dm_list_add_h(&lvs_changed, &lvl2.list);
 
 	log_verbose("Writing out updated volume group");
 	if (!vg_write(vg))


