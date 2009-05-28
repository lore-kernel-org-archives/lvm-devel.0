From: agk@sourceware.org <agk@sourceware.org>
Date: 28 May 2009 01:11:31 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20090528011131.31361.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-05-28 01:11:30

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Remove /dev/vgname/lvname symlink automatically if LV is no longer visible.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1130&r2=1.1131
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.150&r2=1.151

--- LVM2/WHATS_NEW	2009/05/28 00:29:14	1.1130
+++ LVM2/WHATS_NEW	2009/05/28 01:11:29	1.1131
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Remove /dev/vgname/lvname symlink automatically if LV is no longer visible.
   Rename internal vorigin LV to match visible LV.
   Suppress 'removed' messages displayed when internal LVs are removed.
   Fix lvchange -a and -p for sparse LVs.
--- LVM2/lib/activate/dev_manager.c	2009/05/20 11:09:49	1.150
+++ LVM2/lib/activate/dev_manager.c	2009/05/28 01:11:30	1.151
@@ -1067,7 +1067,14 @@
 			}
 			if (!fs_rename_lv(lvlayer->lv, name, old_vgname, old_lvname))
 				r = 0;
-		} else if (!dev_manager_lv_mknodes(lvlayer->lv))
+			continue;
+		}
+		if (lv_is_visible(lvlayer->lv)) {
+			if (!dev_manager_lv_mknodes(lvlayer->lv))
+				r = 0;
+			continue;
+		}
+		if (!dev_manager_lv_rmnodes(lvlayer->lv))
 			r = 0;
 	}
 


