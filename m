From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Oct 2011 16:47:23 -0000
Subject: LVM2/tools vgchange.c
Message-ID: <20111022164723.9519.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-22 16:47:23

Modified files:
	tools          : vgchange.c 

Log message:
	Ensure thin LVs take an exclusive activation

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.123&r2=1.124

--- LVM2/tools/vgchange.c	2011/09/14 18:20:04	1.123
+++ LVM2/tools/vgchange.c	2011/10/22 16:47:23	1.124
@@ -145,7 +145,10 @@
 				stack;
 				continue;
 			}
-		} else if (lv_is_origin(lv) || (activate == CHANGE_AE)) {
+		} else if (lv_is_origin(lv) ||
+			   lv_is_thin_pool(lv) ||
+			   lv_is_thin_volume(lv) ||
+			   (activate == CHANGE_AE)) {
 			if (!activate_lv_excl(cmd, lv)) {
 				stack;
 				continue;


