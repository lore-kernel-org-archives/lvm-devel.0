From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 04 Sep 2008 09:40:39 -0500
Subject: [PATCH] Fix mirror corruption during primary device failure.
Message-ID: <1220539239.3670.3.camel@hydrogen>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 brassow

When down converting mirrors (e.g. going from a 3-leg to 2-leg mirror),
removable legs are pushed to the end of the array via swapping with the
last element.

Example:
- Mirror consists of devices A, B, C; and we wish to remove A
- A is first swapped with C, leaving C, B, A
- The leg count is reduced and A is removed, leaving C, B

The above works fine in most cases.  However, if there is a failure
of the primary device (the first device), the kernel selects the next
leg as the primary and continues.  While there is a failed device,
the kernel will only write to the primary.

Revisiting the above example:
- Mirror consists of devices A, B, C
- A fails, leaving a, B, C
- kernel selects B as the new primary.
- Performing the above conversion will cause a 2-way mirror to
  be put in place with THE WRONG PRIMARY, C.

The scenario causes all writes performed between the time of failure
and the conversion to be lost - causing corruption of file systems
and loss of data.

This patch preserves the ordering of devices when moving 'removable
pvs' to the end of the array.  So, rather than having:
	1) A, B, C (starting mirror)
	2) C, B, A (reordering legs)
	3) C, B	   (converted mirror)
we have:
        1) A, B, C (starting mirror)
        2) B, C, A (reordering legs)
        3) B, C    (converted mirror)

Index: LVM2-rhel5/lib/metadata/mirror.c
===================================================================
--- LVM2-rhel5.orig/lib/metadata/mirror.c
+++ LVM2-rhel5/lib/metadata/mirror.c
@@ -136,6 +136,53 @@ uint32_t adjusted_mirror_region_size(uin
 }
 
 /*
+ * shift_mirror_legs
+ * @mirrored_seg
+ * @leg_pos:  The position (index) of the leg to move to the end
+ *
+ * When dealing with removal of legs, we often move a 'removable leg'
+ * to the back of the 'areas' array.  It is critically important not
+ * to simply swap it for the last area in the array.  This would have
+ * the affect of reordering the remaining legs - altering position of
+ * the primary.  So, we must shuffle all of the areas in the array
+ * to maintain their relative position before moving the 'removable
+ * leg' to the end.
+ *
+ * Short illustration of the problem:
+ *   - Mirror consists of legs A, B, C and we want to remove A
+ *   - We swap A and C and then remove A, leaving C, B
+ * This scenario is problematic in failure cases where A dies, because
+ * B becomes the primary.  If the above happens, we effectively throw
+ * away any changes made between the time of failure and the time of
+ * restructuring the mirror.
+ *
+ * So, any time we want to move areas to the end to be removed, use
+ * this function.
+ *
+ * Returns: 0 on success, 1 on failure
+ */
+static int shift_mirror_legs(struct lv_segment *mirrored_seg, int leg_pos)
+{
+	int i;
+	struct lv_segment_area area;
+
+
+	if (leg_pos >= mirrored_seg->area_count)
+		return 1; /* -EINVAL */
+
+	area = mirrored_seg->areas[leg_pos];
+
+	/* Shift everyone down to fill the hole */
+	for (i = leg_pos+1; i < mirrored_seg->area_count; i++)
+		mirrored_seg->areas[i-1] = mirrored_seg->areas[i];
+
+	/* Stick this one at the end */
+	mirrored_seg->areas[i-1] = area;
+
+	return 0;
+}
+
+/*
  * This function writes a new header to the mirror log header to the lv
  *
  * Returns: 1 on success, 0 on failure
@@ -469,13 +516,12 @@ static int _remove_mirror_images(struct 
 		for (s = 0; s < mirrored_seg->area_count &&
 			    old_area_count - new_area_count < num_removed; s++) {
 			sub_lv = seg_lv(mirrored_seg, s);
+
 			if (!is_temporary_mirror_layer(sub_lv) &&
 			    _is_mirror_image_removable(sub_lv, removable_pvs)) {
-				/* Swap segment to end */
+				if (shift_mirror_legs(mirrored_seg, s))
+					return 0;
 				new_area_count--;
-				area = mirrored_seg->areas[new_area_count];
-				mirrored_seg->areas[new_area_count] = mirrored_seg->areas[s];
-				mirrored_seg->areas[s] = area;
 			}
 		}
 		if (num_removed && old_area_count == new_area_count)



