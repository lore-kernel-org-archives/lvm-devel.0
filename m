From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 06 Feb 2008 17:05:11 -0500
Subject: [PATCH lvconvert 2/2] Update dm table of off-tree layer LV on lvconvert
In-Reply-To: <47AA2CBF.1060109@ce.jp.nec.com>
References: <47AA2CBF.1060109@ce.jp.nec.com>
Message-ID: <47AA2F17.5090808@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If a LV in the middle of the stacked LV is removed,
the suspend/resume of the stacked LV doesn't update the removed
LV's dm table in kernel.
It is not a problem in the current LVM2 features except for
lvconvert finishing adding mirror image(s) to mirror LV.
Attached patch works around the lvconvert problem.


For details, see below.

> When updating a structure of active LV,
> LVM2 preloads new dm table for each device from bottom to top,
> then suspend top-down and resume bottom-up.

When a layer LV is being removed from the tree,
there is a problem that the removed layer LV is resumed
with the same table before the suspend.

remove_layer_from_lv() will set error segment for the layer LV.
However, since the layer LV is no longer a part of the LV stack,
either preloading or resuming doesn't load the new table with
the error segment.

The upper device will load and resume new table, that is
usually very similar to that for the layer LV.
The layer LV will be removed later. However, until then,
there are 2 active tables working on the same resource
(e.g. mirror log, snapshot metadata).

In the current LVM2 code, the problem can only occur when
lvconvert finishes mirror addition to existing mirror.
_remove_mirror_images() activates the layer LV which is
removed from the mirror LV, before resuming the mirror LV.


Below, I'm trying to explain what's happening using the 'dmsetup ls --tree'
output during "lvconvert adds 1 mirror to 2-way mirrored LV".

lvconvert will change the device tree as follows:

1. Before lvconvert
    vg-lvol0 (253:4)
     |-vg-lvol0_mimage_1 (253:3)
     |-vg-lvol0_mimage_0 (253:2)
     `-vg-lvol0_mlog (253:1)

2. During lvconvert
    vg-lvol0 (253:4)
     |-vg-lvol0_mimage_2 (253:6)
     `-vg-lvol0_mimagetmp_2 (253:5)
        |-vg-lvol0_mimage_1 (253:3)
        |-vg-lvol0_mimage_0 (253:2)
        `-vg-lvol0_mlog (253:1)

3. After lvconvert
    vg-lvol0 (253:4)
     |-vg-lvol0_mimage_2 (253:6)
     |-vg-lvol0_mimage_1 (253:3)
     |-vg-lvol0_mimage_0 (253:2)
     `-vg-lvol0_mlog (253:1)


