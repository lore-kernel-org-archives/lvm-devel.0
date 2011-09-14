From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 14 Sep 2011 18:20:04 -0000
Subject: LVM2 ./WHATS_NEW tools/vgchange.c
Message-ID: <20110914182004.1844.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-09-14 18:20:04

Modified files:
	.              : WHATS_NEW 
	tools          : vgchange.c 

Log message:
	Fix vgchange activation of snapshot with virtual origin.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2109&r2=1.2110
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.122&r2=1.123

--- LVM2/WHATS_NEW	2011/09/14 14:20:16	1.2109
+++ LVM2/WHATS_NEW	2011/09/14 18:20:03	1.2110
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix vgchange activation of snapshot with virtual origin.
   Activate virtual snapshot origin exclusively (only on local node in cluster).
   Fix lv_mirror_count to handle mirrored stripes properly.
   Fix failure to down-convert a mirror to linear due to udev "dev open" conflict
--- LVM2/tools/vgchange.c	2011/09/07 08:41:48	1.122
+++ LVM2/tools/vgchange.c	2011/09/14 18:20:04	1.123
@@ -100,6 +100,10 @@
 		if (!lv_is_visible(lv))
 			continue;
 
+		/* If LV is sparse, activate origin instead */
+		if (lv_is_cow(lv) && lv_is_virtual_origin(origin_from_cow(lv)))
+			lv = origin_from_cow(lv);
+
 		/* Only request activation of snapshot origin devices */
 		if ((lv->status & SNAPSHOT) || lv_is_cow(lv))
 			continue;


