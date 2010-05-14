From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 14 May 2010 12:30:45 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20100514123045.31048.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-05-14 12:30:45

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Fix empty layer detection is scan devices.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.189&r2=1.190

--- LVM2/lib/activate/dev_manager.c	2010/05/14 12:03:32	1.189
+++ LVM2/lib/activate/dev_manager.c	2010/05/14 12:30:43	1.190
@@ -180,7 +180,7 @@
 		    !dm_split_lvm_name(NULL, NULL, &vgname, &lvname, &layer))
 			goto_out;
 
-		if (lvname && (is_reserved_lvname(lvname) || layer)) {
+		if (lvname && (is_reserved_lvname(lvname) || (layer && *layer))) {
 			log_debug("%s: Reserved internal LV device %s/%s%s%s not usable.",
 				  dev_name(dev), vgname, lvname, layer ? "-" : "",
 				  layer ?: "");


