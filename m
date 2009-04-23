From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 23 Apr 2009 16:41:28 -0000
Subject: LVM2/lib/metadata pv_map.c
Message-ID: <20090423164128.10352.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-04-23 16:41:28

Modified files:
	lib/metadata   : pv_map.c 

Log message:
	Do not include MISSING_PVs in allocation maps.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_map.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/lib/metadata/pv_map.c	2008/11/04 15:07:44	1.33
+++ LVM2/lib/metadata/pv_map.c	2009/04/23 16:41:27	1.34
@@ -129,6 +129,9 @@
 	dm_list_iterate_items(pvl, pvs) {
 		if (!(pvl->pv->status & ALLOCATABLE_PV))
 			continue;
+		if (pvl->pv->status & MISSING_PV)
+			continue;
+		assert(pvl->pv->dev);
 
 		pvm = NULL;
 


