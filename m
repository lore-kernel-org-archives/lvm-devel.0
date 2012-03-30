From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 30 Mar 2012 08:58:03 -0000
Subject: LVM2 ./WHATS_NEW tools/lvconvert.c
Message-ID: <20120330085803.6643.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-03-30 08:58:02

Modified files:
	.              : WHATS_NEW 
	tools          : lvconvert.c 

Log message:
	Detect VG name being part of the LV name in lvconvert --splitmirrors -n.
	
	Before:
	devel/~ # lvconvert --splitmirrors 1 -n vg/splitted_one vg/mirrored_one
	Internal error: LV name vg/splitted_one has invalid form.
	Intermediate VG metadata write failed.
	
	After:
	devel/~ # lvconvert --splitmirrors 1 -n vg/splitted_one vg/mirrored_one
	Logical volume mirrored_one converted.
	
	devel/~ # lvconvert --splitmirrors 1 -n abc/splitted_one vg/mirrored_one
	Please use a single volume group name ("vg" or "abc")
	Run `lvconvert --help' for more information.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2372&r2=1.2373
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.188&r2=1.189

--- LVM2/WHATS_NEW	2012/03/27 15:53:45	1.2372
+++ LVM2/WHATS_NEW	2012/03/30 08:58:02	1.2373
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Detect VG name being part of the LV name in lvconvert --splitmirrors -n.
   Fix exclusive lvchange running from other node. (2.02.89)
   Add 'vgscan --cache' functionality for consistency with 'pvscan --cache'.
   Keep exclusive activation in pvmove if LV is already active.
--- LVM2/tools/lvconvert.c	2012/03/01 21:14:43	1.188
+++ LVM2/tools/lvconvert.c	2012/03/30 08:58:02	1.189
@@ -173,9 +173,19 @@
 		}
 
 		lp->lv_split_name = arg_value(cmd, name_ARG);
-		if (lp->lv_split_name &&
-		    !apply_lvname_restrictions(lp->lv_split_name))
-			return_0;
+		if (lp->lv_split_name) {
+			if (strchr(lp->lv_split_name, '/')) {
+				if (!(lp->vg_name = extract_vgname(cmd, lp->lv_split_name)))
+					return_0;
+
+				/* Strip VG from lv_split_name */
+				if ((tmp_str = strrchr(lp->lv_split_name, '/')))
+					lp->lv_split_name = tmp_str + 1;
+			}
+
+			if (!apply_lvname_restrictions(lp->lv_split_name))
+				return_0;
+		}
 
 		lp->keep_mimages = 1;
 		lp->mirrors = arg_uint_value(cmd, splitmirrors_ARG, 0);


