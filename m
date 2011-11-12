From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 12 Nov 2011 22:51:20 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20111112225120.28622.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-12 22:51:20

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Missing stack printing

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.330&r2=1.331

--- LVM2/lib/metadata/lv_manip.c	2011/11/10 12:43:05	1.330
+++ LVM2/lib/metadata/lv_manip.c	2011/11/12 22:51:20	1.331
@@ -3142,7 +3142,7 @@
 	vg = lv->vg;
 
 	if (!vg_check_status(vg, LVM_WRITE))
-		return 0;
+		return_0;
 
 	if (lv_is_origin(lv)) {
 		log_error("Can't remove logical volume \"%s\" under snapshot",


