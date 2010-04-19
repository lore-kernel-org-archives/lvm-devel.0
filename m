From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 19 Apr 2010 18:38:20 -0400
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM libdm/libdm-de ...
In-Reply-To: <20100407200443.26841.qmail@sourceware.org>
References: <20100407200443.26841.qmail@sourceware.org>
Message-ID: <20100419223820.GA11273@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Apr 07 2010 at  4:04pm -0400,
agk at sourceware.org <agk@sourceware.org> wrote:

> CVSROOT:	/cvs/lvm2
> Module name:	LVM2
> Changes by:	agk at sourceware.org	2010-04-07 20:04:42
> 
> Modified files:
> 	.              : WHATS_NEW WHATS_NEW_DM 
> 	libdm          : libdm-deptree.c 
> 	lib/activate   : dev_manager.c 
> 
> Log message:
> 	Fix incorrect removal of symlinks after LV deactivation fails.

<snip>

> --- LVM2/WHATS_NEW_DM	2010/04/07 15:57:20	1.353
> +++ LVM2/WHATS_NEW_DM	2010/04/07 20:04:42	1.354
> @@ -1,6 +1,7 @@
>  Version 1.02.46 - 
>  ================================
> -  Wipe memory buffers for dm-ioctl parameters before releaseing.
> +  Change dm_tree_deactivate_children to fail if device is open.
> +  Wipe memory buffers for dm-ioctl parameters before releasing.
>    Strictly require libudev if udev_sync is used.
>    Add support for ioctl's DM_UEVENT_GENERATED_FLAG.
>  
> --- LVM2/libdm/libdm-deptree.c	2010/03/25 18:22:04	1.72
> +++ LVM2/libdm/libdm-deptree.c	2010/04/07 20:04:42	1.73
> @@ -1047,9 +1047,14 @@
>  
>  		/* Refresh open_count */
>  		if (!_info_by_dev(dinfo->major, dinfo->minor, 1, &info) ||
> -		    !info.exists || info.open_count)
> +		    !info.exists)
>  			continue;
>  
> +		if (info.open_count) {
> +			r = 0;
> +			continue;
> +		}
> +
>  		if (!_deactivate_node(name, info.major, info.minor,
>  				      &child->dtree->cookie, child->udev_flags)) {
>  			log_error("Unable to deactivate %s (%" PRIu32

This change causes test/t-snapshot-merge.sh's 2nd snapshot-merge test
(onactivate merge negative testing) to fail.  Later lvm2 changes refined
the failure to occur IFF the device is a toplevel device.  In the case
of snapshot-merge it is failing with the following error (using the
latest lvm2):

+ lvremove -f LVMTEST5289vg/LV1
  Unable to deactivate open LVMTEST3125vg-LV1-real (253:6)
  Failed to resume LV1.

It would appear that the non-zero open_count associated with the -real
device is stale (during lvremove's dm_tree_deactivate_children).  If I
unmount the snapshot before doing the --refresh the lvremove works fine.

Somewhat more detailed log from failing test:
lvs -a
+ lvs -a
  LV       VG            Attr   LSize  Origin Snap%  Move Log Copy%  Convert
  LV1      LVMTEST5289vg owi-a- 48.00m                                      
  LV1_snap LVMTEST5289vg swi-a-  8.00m LV1     73.05                        
mkdir test_mnt
+ mkdir test_mnt
mount $(lvdev_ $vg $lv1) test_mnt
lvdev_ $vg $lv1)
lvdev_ $vg $lv1
++ lvdev_ LVMTEST5289vg LV1
++ echo /root/git/lvm2/test/LVMTEST5289.7xFSvbHNO8/dev/LVMTEST5289vg/LV1
+ mount /root/git/lvm2/test/LVMTEST5289.7xFSvbHNO8/dev/LVMTEST5289vg/LV1 test_mnt
lvconvert --merge $vg/$(snap_lv_name_ $lv1)
snap_lv_name_ $lv1)
snap_lv_name_ $lv1
++ snap_lv_name_ LV1
++ echo LV1_snap
+ lvconvert --merge LVMTEST5289vg/LV1_snap
  Can't merge over open origin volume
  WARNING: This metadata update is NOT backed up
  Merging of snapshot LV1_snap will start next activation.
lvchange --refresh $vg/$lv1
+ lvchange --refresh LVMTEST5289vg/LV1
umount test_mnt
+ umount test_mnt
rm -r test_mnt
+ rm -r test_mnt
# an active merge uses the "snapshot-merge" target
dmsetup table ${vg}-${lv1} | grep -q " snapshot-origin "
+ dmsetup table LVMTEST5289vg-LV1
+ grep -q ' snapshot-origin '
test $? = 0
+ test 0 = 0
lvremove -f $vg/$lv1
+ lvremove -f LVMTEST5289vg/LV1
  Unable to deactivate open LVMTEST5289vg-LV1-real (253:6)
  Failed to resume LV1.

I'll look closer at this "stale open_count" theory I raised above.

But in the near-term I have a "fix" for test/t-snapshot-merge.sh (works
with both LVM_TEST_LOCKING=1 and LVM_TEST_LOCKING=3).  I just start
merging the snapshot and then lvremove the merging origin and its
snapshot:

diff --git a/test/t-snapshot-merge.sh b/test/t-snapshot-merge.sh
index b7c0cb0..ff78f14 100755
--- a/test/t-snapshot-merge.sh
+++ b/test/t-snapshot-merge.sh
@@ -55,19 +55,24 @@ lvconvert --merge $vg/$(snap_lv_name_ $lv1)
 lvremove -f $vg/$lv1
 
 
-# "onactivate merge" test -- refresh LV while FS is still mounted;
-# verify snapshot-origin target is still being used
+# "onactivate merge" test
 setup_merge $vg $lv1
 lvs -a
 mkdir test_mnt
 mount $(lvdev_ $vg $lv1) test_mnt
 lvconvert --merge $vg/$(snap_lv_name_ $lv1)
+# -- refresh LV while FS is still mounted (merge must not start),
+#    verify 'snapshot-origin' target is still being used
 lvchange --refresh $vg/$lv1
 umount test_mnt
 rm -r test_mnt
-# an active merge uses the "snapshot-merge" target
 dmsetup table ${vg}-${lv1} | grep -q " snapshot-origin "
-test $? = 0
+# -- refresh LV to start merge (now that FS is unmounted),
+#    an active merge uses the 'snapshot-merge' target
+lvchange --refresh $vg/$lv1
+dmsetup table ${vg}-${lv1} | grep -q " snapshot-merge "
+# -- don't care if merge is still active; lvremove at this point
+#    may test stopping an active merge
 lvremove -f $vg/$lv1
 
 



