From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 23 Apr 2009 16:43:02 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20090423164302.11615.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-04-23 16:43:01

Modified files:
	lib/metadata   : mirror.c 

Log message:
	A more thorough PV equality test (that also copes better with MISSING_PVs) in
	_is_mirror_image_removable.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85

--- LVM2/lib/metadata/mirror.c	2009/04/21 14:31:58	1.84
+++ LVM2/lib/metadata/mirror.c	2009/04/23 16:43:01	1.85
@@ -440,7 +440,12 @@
 
 			pv_found = 0;
 			dm_list_iterate_items(pvl, removable_pvs) {
-				if (pv->dev->dev == pvl->pv->dev->dev) {
+				if (id_equal(&pv->id, &pvl->pv->id)) {
+					pv_found = 1;
+					break;
+				}
+				if (pvl->pv->dev && pv->dev &&
+				    pv->dev->dev == pvl->pv->dev->dev) {
 					pv_found = 1;
 					break;
 				}


