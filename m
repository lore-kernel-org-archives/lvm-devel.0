From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 23 Sep 2011 17:04:43 -0000
Subject: LVM2/doc lvm2-raid.txt
Message-ID: <20110923170443.16620.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-09-23 17:04:42

Modified files:
	doc            : lvm2-raid.txt 

Log message:
	Update the RAID design doc to reflect some of the new options introduce (e.g.
	--merge and --trackchanges) and document the coding steps of up/down-conversion,
	splitting RAID1 images, and merging RAID1 images.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/lvm2-raid.txt.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/doc/lvm2-raid.txt	2011/07/14 17:00:59	1.1
+++ LVM2/doc/lvm2-raid.txt	2011/09/23 17:04:41	1.2
@@ -38,9 +38,10 @@
 	"raid6_nc" - RAID6 Rotating parity N with data continuation
 The exception to 'no shorthand options' will be where the RAID implementations
 can displace traditional tagets.  This is the case with 'mirror' and 'raid1'.
-In these cases, a switch will exist in lvm.conf allowing the user to specify
-which implementation they want.  When this is in place, the segment type is
-inferred from the argument, '-m' for example.
+In this case, "mirror_segtype_default" - found under the "global" section in
+lvm.conf - can be set to "mirror" or "raid1".  The segment type inferred when
+the '-m' option is used will be taken from this setting.  The default segment
+types can be overridden on the command line by using the '--type' argument.
 
 Line 02:
 Region size is relevant for all RAID types.  It defines the granularity for
