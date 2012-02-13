From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Feb 2012 11:09:26 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c
Message-ID: <20120213110926.12706.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-13 11:09:26

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 

Log message:
	Add check for mda_copy failure

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2287&r2=1.2288
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.192&r2=1.193

--- LVM2/WHATS_NEW	2012/02/13 11:07:55	1.2287
+++ LVM2/WHATS_NEW	2012/02/13 11:09:25	1.2288
@@ -1,5 +1,6 @@
 Version 2.02.92 - 
 ====================================
+  Add check for mda_copy failure in _text_pv_setup().
   Add check for _mirrored_init_target failure.
   Add free_orphan_vg.
   Skip pv/vg_set_fid processing if the fid is same.
--- LVM2/lib/format_text/format-text.c	2012/02/13 11:04:00	1.192
+++ LVM2/lib/format_text/format-text.c	2012/02/13 11:09:25	1.193
@@ -1608,7 +1608,8 @@
 
 			/* Be sure it's not already in VG's format instance! */
 			if (!fid_get_mda_indexed(vg->fid, pvid, ID_LEN, mda_index)) {
-				pv_mda_copy = mda_copy(vg->fid->mem, pv_mda);
+				if (!(pv_mda_copy = mda_copy(vg->fid->mem, pv_mda)))
+					return_0;
 				fid_add_mda(vg->fid, pv_mda_copy, pvid, ID_LEN, mda_index);
 			}
 		}


