From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Apr 2008 20:56:06 -0000
Subject: LVM2 ./WHATS_NEW test/t-vgsplit-operation.sh t ...
Message-ID: <20080409205606.25252.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-09 20:56:06

Modified files:
	.              : WHATS_NEW 
	test           : t-vgsplit-operation.sh 
	tools          : vgsplit.c 

Log message:
	Fix vgsplit to only move hidden 'snapshotN' LVs when necessary.
	
	This bug has been around for a long time as far as I can tell.
	Without this fix, a vgsplit would unconditionally move the
	'hidden/internal' snapshot LVs, and result in corrupted metadata
	in the following case:
	vg1: contains lv1, lv1snap, both on pvset1
	vg1: contains lv2, on pvset2
	
	"vgsplit vg1 vg2 pvset2"
	would result in "snapshot0" hidden LV being moved to vg2, and
	the origin and cow being left in vg1.  The tools detect the
	corruption in vg2, but not in vg1.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.840&r2=1.841
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/WHATS_NEW	2008/04/09 14:47:34	1.840
+++ LVM2/WHATS_NEW	2008/04/09 20:56:05	1.841
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Fix vgsplit to only move hidden 'snapshotN' LVs when necessary.
   Update vgsplit tests for lvnames on the cmdline.
   Update vgsplit man page to reflect lvnames on the cmdline.
   Update vgsplit to take "-n LogicalVolumeName" on the cmdline.
--- LVM2/test/t-vgsplit-operation.sh	2008/04/09 14:47:34	1.15
+++ LVM2/test/t-vgsplit-operation.sh	2008/04/09 20:56:06	1.16
@@ -149,6 +149,35 @@
    lvremove -f $vg2/$lv1 &&
    vgremove -f $vg2'
 
+test_expect_success \
+  "vgsplit correctly splits linear LV but not snap+origin LV into $i VG ($j args)" \
+  'vgcreate $vg1 $d1 $d2 &&
+   if [ $i == existing ]; then
+     vgcreate $vg2 $d3
+   fi &&
+   lvcreate -l 64 -i 2 -n $lv1 $vg1 &&
+   lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1 &&
+   vgextend $vg1 $d4 &&
+   lvcreate -l 64 -n $lv3 $vg1 $d4 &&
+   vgchange -an $vg1 &&
+   if [ $j == PV ]; then
+     vgsplit $vg1 $vg2 $d4
+   else
+     vgsplit -n $lv3 $vg1 $vg2
+   fi &&
+   if [ $i == existing ]; then
+     vg_validate_pvlv_counts_ $vg2 2 1 0
+     vg_validate_pvlv_counts_ $vg1 2 1 1
+   else
+     vg_validate_pvlv_counts_ $vg2 1 1 0
+     vg_validate_pvlv_counts_ $vg1 2 1 1
+   fi &&
+   lvremove -f $vg1/$lv2 &&
+   lvremove -f $vg1/$lv1 &&
+   lvremove -f $vg2/$lv3 &&
+   vgremove -f $vg1 &&
+   vgremove -f $vg2'
+
 done
 done
 
--- LVM2/tools/vgsplit.c	2008/04/09 13:47:13	1.57
+++ LVM2/tools/vgsplit.c	2008/04/09 20:56:06	1.58
@@ -164,6 +164,9 @@
 	return 1;
 }
 
+/*
+ * Move the hidden / internal "snapshotN" LVs.from 'vg_from' to 'vg_to'.
+ */
 static int _move_snapshots(struct volume_group *vg_from,
 			   struct volume_group *vg_to)
 {
@@ -191,14 +194,21 @@
 					  " two Volume Groups", seg->cow->name);
 				return 0;
 			}
-		}
 
-		/* Move this snapshot */
-		list_del(lvh);
-		list_add(&vg_to->lvs, lvh);
+			/*
+			 * At this point, the cow and origin should already be
+			 * in vg_to.
+			 */
+			if (_lv_is_in_vg(vg_to, seg->cow) &&
+			    _lv_is_in_vg(vg_to, seg->origin)) {
+				list_del(lvh);
+				list_add(&vg_to->lvs, lvh);
+				
+				vg_from->snapshot_count--;
+				vg_to->snapshot_count++;
+			}
+		}
 
-		vg_from->snapshot_count--;
-		vg_to->snapshot_count++;
 	}
 
 	return 1;


