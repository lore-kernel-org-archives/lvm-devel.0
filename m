From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 18 Nov 2009 17:20:19 -0000
Subject: LVM2 ./WHATS_NEW tools/vgchange.c
Message-ID: <20091118172019.4879.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-11-18 17:20:18

Modified files:
	.              : WHATS_NEW 
	tools          : vgchange.c 

Log message:
	Never activate hidden volumes directly in vgchange.
	
	All hidden (not visible) volumes should be activated through
	other visible volumes.
	
	(There are already exceptions like snapshot, mirror log and image,
	which should be cleaned one day...)
	
	This solves problems for future types of hidden volumes,
	which can have special meaning and must not be activated implicitly
	(e.g. key store volume).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1315&r2=1.1316
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90

--- LVM2/WHATS_NEW	2009/11/18 16:48:10	1.1315
+++ LVM2/WHATS_NEW	2009/11/18 17:20:18	1.1316
@@ -1,5 +1,6 @@
 Version 2.02.55 -
 ===================================
+  Do not activate directly not visible volumes in vgchange.
   Fix pvmove region_size oveflow for very large PVs.
   Fix lvcreate and lvresize processing of %PVS argument.
   Tidy some uses of arg_count and introduce arg_is_set.
--- LVM2/tools/vgchange.c	2009/10/31 17:30:52	1.89
+++ LVM2/tools/vgchange.c	2009/11/18 17:20:18	1.90
@@ -61,6 +61,9 @@
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
 
+		if (!lv_is_visible(lv))
+			continue;
+
 		/* Only request activation of snapshot origin devices */
 		if ((lv->status & SNAPSHOT) || lv_is_cow(lv))
 			continue;


