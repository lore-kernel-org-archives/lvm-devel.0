From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 30 Sep 2010 14:12:15 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c
Message-ID: <20100930141215.19651.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-09-30 14:12:14

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 

Log message:
	Fix memory leak of vg_read while using live copies of metadata in directories.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1741&r2=1.1742
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.145&r2=1.146

--- LVM2/WHATS_NEW	2010/09/30 11:44:54	1.1741
+++ LVM2/WHATS_NEW	2010/09/30 14:12:14	1.1742
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Fix memory leak of vg_read while using live copies of metadata in directories.
   Fix memory leak of config_tree in reinitialization code path.
   Swap pool destruction order in dmeventd_lvm2_exit() to fix leak report.
   Read whole /proc/self/maps file before working with maps entries.
--- LVM2/lib/format_text/format-text.c	2010/09/27 19:09:35	1.145
+++ LVM2/lib/format_text/format-text.c	2010/09/30 14:12:14	1.146
@@ -1083,9 +1083,11 @@
 				fid = _text_create_text_instance(fmt, NULL, NULL,
 							    NULL);
 				if ((vg = _vg_read_file_name(fid, vgname,
-							     path)))
+							     path))) {
 					/* FIXME Store creation host in vg */
 					lvmcache_update_vg(vg, 0);
+					dm_pool_destroy(vg->vgmem);
+				}
 			}
 
 		if (closedir(d))