While moving from the stage 2 to the stage 3,
lvconvert will move the segments of the layer 'vg-lvol0_mimagetmp_2'
to 'vg-lvol0' and put an error segment instead.
Thus, vg-lvol0_mimagetmp_2 is free to be removed.

    vg-lvol0_mimagetmp_2 (253:5)

    vg-lvol0 (253:4)
     |-vg-lvol0_mimage_2 (253:6)
     |-vg-lvol0_mimage_1 (253:3)
     |-vg-lvol0_mimage_0 (253:2)
     `-vg-lvol0_mlog (253:1)

However, since the load/suspend/resume operation is done
only on vg-lvol0 and vg-lvol0_mimagetmp_2 is already out of
the tree, the table of vg-lvol0_mimagetmp_2 is unchanged
from the stage 2:

    vg-lvol0_mimagetmp_2 (253:5)
     |-vg-lvol0_mimage_1 (253:3)
     |-vg-lvol0_mimage_0 (253:2)
     `-vg-lvol0_mlog (253:1)

    vg-lvol0 (253:4)
     |-vg-lvol0_mimage_2 (253:6)
     |-vg-lvol0_mimage_1 (253:3)
     |-vg-lvol0_mimage_0 (253:2)
     `-vg-lvol0_mlog (253:1)

So we have 2 active mirrors with same mirror log for a short while
until lvconvert removes vg-lvol0_mimagetmp_2.
The attached patch updates the table of vg-lvol0_mimagetmp_2
before updating that of vg-lvol0 to avoid this situation.

Without the patch, you can see vg-lvol0_mimagetmp_2
is resumed without loading a new table.
(excerpt from lvconvert-bad.log)

#libdm-deptree.c:940     Suspending vg-lvol0 (253:4)
#libdm-deptree.c:940     Suspending vg-lvol0_mimage_2 (253:6)
#libdm-deptree.c:940     Suspending vg-lvol0_mimagetmp_2 (253:5)
#libdm-deptree.c:940     Suspending vg-lvol0_mimage_1 (253:3)
#libdm-deptree.c:940     Suspending vg-lvol0_mimage_0 (253:2)
#libdm-deptree.c:940     Suspending vg-lvol0_mlog (253:1)
#libdm-deptree.c:1470     Loading vg-lvol0_mimage_2 table
#libdm-deptree.c:1421         Adding target: 0 4096 linear 8:49 384
#libdm-deptree.c:897     Resuming vg-lvol0_mimage_2 (253:6)
#libdm-deptree.c:1470     Loading vg-lvol0_mimage_1 table
#libdm-deptree.c:1421         Adding target: 0 4096 linear 8:33 384
#libdm-deptree.c:897     Resuming vg-lvol0_mimage_1 (253:3)
#libdm-deptree.c:1470     Loading vg-lvol0_mimage_0 table
#libdm-deptree.c:1421         Adding target: 0 4096 linear 8:65 384
#libdm-deptree.c:897     Resuming vg-lvol0_mimage_0 (253:2)
#libdm-deptree.c:1470     Loading vg-lvol0_mlog table
#libdm-deptree.c:1421         Adding target: 0 4096 linear 8:34 384
#libdm-deptree.c:897     Resuming vg-lvol0_mlog (253:1)
#libdm-deptree.c:897     Resuming vg-lvol0_mimagetmp_2 (253:5)
#libdm-deptree.c:897     Resuming vg-lvol0 (253:4)

OTOH, with the patch, it shows that the error target is loaded
for vg-lvol0_mimagetmp_2.
(excerpt from lvconvert-good.log)

#libdm-deptree.c:940     Suspending vg-lvol0 (253:4)
#libdm-deptree.c:940     Suspending vg-lvol0_mimage_2 (253:6)
#libdm-deptree.c:940     Suspending vg-lvol0_mimagetmp_2 (253:5)
#libdm-deptree.c:940     Suspending vg-lvol0_mimage_1 (253:3)
#libdm-deptree.c:940     Suspending vg-lvol0_mimage_0 (253:2)
#libdm-deptree.c:940     Suspending vg-lvol0_mlog (253:1)
#libdm-deptree.c:897     Resuming vg-lvol0_mimage_1 (253:3)
#libdm-deptree.c:897     Resuming vg-lvol0_mimage_0 (253:2)
#libdm-deptree.c:897     Resuming vg-lvol0_mlog (253:1)
#libdm-deptree.c:1470     Loading vg-lvol0_mimagetmp_2 table
#libdm-deptree.c:1421         Adding target: 0 4096 error 
#libdm-deptree.c:897     Resuming vg-lvol0_mimagetmp_2 (253:5)
#libdm-deptree.c:1470     Loading vg-lvol0_mimage_2 table
#libdm-deptree.c:1421         Adding target: 0 4096 linear 8:49 384
#libdm-deptree.c:897     Resuming vg-lvol0_mimage_2 (253:6)
#libdm-deptree.c:1470     Loading vg-lvol0_mlog table
#libdm-deptree.c:1421         Adding target: 0 4096 linear 8:34 384
#libdm-deptree.c:1470     Loading vg-lvol0_mimage_0 table
#libdm-deptree.c:1421         Adding target: 0 4096 linear 8:65 384
#libdm-deptree.c:1470     Loading vg-lvol0_mimage_1 table
#libdm-deptree.c:1421         Adding target: 0 4096 linear 8:33 384
#libdm-deptree.c:897     Resuming vg-lvol0 (253:4)

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America

-------------- next part --------------
A non-text attachment was scrubbed...
Name: fix-explicit-activation-of-offtree-lv.patch
Type: text/x-patch
Size: 1517 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080206/146d25c1/attachment.bin>
