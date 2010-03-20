From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 20 Mar 2010 03:44:04 -0000
Subject: LVM2 ./WHATS_NEW tools/lvresize.c
Message-ID: <20100320034404.3220.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-03-20 03:44:04

Modified files:
	.              : WHATS_NEW 
	tools          : lvresize.c 

Log message:
	Don't allow resizing of internal logical volumes.
	
	Prevent lvresize from being able to resize internal LVs: mirror legs
	(*_mimage_*), mirror log (*_mlog), snapshot placeholder LVs (snapshot*)
	and others.  Resizing these would leads to unexpected metadata and
	sometimes crashes (in case of growing snapshot*).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1471&r2=1.1472
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.119&r2=1.120

--- LVM2/WHATS_NEW	2010/03/19 18:33:55	1.1471
+++ LVM2/WHATS_NEW	2010/03/20 03:44:04	1.1472
@@ -1,5 +1,6 @@
 Version 2.02.63 - 
 ================================
+  Don't allow resizing of internal logical volumes.
   Fix libdevmapper-event pkgconfig version string to match libdevmapper.
   Avoid scanning all pvs in the system if operating on a device with mdas.
   Add configure --with-clvmd=singlenode to use clvmd w/o cluster infrastructure.
--- LVM2/tools/lvresize.c	2010/02/03 03:58:08	1.119
+++ LVM2/tools/lvresize.c	2010/03/20 03:44:04	1.120
@@ -323,6 +323,11 @@
 
 	lv = lvl->lv;
 
+	if (!lv_is_visible(lv)) {
+		log_error("Can't resize internal logical volume %s", lv->name);
+		return ECMD_FAILED;
+	}
+
 	if (lv->status & LOCKED) {
 		log_error("Can't resize locked LV %s", lv->name);
 		return ECMD_FAILED;


