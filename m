From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 16 Sep 2011 11:59:23 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20110916115923.21652.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-16 11:59:22

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Reset LV status when unlinking LV from VG
	
	When LV is unlinked, we want to catch problem in vg_validate,
	that LV has changed.
	
	i.e. catch LV has been removed and is no long thin_pool while still
	being referenced by some thin volume.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.286&r2=1.287

--- LVM2/lib/metadata/lv_manip.c	2011/09/16 09:59:42	1.286
+++ LVM2/lib/metadata/lv_manip.c	2011/09/16 11:59:22	1.287
@@ -3028,6 +3028,8 @@
 
 	dm_list_del(&lvl->list);
 
+	lv->status = 0;   /* Reset */
+
 	return 1;
 }
 


