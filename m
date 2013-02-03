From: Jonathan Brassow <jbrassow@redhat.com>
Date: Sun, 03 Feb 2013 02:32:39 -0600
Subject: [PATCH 3 of 3] Allow lvconvert repair to work on RAID images with error segments
In-Reply-To: <1359880051.15387.8.camel@f16>
References: <1359880051.15387.8.camel@f16>
Message-ID: <1359880359.15387.14.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

RAID: Allow replacement of RAID images that contain error segments

This patch adds the ability to replace RAID images that contain error
segments.  The user will still be unable to run 'lvconvert --replace'
because there is no way to address the 'error' segment (i.e. no PV
that it is associated with).  However, 'lvconvert --repair' can be
used to replace the image's error segment with a new PV.  This is also
the most appropriate way to do it, since the LV will continue to be
reported as 'partial'.

Index: lvm2/lib/metadata/raid_manip.c
===================================================================
--- lvm2.orig/lib/metadata/raid_manip.c
+++ lvm2/lib/metadata/raid_manip.c
@@ -1631,8 +1631,8 @@ int lv_raid_reshape(struct logical_volum
 /*
  * lv_raid_replace
  * @lv
- * @replace_pvs
- * @allocatable_pvs
+ * @remove_pvs
+ * @allocate_pvs
  *
  * Replace the specified PVs.
  */
@@ -1675,7 +1675,10 @@ int lv_raid_replace(struct logical_volum
 			return 0;
 		}
 
-		if (_lv_is_on_pvs(seg_lv(raid_seg, s), remove_pvs) ||
+		// FIXME: safe to use 'virtual' as a substitute for 'error'?
+		if (lv_is_virtual(seg_lv(raid_seg, s)) ||
+		    lv_is_virtual(seg_metalv(raid_seg, s)) ||
+		    _lv_is_on_pvs(seg_lv(raid_seg, s), remove_pvs) ||
 		    _lv_is_on_pvs(seg_metalv(raid_seg, s), remove_pvs))
 			match_count++;
 	}
@@ -1705,7 +1708,9 @@ int lv_raid_replace(struct logical_volum
 			if (!(i % copies))
 				rebuilds_per_group = 0;
 			if (_lv_is_on_pvs(seg_lv(raid_seg, s), remove_pvs) ||
-			    _lv_is_on_pvs(seg_metalv(raid_seg, s), remove_pvs))
+			    _lv_is_on_pvs(seg_metalv(raid_seg, s), remove_pvs) ||
+			    lv_is_virtual(seg_lv(raid_seg, s)) ||
+			    lv_is_virtual(seg_metalv(raid_seg, s)))
 				rebuilds_per_group++;
 			if (rebuilds_per_group >= copies) {
 				log_error("Unable to replace all the devices "



