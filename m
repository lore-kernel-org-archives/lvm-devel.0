From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Jan 2008 19:03:32 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c
Message-ID: <20080103190332.28839.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-03 19:03:32

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c 

Log message:
	Fix vgreduce PV list processing not to process every PV in the VG.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.749&r2=1.750
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.122&r2=1.123

--- LVM2/WHATS_NEW	2007/12/22 12:13:29	1.749
+++ LVM2/WHATS_NEW	2008/01/03 19:03:31	1.750
@@ -1,5 +1,6 @@
 Version 2.02.30 -
 ===================================
+  Fix vgreduce PV list processing not to process every PV in the VG. (2.02.29)
   Extend lvconvert to use polldaemon.
   Add support for stacked mirrors.
   Major restructuring of pvmove and lvconvert layer manipulation code.
--- LVM2/tools/toollib.c	2007/12/22 02:13:00	1.122
+++ LVM2/tools/toollib.c	2008/01/03 19:03:32	1.123
@@ -746,14 +746,7 @@
 			if (sigint_caught())
 				return ret_max;
 		}
-		if (vg) {
-			ret = process_each_pv_in_vg(cmd, vg, &tags,
-						    handle, process_single);
-			if (ret > ret_max)
-				ret_max = ret;
-			if (sigint_caught())
-				return ret_max;
-		} else if (!list_empty(&tags) && (vgnames = get_vgs(cmd, 0)) &&
+		if (!list_empty(&tags) && (vgnames = get_vgs(cmd, 0)) &&
 			   !list_empty(vgnames)) {
 			list_iterate_items(sll, vgnames) {
 				if (!lock_vol(cmd, sll->str, lock_type)) {


