From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Nov 2011 14:41:19 -0000
Subject: LVM2/tools lvchange.c vgchange.c
Message-ID: <20111103144119.7765.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-03 14:41:18

Modified files:
	tools          : lvchange.c vgchange.c 

Log message:
	Thin avoids need of having writable VG for activation

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.133&r2=1.134
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.127&r2=1.128

--- LVM2/tools/lvchange.c	2011/10/30 22:07:38	1.133
+++ LVM2/tools/lvchange.c	2011/11/03 14:41:18	1.134
@@ -142,10 +142,6 @@
 				    "exclusively", lv->name);
 			if (!activate_lv_excl(cmd, lv))
 				return_0;
-			/* Drop any left thin messages after activation */
-			if (lv_is_thin_volume(lv) &&
-			    !detach_pool_messages(first_seg(lv)->pool_lv))
-				return_0;
 		} else if (activate == CHANGE_ALY) {
 			log_verbose("Activating logical volume \"%s\" locally",
 				    lv->name);
--- LVM2/tools/vgchange.c	2011/10/30 22:07:38	1.127
+++ LVM2/tools/vgchange.c	2011/11/03 14:41:18	1.128
@@ -157,12 +157,6 @@
 				stack;
 				continue;
 			}
-			/* Drop any left thin messages after activation */
-			if (lv_is_thin_volume(lv) &&
-			    !detach_pool_messages(first_seg(lv)->pool_lv)) {
-				stack;
-				continue;
-			}
 		} else if (activate == CHANGE_ALY) {
 			if (!activate_lv_local(cmd, lv)) {
 				stack;


