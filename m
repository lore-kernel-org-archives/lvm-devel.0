From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 14:06:33 -0000
Subject: LVM2/lib/format1 format1.c
Message-ID: <20101220140633.23325.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 14:06:33

Modified files:
	lib/format1    : format1.c 

Log message:
	Remove unused variable label
	
	Variable 'label' is unused in _format1_pv_write().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.126&r2=1.127

--- LVM2/lib/format1/format1.c	2010/12/20 13:32:49	1.126
+++ LVM2/lib/format1/format1.c	2010/12/20 14:06:33	1.127
@@ -428,13 +428,12 @@
 	struct dm_pool *mem;
 	struct disk_list *dl;
 	struct dm_list pvs;
-	struct label *label;
 	struct lvmcache_info *info;
 
 	if (!(info = lvmcache_add(fmt->labeller, (char *) &pv->id, pv->dev,
 				  pv->vg_name, NULL, 0)))
 		return_0;
-	label = info->label;
+
 	info->device_size = pv->size << SECTOR_SHIFT;
 	info->fmt = fmt;
 


