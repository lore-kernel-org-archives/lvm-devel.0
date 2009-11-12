From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 11 Nov 2009 21:35:34 -0600
Subject: [PATCH] LVM: Mirror down-convert bug fix.
Message-ID: <1257996934.4390.10.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Noticed this while working on multi-leg split mirror support.

 brassow

Down-convert is not properly handling image removal when specific
PVs are specified.

Old bad behavior:
[root at bp-01 LVM2]# !lvs
lvs -a -o name,copy_percent,devices
  LV            Copy%  Devices
  LogVol00             /dev/sda2(0)
  LogVol01             /dev/sda2(4451)
  lv             36.00 lv_mimage_0(0),lv_mimage_1(0),lv_mimage_2(0),lv_mimage_3(0)
  [lv_mimage_0]        /dev/sdb1(0)
  [lv_mimage_1]        /dev/sdc1(0)
  [lv_mimage_2]        /dev/sdd1(0)
  [lv_mimage_3]        /dev/sde1(0)
  [lv_mlog]            /dev/sdi1(0)
[root at bp-01 LVM2]# !lvco
lvconvert -m0 vg/lv /dev/sd[ceb]1
  Logical volume lv converted.
[root at bp-01 LVM2]# !lvs
lvs -a -o name,copy_percent,devices
  LV       Copy%  Devices
  LogVol00        /dev/sda2(0)
  LogVol01        /dev/sda2(4451)
  lv              /dev/sdc1(0)

Note how sdc1 is the remaining device, even though we specifically said
to remove that one....

New good behaviour:
[root at bp-01 LVM2]# !lvs
lvs -a -o name,copy_percent,devices
  LV            Copy%  Devices
  LogVol00             /dev/sda2(0)
  LogVol01             /dev/sda2(4451)
  lv            100.00 lv_mimage_0(0),lv_mimage_1(0),lv_mimage_2(0),lv_mimage_3(0)
  [lv_mimage_0]        /dev/sdb1(0)
  [lv_mimage_1]        /dev/sdc1(0)
  [lv_mimage_2]        /dev/sdd1(0)
  [lv_mimage_3]        /dev/sde1(0)
  [lv_mlog]            /dev/sdi1(0)
[root at bp-01 LVM2]# lvconvert -m0 vg/lv /dev/sd[ceb]1
  Logical volume lv converted.
[root at bp-01 LVM2]# !lvs
lvs -a -o name,copy_percent,devices
  LV       Copy%  Devices
  LogVol00        /dev/sda2(0)
  LogVol01        /dev/sda2(4451)
  lv              /dev/sdd1(0)

I would have like to use _move_removable_mimages_to_end, but that is an all or
nothing behaviour.  The way down-convert has been working allows for specifying
some, but not all, devices to be removed.  I'm not sure if this is the intended
behaviour.  If it is, then this patch does the job.  If it isn't, then we
should probably be sharing '_move_removable_mimages_to_end' with 'split_mirror_images'.

Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>



Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -753,15 +753,19 @@ static int _remove_mirror_images(struct 
 
 	/* Move removable_pvs to end of array */
 	if (removable_pvs) {
-		for (s = 0; s < mirrored_seg->area_count &&
-			    old_area_count - new_area_count < num_removed; s++) {
-			sub_lv = seg_lv(mirrored_seg, s);
-
-			if (!is_temporary_mirror_layer(sub_lv) &&
-			    _is_mirror_image_removable(sub_lv, removable_pvs)) {
-				if (!shift_mirror_images(mirrored_seg, s))
-					return_0;
-				new_area_count--;
+		for (m = mirrored_seg->area_count;
+		     m && ((old_area_count - new_area_count) < num_removed); m--) {
+			for (s = 0; s < m; s++) {
+				sub_lv = seg_lv(mirrored_seg, s);
+
+				if (!is_temporary_mirror_layer(sub_lv) &&
+				    _is_mirror_image_removable(sub_lv,
+							       removable_pvs)) {
+					if (!shift_mirror_images(mirrored_seg, s))
+						return_0;
+					new_area_count--;
+					break;
+				}
 			}
 		}
 		if (num_removed && old_area_count == new_area_count)



