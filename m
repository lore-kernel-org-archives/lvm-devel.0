From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Nov 2011 14:38:39 -0000
Subject: LVM2 lib/metadata/thin_manip.c lib/misc/lvm-st ...
Message-ID: <20111103143839.26671.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-03 14:38:37

Modified files:
	lib/metadata   : thin_manip.c 
	lib/misc       : lvm-string.c 
	man            : lvm.8.in 

Log message:
	Thin uses _tdata instead of _tpool for data LV
	
	Switch to different suffix and keep -tpool reserved for overlay device name.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.8.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/lib/metadata/thin_manip.c	2011/11/03 14:36:40	1.18
+++ LVM2/lib/metadata/thin_manip.c	2011/11/03 14:38:36	1.19
@@ -300,7 +300,7 @@
 		return_0;
 
 	if (!(data_lv = insert_layer_for_lv(pool_lv->vg->cmd, pool_lv,
-					    pool_lv->status, "_tpool")))
+					    pool_lv->status, "_tdata")))
 		return_0;
 
 	seg = first_seg(pool_lv);
--- LVM2/lib/misc/lvm-string.c	2011/09/06 15:38:44	1.31
+++ LVM2/lib/misc/lvm-string.c	2011/11/03 14:38:36	1.32
@@ -107,7 +107,7 @@
 		"_rimage",
 		"_rmeta",
 		"_vorigin",
-		"_tpool",
+		"_tdata",
 		"_tmeta",
 		NULL
 	};
--- LVM2/man/lvm.8.in	2011/10/19 16:45:35	1.7
+++ LVM2/man/lvm.8.in	2011/11/03 14:38:37	1.8
@@ -276,7 +276,7 @@
 There are also various reserved names that are used internally by lvm that can not be used as LV or VG names.
 A VG cannot be called anything that exists in /dev/ at the time of creation, nor can it be called '.' or '..'.
 A LV cannot be called '.' '..' 'snapshot' or 'pvmove'. The LV name may also not contain
-the strings '_mlog', '_mimage', '_tmeta', '_tpool'.
+the strings '_mlog', '_mimage', '_tdata', '_tmeta'.
 
 
 .SH DIAGNOSTICS


