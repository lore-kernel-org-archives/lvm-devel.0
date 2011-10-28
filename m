From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Oct 2011 20:34:45 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20111028203445.26169.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-28 20:34:45

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Avoid creation of /dev/vg/thinpool

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.246&r2=1.247

--- LVM2/lib/activate/dev_manager.c	2011/10/17 14:18:07	1.246
+++ LVM2/lib/activate/dev_manager.c	2011/10/28 20:34:45	1.247
@@ -892,7 +892,8 @@
 	 * Is this top-level and visible device?
 	 * If not, create just the /dev/mapper content.
 	 */
-	if (layer || !lv_is_visible(lv))
+	/* FIXME: add target's method for this */
+	if (layer || !lv_is_visible(lv) || lv_is_thin_pool(lv))
 		udev_flags |= DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG |
 			      DM_UDEV_DISABLE_DISK_RULES_FLAG |
 			      DM_UDEV_DISABLE_OTHER_RULES_FLAG;


