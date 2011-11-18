From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Nov 2011 19:25:21 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c test/ ...
Message-ID: <20111118192521.17021.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-18 19:25:21

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 
	test           : t-lvcreate-usage.sh 

Log message:
	Query before removing inactive snapshots
	
	Removal of an inactive origin removes also all related snapshots.
	
	When we now support 'old' external snapshots with thin volumes,
	removal of pool will not only drop all thin volumes, but as
	a consequence also all snapshots - which might be seen a bit
	unexpected for the user - so add a query to confirm such action.
	
	lvremove -f will skip the prompt.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2188&r2=1.2189
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.337&r2=1.338
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/WHATS_NEW	2011/11/18 19:22:49	1.2188
+++ LVM2/WHATS_NEW	2011/11/18 19:25:20	1.2189
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add query before removing snapshots when inactive snapshot origin is removed.
   Allow changing availability state of snapshots.
   Skip non-virtual snapshots for availability change for lvchange with vg name.
   Adjusted mirror region size only for mirrors and raids.
--- LVM2/lib/metadata/lv_manip.c	2011/11/15 17:32:12	1.337
+++ LVM2/lib/metadata/lv_manip.c	2011/11/18 19:25:20	1.338
@@ -3248,7 +3248,17 @@
 	}
 
 	if (lv_is_origin(lv)) {
-		/* remove snapshot LVs first */
+		/* Remove snapshot LVs first */
+		if ((force == PROMPT) &&
+		    /* Active snapshot already needs to confirm each active LV */
+		    !lv_is_active(lv) &&
+		    yes_no_prompt("Removing origin %s will also remove %u "
+				  "snapshots(s). Proceed? [y/n]: ",
+				  lv->name, lv->origin_count) == 'n') {
+			log_error("Logical volume %s not removed.", lv->name);
+			return 0;
+		}
+
 		dm_list_iterate_safe(snh, snht, &lv->snapshot_segs)
 			if (!lv_remove_with_dependencies(cmd, dm_list_struct_base(snh, struct lv_segment,
 										  origin_list)->cow,
--- LVM2/test/t-lvcreate-usage.sh	2011/06/28 09:43:28	1.20
+++ LVM2/test/t-lvcreate-usage.sh	2011/11/18 19:25:21	1.21
@@ -122,7 +122,7 @@
 lvrename $vg/$lv1 $vg/$lv2
 lvcreate -s --virtualoriginsize 64m -L 32m -n $lv1 $vg
 lvchange -a n $vg/$lv1
-lvremove $vg/$lv1
+lvremove -ff $vg/$lv1
 lvremove -ff $vg
 
 # readahead default (auto), none, #, auto