@@ -91,14 +92,15 @@
 02:	      [-R/--regionsize <size>] \
 03:	      [-i/--stripes <#>] [-I,--stripesize <size>] \
 04:	      [-m/--mirrors <#>] \
-05:	      [--splitmirrors <#>] \
-06:	      [--replace <sub_lv|device>] \
-07:	      [--[min|max]recoveryrate <kB/sec/disk>] \
-08:	      [--stripecache <size>] \
-09:	      [--writemostly <devices>] \
-10:	      [--maxwritebehind <size>] \
-11:	      vg/lv
-12:	      [devices]
+05:	      [--merge]
+06:	      [--splitmirrors <#> [--trackchanges]] \
+07:	      [--replace <sub_lv|device>] \
+08:	      [--[min|max]recoveryrate <kB/sec/disk>] \
+09:	      [--stripecache <size>] \
+10:	      [--writemostly <devices>] \
+11:	      [--maxwritebehind <size>] \
+12:	      vg/lv
+13:	      [devices]
 
 lvconvert should work exactly as it does now when dealing with mirrors -
 even if(when) we switch to MD RAID1.  Of course, there are no plans to
@@ -115,28 +117,46 @@
 a RAID device of a different type.  For example, you could change from
 RAID4 to RAID5 or RAID5 to RAID6.
 
-Line 02/03/04/05:
+Line 02/03/04:
 These are familiar options - all of which would now be available as options
 for change.  (However, it'd be nice if we didn't have regionsize in there.
 It's simple on the kernel side, but is just an extra - often unecessary -
 parameter to many functions in the LVM codebase.)
 
+Line 05:
+This option is used to merge an LV back into a RAID1 array - provided it was
+split for temporary read-only use by '--splitmirrors 1 --trackchanges'.
+
 Line 06:
+The '--splitmirrors <#>' argument should be familiar from the "mirror" segment
+type.  It allows RAID1 images to be split from the array to form a new LV.
+Either the original LV or the split LV - or both - could become a linear LV as
+a result.  If the '--trackchanges' argument is specified in addition to
+'--splitmirrors', an LV will be split from the array.  It will be read-only.
+This operation does not change the original array - except that it uses an empty
+slot to hold the position of the split LV which it expects to return in the
+future (see the '--merge' argument).  It tracks any changes that occur to the
+array while the slot is kept in reserve.  If the LV is merged back into the
+array, only the changes are resync'ed to the returning image.  Repeating the
+'lvconvert' operation without the '--trackchanges' option will complete the
+split of the LV permanently.
+
+Line 07:
 This option allows the user to specify a sub_lv (e.g. a mirror image) or
 a particular device for replacement.  The device (or all the devices in
 the sub_lv) will be removed and replaced with different devices from the
 VG.
 
-Line 07/08/09/10:
+Line 08/09/10/11:
 It should be possible to alter these parameters of a RAID device.  As with
 lvcreate, however, I'm not entirely certain how to best define some of these.
 We don't need all the capabilities at once though, so it isn't a pressing
 issue.
 
-Line 11:
+Line 12:
 The LV to operate on.
 
-Line 12:
+Line 13:
 Devices that are to be used to satisfy the conversion request.  If the
 operation removes devices or splits a mirror, then the devices specified
 form the list of candidates for removal.  If the operation adds or replaces
@@ -173,7 +193,7 @@
 |   [foo_rmeta_1's lv_segment]
 
 LVM Meta-data format
---------------------
+====================
 The RAID format will need to be able to store parameters that are unique to
 RAID and unique to specific RAID sub-devices.  It will be modeled after that
 of mirroring.
@@ -238,8 +258,13 @@
 array as a whole.  In these cases, the status field of the sub-lv's themselves
 will hold these flags - the meaning being only useful in the larger context.
 
+
+##############################################
+# Chapter 3: LVM RAID implementation details #
+##############################################
+
 New Segment Type(s)
--------------------
+===================
 I've created a new file 'lib/raid/raid.c' that will handle the various different
 RAID types.  While there will be a unique segment type for each RAID variant,
 they will all share a common backend - segtype_handler functions and
@@ -262,7 +287,7 @@
 should not affect the way size is calculated via the area_multiple.
 
 Allocation
-----------
+==========
 When a RAID device is created, metadata LVs must be created along with the
 data LVs that will ultimately compose the top-level RAID array.  For the
 foreseeable future, the metadata LVs must reside on the same device as (or
@@ -287,8 +312,8 @@
 1) how many parity devices are required and 2) does an allocated area need to
 be split out for the metadata LVs after finding the space to fill the request.
 We simply add these two fields to the 'alloc_handle' data structure as,
-'parity_count' and 'alloc_and_split_meta'.  These two fields get set simply
-in '_alloc_init'.   The 'segtype->parity_devs' holds the number of parity
+'parity_count' and 'alloc_and_split_meta'.  These two fields get set in
+'_alloc_init'.   The 'segtype->parity_devs' holds the number of parity
 drives and can be directly copied to 'ah->parity_count' and
 'alloc_and_split_meta' is set when a RAID segtype is detected and
 'metadata_area_count' has been specified.  With these two variables set, we
@@ -296,3 +321,86 @@
 find the actual space, they stop not when they have found ah->area_count but
 when they have found (ah->area_count + ah->parity_count).
 
+Conversion
+==========
+RAID -> RAID, adding images
+---------------------------
+When adding images to a RAID array, metadata and data components must be added
+as a pair.  It is best to perform as many operations as possible before writing
+new LVM metadata.  This allows us to error-out without having to unwind any
+changes.  It also makes things easier if the machine should crash during a
+conversion operation.  Thus, the actions performed when adding a new image are:
+        1) Allocate the required number of metadata/data pairs using the method
+	   describe above in 'Allocation' (i.e. find the metadata/data space
+	   as one unit and split the space between them after found - this keeps
+	   them together on the same device).
+	2) Form the metadata/data LVs from the allocated space (leave them
+	   visible) - setting required RAID_[IMAGE | META] flags as appropriate.
+	3) Write the LVM metadata
+	4) Activate and clear the metadata LVs.  The clearing of the metadata
+	   requires the LVM metadata be written (step 3) and is a requirement
+	   before adding the new metadata LVs to the array.  If the metadata
+	   is not cleared, it carry residual superblock state from a previous
+	   array the device may have been part of.
+	5) Deactivate new sub-LVs and set them "hidden".
+	6) expand the 'first_seg(raid_lv)->areas' and '->meta_areas' array
+	   for inclusion of the new sub-LVs
+	7) Add new sub-LVs and update 'first_seg(raid_lv)->area_count'
+	8) Commit new LVM metadata
+Failure during any of these steps will not affect the original RAID array.  In
+the worst scenario, the user may have to remove the new sub-LVs that did not
+yet make it into the array.
+
+RAID -> RAID, removing images
+-----------------------------
+To remove images from a RAID, the metadata/data LV pairs must be removed
+together.  This is pretty straight-forward, but one place where RAID really
+differs from the "mirror" segment type is how the resulting "holes" are filled.
+When a device is removed from a "mirror" segment type, it is identified, moved
+to the end of the 'mirrored_seg->areas' array, and then removed.  This action
+causes the other images to shift down and fill the position of the device which
+was removed.  While "raid1" could be handled in this way, the other RAID types
+could not be - it would corrupt the ordering of the data on the array.  Thus,
+when a device is removed from a RAID array, the corresponding metadata/data
+sub-LVs are removed from the 'raid_seg->meta_areas' and 'raid_seg->areas' arrays.
+The slot in these 'lv_segment_area' arrays are set to 'AREA_UNASSIGNED'.  RAID
+is perfectly happy to construct a DM table mapping with '- -' if it comes across
+area assigned in such a way.  The pair of dashes is a valid way to tell the RAID
+kernel target that the slot should be considered empty.  So, we can remove
+devices from a RAID array without affecting the correct operation of the RAID.
+(It also becomes easy to replace the empty slots properly if a spare device is
+available.)  In the case of RAID1 device removal, the empty slot can be safely
+eliminated.  This is done by shifting the higher indexed devices down to fill
+the slot.  Even the names of the images will be renamed to properly reflect
+their index in the array.  Unlike the "mirror" segment type, you will never have
+an image named "*_rimage_1" occupying the index position 0.
+
+As with adding images, removing images holds off on commiting LVM metadata
+until all possible changes have been made.  This reduces the likelyhood of bad
+intermediate stages being left due to a failure of operation or machine crash.
+
+RAID1 '--splitmirrors', '--trackchanges', and '--merge' operations
+-----------------------------------------------------------------
+This suite of operations is only available to the "raid1" segment type.
+
+Splitting an image from a RAID1 array is almost identical to the removal of
+an image described above.  However, the metadata LV associated with the split
+image is removed and the data LV is kept and promoted to a top-level device.
+(i.e.  It is made visible and stripped of its RAID_IMAGE status flags.)
+
+When the '--trackchanges' option is given along with the '--splitmirrors'
+argument, the metadata LV is left as part of the original array.  The data LV
+is set as 'VISIBLE' and read-only (~LVM_WRITE).  When the array DM table is
+being created, it notices the read-only, VISIBLE nature of the sub-LV and puts
+in the '- -' sentinel.  Only a single image can be split from the mirror and
+the name of the sub-LV cannot be changed.  Unlike '--splitmirrors' on its own,
+the '--name' argument must not be specified.  Therefore, the name of the newly
+split LV will remain the same '<lv>_rimage_<N>', where 'N' is the index of the
+slot in the array for which it is associated.
+
+When an LV which was split from a RAID1 array with the '--trackchanges' option
+is merged back into the array, its read/write status is restored and it is
+set as "hidden" again.  Recycling the array (suspend/resume) restores the sub-LV
+to its position in the array and begins the process of sync'ing the changes that
+were made since the time it was split from the array.
+


