From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Apr 2008 14:57:13 -0000
Subject: LVM2/tools vgsplit.c
Message-ID: <20080415145713.24967.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-15 14:57:12

Modified files:
	tools          : vgsplit.c 

Log message:
	missing stack

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66

--- LVM2/tools/vgsplit.c	2008/04/10 21:34:53	1.65
+++ LVM2/tools/vgsplit.c	2008/04/15 14:57:12	1.66
@@ -175,7 +175,7 @@
 
 		/* Move this LV */
 		if (!_move_one_lv(vg_from, vg_to, lvh))
-			return 0;
+			return_0;
 	}
 
 	/* FIXME Ensure no LVs contain segs pointing at LVs in the other VG */
@@ -221,7 +221,7 @@
 			if (_lv_is_in_vg(vg_to, seg->cow) &&
 			    _lv_is_in_vg(vg_to, seg->origin)) {
 				if (!_move_one_lv(vg_from, vg_to, lvh))
-					return 0;
+					return_0;
 			}
 		}
 
@@ -263,7 +263,7 @@
 
 		if (seg_in == seg->area_count && log_in) {
 			if (!_move_one_lv(vg_from, vg_to, lvh))
-				return 0;
+				return_0;
 		}
 	}
 


