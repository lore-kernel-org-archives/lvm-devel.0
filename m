From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 27 Jan 2010 13:24:04 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c
Message-ID: <20100127132404.9752.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-01-27 13:23:57

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 

Log message:
	Always query device by using uuid only and not name in clvmd.
	
	Otherwise confusion with the device of the same name
	(but different UUID, e.g. non-lvm device) can happen.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1410&r2=1.1411
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.163&r2=1.164

--- LVM2/WHATS_NEW	2010/01/26 08:01:18	1.1410
+++ LVM2/WHATS_NEW	2010/01/27 13:23:57	1.1411
@@ -1,5 +1,6 @@
 Version 2.02.60 - 23rd January 2010
 ===================================
+  Always query device by using uuid only and not name in clvmd.
   Add missing metadata reverts in pvmove error path.
   Unlock shared lock in clvmd if activation calls failed.
   Fix return code of info call for query by uuid.
--- LVM2/lib/activate/activate.c	2010/01/13 01:55:43	1.163
+++ LVM2/lib/activate/activate.c	2010/01/27 13:23:57	1.164
@@ -492,7 +492,7 @@
 	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
 		return 0;
 
-	r = _lv_info(cmd, lv, 0, info, with_open_count, with_read_ahead, 0);
+	r = _lv_info(cmd, lv, 0, info, with_open_count, with_read_ahead, 1);
 	vg_release(lv->vg);
 
 	return r;


